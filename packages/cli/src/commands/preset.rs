use anyhow::Result;
use clap::Subcommand;
use std::collections::HashSet;

use crate::commands::add::add_component;
use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::{logger, prompt};

#[derive(Subcommand, Debug, Clone)]
pub enum PresetSubcommands {
    /// List all available visual design style presets
    List,
    /// Apply a visual design style preset to installed components
    Apply {
        /// Name of the preset to apply (e.g. default, neobrutalism)
        name: String,
    },
    /// Show detailed token configuration for a specific preset
    Info {
        /// Name of the preset to inspect
        name: String,
    },
}

pub fn run(
    subcommand: Option<PresetSubcommands>,
    name: Option<String>,
    apply: bool,
    list: bool,
    info_preset: Option<String>,
    auto_yes: bool,
) -> Result<()> {
    if let Some(sub) = subcommand {
        return match sub {
            PresetSubcommands::List => run_list(),
            PresetSubcommands::Apply { name } => run_apply(&name, auto_yes),
            PresetSubcommands::Info { name } => run_info(&name),
        };
    }

    if list {
        return run_list();
    }

    if let Some(preset_name) = info_preset {
        return run_info(&preset_name);
    }

    if let Some(preset_name) = name {
        if preset_name == "list" {
            return run_list();
        }
        if apply {
            return run_apply(&preset_name, auto_yes);
        }

        return run_info(&preset_name);
    }

    run_list()
}

fn run_list() -> Result<()> {
    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if !config_path.exists() {
        logger::error("Project not initialized. Run \"justui init\" first.");
        return Ok(());
    }

    let config = match std::fs::read_to_string(config_path) {
        Ok(content) => JustUIConfig::from_yaml(&content),
        Err(e) => {
            logger::error(&format!("Failed to read config: {}", e));
            return Ok(());
        }
    };

    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!("Failed to fetch registry: {}", e));
            return Ok(());
        }
    };

    if index.presets.is_empty() {
        logger::warning("No presets found in registry.");
        return Ok(());
    }

    logger::panel("Available Presets");
    for preset in &index.presets {
        let is_active = preset == &config.preset;
        let active_marker = if is_active { " (active)" } else { "" };
        let supported_count = index
            .components
            .iter()
            .filter(|c| c.supported_presets.contains(preset))
            .count();
        logger::stdout(&format!(
            "  {}{}  —  {} component(s)",
            preset, active_marker, supported_count
        ));
    }

    Ok(())
}

fn run_info(preset_name: &str) -> Result<()> {
    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if !config_path.exists() {
        logger::error("Project not initialized. Run \"justui init\" first.");
        return Ok(());
    }

    let config = match std::fs::read_to_string(config_path) {
        Ok(content) => JustUIConfig::from_yaml(&content),
        Err(e) => {
            logger::error(&format!("Failed to read config: {}", e));
            return Ok(());
        }
    };

    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!("Failed to fetch registry: {}", e));
            return Ok(());
        }
    };

    if !index.presets.contains(&preset_name.to_string()) {
        logger::error(&format!(
            "Preset \"{}\" not found in registry. Run \"justui preset list\" to see available presets.",
            preset_name
        ));
        return Ok(());
    }

    let supported: Vec<&str> = index
        .components
        .iter()
        .filter(|c| c.supported_presets.contains(&preset_name.to_string()))
        .map(|c| c.name.as_str())
        .collect();

    let unsupported: Vec<&str> = index
        .components
        .iter()
        .filter(|c| !c.supported_presets.contains(&preset_name.to_string()))
        .map(|c| c.name.as_str())
        .collect();

    let is_active = preset_name == config.preset;
    logger::panel(&format!(
        "Preset: {}{}",
        preset_name,
        if is_active { " (active)" } else { "" }
    ));

    logger::stdout(&format!("\n  Supported components ({}):", supported.len()));
    for name in &supported {
        logger::stdout(&format!("    ✔  {}", name));
    }

    if !unsupported.is_empty() {
        logger::stdout(&format!("\n  Not yet supported ({}):", unsupported.len()));
        for name in &unsupported {
            logger::stdout(&format!("    ○  {}", name));
        }
    }

    Ok(())
}

