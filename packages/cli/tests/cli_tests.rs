/// Integration tests for the JustUI CLI — port of `just_ui_cli_test.dart`.
///
/// These tests use `tempfile` for isolated filesystem environments and
/// `assert_cmd` to run the compiled binary.
use std::collections::HashMap;

use justui_cli::config::JustUIConfig;
use justui_cli::registry::{RegistryComponent, RegistryFile, RegistryIndex};
use justui_cli::utils::diff_formatter;
use justui_cli::utils::import_rewriter;

// ─── JustUIConfig Tests ────────────────────────────────────────────────────────

#[test]
fn config_parses_from_yaml_correctly() {
    let yaml = r#"
components_dir: custom/ui
tokens_dir: custom/tokens
registry_url: http://example.com/reg
"#;
    let config = JustUIConfig::from_yaml(yaml);
    assert_eq!(config.components_dir, "custom/ui");
    assert_eq!(config.tokens_dir, "custom/tokens");
    assert_eq!(config.registry_url, "http://example.com/reg");
}

#[test]
fn config_falls_back_to_defaults_on_invalid_yaml() {
    let config = JustUIConfig::from_yaml("invalid yaml map: [[[");
    assert_eq!(config.components_dir, "lib/widgets");
    assert_eq!(config.tokens_dir, "lib/tokens");
    assert_eq!(config.shared_dir, "lib/widgets/shared");
}

#[test]
fn config_parses_shared_dir_from_yaml() {
    let yaml = r#"
components_dir: lib/ui
tokens_dir: lib/tokens
shared_dir: lib/ui/common
registry_url: http://example.com/reg
"#;
    let config = JustUIConfig::from_yaml(yaml);
    assert_eq!(config.shared_dir, "lib/ui/common");
}

#[test]
fn config_falls_back_shared_dir_to_components_plus_shared() {
    let yaml = r#"
components_dir: lib/custom
tokens_dir: lib/tokens
registry_url: http://example.com/reg
"#;
    let config = JustUIConfig::from_yaml(yaml);
    assert_eq!(config.shared_dir, "lib/custom/shared");
}

#[test]
fn config_to_yaml_string_contains_comment_block() {
    let config = JustUIConfig::default();
    let yaml = config.to_yaml_string();
    assert!(yaml.contains("# JustUI Scaffolding Configuration"));
    assert!(yaml.contains("# Version 1"));
    assert!(yaml.contains("components_dir:"));
    assert!(yaml.contains("tokens_dir:"));
    assert!(yaml.contains("shared_dir:"));
    assert!(yaml.contains("registry_url:"));
}

// ─── ImportRewriter Tests ─────────────────────────────────────────────────────

#[test]
fn normalize_shared_file_name_strips_prefix() {
    assert_eq!(
        import_rewriter::normalize_shared_file_name("_shared_pressable.dart"),
        "just_pressable.dart"
    );
    assert_eq!(
        import_rewriter::normalize_shared_file_name("just_button.dart"),
        "just_button.dart"
    );
    assert_eq!(
        import_rewriter::normalize_shared_file_name("_shared_base.dart"),
        "just_base.dart"
    );
}

#[test]
fn parse_metadata_extracts_hashes() {
    let hash_a = "a".repeat(64);
    let hash_b = "b".repeat(64);
    let content = format!(
        "// justui-meta: registry={} local={}\nsome dart code\n",
        hash_a, hash_b
    );
    let meta = import_rewriter::parse_metadata(&content).unwrap();
    assert_eq!(meta.registry_hash, hash_a);
    assert_eq!(meta.local_hash, hash_b);
}

#[test]
fn parse_metadata_returns_none_when_absent() {
    assert!(import_rewriter::parse_metadata("just dart code").is_none());
}

#[test]
fn strip_metadata_removes_header() {
    let hash_a = "a".repeat(64);
    let hash_b = "b".repeat(64);
    let content = format!(
        "// justui-meta: registry={} local={}\nsome dart code\n",
        hash_a, hash_b
    );
    let stripped = import_rewriter::strip_metadata(&content);
    assert_eq!(stripped, "some dart code\n");
}

#[test]
fn inject_metadata_prepends_header() {
    let hash_r = "a".repeat(64);
    let hash_l = "b".repeat(64);
    let result = import_rewriter::inject_metadata("some code\n", &hash_r, &hash_l);
    assert!(result.starts_with("// justui-meta: registry="));
    assert!(result.contains(&format!("registry={} local={}", hash_r, hash_l)));
    assert!(result.ends_with("some code\n"));
}

