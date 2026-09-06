use anyhow::Result;
use rust_embed::RustEmbed;
use std::path::Path;

use crate::utils::logger;

#[derive(RustEmbed)]
#[folder = "../tokens/lib/"]
pub struct TokensAssets;

#[derive(RustEmbed)]
#[folder = "../core/lib/"]
pub struct CoreAssets;

pub fn extract_tokens(target_tokens_dir: &Path, package_name: &str) -> Result<()> {
    logger::info(&format!(
        "Extracting design tokens to {}...",
        target_tokens_dir.display()
    ));

    for file_path in TokensAssets::iter() {
        let path_str = file_path.as_ref();

        if let Some(content) = TokensAssets::get(path_str) {
            let mut file_content = match String::from_utf8(content.data.to_vec()) {
                Ok(s) => s,
                Err(_) => continue,
            };

            file_content = rewrite_tokens_internal_imports(&file_content, package_name);

            let rel_path_str = path_str
                .strip_prefix("src/")
                .or_else(|| path_str.strip_prefix("src\\"))
                .unwrap_or(path_str);

            let dest_path = target_tokens_dir.join(rel_path_str);
            if let Some(parent) = dest_path.parent() {
                std::fs::create_dir_all(parent)?;
            }
            std::fs::write(&dest_path, file_content)?;
        }
    }

    Ok(())
}

pub fn extract_core(target_core_dir: &Path, package_name: &str, tokens_dir: &str) -> Result<()> {
    logger::info(&format!(
        "Extracting core theming engine to {}...",
        target_core_dir.display()
    ));

    for file_path in CoreAssets::iter() {
        let path_str = file_path.as_ref();

        if path_str.starts_with("src/components/") || path_str.starts_with("src\\components\\") {
            continue;
        }

        if let Some(content) = CoreAssets::get(path_str) {
            let mut file_content = match String::from_utf8(content.data.to_vec()) {
                Ok(s) => s,
                Err(_) => continue,
            };

            file_content = rewrite_core_internal_imports(&file_content, package_name, tokens_dir);

            if path_str.ends_with("theme_data_material.dart") {
                file_content = sanitize_theme_data_material(&file_content);
            }

            let rel_path_str = path_str
                .strip_prefix("src/")
                .or_else(|| path_str.strip_prefix("src\\"))
                .unwrap_or(path_str);

            let dest_path = target_core_dir.join(rel_path_str);
            if let Some(parent) = dest_path.parent() {
                std::fs::create_dir_all(parent)?;
            }
            std::fs::write(&dest_path, file_content)?;
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
    let tokens_import = format!(
        "package:{}/{}/just_ui_tokens.dart",
        package_name, tokens_dir_rel
    );

    content
        .replace("export 'src/", "export '")
        .replace("import 'src/", "import '")
        .replace(
            "import 'package:just_ui_tokens/just_ui_tokens.dart';",
            &format!("import '{}';", tokens_import),
        )
        .replace(
            "export 'package:just_ui_tokens/just_ui_tokens.dart';",
            &format!("export '{}';", tokens_import),
        )
        .replace(
            "package:just_ui_tokens/",
            &format!("package:{}/{}/", package_name, tokens_dir_rel),
        )
        .replace(
            "package:just_ui_core/",
            &format!("package:{}/core/", package_name),
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

        let temp_dir = tempfile::tempdir().unwrap();
        let tok_dir = temp_dir.path().join("tokens");
        let core_dir = temp_dir.path().join("core");

        assert!(extract_tokens(&tok_dir, "my_app").is_ok());
        assert!(extract_core(&core_dir, "my_app", "lib/tokens").is_ok());
    }

    #[test]
    fn test_sanitize_theme_data_material() {
        let dirty = r#"import 'package:flutter/material.dart';
import '../components/button/just_button_theme.dart';
import 'theme_data.dart';

      extensions: const [
        // CLI:REGISTER_EXTENSIONS
        JustButtonTheme.defaults,
      ],
"#;
        let clean = sanitize_theme_data_material(dirty);
        assert!(!clean.contains("just_button_theme.dart"));
        assert!(!clean.contains("JustButtonTheme.defaults"));
        assert!(clean.contains("// CLI:REGISTER_EXTENSIONS"));
    }
}
