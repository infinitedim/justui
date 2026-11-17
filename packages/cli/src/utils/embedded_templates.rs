use anyhow::Result;
use rust_embed::RustEmbed;
use std::path::Path;

use crate::utils::constructor_transpiler::apply_dart_target;
use crate::utils::env_resolver::{DartTarget, apply_material_target, resolve_material_target};
use crate::utils::logger;

#[derive(RustEmbed)]
#[folder = "../tokens/lib/"]
pub struct TokensAssets;

#[derive(RustEmbed)]
#[folder = "../core/lib/"]
pub struct CoreAssets;

/// Extracts embedded design token files into `target_tokens_dir`.
///
/// # Errors
/// Returns an error if writing any extracted token file fails.
pub fn extract_tokens(
    target_tokens_dir: &Path,
    package_name: &str,
    dart_target: DartTarget,
) -> Result<()> {
    logger::info(&format!(
        "Extracting design tokens to {}...",
        target_tokens_dir.display()
    ));

    for file_path in TokensAssets::iter() {
        let path_str = file_path.as_ref();

        if let Some(content) = TokensAssets::get(path_str) {
            let Ok(mut file_content) = String::from_utf8(content.data.to_vec()) else {
                continue;
            };

            file_content = rewrite_tokens_internal_imports(&file_content, package_name);
            file_content = apply_dart_target(&file_content, dart_target);

            let rel_path_str = path_str
                .strip_prefix("src/")
                .or_else(|| path_str.strip_prefix("src\\"))
                .unwrap_or(path_str);

            let dest_path = target_tokens_dir.join(rel_path_str);
            crate::utils::path_guard::atomic_write(&dest_path, file_content)?;
            crate::utils::dart_formatter::format_and_refresh_metadata(&dest_path);
        }
    }

    Ok(())
}

/// Extracts embedded core theming files into `target_core_dir`, adapting
/// constructors and Material imports for the target project.
///
/// # Errors
/// Returns an error if writing any extracted core file fails.
pub fn extract_core(
    target_core_dir: &Path,
    package_name: &str,
    tokens_dir: &str,
    dart_target: DartTarget,
) -> Result<()> {
    logger::info(&format!(
        "Extracting core theming engine to {}...",
        target_core_dir.display()
    ));

    let project_root = target_core_dir
        .parent()
        .and_then(Path::parent)
        .filter(|root| !root.as_os_str().is_empty() && root.join("pubspec.yaml").exists())
        .unwrap_or_else(|| Path::new("."));
    let material_target = resolve_material_target(project_root);

    for file_path in CoreAssets::iter() {
        let path_str = file_path.as_ref();

        if path_str.starts_with("src/components/") || path_str.starts_with("src\\components\\") {
            continue;
        }

        if let Some(content) = CoreAssets::get(path_str) {
            let Ok(mut file_content) = String::from_utf8(content.data.to_vec()) else {
                continue;
            };

            file_content = rewrite_core_internal_imports(&file_content, package_name, tokens_dir);

            if path_str.ends_with("theme_data_material.dart") {
                file_content = sanitize_theme_data_material(&file_content);
            }
            file_content = apply_material_target(&file_content, material_target);
            file_content = apply_dart_target(&file_content, dart_target);

            let rel_path_str = path_str
                .strip_prefix("src/")
                .or_else(|| path_str.strip_prefix("src\\"))
                .unwrap_or(path_str);

            let dest_path = target_core_dir.join(rel_path_str);
            crate::utils::path_guard::atomic_write(&dest_path, &file_content)?;
            crate::utils::dart_formatter::format_and_refresh_metadata(&dest_path);
        }
    }

    Ok(())
}

fn rewrite_tokens_internal_imports(content: &str, _package_name: &str) -> String {
    content
        .replace("export 'src/", "export '")
        .replace("import 'src/", "import '")
}

fn rewrite_core_internal_imports(content: &str, package_name: &str, tokens_dir: &str) -> String {
    let tokens_dir_rel = tokens_dir.strip_prefix("lib/").unwrap_or(tokens_dir);
    let tokens_import = format!("package:{package_name}/{tokens_dir_rel}/just_ui_tokens.dart");

    content
        .replace("export 'src/", "export '")
        .replace("import 'src/", "import '")
        .replace(
            "import 'package:just_ui_tokens/just_ui_tokens.dart';",
            &format!("import '{tokens_import}';"),
        )
        .replace(
            "export 'package:just_ui_tokens/just_ui_tokens.dart';",
            &format!("export '{tokens_import}';"),
        )
        .replace(
            "package:just_ui_tokens/src/",
            &format!("package:{package_name}/{tokens_dir_rel}/"),
        )
        .replace(
            "package:just_ui_tokens/",
            &format!("package:{package_name}/{tokens_dir_rel}/"),
        )
        .replace(
            "package:just_ui_core/src/",
            &format!("package:{package_name}/core/"),
        )
        .replace(
            "package:just_ui_core/",
            &format!("package:{package_name}/core/"),
        )
}

