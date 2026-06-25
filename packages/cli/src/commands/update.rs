use anyhow::Result;
use std::collections::HashSet;

use crate::commands::add::{add_component, sha256_hex};
use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::{import_rewriter, logger, prompt};

/// Runs the `justui update` command.
pub fn run() -> Result<()> {
    // 1. Verify initialization config exists
    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if !config_path.exists() {
        logger::error(
            "Project not initialized. Please run \"justui init\" in the root directory first.",
        );
        return Ok(());
    }

    // 2. Parse configuration
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

    logger::info("Checking for updates...");

    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!("Failed to perform update: {}", e));
            return Ok(());
        }
    };

    // Scan local components directory for subdirectories
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

    let shared_components = index.compute_shared_components();
    let mut outdated_components: Vec<String> = Vec::new();

    for local_name in &local_component_names {
        let component = match index.components.iter().find(|c| c.name == *local_name) {
            Some(c) => c,
            None => continue,
        };

        let target_dir = if component.category == "tokens" || component.category == "core" {
            config.tokens_dir.clone()
        } else if shared_components.contains(&component.name) {
            config.shared_dir.clone()
        } else {
            format!("{}/{}", config.components_dir, component.name)
        };

        let mut needs_update = false;

        for file in &component.files {
            let local_file_name = if shared_components.contains(&component.name) {
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
                // Fall back to direct hash check
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
        logger::success("All components are up-to-date!");
        return Ok(());
    }

    logger::stdout("Outdated components found:");
    let refs: Vec<&str> = outdated_components.iter().map(|s| s.as_str()).collect();
    let selected_indices = prompt::select_multiple("Select components to update", &refs);

    if selected_indices.is_empty() {
        logger::warning("No updates performed.");
        return Ok(());
    }

    let mut visited: HashSet<String> = HashSet::new();
    for idx in selected_indices {
        let comp_name = &outdated_components[idx];
        if let Err(e) = add_component(
            comp_name,
            &index,
            &client,
            &config.components_dir,
            &config.tokens_dir,
            &config.shared_dir,
            &shared_components,
            &mut visited,
        ) {
            logger::error(&format!("Failed to update \"{}\": {}", comp_name, e));
        }
    }

    Ok(())
}
