use anyhow::Result;
use sha2::{Digest, Sha256};
use std::collections::HashSet;

use crate::config::JustUIConfig;
use crate::registry::{RegistryClient, RegistryIndex};
use crate::utils::{diff_formatter, import_rewriter, logger, prompt, pubspec_editor};

/// Runs the `justui add [component...]` command.
pub fn run(components: Vec<String>) -> Result<()> {
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

    logger::info(&format!(
        "Fetching registry index from: {}",
        config.registry_url
    ));

    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!("Failed to add components: {}", e));
            return Ok(());
        }
    };

    let components_to_add: Vec<String> = if components.is_empty() {
        // Interactive selection
        let component_names: Vec<String> = index
            .components
            .iter()
            .map(|c| format!("{} ({})", c.name, c.description))
            .collect();

        if component_names.is_empty() {
            logger::error("No components found in the registry.");
            return Ok(());
        }

        logger::stdout("Select components to add:");
        let refs: Vec<&str> = component_names.iter().map(|s| s.as_str()).collect();
        let selected_indices = prompt::select_multiple("Choose components", &refs);

        if selected_indices.is_empty() {
            logger::warning("No components selected.");
            return Ok(());
        }

        selected_indices
            .into_iter()
            .map(|idx| index.components[idx].name.clone())
            .collect()
    } else {
        components
    };

    let mut visited: HashSet<String> = HashSet::new();
    let shared_components = index.compute_shared_components();
    let mut last_error: Option<anyhow::Error> = None;

    for comp_name in &components_to_add {
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
            last_error = Some(e);
            break;
        }
    }

    if let Some(e) = last_error {
        logger::error(&format!("Failed to add components: {}", e));
    }

    Ok(())
}

/// Adds a single component (and its dependencies recursively) to the project.
/// Shared between `add` and `update` commands.
pub fn add_component(
    name: &str,
    index: &RegistryIndex,
    client: &RegistryClient,
    components_dir: &str,
    tokens_dir: &str,
    shared_dir: &str,
    shared_components: &HashSet<String>,
    visited: &mut HashSet<String>,
) -> Result<()> {
    // Circular dependency check and double-copy guard
    if visited.contains(name) {
        return Ok(());
    }
    visited.insert(name.to_string());

    let component = index
        .components
        .iter()
        .find(|c| c.name == name)
        .ok_or_else(|| anyhow::anyhow!("Component \"{}\" not found in registry", name))?;

    // 1. Recursively resolve registry dependencies first
    let deps: Vec<String> = component.registry_dependencies.clone();
    for dep in &deps {
        add_component(
            dep,
            index,
            client,
            components_dir,
            tokens_dir,
            shared_dir,
            shared_components,
            visited,
        )?;
    }

    logger::info(&format!(
        "Adding component \"{}\" (v{})...",
        component.name, component.version
    ));

    // 2. Map target directory based on category and shared status
    let target_dir = if component.category == "tokens" || component.category == "core" {
        tokens_dir.to_string()
    } else if shared_components.contains(&component.name) {
        shared_dir.to_string()
    } else {
        format!("{}/{}", components_dir, component.name)
    };

    // 3. Download, validate, rewrite, and write each file
    let files: Vec<_> = component.files.clone();
    let comp_name = component.name.clone();
    let pub_deps: Vec<(String, String)> = component
        .pub_dependencies
        .iter()
        .map(|(k, v)| (k.clone(), v.clone()))
        .collect();

    for file in &files {
        let content = client
            .fetch_file_content(&file.path)
            .map_err(|e| anyhow::anyhow!("Failed to fetch \"{}\": {}", file.name, e))?;

        // Verify SHA-256 checksum integrity
        let downloaded_hash = sha256_hex(content.as_bytes());
        let expected_hash = file.checksum.replace("sha256:", "").trim().to_string();

        if downloaded_hash != expected_hash {
            return Err(anyhow::anyhow!(
                "Security check failed: Checksum mismatch for downloaded file \"{}\".\n  \
                 Expected: {}\n  Got:      {}\n\
                 The download might be corrupted or tampered with.",
                file.name,
                expected_hash,
                downloaded_hash
            ));
        }

        // Apply import rewriting
        let rewritten_content = import_rewriter::rewrite(
            &content,
            &file.path,
            &comp_name,
            index,
            components_dir,
            tokens_dir,
            shared_dir,
            shared_components,
        );

        let local_rewritten_hash = sha256_hex(rewritten_content.as_bytes());
        let final_content = import_rewriter::inject_metadata(
            &rewritten_content,
            &expected_hash,
            &local_rewritten_hash,
        );

        let local_file_name = if shared_components.contains(&comp_name) {
            import_rewriter::normalize_shared_file_name(&file.name)
        } else {
            file.name.clone()
        };
        let target_path = std::path::Path::new(&target_dir).join(&local_file_name);

        let should_write = if target_path.exists() {
            resolve_conflict(
                &target_path,
                &local_file_name,
                &expected_hash,
                &rewritten_content,
                &final_content,
            )?
        } else {
            true
        };

        if should_write {
            if let Some(parent) = target_path.parent() {
                std::fs::create_dir_all(parent)?;
            }
            std::fs::write(&target_path, &final_content)?;
            logger::stdout(&format!(
                "  - Copied {} to {}/",
                local_file_name, target_dir
            ));
        }
    }

    // 4. Inject pub dependencies into pubspec.yaml
    if !pub_deps.is_empty() {
        let pubspec_path = std::path::Path::new("pubspec.yaml");
        for (dep, version) in &pub_deps {
            match pubspec_editor::add_dependency(pubspec_path, dep, version) {
                Ok(_) => {
                    logger::success(&format!(
                        "Added dependency \"{}: {}\" to pubspec.yaml.",
                        dep, version
                    ));
                }
                Err(e) => {
                    logger::warning(&format!("Could not add dependency \"{}\": {}", dep, e));
                }
            }
        }
    }

    logger::success(&format!("Component \"{}\" added successfully.", comp_name));
    Ok(())
}

