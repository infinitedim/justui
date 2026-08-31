use anyhow::Result;
use regex::Regex;

use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::logger;

pub fn run(component_name: Option<String>) -> Result<()> {
    let version = env!("CARGO_PKG_VERSION");

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

    if let Some(ref name) = component_name {
        logger::info(&format!("Component info for \"{}\"", name));
        let client = RegistryClient::new(config.registry_url.clone());
        if let Ok(index) = client.fetch_index() {
            if let Some(c) = index.components.iter().find(|comp| comp.name == *name) {
                logger::stdout(&format!("{} ({})", c.name, c.description));
                logger::stdout(&format!("Version: {}", c.version));
                logger::stdout(&format!("Category: {}", c.category));
                return Ok(());
            }
        }
        return Err(anyhow::anyhow!(
            "Component \"{}\" not found in registry",
            name
        ));
    }

    logger::stdout(&format!("JustUI CLI v{}", version));
    logger::stdout("");

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
    use tempfile::tempdir;

    struct DirGuard(std::path::PathBuf);
    impl Drop for DirGuard {
        fn drop(&mut self) {
            let _ = std::env::set_current_dir(&self.0);
        }
    }
    fn set_dir<P: AsRef<std::path::Path>>(p: P) -> DirGuard {
        let orig = std::env::current_dir()
            .unwrap_or_else(|_| std::path::PathBuf::from("/home/yourblooo/development/justui"));
        let _ = std::env::set_current_dir(p);
        DirGuard(orig)
    }

    #[test]
    fn test_info_run_without_config() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());
        assert!(run(None).is_ok());
    }

    #[test]
    fn test_info_run_with_pubspec_name_and_nameless() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        // 1. pubspec.yaml with name
        std::fs::write(
            temp_dir.path().join("pubspec.yaml"),
            "name: my_test_project\nversion: 1.0.0\n",
        )
        .unwrap();
        assert!(run(None).is_ok());

        // 2. pubspec.yaml without name field
        std::fs::write(
            temp_dir.path().join("pubspec.yaml"),
            "version: 1.0.0\ndescription: app without name\n",
        )
        .unwrap();
        assert!(run(None).is_ok());
    }

    #[test]
    fn test_info_run_with_valid_config_and_local_registry() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(&reg_dir).unwrap();

        let index_json = r#"{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {
                    "name": "button",
                    "version": "1.2.0",
                    "description": "A customized button",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [
                            {
                                "name": "button.dart",
                                "path": "components/button.dart",
                                "checksum": "sha256:2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
                            }
                        ]
                    }
                }
            ]
        }"#;
        std::fs::write(reg_dir.join("index.json"), index_json).unwrap();

        let config_yaml = format!(
            "components_dir: lib/components\ntokens_dir: lib/tokens\nshared_dir: lib/shared\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(
            temp_dir.path().join(JustUIConfig::CONFIG_FILE_NAME),
            config_yaml,
        )
        .unwrap();

        // Run general info with found config and working registry
        assert!(run(None).is_ok());

        // Run query for existing component
        assert!(run(Some("button".to_string())).is_ok());

        // Run query for non-existing component
        let err = run(Some("card".to_string())).unwrap_err();
        assert!(err.to_string().contains("Component \"card\" not found"));
    }

    #[test]
    fn test_info_run_unreachable_registry_and_read_error_config() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        // Config pointing to non-existent local directory for registry
        let config_yaml = "components_dir: lib/comp\nregistry_url: /non/existent/path/999\n";
        std::fs::write(
            temp_dir.path().join(JustUIConfig::CONFIG_FILE_NAME),
            config_yaml,
        )
        .unwrap();

        assert!(run(None).is_ok());
        let err = run(Some("button".to_string())).unwrap_err();
        assert!(err.to_string().contains("Component \"button\" not found"));

        // Read error config: directory named justui.config.yaml
        let temp_dir2 = tempdir().unwrap();
        let _guard2 = set_dir(temp_dir2.path());
        std::fs::create_dir_all(temp_dir2.path().join(JustUIConfig::CONFIG_FILE_NAME)).unwrap();
        assert!(run(None).is_ok());
    }

    #[test]
    fn test_info_with_config_and_pubspec() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        // Create pubspec.yaml with name
        std::fs::write(temp_dir.path().join("pubspec.yaml"), "name: my_test_app\n").unwrap();

        // Create local registry with index.json
        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(&reg_dir).unwrap();
        std::fs::write(
            reg_dir.join("index.json"),
            r#"{
                "version": "1.2.3",
                "presets": ["default"],
                "components": [
                    {
                        "name": "button",
                        "version": "1.0.0",
                        "description": "Button component",
                        "category": "primitive",
                        "internal": false,
                        "supported_presets": ["default"],
                        "registry_dependencies": [],
                        "pub_dependencies": {},
                        "files": {}
                    }
                ]
            }"#,
        )
        .unwrap();

        // Create justui.config.yaml
        let config_yaml = format!("registry_url: {}\n", reg_dir.to_string_lossy());
        std::fs::write(temp_dir.path().join("justui.config.yaml"), config_yaml).unwrap();

        // Test run(None) -> prints config, pubspec, registry OK
        assert!(run(None).is_ok());

        // Test run(Some("button")) -> prints component info
        assert!(run(Some("button".to_string())).is_ok());

        // Test run(Some("invalid")) -> returns Err
        assert!(run(Some("invalid".to_string())).is_err());
    }

    #[test]
    fn test_info_pubspec_without_name() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        // Create pubspec.yaml without name:
        std::fs::write(
            temp_dir.path().join("pubspec.yaml"),
            "description: test app\n",
        )
        .unwrap();

        assert!(run(None).is_ok());
    }
}
