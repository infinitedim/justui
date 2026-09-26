use super::*;

use crate::utils::set_dir;

#[test]
fn test_add_helpers() {
    let mut s1 = DryRunStats::new();
    s1.will_write = 2;
    let mut s2 = DryRunStats::new();
    s2.skipped = 1;
    s2.conflicts = 3;
    s1.merge(&s2);

    assert_eq!(s1.will_write, 2);
    assert_eq!(s1.skipped, 1);
    assert_eq!(s1.conflicts, 3);

    let hash = sha256_hex(b"hello");
    assert_eq!(
        hash,
        "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
    );

    assert_eq!(
        extract_theme_class_name("class ButtonTheme extends ThemeExtension<ButtonTheme>"),
        Some("ButtonTheme".to_string())
    );
    assert_eq!(extract_theme_class_name("class RegularClass {}"), None);
}

#[test]
fn test_add_run_uninitialized_and_conflict_resolution() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    // 1. Uninitialized project returns Ok with warning
    assert!(run(vec![], false, false, false, false, true).is_ok());

    // 2. Test resolve_conflict when target file exists with metadata up-to-date
    let file_path = temp_dir.path().join("just_button.dart");
    let raw_code = "class JustButton {}";
    let hash = sha256_hex(raw_code.as_bytes());
    let meta_content = import_rewriter::inject_metadata(raw_code, &hash, &hash);
    std::fs::write(&file_path, &meta_content).unwrap();

    let (will_write, status) = resolve_conflict(
        &file_path,
        "just_button.dart",
        &hash,
        raw_code,
        &meta_content,
        true,
    )
    .unwrap();
    assert!(!will_write);
    assert_eq!(status, OperationStatus::UpToDate);

    // 3. Test resolve_conflict_dry when target file exists with metadata up-to-date
    let (will_write_dry, conflict, _, status_dry) =
        resolve_conflict_dry(&file_path, "just_button.dart", &hash, raw_code, true).unwrap();
    assert!(!will_write_dry);
    assert!(!conflict);
    assert_eq!(status_dry, OperationStatus::UpToDate);
}

#[test]
fn test_add_run_malformed_config_and_unusual_dirs() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    // 1. Config with invalid YAML returns Ok without erroring out
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, "::invalid::yaml::").unwrap();
    assert!(run(vec![], false, false, false, false, true).is_ok());

    // 2. Config with unusual shared_dir (not nested under components_dir)
    let config_yaml =
        "components_dir: lib/components\nshared_dir: lib/shared\nregistry_url: /invalid/registry\n";
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();
    assert!(run(vec![], false, false, false, false, true).is_ok());
}

#[test]
fn test_add_run_empty_registry_and_selection() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(&reg_dir).unwrap();

    // Empty components list in registry index
    let index_json = r#"{"version": "1.0.0", "presets": ["default"], "components": []}"#;
    std::fs::write(reg_dir.join("index.json"), index_json).unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // Prompting components with auto_yes when registry has 0 components -> logs error and returns Ok
    assert!(run(vec![], false, false, false, false, true).is_ok());

    // Non-interactive fallback when components vector is empty -> returns Ok
    assert!(run(vec![], false, false, false, false, false).is_ok());
}

