use anyhow::Result;
use std::collections::HashSet;

use crate::commands::add::{add_component, sha256_hex};
use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::{import_rewriter, logger, prompt};

pub fn run(auto_yes: bool) -> Result<()> {
    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if !config_path.exists() {
        logger::error(
            "Project not initialized. Please run \"justui init\" in the root directory first.",
        );
        return Ok(());
    }

    let config = match std::fs::read_to_string(config_path) {
        Ok(content) => JustUIConfig::from_yaml(&content),
        Err(e) => {
            logger::error(&format!(
                "Failed to parse {}: {}",
                JustUIConfig::CONFIG_FILE_NAME,
                e
            ));
            return Ok(());
        }
    };

    let pb_index = indicatif::ProgressBar::new_spinner();
    pb_index.set_message("Checking for updates...");
    pb_index.enable_steady_tick(std::time::Duration::from_millis(100));

    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => {
            pb_index.finish_and_clear();
            idx
        }
        Err(e) => {
            pb_index.finish_and_clear();
            logger::error(&format!("Failed to perform update: {}", e));
            return Ok(());
        }
    };

    let components_dir = std::path::Path::new(&config.components_dir);
    if !components_dir.exists() {
        logger::warning(&format!(
            "Components directory \"{}\" does not exist. No components installed yet.",
            config.components_dir
        ));
        return Ok(());
    }

    let mut local_component_names: Vec<String> = Vec::new();
    let entries = match std::fs::read_dir(components_dir) {
        Ok(e) => e,
        Err(e) => {
            logger::error(&format!("Failed to perform update: {}", e));
            return Ok(());
        }
    };
    for entry in entries.flatten() {
        if entry.path().is_dir() {
            if let Some(name) = entry.file_name().to_str() {
                local_component_names.push(name.to_string());
            }
        }
    }

    if local_component_names.is_empty() {
        logger::warning("No installed components found.");
        return Ok(());
    }

    let mut outdated_components: Vec<String> = Vec::new();

    for local_name in &local_component_names {
        let component = match index.components.iter().find(|c| c.name == *local_name) {
            Some(c) => c,
            None => continue,
        };

        let target_dir = if component.category == "tokens" || component.category == "core" {
            config.tokens_dir.clone()
        } else if component.name == "_shared_theme_provider" {
            "lib/theme".to_string()
        } else if component.internal {
            config.shared_dir.clone()
        } else {
            format!("{}/{}", config.components_dir, component.name)
        };

        let mut needs_update = false;

        for file in component.files_for_preset(&config.preset) {
            let local_file_name = if component.name == "_shared_theme_provider" {
                file.name.clone()
            } else if component.internal {
                import_rewriter::normalize_shared_file_name(&file.name)
            } else {
                file.name.clone()
            };
            let target_path = format!("{}/{}", target_dir, local_file_name);
            let local_file = std::path::Path::new(&target_path);

            if !local_file.exists() {
                needs_update = true;
                break;
            }

            let raw = std::fs::read_to_string(local_file).unwrap_or_default();
            let local_content = raw.replace("\r\n", "\n");
            let expected_hash = file.checksum.replace("sha256:", "").trim().to_string();

            if let Some(meta) = import_rewriter::parse_metadata(&local_content) {
                if meta.registry_hash != expected_hash {
                    needs_update = true;
                    break;
                }
            } else {
                let local_hash = sha256_hex(local_content.as_bytes());
                if local_hash != expected_hash {
                    needs_update = true;
                    break;
                }
            }
        }

        if needs_update {
            outdated_components.push(component.name.clone());
        }
    }

    if outdated_components.is_empty() {
        logger::stdout("Semua komponen sudah menggunakan versi terbaru");
        logger::success("All components are up-to-date!");
        return Ok(());
    }

    logger::stdout("Outdated components found:");

    let selected_indices: Vec<usize> = if auto_yes {
        let names_str = outdated_components.join(", ");
        logger::stdout(&format!(
            "[auto] Updating all outdated components: {}",
            names_str
        ));
        (0..outdated_components.len()).collect()
    } else {
        let refs: Vec<&str> = outdated_components.iter().map(|s| s.as_str()).collect();
        let indices = prompt::select_multiple("Select components to update", &refs);
        if indices.is_empty() {
            logger::warning("No updates performed.");
            return Ok(());
        }
        indices
    };

    let mut visited: HashSet<String> = HashSet::new();
    for idx in selected_indices {
        let comp_name = &outdated_components[idx];
        logger::info(&format!("Diperbarui component \"{}\"", comp_name));
        if let Err(e) = add_component(
            comp_name,
            &index,
            &client,
            &config.components_dir,
            &config.tokens_dir,
            &config.shared_dir,
            &mut visited,
            false,
            false,
            auto_yes,
            &None,
            &config.preset,
            config.dart_target,
        ) {
            logger::error(&format!("Failed to update \"{}\": {}", comp_name, e));
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_update_run_uninitialized() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        assert!(run(true).is_ok());
    }

    #[test]
    fn test_update_invalid_yaml_config() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        std::fs::write(
            temp_dir.path().join("justui.config.yaml"),
            "invalid: [yaml: :",
        )
        .unwrap();
        assert!(run(true).is_ok());
    }

    #[test]
    fn test_update_missing_components_dir_and_empty_components() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(&reg_dir).unwrap();
        std::fs::write(
            reg_dir.join("index.json"),
            r#"{"version":"1.0.0","presets":["default"],"components":[]}"#,
        )
        .unwrap();

        let comp_dir = temp_dir.path().join("lib/components");

        let config_yaml = format!(
            "registry_url: {}\ncomponents_dir: {}\n",
            reg_dir.to_string_lossy(),
            comp_dir.to_string_lossy()
        );
        std::fs::write(temp_dir.path().join("justui.config.yaml"), config_yaml).unwrap();

        // 1. Missing components_dir
        assert!(run(true).is_ok());

        // 2. Empty components_dir (no subdirectories)
        std::fs::create_dir_all(&comp_dir).unwrap();
        assert!(run(true).is_ok());
    }

    #[test]
    fn test_update_outdated_component_auto_yes() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(&reg_dir).unwrap();
        let file_content = "// new button content";
        std::fs::write(reg_dir.join("just_button.dart"), file_content).unwrap();
        let new_hash = sha256_hex(file_content.as_bytes());

        std::fs::write(
            reg_dir.join("index.json"),
            format!(
                r#"{{
                    "version": "1.0.0",
                    "presets": ["default"],
                    "components": [
                        {{
                            "name": "button",
                            "version": "1.1.0",
                            "description": "Button",
                            "category": "primitive",
                            "internal": false,
                            "supported_presets": ["default"],
                            "registry_dependencies": [],
                            "pub_dependencies": {{}},
                            "files": {{
                                "default": [
                                    {{
                                        "name": "just_button.dart",
                                        "path": "just_button.dart",
                                        "checksum": "sha256:{}"
                                    }}
                                ]
                            }}
                        }}
                    ]
                }}"#,
                new_hash
            ),
        )
        .unwrap();

        let comp_dir = temp_dir.path().join("lib/components");
        let installed_button_dir = comp_dir.join("button");
        std::fs::create_dir_all(&installed_button_dir).unwrap();

        let local_file = installed_button_dir.join("just_button.dart");
        std::fs::write(&local_file, "// old button content").unwrap();

        let config_yaml = format!(
            "registry_url: {}\ncomponents_dir: {}\ntokens_dir: {}\nshared_dir: {}\n",
            reg_dir.to_string_lossy(),
            comp_dir.to_string_lossy(),
            temp_dir.path().join("lib/tokens").to_string_lossy(),
            temp_dir.path().join("lib/shared").to_string_lossy(),
        );
        std::fs::write(temp_dir.path().join("justui.config.yaml"), config_yaml).unwrap();

        // 1. Run update with auto_yes = true (outdated detected and updated)
        assert!(run(true).is_ok());

        // 2. Run update again (now up-to-date)
        assert!(run(true).is_ok());
    }
}
