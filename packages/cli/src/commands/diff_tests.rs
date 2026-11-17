use super::*;

#[test]
fn test_apply_file_change_writes_dart_format_clean_output() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let target_file = temp_dir.path().join("just_messy.dart");

    // Deliberately unformatted, as `import_rewriter::rewrite` output
    // would be if the registry source itself isn't formatter-clean.
    let messy = "class Messy {\n  final int a;\n\n\n  Messy(this.a,this.a);\n}\n";

    let fs_status = DiffFileStatus {
        file: crate::registry::RegistryFile {
            name: "just_messy.dart".to_string(),
            path: "components/messy/just_messy.dart".to_string(),
            checksum: "sha256:irrelevant".to_string(),
        },
        status_type: DiffStatusType::UpdateAvailable,
        local_content: String::new(),
        target_path: target_file.to_string_lossy().to_string(),
        expected_hash: "deadbeef".repeat(8),
    };

    let dummy_index = crate::registry::RegistryIndex {
        version: "0.1.0".to_string(),
        presets: vec![],
        components: vec![],
    };

    assert!(apply_file_change(&fs_status, messy, "messy", &dummy_index).is_ok());

    let format_check = std::process::Command::new("dart")
        .arg("format")
        .arg("--output=none")
        .arg("--set-exit-if-changed")
        .arg(&target_file)
        .status();
    if let Ok(status) = format_check {
        assert!(
            status.success(),
            "file written by apply_file_change must already be dart-format-clean"
        );
    }

    let raw = std::fs::read_to_string(&target_file).unwrap();
    let content = raw.replace("\r\n", "\n");
    let meta = import_rewriter::parse_metadata(&content)
        .expect("written file must carry a justui-meta header");
    let clean = import_rewriter::strip_metadata(&content);
    assert_eq!(meta.local_hash, sha256_hex(clean.as_bytes()));
}

#[test]
fn test_diff_helpers_and_uninitialized() {
    let _lock = crate::utils::lock_test_mutex();
    let local = "line 1\nline 2 local\nline 3 local";
    let remote = "line 1\nline 2 remote\nline 4 remote";
    print_line_diff("just_button.dart", local, remote);

    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());

    // Uninitialized project returns Err
    assert!(run(Some("button".to_string()), false, false, true).is_err());

    // Test apply_file_change
    let target_file = temp_dir.path().join("lib/ui/just_button.dart");
    let fs_status = DiffFileStatus {
        file: crate::registry::RegistryFile {
            name: "just_button.dart".to_string(),
            path: "components/button/just_button.dart".to_string(),
            checksum: "sha256:hash1".to_string(),
        },
        status_type: DiffStatusType::LocallyModified,
        local_content: "class Old {}".to_string(),
        target_path: target_file.to_string_lossy().to_string(),
        expected_hash: "hash1".to_string(),
    };

    let dummy_index = crate::registry::RegistryIndex {
        version: "0.1.0".to_string(),
        presets: vec![],
        components: vec![],
    };

    assert!(apply_file_change(&fs_status, "class New {}", "button", &dummy_index).is_ok());
    assert!(target_file.exists());

    // Test show_all_diffs
    let mut map = std::collections::HashMap::new();
    map.insert(0, "class New {}".to_string());
    show_all_diffs(&[fs_status], &[0], &map, 2);

    // Test run with initialized project and mock local registry
    let registry_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();
    let button_code = "class JustButton {}";
    let button_hash = sha256_hex(button_code.as_bytes());

    std::fs::write(
        registry_dir.join("index.json"),
        serde_json::to_string(&serde_json::json!({
            "version": "0.1.0",
            "presets": ["default"],
            "components": [{
                "name": "button",
                "version": "0.1.0",
                "description": "Button",
                "category": "primitives",
                "supportedPresets": ["default"],
                "registryDependencies": [],
                "pubDependencies": {},
                "files": {
                    "default": [{
                        "name": "just_button.dart",
                        "path": "components/button/just_button.dart",
                        "checksum": format!("sha256:{}", button_hash)
                    }]
                }
            }]
        }))
        .unwrap(),
    )
    .unwrap();

    std::fs::write(
        registry_dir.join("components/button/just_button.dart"),
        button_code,
    )
    .unwrap();
    std::fs::write("pubspec.yaml", "name: test_app").unwrap();
    std::fs::write(
        "justui.config.yaml",
        format!("components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\npreset: default\nregistry_url: {}\n", registry_dir.display()),
    )
    .unwrap();

    assert!(run(Some("button".to_string()), true, false, true).is_ok());
    assert!(run(Some("button".to_string()), false, false, true).is_ok());

    // Test run with modified local component and auto_yes
    let local_comp_file = temp_dir.path().join("lib/ui/just_button.dart");
    std::fs::create_dir_all(local_comp_file.parent().unwrap()).unwrap();
    std::fs::write(&local_comp_file, "class ModifiedButton {}").unwrap();

    assert!(run(Some("button".to_string()), true, false, true).is_ok());
    assert!(run(Some("button".to_string()), false, false, true).is_ok());

    // Test missing component in registry
    assert!(run(Some("nonexistent_comp".to_string()), false, false, true).is_err());

    // Test run(None, ...) -> diff all components
    assert!(run(None, false, false, true).is_ok());
    assert!(run(None, true, false, true).is_ok());

    // Test DiffStatusType::Missing in show_all_diffs
    let fs_missing = DiffFileStatus {
        file: crate::registry::RegistryFile {
            name: "missing.dart".to_string(),
            path: "components/button/missing.dart".to_string(),
            checksum: "sha256:hash2".to_string(),
        },
        status_type: DiffStatusType::Missing,
        local_content: String::new(),
        target_path: temp_dir
            .path()
            .join("lib/ui/missing.dart")
            .to_string_lossy()
            .to_string(),
        expected_hash: "hash2".to_string(),
    };
    show_all_diffs(&[fs_missing], &[0], &std::collections::HashMap::new(), 3);

    // Test metadata with UpdateAvailable and Conflict
    let old_reg_hash = "old_reg_hash_123";
    let content_unmodified = "class Button {}";
    let content_modified = "class ButtonModified {}";
    let local_hash_unmodified = sha256_hex(content_unmodified.as_bytes());

    // UpdateAvailable metadata
    let meta_update =
        import_rewriter::inject_metadata(content_unmodified, old_reg_hash, &local_hash_unmodified);
    std::fs::write(&local_comp_file, meta_update).unwrap();
    assert!(run(Some("button".to_string()), false, false, true).is_ok());

    // Conflict metadata
    let meta_conflict =
        import_rewriter::inject_metadata(content_modified, old_reg_hash, &local_hash_unmodified);
    std::fs::write(&local_comp_file, meta_conflict).unwrap();
    assert!(run(Some("button".to_string()), false, false, true).is_ok());
}