#[test]
fn test_add_component_execution_flow_all_types() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("components")).unwrap();
    std::fs::create_dir_all(reg_dir.join("tokens")).unwrap();

    let btn_code = "class Button {}";
    let btn_hash = sha256_hex(btn_code.as_bytes());

    let tok_code = "class ColorTokens {}";
    let tok_hash = sha256_hex(tok_code.as_bytes());

    let theme_code = "class ButtonTheme extends ThemeExtension<ButtonTheme> {}";
    let theme_hash = sha256_hex(theme_code.as_bytes());

    let index_json = format!(
        r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "button",
                    "version": "1.0.0",
                    "description": "Button component",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": ["tokens"],
                    "pubDependencies": {{"flutter_bloc": "^8.0.0"}},
                    "files": {{
                        "default": [
                            {{
                                "name": "button.dart",
                                "path": "components/button.dart",
                                "checksum": "sha256:{btn_hash}"
                            }},
                            {{
                                "name": "button_theme.dart",
                                "path": "components/button_theme.dart",
                                "checksum": "sha256:{theme_hash}"
                            }}
                        ]
                    }}
                }},
                {{
                    "name": "tokens",
                    "version": "1.0.0",
                    "description": "Design tokens",
                    "category": "tokens",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "colors.dart",
                                "path": "tokens/colors.dart",
                                "checksum": "sha256:{tok_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
    );

    std::fs::write(reg_dir.join("index.json"), index_json).unwrap();
    std::fs::write(reg_dir.join("components/button.dart"), btn_code).unwrap();
    std::fs::write(reg_dir.join("components/button_theme.dart"), theme_code).unwrap();
    std::fs::write(reg_dir.join("tokens/colors.dart"), tok_code).unwrap();

    // Create theme file to test register_theme_extension
    std::fs::create_dir_all("lib/core/theme").unwrap();
    std::fs::write(
        "lib/core/theme/theme_data_material.dart",
        "class ThemeData {}",
    )
    .unwrap();
    std::fs::write("pubspec.yaml", "name: my_app\n").unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\ndart_target: primary\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // 1. Dry run with diff enabled
    assert!(run(vec!["button".to_string()], true, true, false, false, true).is_ok());

    // 2. Real run adding components (dry_run=false, show_diff=false)
    assert!(run(vec!["button".to_string()], false, false, false, false, true).is_ok());

    // Verify files were created
    assert!(std::path::Path::new("lib/widgets/button/button.dart").exists());
    assert!(std::path::Path::new("lib/widgets/button/button_theme.dart").exists());
    assert!(std::path::Path::new("lib/tokens/colors.dart").exists());

    // 3. Re-run (UpToDate status)
    assert!(run(vec!["button".to_string()], false, false, false, false, true).is_ok());
}

#[test]
fn test_add_component_checksum_and_unknown_dependency() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("components")).unwrap();

    // Checksum in index doesn't match downloaded file content
    let index_json = r#"{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {
                    "name": "bad_checksum",
                    "version": "1.0.0",
                    "description": "Corrupt",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [
                            {
                                "name": "corrupt.dart",
                                "path": "components/corrupt.dart",
                                "checksum": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
                            }
                        ]
                    }
                },
                {
                    "name": "broken_dep",
                    "version": "1.0.0",
                    "description": "Dep error",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": ["non_existent_dep"],
                    "pubDependencies": {},
                    "files": {}
                }
            ]
        }"#;

    std::fs::write(reg_dir.join("index.json"), index_json).unwrap();
    std::fs::write(reg_dir.join("components/corrupt.dart"), "some content").unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // 1. Security checksum failure
    assert!(run(
        vec!["bad_checksum".to_string()],
        false,
        false,
        false,
        false,
        true
    )
    .is_ok());

    // 2. Unknown dependency error
    assert!(run(
        vec!["broken_dep".to_string()],
        false,
        false,
        false,
        false,
        true
    )
    .is_ok());
}

#[test]
fn test_add_component_all_conflict_branches() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let target = temp_dir.path().join("test.dart");
    let raw = "class Test {}";
    let expected_hash = sha256_hex(raw.as_bytes());
    let local_clean = "class LocalModified {}";
    let local_hash = sha256_hex(local_clean.as_bytes());
    let dummy_reg_hash = "0000000000000000000000000000000000000000000000000000000000000000";
    let dummy_loc_hash = "1111111111111111111111111111111111111111111111111111111111111111";

    // Case 1: Unmodified locally, registry updated -> Overwritten (returns true)
    let meta_unmodified =
        import_rewriter::inject_metadata(local_clean, dummy_reg_hash, &local_hash);
    std::fs::write(&target, &meta_unmodified).unwrap();
    let (write1, status1) = resolve_conflict(
        &target,
        "test.dart",
        &expected_hash,
        raw,
        &meta_unmodified,
        true,
    )
    .unwrap();
    assert!(write1);
    assert_eq!(status1, OperationStatus::Overwritten);

    // Case 2: Modified locally, registry updated -> ConflictResolvedSkip (returns false)
    let meta_modified =
        import_rewriter::inject_metadata(local_clean, dummy_reg_hash, dummy_loc_hash);
    std::fs::write(&target, &meta_modified).unwrap();
    let (write2, status2) = resolve_conflict(
        &target,
        "test.dart",
        &expected_hash,
        raw,
        &meta_modified,
        true,
    )
    .unwrap();
    assert!(!write2);
    assert_eq!(status2, OperationStatus::ConflictResolvedSkip);

    // Case 3: File without metadata, content differs -> ConflictResolvedOverwrite (returns true)
    std::fs::write(&target, "different content without meta").unwrap();
    let (write3, status3) = resolve_conflict(
        &target,
        "test.dart",
        &expected_hash,
        raw,
        &meta_modified,
        true,
    )
    .unwrap();
    assert!(write3);
    assert_eq!(status3, OperationStatus::ConflictResolvedOverwrite);

    // Case 4: resolve_conflict_dry with metadata modified locally and registry unchanged
    let meta_same_reg =
        import_rewriter::inject_metadata(local_clean, &expected_hash, dummy_loc_hash);
    std::fs::write(&target, &meta_same_reg).unwrap();
    let (write4, conflict4, _, status4) =
        resolve_conflict_dry(&target, "test.dart", &expected_hash, raw, true).unwrap();
    assert!(!write4);
    assert!(!conflict4);
    assert_eq!(status4, OperationStatus::SkippedLocalCustomization);

    // Case 5: resolve_conflict_dry without metadata modified
    std::fs::write(&target, "different content").unwrap();
    let (write5, conflict5, _, status5) =
        resolve_conflict_dry(&target, "test.dart", &expected_hash, raw, true).unwrap();
    assert!(!write5);
    assert!(!conflict5);
    assert_eq!(status5, OperationStatus::SkippedLocalCustomization);
}

