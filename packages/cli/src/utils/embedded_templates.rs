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

            let filename = Path::new(path_str)
                .file_name()
                .unwrap_or(std::ffi::OsStr::new(path_str));

            let dest_path = target_tokens_dir.join(filename);
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

        if path_str.starts_with("src/components/") {
            continue;
        }

        if let Some(content) = CoreAssets::get(path_str) {
            let mut file_content = match String::from_utf8(content.data.to_vec()) {
                Ok(s) => s,
                Err(_) => continue,
            };

            file_content = rewrite_core_internal_imports(&file_content, package_name, tokens_dir);

            let filename = Path::new(path_str)
                .file_name()
                .unwrap_or(std::ffi::OsStr::new(path_str));

            let dest_path = target_core_dir.join(filename);
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
        .replace("export 'src/colors/", "export '")
        .replace("export 'src/", "export '")
        .replace("import 'src/colors/", "import '")
        .replace("import 'src/", "import '")
}

fn rewrite_core_internal_imports(content: &str, package_name: &str, tokens_dir: &str) -> String {
    let tokens_dir_rel = tokens_dir.strip_prefix("lib/").unwrap_or(tokens_dir);
    let tokens_import = format!(
        "package:{}/{}/just_ui_tokens.dart",
        package_name, tokens_dir_rel
    );

    content
        .replace("export 'src/theme/", "export '")
        .replace("export 'src/overlay/", "export '")
        .replace("export 'src/", "export '")
        .replace("import 'src/theme/", "import '")
        .replace("import 'src/overlay/", "import '")
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
