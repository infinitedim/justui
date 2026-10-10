use super::*;
use tempfile::tempdir;

use crate::utils::set_dir;

#[test]
fn test_info_run_without_config() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());
    assert!(run(None).is_ok());
}

#[test]
fn test_info_run_with_pubspec_name_and_nameless() {
    let _lock = crate::utils::lock_test_mutex();
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
    let _lock = crate::utils::lock_test_mutex();
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
    let _lock = crate::utils::lock_test_mutex();
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
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

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
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    // Create pubspec.yaml without name:
    std::fs::write(
        temp_dir.path().join("pubspec.yaml"),
        "description: test app\n",
    )
    .unwrap();

    assert!(run(None).is_ok());
}