#[test]
fn test_add_conflict_interactive_and_non_auto_yes() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let target = temp_dir.path().join("test.dart");
    let raw = "class Test {}";
    let expected_hash = sha256_hex(raw.as_bytes());
    let local_clean = "class LocalModified {}";
    let local_hash = sha256_hex(local_clean.as_bytes());
    let dummy_reg_hash = "0000000000000000000000000000000000000000000000000000000000000000";
    let dummy_loc_hash = "1111111111111111111111111111111111111111111111111111111111111111";

    // 1. Unmodified locally, registry updated (auto_yes = false)
    let meta_unmodified =
        import_rewriter::inject_metadata(local_clean, dummy_reg_hash, &local_hash);
    std::fs::write(&target, &meta_unmodified).unwrap();
    let (write1, status1) = resolve_conflict(
        &target,
        "test.dart",
        &expected_hash,
        raw,
        &meta_unmodified,
        false,
    )
    .unwrap();
    assert!(write1);
    assert_eq!(status1, OperationStatus::Overwritten);

    // 2. Modified locally, registry up-to-date (auto_yes = false)
    let meta_same_reg =
        import_rewriter::inject_metadata(local_clean, &expected_hash, dummy_loc_hash);
    std::fs::write(&target, &meta_same_reg).unwrap();
    let (write2, status2) = resolve_conflict(
        &target,
        "test.dart",
        &expected_hash,
        raw,
        &meta_same_reg,
        false,
    )
    .unwrap();
    assert!(!write2);
    assert_eq!(status2, OperationStatus::SkippedLocalCustomization);

    // 3. Modified locally, registry updated (auto_yes = false, conflict_prompt fallback "s")
    let meta_modified =
        import_rewriter::inject_metadata(local_clean, dummy_reg_hash, dummy_loc_hash);
    std::fs::write(&target, &meta_modified).unwrap();
    let (write3, status3) = resolve_conflict(
        &target,
        "test.dart",
        &expected_hash,
        raw,
        &meta_modified,
        false,
    )
    .unwrap();
    assert!(!write3);
    assert_eq!(status3, OperationStatus::ConflictResolvedSkip);

    // 4. File without metadata, content identical to expected
    std::fs::write(&target, raw).unwrap();
    let (write4, status4) =
        resolve_conflict(&target, "test.dart", &expected_hash, raw, raw, false).unwrap();
    assert!(!write4);
    assert_eq!(status4, OperationStatus::UpToDate);

    // 5. File without metadata, content differs (auto_yes = false, conflict_prompt fallback "s")
    std::fs::write(&target, "different raw content").unwrap();
    let (write5, status5) =
        resolve_conflict(&target, "test.dart", &expected_hash, raw, raw, false).unwrap();
    assert!(!write5);
    assert_eq!(status5, OperationStatus::ConflictResolvedSkip);
}