#[test]
fn inject_metadata_strips_existing_before_prepend() {
    let hash_r1 = "a".repeat(64);
    let hash_l1 = "b".repeat(64);
    let hash_r2 = "c".repeat(64);
    let hash_l2 = "d".repeat(64);
    let with_meta = import_rewriter::inject_metadata("code\n", &hash_r1, &hash_l1);
    let re_injected = import_rewriter::inject_metadata(&with_meta, &hash_r2, &hash_l2);
    // Only one meta line
    assert_eq!(
        re_injected
            .lines()
            .filter(|l| l.starts_with("// justui-meta:"))
            .count(),
        1
    );
    assert!(re_injected.contains(&hash_r2));
}

#[test]
fn rewrite_skips_package_and_dart_imports() {
    let index = RegistryIndex {
        version: "1".to_string(),
        presets: vec!["default".to_string()],
        components: vec![],
    };
    let content = "import 'package:flutter/widgets.dart';\nimport 'dart:io';\n";
    let result = import_rewriter::rewrite(
        content,
        "components/button/just_button.dart",
        "button",
        &index,
        "lib/widgets",
        "lib/tokens",
        "lib/widgets/shared",
        "default",
    );
    assert_eq!(result, content);
}

#[test]
fn rewrite_converts_theme_import_to_package() {
    let index = RegistryIndex {
        version: "1".to_string(),
        presets: vec!["default".to_string()],
        components: vec![],
    };
    let content = "import '../theme/theme_provider.dart';\n";
    let result = import_rewriter::rewrite(
        content,
        "components/button/just_button.dart",
        "button",
        &index,
        "lib/widgets",
        "lib/tokens",
        "lib/widgets/shared",
        "default",
    );
    assert!(result.contains("import 'package:just_ui_core/just_ui_core.dart';"));
}

#[test]
fn rewrite_computes_relative_path_for_component_import() {
    let index = RegistryIndex {
        version: "1".to_string(),
        presets: vec!["default".to_string()],
        components: vec![
            RegistryComponent {
                name: "button".to_string(),
                version: "0.1.0".to_string(),
                description: "".to_string(),
                category: "primitives".to_string(),
                internal: false,
                supported_presets: vec!["default".to_string()],
                registry_dependencies: vec![],
                pub_dependencies: HashMap::new(),
                files: HashMap::from([
                    ("default".to_string(), vec![RegistryFile {
                        name: "just_button.dart".to_string(),
                        path: "components/button/just_button.dart".to_string(),
                        checksum: "sha256:aabbcc".to_string(),
                    }])
                ]),
            },
            RegistryComponent {
                name: "spacing".to_string(),
                version: "0.1.0".to_string(),
                description: "".to_string(),
                category: "tokens".to_string(),
                internal: false,
                supported_presets: vec!["default".to_string()],
                registry_dependencies: vec![],
                pub_dependencies: HashMap::new(),
                files: HashMap::from([
                    ("default".to_string(), vec![RegistryFile {
                        name: "spacing.dart".to_string(),
                        path: "tokens/spacing.dart".to_string(),
                        checksum: "sha256:ddeeff".to_string(),
                    }])
                ]),
            },
        ],
    };
    // button imports spacing
    let content = "import '../../tokens/spacing.dart';\n";
    let result = import_rewriter::rewrite(
        content,
        "components/button/just_button.dart",
        "button",
        &index,
        "lib/widgets",
        "lib/tokens",
        "lib/widgets/shared",
        "default",
    );
    // current file: lib/widgets/button/just_button.dart
    // target file: lib/tokens/spacing.dart
    // relative from lib/widgets/button → ../../tokens/spacing.dart
    assert!(
        result.contains("import '../../tokens/spacing.dart';"),
        "got: {}",
        result
    );
}

// ─── DiffFormatter Tests ──────────────────────────────────────────────────────

#[test]
fn calculate_diff_detects_unchanged() {
    let diff = diff_formatter::calculate_diff("line1\nline2\n", "line1\nline2\n");
    assert!(diff
        .iter()
        .all(|d| matches!(d.kind, diff_formatter::DiffKind::Unchanged)));
}

#[test]
fn calculate_diff_detects_additions() {
    let diff = diff_formatter::calculate_diff("", "added\n");
    assert!(diff
        .iter()
        .any(|d| matches!(d.kind, diff_formatter::DiffKind::Added)));
}

