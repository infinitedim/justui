use anyhow::Result;
use regex::Regex;

use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::logger;

pub fn run(component_name: Option<String>) -> Result<()> {
    let version = env!("CARGO_PKG_VERSION");
    if let Some(ref comp) = component_name {
        logger::stdout(&format!("JustUI CLI v{} - Info for {}", version, comp));
    } else {
        logger::stdout(&format!("JustUI CLI v{}", version));
    }
    logger::stdout("");

    let config_file = JustUIConfig::CONFIG_FILE_NAME;
    let config_path = std::path::Path::new(config_file);

    let (config_status, config) = if config_path.exists() {
        match std::fs::read_to_string(config_path) {
            Ok(content) => ("[found]".to_string(), JustUIConfig::from_yaml(&content)),
            Err(_) => ("[read error]".to_string(), JustUIConfig::default()),
        }
    } else {
        ("[not found]".to_string(), JustUIConfig::default())
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
    logger::stdout(&format!(
        "  {:<14}: {}",
        "Registry URL", config.registry_url
    ));
    logger::stdout("");

    let pubspec_path = std::path::Path::new("pubspec.yaml");
    let (pubspec_status, project_name) = if pubspec_path.exists() {
        let content = std::fs::read_to_string(pubspec_path).unwrap_or_default();
        let re = Regex::new(r"(?m)^name:\s*(.+)$").unwrap();
        let name = re
            .captures(&content)
            .and_then(|caps| caps.get(1))
            .map(|m| m.as_str().trim().to_string())
            .unwrap_or_else(|| "-".to_string());
        ("[found]".to_string(), name)
    } else {
        ("[not found]".to_string(), "-".to_string())
    };

    logger::stdout("Project");
    logger::stdout(&format!("  {:<14}: {}", "pubspec.yaml", pubspec_status));
    logger::stdout(&format!("  {:<14}: {}", "Project name", project_name));
    logger::stdout("");

    let client = RegistryClient::new(config.registry_url.clone());
    logger::stdout("Registry");
    match client.fetch_index() {
        Ok(index) => {
            logger::stdout(&format!("  {:<14}: OK", "Status"));
            logger::stdout(&format!("  {:<14}: {}", "Index version", index.version));
            logger::stdout(&format!(
                "  {:<14}: {}",
                "Components",
                index.components.len()
            ));
        }
        Err(_) => {
            logger::stdout(&format!("  {:<14}: Unreachable", "Status"));
            logger::stdout(&format!("  {:<14}: -", "Index version"));
            logger::stdout(&format!("  {:<14}: -", "Components"));
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_info_run_without_config() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());
        assert!(run(None).is_ok());
    }
}