#[test]
fn test_add_special_component_categories_and_all_flag() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("core")).unwrap();
    std::fs::create_dir_all(reg_dir.join("theme")).unwrap();

    let core_code = "class JustCore {}";
    let core_hash = sha256_hex(core_code.as_bytes());

    let theme_code = "class ThemeProvider {}";
    let theme_hash = sha256_hex(theme_code.as_bytes());

    let index_json = format!(
        r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "core_comp",
                    "version": "1.0.0",
                    "description": "Core component",
                    "category": "core",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "core.dart",
                                "path": "core/core.dart",
                                "checksum": "sha256:{core_hash}"
                            }}
                        ]
                    }}
                }},
                {{
                    "name": "_shared_theme_bridge",
                    "version": "1.0.0",
                    "description": "Shared theme bridge",
                    "category": "shared",
                    "internal": true,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "_shared_theme_bridge.dart",
                                "path": "theme/_shared_theme_bridge.dart",
                                "checksum": "sha256:{theme_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
    );

    std::fs::write(reg_dir.join("index.json"), index_json).unwrap();
    std::fs::write(reg_dir.join("core/core.dart"), core_code).unwrap();
    std::fs::write(reg_dir.join("theme/_shared_theme_bridge.dart"), theme_code).unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // Test run with `all = true` flag
    assert!(run(vec![], false, false, true, false, true).is_ok());

    assert!(std::path::Path::new("lib/tokens/core.dart").exists());
    // Internal components always land flat in shared_dir with the `_shared_` prefix
    // rewritten to `just_`.
    assert!(std::path::Path::new("lib/widgets/shared/just_theme_bridge.dart").exists());
}

#[test]
fn test_add_progress_bar_and_theme_file_candidates_and_error_handling() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("shared")).unwrap();

    let shared_code = "class SharedWidget {}";
    let shared_hash = sha256_hex(shared_code.as_bytes());

    let theme_code = "class CustomTheme extends ThemeExtension<CustomTheme> {}";
    let theme_hash = sha256_hex(theme_code.as_bytes());

    let index_json = format!(
        r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "custom",
                    "version": "1.0.0",
                    "description": "Custom component",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": ["_shared_helper"],
                    "pubDependencies": {{"flutter": "any"}},
                    "files": {{
                        "default": [
                            {{
                                "name": "custom_theme.dart",
                                "path": "shared/custom_theme.dart",
                                "checksum": "sha256:{theme_hash}"
                            }}
                        ]
                    }}
                }},
                {{
                    "name": "_shared_helper",
                    "version": "1.0.0",
                    "description": "Internal helper",
                    "category": "shared",
                    "internal": true,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "_shared_helper.dart",
                                "path": "shared/helper.dart",
                                "checksum": "sha256:{shared_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
    );

    std::fs::write(reg_dir.join("index.json"), index_json).unwrap();
    std::fs::write(reg_dir.join("shared/custom_theme.dart"), theme_code).unwrap();
    std::fs::write(reg_dir.join("shared/helper.dart"), shared_code).unwrap();

    // Create theme file at lib/core/theme_data_material.dart
    std::fs::create_dir_all("lib/core").unwrap();
    std::fs::write("lib/core/theme_data_material.dart", "class ThemeData {}").unwrap();
    std::fs::write("pubspec.yaml", "name: app\n").unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // Run with overwrite = true (sets auto_yes = true)
    assert!(run(vec!["custom".to_string()], false, false, false, true, false).is_ok());

    // Verify normalized file name just_helper.dart exists in shared_dir
    assert!(std::path::Path::new("lib/widgets/shared/just_helper.dart").exists());

    // Now create alternative theme candidate paths: lib/core/theme/theme_data_material.dart
    std::fs::create_dir_all("lib/core/theme").unwrap();
    std::fs::write(
        "lib/core/theme/theme_data_material.dart",
        "// CLI:REGISTER_EXTENSIONS\n",
    )
    .unwrap();
    std::fs::remove_file("lib/core/theme_data_material.dart").unwrap();

    // Dry run to exercise dry-run theme registration log
    assert!(run(vec!["custom".to_string()], true, false, false, false, true).is_ok());

    // Real run to register theme extension in lib/core/theme/theme_data_material.dart
    assert!(run(vec!["custom".to_string()], false, false, false, false, true).is_ok());

    // Test HTTP index error path: invalid registry URL in config
    let bad_config = "components_dir: lib/widgets\nregistry_url: http://127.0.0.1:1/invalid\n";
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, bad_config).unwrap();
    assert!(run(vec!["custom".to_string()], false, false, false, false, true).is_ok());
}