#[test]
fn calculate_diff_detects_removals() {
    let diff = diff_formatter::calculate_diff("removed\n", "");
    assert!(diff
        .iter()
        .any(|d| matches!(d.kind, diff_formatter::DiffKind::Removed)));
}

#[test]
fn calculate_diff_normalizes_crlf() {
    // CRLF in local should be treated as equal to LF in remote
    let diff = diff_formatter::calculate_diff("line1\r\nline2\r\n", "line1\nline2\n");
    assert!(diff
        .iter()
        .all(|d| matches!(d.kind, diff_formatter::DiffKind::Unchanged)));
}

// ─── RegistryIndex::internal field Tests ──────────────────────────────────────

#[test]
fn registry_component_deserializes_internal_field() {
    let json = r#"{
        "version": "1",
        "components": [
            {
                "name": "button",
                "version": "0.1.0",
                "category": "primitives"
            },
            {
                "name": "pressable",
                "version": "0.1.0",
                "category": "shared",
                "internal": true
            }
        ]
    }"#;
    let index: RegistryIndex = serde_json::from_str(json).unwrap();
    assert!(!index.components[0].internal);
    assert!(index.components[1].internal);
}

// ─── CLI integration tests (using assert_cmd) ─────────────────────────────────

#[cfg(test)]
mod cli_integration {
    use assert_cmd::Command;
    use predicates::prelude::*;
    use tempfile::TempDir;

    fn justui() -> Command {
        Command::cargo_bin("justui").unwrap()
    }

    #[test]
    fn init_fails_without_pubspec() {
        let dir = TempDir::new().unwrap();
        justui()
            .current_dir(dir.path())
            .args(["init"])
            .assert()
            .stdout(predicate::str::contains("No pubspec.yaml found"));
    }

    #[test]
    fn init_with_preset_flag_creates_neobrutalism_theme() {
        let dir = TempDir::new().unwrap();
        std::fs::write(dir.path().join("pubspec.yaml"), "name: test").unwrap();

        // Provide stdin answers: compDir selection (empty=default), tokens (empty), shared (empty), brand color (empty)
        justui()
            .current_dir(dir.path())
            .args(["init", "--preset", "neo"])
            .write_stdin("\n\n\n\n")
            .assert()
            .success()
            .stdout(predicate::str::contains("Bootstrap theme created"));

        let theme = std::fs::read_to_string(dir.path().join("lib/theme/just_theme.dart")).unwrap();
        assert!(
            theme.contains("JustThemePreset.neobrutalism"),
            "theme file should contain neobrutalism preset, got: {}",
            theme
        );
    }

    #[test]
    fn init_already_initialized_warns() {
        let dir = TempDir::new().unwrap();
        std::fs::write(dir.path().join("pubspec.yaml"), "name: test").unwrap();
        std::fs::write(dir.path().join("justui.config.yaml"), "components_dir: lib/widgets\ntokens_dir: lib/tokens\nshared_dir: lib/widgets/shared\nregistry_url: https://example.com\n").unwrap();

        justui()
            .current_dir(dir.path())
            .args(["init"])
            .assert()
            .stdout(predicate::str::contains("already exists in this project"));
    }

    #[test]
    fn list_requires_reachable_registry() {
        // A local registry path that doesn't exist should error out gracefully
        let dir = TempDir::new().unwrap();
        std::fs::write(dir.path().join("justui.config.yaml"), "components_dir: lib/widgets\ntokens_dir: lib/tokens\nshared_dir: lib/widgets/shared\nregistry_url: /nonexistent/registry\n").unwrap();

        justui()
            .current_dir(dir.path())
            .args(["list"])
            .assert()
            .stdout(predicate::str::contains("Failed to list components"));
    }

    #[test]
    fn add_with_local_registry_downloads_files() {
        let dir = TempDir::new().unwrap();
        let registry_dir = dir.path().join("mock_registry");
        std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();

        // Write button component files
        let button_content = "button_code";
        let hash = {
            use sha2::{Digest, Sha256};
            let mut h = Sha256::new();
            h.update(button_content.as_bytes());
            hex::encode(h.finalize())
        };

        std::fs::write(
            registry_dir.join("index.json"),
            serde_json::to_string(&serde_json::json!({
                "version": "0.1.0",
                "presets": ["default"],
                "components": [{
                    "name": "button",
                    "version": "0.1.0",
                    "description": "A button",
                    "category": "primitives",
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [{
                            "name": "just_button.dart",
                            "path": "components/button/just_button.dart",
                            "checksum": format!("sha256:{}", hash)
                        }]
                    }
                }]
            }))
            .unwrap(),
        )
        .unwrap();
        std::fs::write(
            registry_dir.join("components/button/just_button.dart"),
            button_content,
        )
        .unwrap();