#[test]
fn test_diff_adapts_material_import_to_project() {
    let _lock = crate::utils::lock_test_mutex();
    let _trust = crate::utils::trust_store::TestTrustGuard::new();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());

    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(reg_dir.join("components/button")).unwrap();

    let reg_src = "import 'package:material_ui/material_ui.dart' show ThemeExtension;\nclass JustButtonTheme {}\n";
    let reg_hash = sha256_hex(reg_src.as_bytes());
    std::fs::write(
        reg_dir.join("components/button/just_button_theme.dart"),
        reg_src,
    )
    .unwrap();
    let index_json = serde_json::json!({
        "version": "1.0.0",
        "components": [{
            "name": "button",
            "version": "1.0.0",
            "files": {
                "default": [{
                    "name": "just_button_theme.dart",
                    "path": "components/button/just_button_theme.dart",
                    "checksum": format!("sha256:{reg_hash}")
                }]
            }
        }]
    });
    std::fs::write(
        reg_dir.join("index.json"),
        serde_json::to_string(&index_json).unwrap(),
    )
    .unwrap();

    let comp_dir = temp_dir.path().join("lib/ui/button");
    std::fs::create_dir_all(&comp_dir).unwrap();
    let local_rewritten =
        "import 'package:flutter/material.dart' show ThemeExtension;\nclass JustButtonTheme {}\n";
    let local_hash = sha256_hex(local_rewritten.as_bytes());
    std::fs::write(
        comp_dir.join("just_button_theme.dart"),
        import_rewriter::inject_metadata(local_rewritten, "old_reg_hash", &local_hash),
    )
    .unwrap();

    // Flutter 3.50 without material_ui dependency: diff applies package:flutter/material.dart
    std::fs::write(
        "pubspec.yaml",
        "name: test_app\nenvironment:\n  flutter: '>=3.50.0'\ndependencies:\n  flutter:\n    sdk: flutter\n",
    )
    .unwrap();
    std::fs::write(
        JustUIConfig::CONFIG_FILE_NAME,
        format!(
            "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\ndart_target: standard\nregistry_url: {}\n",
            reg_dir.display()
        ),
    )
    .unwrap();

    assert!(run(Some("button".to_string()), false, false, true).is_ok());
    let updated = std::fs::read_to_string(comp_dir.join("just_button_theme.dart")).unwrap();
    assert!(updated.contains("import 'package:flutter/material.dart' show ThemeExtension;"));
    assert!(!updated.contains("import 'package:material_ui/material_ui.dart'"));
}