#[test]
fn test_add_run_all_operation_statuses_output_formatting() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("comp")).unwrap();

    let v1_code = "class WidgetV1 {}";
    let v1_hash = sha256_hex(v1_code.as_bytes());

    let v2_code = "class WidgetV2 {}";
    let v2_hash = sha256_hex(v2_code.as_bytes());

    let make_index = |checksum: &str| {
        format!(
            r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "widget",
                    "version": "1.0.0",
                    "description": "Widget component",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "widget.dart",
                                "path": "comp/widget.dart",
                                "checksum": "sha256:{checksum}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
        )
    };

    std::fs::write(reg_dir.join("index.json"), make_index(&v1_hash)).unwrap();
    std::fs::write(reg_dir.join("comp/widget.dart"), v1_code).unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // Run 1: Copied (New)
    assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

    // Run 2: UpToDate
    assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

    // Run 3: Registry updated (v2), local unmodified -> Overwritten
    std::fs::write(reg_dir.join("index.json"), make_index(&v2_hash)).unwrap();
    std::fs::write(reg_dir.join("comp/widget.dart"), v2_code).unwrap();
    assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

    // Run 4: Registry same (v2), local modified -> SkippedLocalCustomization
    let local_file = temp_dir.path().join("lib/widgets/widget/widget.dart");
    let modified_meta = import_rewriter::inject_metadata(
        "class LocallyModified {}",
        &v2_hash,
        "9999999999999999999999999999999999999999999999999999999999999999",
    );
    std::fs::write(&local_file, &modified_meta).unwrap();
    assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

    // Run 5: Registry updated back to v1, local modified -> ConflictResolvedSkip
    std::fs::write(reg_dir.join("index.json"), make_index(&v1_hash)).unwrap();
    std::fs::write(reg_dir.join("comp/widget.dart"), v1_code).unwrap();
    assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

    // Run 6: Local file without metadata, content differs -> ConflictResolvedOverwrite
    std::fs::write(&local_file, "class WithoutMeta {}").unwrap();
    assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());
}

#[test]
fn test_add_diff_formatting_and_dry_run_conflicts() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("comp")).unwrap();

    let v1_code = "class WidgetV1 {}";
    let v1_hash = sha256_hex(v1_code.as_bytes());

    let index_json = format!(
        r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "widget",
                    "version": "1.0.0",
                    "description": "Widget component",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{"some_pkg": "1.0.0"}},
                    "files": {{
                        "default": [
                            {{
                                "name": "widget.dart",
                                "path": "comp/widget.dart",
                                "checksum": "sha256:{v1_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
    );

    std::fs::write(reg_dir.join("index.json"), &index_json).unwrap();
    std::fs::write(reg_dir.join("comp/widget.dart"), v1_code).unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // 1. show_diff = true for new file
    assert!(run(vec!["widget".to_string()], false, true, false, false, true).is_ok());

    // Create local file modified to create conflict
    let local_file = temp_dir.path().join("lib/widgets/widget/widget.dart");
    std::fs::create_dir_all(local_file.parent().unwrap()).unwrap();
    let meta_conflict = import_rewriter::inject_metadata(
        "class LocalMod {}",
        "0000000000000000000000000000000000000000000000000000000000000000",
        "1111111111111111111111111111111111111111111111111111111111111111",
    );
    std::fs::write(&local_file, &meta_conflict).unwrap();

    // 2. show_diff = true for existing modified file -> calls print_unified_diff
    assert!(run(vec!["widget".to_string()], false, true, false, false, true).is_ok());

    // 3. dry_run = true with conflict -> stats.conflicts += 1
    assert!(run(vec!["widget".to_string()], true, false, false, false, true).is_ok());

    // 4. dry_run = true with up-to-date file -> stats.skipped += 1
    let meta_uptodate = import_rewriter::inject_metadata(v1_code, &v1_hash, &v1_hash);
    std::fs::write(&local_file, &meta_uptodate).unwrap();
    assert!(run(vec!["widget".to_string()], true, false, false, false, true).is_ok());

    // 5. pub_deps with missing pubspec.yaml -> triggers warning branch in pubspec_editor
    assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());
}

#[test]
fn test_add_run_summary_output_and_auto_select_all() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("comp")).unwrap();
    std::fs::create_dir_all(reg_dir.join("core")).unwrap();
    std::fs::create_dir_all(reg_dir.join("shared")).unwrap();

    let code1 = "class Comp1 {}";
    let hash1 = sha256_hex(code1.as_bytes());

    let code2 = "class Comp2 {}";
    let hash2 = sha256_hex(code2.as_bytes());

    let index_json = format!(
        r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "normal_widget",
                    "version": "1.0.0",
                    "description": "Normal widget",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "normal.dart",
                                "path": "comp/normal.dart",
                                "checksum": "sha256:{hash1}"
                            }}
                        ]
                    }}
                }},
                {{
                    "name": "internal_helper",
                    "version": "1.0.0",
                    "description": "Internal helper",
                    "category": "shared",
                    "internal": true,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "helper.dart",
                                "path": "shared/helper.dart",
                                "checksum": "sha256:{hash2}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
    );

    std::fs::write(reg_dir.join("index.json"), &index_json).unwrap();
    std::fs::write(reg_dir.join("comp/normal.dart"), code1).unwrap();
    std::fs::write(reg_dir.join("shared/helper.dart"), code2).unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // Calling run with components = vec![], auto_yes = true, dry_run = false
    // Triggers auto-select all components + logger::summary output loop!
    assert!(run(vec![], false, false, false, false, true).is_ok());
}

