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

/// Extracts all embedded Tokens assets into the target tokens directory (e.g. `lib/tokens`).
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

            let dest_path = target_tokens_dir.join(path_str);
            if let Some(parent) = dest_path.parent() {
                std::fs::create_dir_all(parent)?;
            }
            std::fs::write(&dest_path, file_content)?;
        }
    }

    Ok(())
}

/// Extracts all embedded Core assets into the target core directory (e.g. `lib/core`),
/// excluding `src/components/` (which are individual UI components served via registry).
pub fn extract_core(target_core_dir: &Path, package_name: &str) -> Result<()> {
    logger::info(&format!(
        "Extracting core theming engine to {}...",
        target_core_dir.display()
    ));

    for file_path in CoreAssets::iter() {
        let path_str = file_path.as_ref();

        // Skip component source files inside core
        if path_str.starts_with("src/components/") {
            continue;
        }

        if let Some(content) = CoreAssets::get(path_str) {
            let mut file_content = match String::from_utf8(content.data.to_vec()) {
                Ok(s) => s,
                Err(_) => continue,
            };

            file_content = rewrite_core_internal_imports(&file_content, package_name);

            let dest_path = target_core_dir.join(path_str);
            if let Some(parent) = dest_path.parent() {
                std::fs::create_dir_all(parent)?;
            }
            std::fs::write(&dest_path, file_content)?;
        }
    }

    Ok(())
}

fn rewrite_tokens_internal_imports(content: &str, _package_name: &str) -> String {
    content.to_string()
}

fn rewrite_core_internal_imports(content: &str, package_name: &str) -> String {
    let tokens_import = format!("package:{}/tokens/just_ui_tokens.dart", package_name);
    content
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
            &format!("package:{}/tokens/", package_name),
        )
        .replace(
            "package:just_ui_core/",
            &format!("package:{}/core/", package_name),
        )
}
