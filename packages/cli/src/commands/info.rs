use anyhow::Result;
use regex::Regex;

use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::logger;

/// Runs the `justui info` command.
pub fn run() -> Result<()> {
    // Part 1 — CLI version
    let version = env!("CARGO_PKG_VERSION");
    logger::stdout(&format!("JustUI CLI v{}", version));
    logger::stdout("");

    // Part 2 — Config info
    let config_file = JustUIConfig::CONFIG_FILE_NAME;
    let config_path = std::path::Path::new(config_file);

    let (config_status, config) = if config_path.exists() {
        match std::fs::read_to_string(config_path) {
            Ok(content) => ("[ditemukan]".to_string(), JustUIConfig::from_yaml(&content)),
            Err(_) => ("[error membaca]".to_string(), JustUIConfig::default()),
        }
    } else {
        ("[tidak ditemukan]".to_string(), JustUIConfig::default())
    };

    logger::stdout("Config");
    logger::stdout(&format!(
        "  {:<14}: {} {}",
        "File", config_file, config_status
    ));
    logger::stdout(&format!(
        "  {:<14}: {}",
        "Components", config.components_dir
    ));
    logger::stdout(&format!("  {:<14}: {}", "Tokens", config.tokens_dir));
    logger::stdout(&format!("  {:<14}: {}", "Shared", config.shared_dir));
    logger::stdout(&format!("  {:<14}: {}", "Registry URL", config.registry_url));
    logger::stdout("");

    // Part 3 — Project info
    let pubspec_path = std::path::Path::new("pubspec.yaml");
    let (pubspec_status, project_name) = if pubspec_path.exists() {
        let content = std::fs::read_to_string(pubspec_path).unwrap_or_default();
        let re = Regex::new(r"(?m)^name:\s*(.+)$").unwrap();
        let name = re
            .captures(&content)
            .and_then(|caps| caps.get(1))
            .map(|m| m.as_str().trim().to_string())
            .unwrap_or_else(|| "-".to_string());
        ("[ditemukan]".to_string(), name)
    } else {
        ("[tidak ditemukan]".to_string(), "-".to_string())
    };

    logger::stdout("Project");
    logger::stdout(&format!(
        "  {:<14}: {}",
        "pubspec.yaml", pubspec_status
    ));
    logger::stdout(&format!("  {:<14}: {}", "Nama project", project_name));
    logger::stdout("");

    // Part 4 — Registry info
    let client = RegistryClient::new(config.registry_url.clone());
    logger::stdout("Registry");
    match client.fetch_index() {
        Ok(index) => {
            logger::stdout(&format!("  {:<14}: OK", "Status"));
            logger::stdout(&format!("  {:<14}: {}", "Versi index", index.version));
            logger::stdout(&format!(
                "  {:<14}: {}",
                "Jumlah komponen",
                index.components.len()
            ));
        }
        Err(_) => {
            logger::stdout(&format!("  {:<14}: Tidak dapat dijangkau", "Status"));
            logger::stdout(&format!("  {:<14}: -", "Versi index"));
            logger::stdout(&format!("  {:<14}: -", "Jumlah komponen"));
        }
    }

    Ok(())
}