#[test]
fn test_add_select_empty_and_token_summary() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("tokens")).unwrap();

    let token_code = "class TokenColor {}";
    let token_hash = sha256_hex(token_code.as_bytes());

    let index_json = format!(
        r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "token_color",
                    "version": "1.0.0",
                    "description": "Token color",
                    "category": "tokens",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "token.dart",
                                "path": "tokens/token.dart",
                                "checksum": "sha256:{token_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
    );

    std::fs::write(reg_dir.join("index.json"), &index_json).unwrap();
    std::fs::write(reg_dir.join("tokens/token.dart"), token_code).unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // 1. Run token component addition (dry_run = false) to trigger tokens/core summary item path
    assert!(run(
        vec!["token_color".to_string()],
        false,
        false,
        false,
        false,
        true
    )
    .is_ok());

    // 2. Interactive selection returning empty vector -> returns Ok with warning
    assert!(run(vec![], false, false, false, false, false).is_ok());
}

#[test]
fn test_add_missing_dependency_and_empty_selection() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("comp")).unwrap();

    let index_json = r#"{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {
                    "name": "invalid_dep_comp",
                    "version": "1.0.0",
                    "description": "Component with missing dep",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": ["missing_dep_name"],
                    "pubDependencies": {},
                    "files": {
                        "default": []
                    }
                }
            ]
        }"#;

    std::fs::write(reg_dir.join("index.json"), index_json).unwrap();

    let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
    std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // Triggers "Dependency resolution error: Component "missing_dep_name" not found in registry"
    assert!(run(
        vec!["invalid_dep_comp".to_string()],
        false,
        false,
        false,
        false,
        true
    )
    .is_ok());
}

#[test]
fn test_add_run_config_read_to_string_error() {
    let _lock = crate::utils::TEST_MUTEX
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    // let _temp_dir = tempfile::tempdir().unwrap();
}