        std::fs::write(
            dir.path().join("pubspec.yaml"),
            "name: test\ndependencies:\n  flutter:\n    sdk: flutter\n",
        )
        .unwrap();
        std::fs::write(
            dir.path().join("justui.config.yaml"),
            format!(
                "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\nregistry_url: {}\n",
                registry_dir.display()
            ),
        )
        .unwrap();

        justui()
            .current_dir(dir.path())
            .args(["add", "button"])
            .assert()
            .success()
            .stdout(predicate::str::contains(
                "Component \"button\" added successfully.",
            ))
            .stdout(predicate::str::contains(
                "1 komponen berhasil ditambahkan",
            ))
            .stdout(predicate::str::contains(
                "→  button",
            ));

        let written = dir.path().join("lib/ui/button/just_button.dart");
        assert!(written.exists(), "button file should have been written");
        let content = std::fs::read_to_string(&written).unwrap();
        let stripped = justui_cli::utils::import_rewriter::strip_metadata(&content);
        assert_eq!(stripped.trim(), button_content);
    }

    #[test]
    fn add_button_dry_run_does_not_show_summary() {
        let dir = TempDir::new().unwrap();
        let registry_dir = dir.path().join("mock_registry");
        std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();

        let button_content = "button_code";
        let hash = {
            use sha2::{Digest, Sha256};
            let mut h = Sha256::new();
            h.update(button_content.as_bytes());
            hex::encode(h.finalize())
        };

        std::fs::write(
            registry_dir.join("index.json"),
            serde_json::to_string(&serde_json::json!({
                "version": "0.1.0",
                "presets": ["default"],
                "components": [{
                    "name": "button",
                    "version": "0.1.0",
                    "description": "A button",
                    "category": "primitives",
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [{
                            "name": "just_button.dart",
                            "path": "components/button/just_button.dart",
                            "checksum": format!("sha256:{}", hash)
                        }]
                    }
                }]
            }))
            .unwrap(),
        )
        .unwrap();
        std::fs::write(
            registry_dir.join("components/button/just_button.dart"),
            button_content,
        )
        .unwrap();

        std::fs::write(
            dir.path().join("pubspec.yaml"),
            "name: test\ndependencies:\n  flutter:\n    sdk: flutter\n",
        )
        .unwrap();
        std::fs::write(
            dir.path().join("justui.config.yaml"),
            format!(
                "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\nregistry_url: {}\n",
                registry_dir.display()
            ),
        )
        .unwrap();

        justui()
            .current_dir(dir.path())
            .args(["add", "button", "--dry-run"])
            .assert()
            .success()
            .stdout(predicate::str::contains("1 komponen berhasil ditambahkan").not());
    }

    #[test]
    fn diff_fails_without_init() {
        let dir = TempDir::new().unwrap();
        justui()
            .current_dir(dir.path())
            .args(["diff", "button"])
            .assert()
            .stdout(predicate::str::contains("Project not initialized"));
    }

    #[test]
    fn create_fails_without_init() {
        let dir = TempDir::new().unwrap();
        justui()
            .current_dir(dir.path())
            .args(["create", "my_widget"])
            .assert()
            .stdout(predicate::str::contains("Project not initialized"));
    }

    #[test]
    fn create_scaffolds_four_files() {
        let dir = TempDir::new().unwrap();
        std::fs::write(dir.path().join("pubspec.yaml"), "name: test").unwrap();
        std::fs::write(
            dir.path().join("justui.config.yaml"),
            "components_dir: lib/widgets\ntokens_dir: lib/tokens\nshared_dir: lib/widgets/shared\nregistry_url: https://example.com\n",
        )
        .unwrap();

        justui()
            .current_dir(dir.path())
            .args(["create", "my_card"])
            .assert()
            .stdout(predicate::str::contains(
                "Scaffolded custom component \"MyCard\" successfully.",
            ));

        for file in &[
            "my_card_style.dart",
            "my_card_variants.dart",
            "my_card_theme.dart",
            "my_card.dart",
        ] {
            assert!(
                dir.path()
                    .join(format!("lib/widgets/my_card/{}", file))
                    .exists(),
                "{} not found",
                file
            );
        }
    }
}