fn run_apply(preset_name: &str, auto_yes: bool) -> Result<()> {
    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if !config_path.exists() {
        logger::error("Project not initialized. Run \"justui init\" first.");
        return Ok(());
    }

    let config = match std::fs::read_to_string(config_path) {
        Ok(content) => JustUIConfig::from_yaml(&content),
        Err(e) => {
            logger::error(&format!("Failed to read config: {}", e));
            return Ok(());
        }
    };

    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!("Failed to fetch registry: {}", e));
            return Ok(());
        }
    };

    if !index.presets.contains(&preset_name.to_string()) {
        logger::error(&format!(
            "Preset \"{}\" not found in registry. Run \"justui preset list\" to see available presets.",
            preset_name
        ));
        return Ok(());
    }

    if config.preset == preset_name {
        logger::info(&format!("Preset \"{}\" is already active.", preset_name));
        return Ok(());
    }

    let installed_components: Vec<String> = index
        .components
        .iter()
        .filter(|c| {
            let target_dir = if c.internal {
                config.shared_dir.clone()
            } else {
                format!("{}/{}", config.components_dir, c.name)
            };
            std::path::Path::new(&target_dir).exists()
        })
        .map(|c| c.name.clone())
        .collect();

    if installed_components.is_empty() {
        logger::warning("No installed components found. Run \"justui add\" first.");
        return Ok(());
    }

    let unsupported: Vec<&str> = installed_components
        .iter()
        .filter(|name| {
            index
                .components
                .iter()
                .find(|c| &c.name == *name)
                .map(|c| !c.supported_presets.contains(&preset_name.to_string()))
                .unwrap_or(false)
        })
        .map(|s| s.as_str())
        .collect();

    if !unsupported.is_empty() {
        logger::warning(&format!(
            "The following components do not support preset \"{}\": {}",
            preset_name,
            unsupported.join(", ")
        ));
        logger::warning("These components will be skipped and keep their current preset.");
    }

    let to_apply: Vec<String> = installed_components
        .into_iter()
        .filter(|name| {
            index
                .components
                .iter()
                .find(|c| &c.name == name)
                .map(|c| c.supported_presets.contains(&preset_name.to_string()))
                .unwrap_or(false)
        })
        .collect();

    if to_apply.is_empty() {
        logger::error(&format!(
            "No installed components support preset \"{}\".",
            preset_name
        ));
        return Ok(());
    }

    if !auto_yes {
        logger::stdout(&format!(
            "\nApply preset \"{}\" to {} component(s)?",
            preset_name,
            to_apply.len()
        ));
        for name in &to_apply {
            logger::stdout(&format!("  →  {}", name));
        }
        logger::stdout("");

        let confirm = prompt::confirm(
            &format!("Continue? Existing component files will be overwritten with the \"{}\" preset version.", preset_name),
            false,
        );
        if !confirm {
            logger::info("Cancelled.");
            return Ok(());
        }
    }

    let new_config = JustUIConfig {
        preset: preset_name.to_string(),
        ..config.clone()
    };

    let mut visited: HashSet<String> = HashSet::new();

    logger::panel(&format!("Applying preset \"{}\"", preset_name));

    let pb = indicatif::ProgressBar::new(to_apply.len() as u64);
    pb.set_style(
        indicatif::ProgressStyle::default_bar()
            .template("{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {pos}/{len} {msg}")
            .unwrap()
            .progress_chars("#>-"),
    );

    let mut success_count = 0;
    let mut fail_count = 0;

    for comp_name in &to_apply {
        pb.set_message(format!("Applying {}...", comp_name));
        match add_component(
            comp_name,
            &index,
            &client,
            &new_config.components_dir,
            &new_config.tokens_dir,
            &new_config.shared_dir,
            &mut visited,
            false,
            false,
            true,
            &None,
            &new_config.preset,
        ) {
            Ok(_) => success_count += 1,
            Err(e) => {
                fail_count += 1;
                logger::warning(&format!("Failed to apply \"{}\": {}", comp_name, e));
            }
        }
        pb.inc(1);
    }

    pb.finish_and_clear();

    let new_yaml = new_config.to_yaml_string();
    if let Err(e) = std::fs::write(config_path, new_yaml) {
        logger::error(&format!(
            "Failed to update {}: {}",
            JustUIConfig::CONFIG_FILE_NAME,
            e
        ));
        return Ok(());
    }

    logger::summary(
        &format!("Preset \"{}\" applied successfully", preset_name),
        &[
            crate::utils::logger::SummaryItem {
                label: "Succeeded".to_string(),
                value: format!("{} component(s)", success_count),
            },
            crate::utils::logger::SummaryItem {
                label: "Failed".to_string(),
                value: format!("{} component(s)", fail_count),
            },
            crate::utils::logger::SummaryItem {
                label: "Active preset".to_string(),
                value: preset_name.to_string(),
            },
        ],
    );

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_preset_subcommands_dispatch() {
        let info_sub = PresetSubcommands::Info {
            name: "default".to_string(),
        };
        if let PresetSubcommands::Info { name } = info_sub {
            assert_eq!(name, "default");
        }
    }

    #[test]
    fn test_preset_run_uninitialized() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        // Without config file, preset commands return Ok without erroring out
        assert!(run_list().is_ok());
        assert!(run_info("default").is_ok());
        assert!(run_apply("default", true).is_ok());
        assert!(run(None, Some("default".to_string()), true, false, None, true).is_ok());
        assert!(run(None, None, false, true, None, true).is_ok());
        assert!(run(None, None, false, false, Some("default".to_string()), true).is_ok());
    }

    #[test]
    fn test_preset_run_initialized_with_local_registry() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        let registry_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();
        std::fs::write(
            registry_dir.join("index.json"),
            serde_json::to_string(&serde_json::json!({
                "version": "0.1.0",
                "presets": ["default", "neobrutalism"],
                "components": [{
                    "name": "button",
                    "version": "0.1.0",
                    "description": "Button",
                    "category": "primitives",
                    "supportedPresets": ["default", "neobrutalism"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [{
                            "name": "just_button.dart",
                            "path": "components/button/just_button.dart",
                            "checksum": "sha256:111"
                        }],
                        "neobrutalism": [{
                            "name": "just_button.dart",
                            "path": "components/button/just_button.dart",
                            "checksum": "sha256:222"
                        }]
                    }
                }]
            }))
            .unwrap(),
        )
        .unwrap();

        std::fs::write(
            registry_dir.join("components/button/just_button.dart"),
            "class JustButton {}",
        )
        .unwrap();
        std::fs::write("pubspec.yaml", "name: test_app").unwrap();
        std::fs::write(
            "justui.config.yaml",
            format!("components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\npreset: default\nregistry_url: {}\n", registry_dir.display()),
        )
        .unwrap();

        // Scaffold installed component directory so run_apply finds installed components
        std::fs::create_dir_all("lib/ui/button").unwrap();
        std::fs::write("lib/ui/button/just_button.dart", "class JustButton {}").unwrap();

        // 1. run_list
        assert!(run_list().is_ok());

        // 2. run_info (existing preset)
        assert!(run_info("default").is_ok());

        // 3. run_info (non-existent preset)
        assert!(run_info("invalid_preset").is_ok());

        // 4. run_apply (to same active preset -> notice info)
        assert!(run_apply("default", true).is_ok());

        // 5. run_apply (to neobrutalism preset with auto_yes)
        assert!(run_apply("neobrutalism", true).is_ok());

        // 6. run_apply (to non-existent preset -> error notice)
        assert!(run_apply("nonexistent_preset", true).is_ok());
    }
}