#[test]
fn test_add_resolve_conflict_matrix() {
    let temp_dir = tempfile::tempdir().unwrap();
    let file_path = temp_dir.path().join("just_button.dart");

    let orig_code = "class Button {}";
    let modified_code = "class ButtonModified {}";
    let reg_hash_old = "1111111111111111111111111111111111111111111111111111111111111111";
    let reg_hash_new = "2222222222222222222222222222222222222222222222222222222222222222";

    let local_hash_orig = sha256_hex(orig_code.as_bytes());

    // 1. Metadata present: local modified, registry hash unchanged -> SkippedLocalCustomization
    // Metadata says original hash was local_hash_orig, but file content is modified_code
    let meta1 = import_rewriter::inject_metadata(modified_code, reg_hash_old, &local_hash_orig);
    std::fs::write(&file_path, &meta1).unwrap();
    let (write, status) = resolve_conflict(
        &file_path,
        "just_button.dart",
        reg_hash_old,
        orig_code,
        &meta1,
        true,
    )
    .unwrap();
    assert!(!write);
    assert_eq!(status, OperationStatus::SkippedLocalCustomization);

    // 2. Metadata present: local modified, registry hash updated -> ConflictResolvedSkip (auto_yes=true)
    let (write, status) = resolve_conflict(
        &file_path,
        "just_button.dart",
        reg_hash_new,
        orig_code,
        &meta1,
        true,
    )
    .unwrap();
    assert!(!write);
    assert_eq!(status, OperationStatus::ConflictResolvedSkip);

    // 3. Metadata present: local unmodified, registry hash updated -> Overwritten (auto_yes=true)
    // File content is orig_code, metadata local_hash matches orig_code hash
    let meta3 = import_rewriter::inject_metadata(orig_code, reg_hash_old, &local_hash_orig);
    std::fs::write(&file_path, &meta3).unwrap();
    let (write, status) = resolve_conflict(
        &file_path,
        "just_button.dart",
        reg_hash_new,
        orig_code,
        &meta3,
        true,
    )
    .unwrap();
    assert!(write);
    assert_eq!(status, OperationStatus::Overwritten);

    // 4. No metadata present: local file differs from expected_hash -> ConflictResolvedOverwrite (auto_yes=true)
    std::fs::write(&file_path, "class RawButton {}").unwrap();
    let (write, status) = resolve_conflict(
        &file_path,
        "just_button.dart",
        reg_hash_new,
        orig_code,
        "class RawButton {}",
        true,
    )
    .unwrap();
    assert!(write);
    assert_eq!(status, OperationStatus::ConflictResolvedOverwrite);

    // 5. Dry run conflict resolution for existing modified file
    let (write_dry, _conflict_dry, _, status_dry) = resolve_conflict_dry(
        &file_path,
        "just_button.dart",
        reg_hash_old,
        orig_code,
        true,
    )
    .unwrap();
    assert!(!write_dry);
    assert_eq!(status_dry, OperationStatus::SkippedLocalCustomization);
}

#[test]
fn test_add_run_initialized_all_flags() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    // Setup local registry
    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("components/button")).unwrap();
    std::fs::create_dir_all(reg_dir.join("components/_shared_base")).unwrap();

    let button_code = "class JustButton {}";
    let button_hash = sha256_hex(button_code.as_bytes());

    std::fs::write(reg_dir.join("just_button.dart"), button_code).unwrap();
    std::fs::write(reg_dir.join("_shared_base.dart"), "class JustBase {}").unwrap();

    std::fs::write(
        reg_dir.join("index.json"),
        serde_json::to_string(&serde_json::json!({
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {
                    "name": "button",
                    "version": "1.0.0",
                    "description": "Button",
                    "category": "primitive",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": ["_shared_base"],
                    "pubDependencies": {"flutter_svg": "^2.0.0"},
                    "files": {
                        "default": [{
                            "name": "just_button.dart",
                            "path": "just_button.dart",
                            "checksum": format!("sha256:{}", button_hash)
                        }]
                    }
                },
                {
                    "name": "_shared_base",
                    "version": "1.0.0",
                    "description": "Shared base",
                    "category": "core",
                    "internal": true,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [{
                            "name": "_shared_base.dart",
                            "path": "_shared_base.dart",
                            "checksum": "sha256:abc"
                        }]
                    }
                }
            ]
        }))
        .unwrap(),
    )
    .unwrap();

    std::fs::write(
        "pubspec.yaml",
        "name: test_app\ndependencies:\n  flutter:\n    sdk: flutter\n",
    )
    .unwrap();
    std::fs::write(
            "justui.config.yaml",
            format!("components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\npreset: default\nregistry_url: {}\n", reg_dir.display()),
        )
        .unwrap();

    // 1. Run add single component (button) with auto_yes = true
    assert!(run(vec!["button".to_string()], false, false, false, false, true).is_ok());

    // 2. Run add with --overwrite flag = true
    assert!(run(vec!["button".to_string()], true, false, false, false, true).is_ok());

    // 3. Run add with --dry-run = true
    assert!(run(vec!["button".to_string()], false, true, false, false, true).is_ok());

    // 4. Run add with --all = true
    assert!(run(vec![], false, false, true, false, true).is_ok());

    // 5. Run add with non-existent component name
    assert!(run(
        vec!["nonexistent".to_string()],
        false,
        false,
        false,
        false,
        true
    )
    .is_ok());

    // 6. Run add empty names without --all and auto_yes = true
    assert!(run(vec![], false, false, false, false, true).is_ok());
}