pub fn sanitize_theme_data_material(content: &str) -> String {
    let mut lines = Vec::new();
    let mut in_extensions = false;

    for line in content.lines() {
        let trimmed = line.trim();

        // Strip private component imports
        if trimmed.starts_with("import ")
            && (trimmed.contains("/components/") || trimmed.contains("_theme.dart"))
        {
            continue;
        }

        if trimmed == "extensions: const [" || trimmed == "extensions: [" {
            in_extensions = true;
            lines.push(line.to_string());
            lines.push("        // CLI:REGISTER_EXTENSIONS".to_string());
            continue;
        }

        if in_extensions {
            if trimmed.starts_with("],") || trimmed == "]" {
                in_extensions = false;
                lines.push(line.to_string());
            }
            continue;
        }

        lines.push(line.to_string());
    }

    lines.join("\n") + "\n"
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rewrite_imports_helpers() {
        let tok_res = rewrite_tokens_internal_imports("import 'src/colors/color.dart';", "my_app");
        assert_eq!(tok_res, "import 'colors/color.dart';");

        let core_res = rewrite_core_internal_imports(
            "import 'package:just_ui_tokens/just_ui_tokens.dart';\nimport 'src/theme/theme.dart';",
            "my_app",
            "lib/tokens",
        );
        assert!(core_res.contains("import 'package:my_app/tokens/just_ui_tokens.dart';"));
        assert!(core_res.contains("import 'theme/theme.dart';"));

        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = crate::utils::set_dir(temp_dir.path());
        let tok_dir = temp_dir.path().join("tokens");
        let core_dir = temp_dir.path().join("core");

        assert!(extract_tokens(&tok_dir, "my_app", DartTarget::Standard).is_ok());
        assert!(extract_core(&core_dir, "my_app", "lib/tokens", DartTarget::Standard).is_ok());

        let provider = std::fs::read_to_string(core_dir.join("theme/theme_provider.dart")).unwrap();
        assert!(provider.contains("const JustThemeProvider({"));
        assert!(!provider.contains("class const"));

        let primary_dir = temp_dir.path().join("core_primary");
        assert!(extract_core(&primary_dir, "my_app", "lib/tokens", DartTarget::Primary).is_ok());
        let provider =
            std::fs::read_to_string(primary_dir.join("theme/theme_provider.dart")).unwrap();
        assert!(provider.contains("class const JustThemeProvider({"));
    }

    #[test]
    fn test_sanitize_theme_data_material() {
        let dirty = r"import 'package:flutter/material.dart';
import '../components/button/just_button_theme.dart';
import 'theme_data.dart';

      extensions: const [
        // CLI:REGISTER_EXTENSIONS
        JustButtonTheme.defaults,
      ],
";
        let clean = sanitize_theme_data_material(dirty);
        assert!(!clean.contains("just_button_theme.dart"));
        assert!(!clean.contains("JustButtonTheme.defaults"));
        assert!(clean.contains("// CLI:REGISTER_EXTENSIONS"));
    }

    #[test]
    fn test_extract_core_adapts_material_import() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = crate::utils::set_dir(temp_dir.path());

        // 1. Without material_ui in pubspec -> theme_data_material.dart uses package:flutter/material.dart
        std::fs::write(
            "pubspec.yaml",
            "name: my_app\nenvironment:\n  flutter: '>=3.50.0'\ndependencies:\n  flutter:\n    sdk: flutter\n",
        )
        .unwrap();
        let core_fallback = temp_dir.path().join("core_fallback");
        extract_core(&core_fallback, "my_app", "lib/tokens", DartTarget::Primary).unwrap();
        let theme_fallback =
            std::fs::read_to_string(core_fallback.join("theme/theme_data_material.dart")).unwrap();
        assert!(theme_fallback.contains("import 'package:flutter/material.dart';"));
        assert!(!theme_fallback.contains("import 'package:material_ui/material_ui.dart';"));

        // 2. With Flutter 3.50 + material_ui in pubspec -> theme_data_material.dart uses package:material_ui/material_ui.dart
        std::fs::write(
            "pubspec.yaml",
            "name: my_app\nenvironment:\n  flutter: '>=3.50.0'\ndependencies:\n  flutter:\n    sdk: flutter\n  material_ui: ^1.11.0\n",
        )
        .unwrap();
        let core_material_ui = temp_dir.path().join("core_material_ui");
        extract_core(
            &core_material_ui,
            "my_app",
            "lib/tokens",
            DartTarget::Primary,
        )
        .unwrap();
        let theme_material_ui =
            std::fs::read_to_string(core_material_ui.join("theme/theme_data_material.dart"))
                .unwrap();
        assert!(theme_material_ui.contains("import 'package:material_ui/material_ui.dart';"));
        assert!(!theme_material_ui.contains("import 'package:flutter/material.dart';"));
    }
}