/// Resolves a conflict when a local file already exists.
/// Returns true if the file should be overwritten.
fn resolve_conflict(
    target_path: &std::path::Path,
    local_file_name: &str,
    expected_hash: &str,
    rewritten_content: &str,
    _final_content: &str,
) -> Result<bool> {
    let raw = std::fs::read_to_string(target_path)?;
    let local_content = raw.replace("\r\n", "\n");

    if let Some(meta) = import_rewriter::parse_metadata(&local_content) {
        let local_clean = import_rewriter::strip_metadata(&local_content);
        let current_local_hash = sha256_hex(local_clean.as_bytes());

        if current_local_hash == meta.local_hash {
            // Unmodified locally
            if meta.registry_hash == expected_hash {
                logger::stdout(&format!("  - {} is already up-to-date.", local_file_name));
                return Ok(false);
            } else {
                logger::info(&format!(
                    "  - Updating {} to latest registry version.",
                    local_file_name
                ));
                return Ok(true);
            }
        } else {
            // Locally modified
            if meta.registry_hash == expected_hash {
                logger::stdout(&format!(
                    "  - {} has been customized locally. Skipping.",
                    local_file_name
                ));
                return Ok(false);
            } else {
                // True conflict: prompt
                logger::warning(&format!(
                    "Conflict: Local file \"{}\" has been modified, and a registry update is available.",
                    local_file_name
                ));
                return conflict_prompt(local_file_name, &local_clean, rewritten_content);
            }
        }
    } else {
        // No metadata header: compare raw hash against expected
        let local_hash = sha256_hex(local_content.as_bytes());
        if local_hash == expected_hash {
            logger::stdout(&format!(
                "  - {} is already up-to-date (no metadata).",
                local_file_name
            ));
            return Ok(false);
        } else {
            logger::warning(&format!(
                "Conflict: Local file \"{}\" exists and differs (no metadata).",
                local_file_name
            ));
            return conflict_prompt(local_file_name, &local_content, rewritten_content);
        }
    }
}

/// Interactive conflict resolution prompt loop.
/// Returns true if the file should be overwritten.
fn conflict_prompt(
    local_file_name: &str,
    local_content: &str,
    rewritten_content: &str,
) -> Result<bool> {
    loop {
        let action = prompt::ask(
            "  Choose action: [o] Overwrite, [s] Skip, [d] Show Diff",
            "s",
        )
        .to_lowercase();

        match action.as_str() {
            "o" => return Ok(true),
            "s" => return Ok(false),
            "d" => {
                diff_formatter::print_unified_diff(
                    local_file_name,
                    local_content,
                    rewritten_content,
                    3,
                );
            }
            _ => {
                logger::error("Invalid option. Choose o, s, or d.");
            }
        }
    }
}

pub fn sha256_hex(data: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(data);
    hex::encode(hasher.finalize())
}
