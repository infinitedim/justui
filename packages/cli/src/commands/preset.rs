use anyhow::Result;
use std::collections::HashSet;

use crate::commands::add::add_component;
use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::{logger, prompt};

/// Runs the `justui preset` command.
pub fn run(
    name: Option<String>,
    apply: bool,
    list: bool,
    info_preset: Option<String>,
    auto_yes: bool,
) -> Result<()> {
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
        // Jika nama diberikan tapi tidak ada --apply, tampilkan info
        return run_info(&preset_name);
    }

    // Tidak ada argumen sama sekali — tampilkan list
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
    logger::panel(&format!("Preset: {}{}", preset_name, if is_active { " (active)" } else { "" }));

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
    // 1. Baca config
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

    // 2. Fetch registry
    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!("Failed to fetch registry: {}", e));
            return Ok(());
        }
    };

    // 3. Validasi preset ada di registry
    if !index.presets.contains(&preset_name.to_string()) {
        logger::error(&format!(
            "Preset \"{}\" not found in registry. Run \"justui preset list\" to see available presets.",
            preset_name
        ));
        return Ok(());
    }

    // 4. Cek apakah preset sudah aktif
    if config.preset == preset_name {
        logger::info(&format!("Preset \"{}\" is already active.", preset_name));
        return Ok(());
    }

    // 5. Cari semua komponen yang sudah ter-install (termasuk internal/shared)
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

    // 6. Cek komponen mana yang tidak support preset ini
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

    // 7. Filter hanya yang support preset ini
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

    // 8. Konfirmasi dengan user
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

    // 9. Buat config baru dengan preset yang diupdate
    let new_config = JustUIConfig {
        preset: preset_name.to_string(),
        ..config.clone()
    };

    // 10. Apply — jalankan add_component untuk setiap komponen dengan preset baru
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
            false,  // tidak dry-run
            false,  // tidak show-diff
            true,   // auto_yes: langsung overwrite tanpa prompt
            &None,  // tidak ada progress bar nested
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

    // 11. Update justui.config.yaml dengan preset baru
    let new_yaml = new_config.to_yaml_string();
    if let Err(e) = std::fs::write(config_path, new_yaml) {
        logger::error(&format!("Failed to update {}: {}", JustUIConfig::CONFIG_FILE_NAME, e));
        return Ok(());
    }

    // 12. Summary
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
