use std::collections::HashMap;

use justui_cli::config::JustUIConfig;
use justui_cli::registry::{RegistryComponent, RegistryFile, RegistryIndex};
use justui_cli::utils::diff_formatter;
use justui_cli::utils::import_rewriter;

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
        "my_app",
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
        "my_app",
    );
    assert!(result.contains("import 'package:my_app/core/just_ui_core.dart';"));
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
                files: HashMap::from([(
                    "default".to_string(),
                    vec![RegistryFile {
                        name: "just_button.dart".to_string(),
                        path: "components/button/just_button.dart".to_string(),
                        checksum: "sha256:aabbcc".to_string(),
                    }],
                )]),
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
                files: HashMap::from([(
                    "default".to_string(),
                    vec![RegistryFile {
                        name: "spacing.dart".to_string(),
                        path: "tokens/spacing.dart".to_string(),
                        checksum: "sha256:ddeeff".to_string(),
                    }],
                )]),
            },
        ],
    };

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
        "my_app",
    );

    assert!(
        result.contains("import '../../tokens/spacing.dart';"),
        "got: {}",
        result
    );
}

#[test]
fn test_zero_dep_package_import_rewriting() {
    let index = RegistryIndex {
        version: "1".to_string(),
        presets: vec!["default".to_string()],
        components: vec![],
    };
    let content = "import 'package:just_ui_tokens/just_ui_tokens.dart';\nimport 'package:just_ui_core/just_ui_core.dart';\n";
    let result = import_rewriter::rewrite(
        content,
        "components/button/just_button.dart",
        "button",
        &index,
        "lib/widgets",
        "lib/tokens",
        "lib/widgets/shared",
        "default",
        "my_cool_app",
    );
    assert!(result.contains("import 'package:my_cool_app/tokens/just_ui_tokens.dart';"));
    assert!(result.contains("import 'package:my_cool_app/core/just_ui_core.dart';"));
}

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
    let diff = diff_formatter::calculate_diff("line1\r\nline2\r\n", "line1\nline2\n");
    assert!(diff
        .iter()
        .all(|d| matches!(d.kind, diff_formatter::DiffKind::Unchanged)));
}

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
            .stderr(predicate::str::contains("No pubspec.yaml found"));
    }

    #[test]
    fn init_with_preset_flag_creates_neobrutalism_theme() {
        let dir = TempDir::new().unwrap();
        std::fs::write(dir.path().join("pubspec.yaml"), "name: test").unwrap();

        justui()
            .current_dir(dir.path())
            .args(["init", "--preset", "neo"])
            .write_stdin("\n\n\n\n")
            .assert()
            .success()
            .stderr(predicate::str::contains("Bootstrap theme created"));

        let theme = std::fs::read_to_string(dir.path().join("lib/core/theme/just_theme.dart")).unwrap();
        assert!(
            theme.contains("JustThemePreset.neobrutalism"),
            "theme file should contain neobrutalism preset, got: {}",
            theme
        );

        assert!(
            dir.path().join("lib/tokens/colors/color_palette.dart").exists(),
            "lib/tokens/colors/color_palette.dart should exist"
        );
        assert!(
            dir.path().join("lib/core/theme/theme_data.dart").exists(),
            "lib/core/theme/theme_data.dart should exist"
        );
        assert!(
            dir.path().join("lib/core/overlay/just_overlay_controller.dart").exists(),
            "lib/core/overlay/just_overlay_controller.dart should exist"
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
            .stderr(predicate::str::contains("already exists in this project"));
    }

    #[test]
    fn list_requires_reachable_registry() {
        let dir = TempDir::new().unwrap();
        std::fs::write(dir.path().join("justui.config.yaml"), "components_dir: lib/widgets\ntokens_dir: lib/tokens\nshared_dir: lib/widgets/shared\nregistry_url: /nonexistent/registry\n").unwrap();

        justui()
            .current_dir(dir.path())
            .args(["list"])
            .assert()
            .stderr(predicate::str::contains("Failed to list components"));
    }

    #[test]
    fn add_with_local_registry_downloads_files() {
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
            .args(["add", "button"])
            .assert()
            .success()
            .stderr(predicate::str::contains(
                "added successfully",
            ))
            .stderr(predicate::str::contains(
                "button",
            ))
            .stderr(predicate::str::contains("→  button"));

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
            .stderr(predicate::str::contains("Project not initialized"));
    }

    #[test]
    fn create_fails_without_init() {
        let dir = TempDir::new().unwrap();
        justui()
            .current_dir(dir.path())
            .args(["create", "my_widget"])
            .assert()
            .stderr(predicate::str::contains("Project not initialized"));
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
            .stderr(predicate::str::contains(
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

    #[test]
    fn syntax_highlighter_highlights_dart_code() {
        let code = "void main() {\n  print('hello');\n}";
        let highlighted = justui_cli::utils::syntax_highlighter::highlight_code(code, "dart");
        assert_eq!(highlighted.len(), 3);

        assert!(highlighted[0].contains("\x1b["));
        assert!(highlighted[1].contains("\x1b["));
    }

    #[test]
    fn preset_list_and_info_commands_work() {
        let dir = tempfile::TempDir::new().unwrap();
        let registry_dir = dir.path().join("mock_registry");
        std::fs::create_dir_all(registry_dir.join("components/button/default")).unwrap();

        std::fs::write(
            registry_dir.join("index.json"),
            serde_json::to_string(&serde_json::json!({
                "version": "0.1.0",
                "presets": ["default", "neobrutalism"],
                "components": [{
                    "name": "button",
                    "version": "0.1.0",
                    "description": "A button",
                    "category": "primitives",
                    "supportedPresets": ["default", "neobrutalism"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [{
                            "name": "just_button.dart",
                            "path": "components/button/default/just_button.dart",
                            "checksum": "sha256:aabbcc"
                        }],
                        "neobrutalism": [{
                            "name": "just_button.dart",
                            "path": "components/button/neobrutalism/just_button.dart",
                            "checksum": "sha256:ddeeff"
                        }]
                    }
                }]
            }))
            .unwrap(),
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
            "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\nregistry_url: {}\npreset: default\n",
            registry_dir.display()
        ),
    )
    .unwrap();

        justui()
            .current_dir(dir.path())
            .args(["preset", "--list"])
            .assert()
            .success()
            .stdout(predicates::str::contains("default (active)"))
            .stdout(predicates::str::contains("neobrutalism"));

        justui()
            .current_dir(dir.path())
            .args(["preset", "list"])
            .assert()
            .success()
            .stdout(predicates::str::contains("default (active)"))
            .stdout(predicates::str::contains("neobrutalism"));

        justui()
            .current_dir(dir.path())
            .args(["preset", "info", "default"])
            .assert()
            .success()
            .stderr(predicates::str::contains("Preset: default (active)"))
            .stdout(predicates::str::contains("Supported components"))
            .stdout(predicates::str::contains("button"));

        justui()
            .current_dir(dir.path())
            .args(["preset", "default"])
            .assert()
            .success()
            .stderr(predicates::str::contains("Preset: default (active)"))
            .stdout(predicates::str::contains("Supported components"))
            .stdout(predicates::str::contains("button"));
    }

    #[test]
    fn preset_apply_command_works() {
        let dir = tempfile::TempDir::new().unwrap();
        let registry_dir = dir.path().join("mock_registry");
        std::fs::create_dir_all(registry_dir.join("components/button/default")).unwrap();
        std::fs::create_dir_all(registry_dir.join("components/button/neobrutalism")).unwrap();

        let default_content = "default_button_code";
        let neobrutalism_content = "neobrutalism_button_code";

        let default_hash = {
            use sha2::{Digest, Sha256};
            let mut h = Sha256::new();
            h.update(default_content.as_bytes());
            hex::encode(h.finalize())
        };
        let neobrutalism_hash = {
            use sha2::{Digest, Sha256};
            let mut h = Sha256::new();
            h.update(neobrutalism_content.as_bytes());
            hex::encode(h.finalize())
        };

        std::fs::write(
            registry_dir.join("index.json"),
            serde_json::to_string(&serde_json::json!({
                "version": "0.1.0",
                "presets": ["default", "neobrutalism"],
                "components": [{
                    "name": "button",
                    "version": "0.1.0",
                    "description": "A button",
                    "category": "primitives",
                    "supportedPresets": ["default", "neobrutalism"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [{
                            "name": "just_button.dart",
                            "path": "components/button/default/just_button.dart",
                            "checksum": format!("sha256:{}", default_hash)
                        }],
                        "neobrutalism": [{
                            "name": "just_button.dart",
                            "path": "components/button/neobrutalism/just_button.dart",
                            "checksum": format!("sha256:{}", neobrutalism_hash)
                        }]
                    }
                }]
            }))
            .unwrap(),
        )
        .unwrap();

        std::fs::write(
            registry_dir.join("components/button/default/just_button.dart"),
            default_content,
        )
        .unwrap();

        std::fs::write(
            registry_dir.join("components/button/neobrutalism/just_button.dart"),
            neobrutalism_content,
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
            "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\nregistry_url: {}\npreset: default\n",
            registry_dir.display()
        ),
    )
    .unwrap();

        justui()
            .current_dir(dir.path())
            .args(["add", "button"])
            .assert()
            .success();

        let installed_file = dir.path().join("lib/ui/button/just_button.dart");
        assert!(installed_file.exists());
        let content = std::fs::read_to_string(&installed_file).unwrap();
        assert!(content.contains(default_content));

        justui()
            .current_dir(dir.path())
            .args(["preset", "apply", "neobrutalism", "--yes"])
            .assert()
            .success()
            .stderr(predicates::str::contains(
                "Preset \"neobrutalism\" applied successfully",
            ))
            .stderr(predicates::str::contains("Succeeded"));

        let config_content =
            std::fs::read_to_string(dir.path().join("justui.config.yaml")).unwrap();
        assert!(config_content.contains("preset: neobrutalism"));

        let content_after = std::fs::read_to_string(&installed_file).unwrap();
        assert!(content_after.contains(neobrutalism_content));
    }

    #[test]
    fn files_for_preset_aggregates_common_and_preset_files() {
        use std::collections::HashMap;
        use justui_cli::registry::{RegistryComponent, RegistryFile};

        let comp = RegistryComponent {
            name: "button".to_string(),
            version: "0.1.0".to_string(),
            description: "".to_string(),
            category: "primitive".to_string(),
            internal: false,
            supported_presets: vec!["default".to_string(), "neobrutalism".to_string()],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: HashMap::from([
                (
                    "common".to_string(),
                    vec![RegistryFile {
                        name: "just_button_style.dart".to_string(),
                        path: "components/button/just_button_style.dart".to_string(),
                        checksum: "sha256:111".to_string(),
                    }],
                ),
                (
                    "default".to_string(),
                    vec![RegistryFile {
                        name: "just_button.dart".to_string(),
                        path: "components/button/default/just_button.dart".to_string(),
                        checksum: "sha256:222".to_string(),
                    }],
                ),
            ]),
        };

        let files = comp.files_for_preset("default");
        assert_eq!(files.len(), 2);
        assert_eq!(files[0].name, "just_button_style.dart");
        assert_eq!(files[1].name, "just_button.dart");
    }

    #[test]
    fn info_search_view_and_list_commands_work() {
        let dir = tempfile::TempDir::new().unwrap();
        let registry_dir = dir.path().join("mock_registry");
        std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();
        std::fs::create_dir_all(registry_dir.join("components/input")).unwrap();

        std::fs::write(
            registry_dir.join("index.json"),
            serde_json::to_string(&serde_json::json!({
                "version": "0.1.0",
                "presets": ["default"],
                "components": [
                    {
                        "name": "button",
                        "version": "0.1.0",
                        "description": "Button component",
                        "category": "primitives",
                        "supportedPresets": ["default"],
                        "registryDependencies": [],
                        "pubDependencies": {},
                        "files": {
                            "default": [{
                                "name": "just_button.dart",
                                "path": "components/button/just_button.dart",
                                "checksum": "sha256:111"
                            }]
                        }
                    },
                    {
                        "name": "input",
                        "version": "0.1.0",
                        "description": "Text input component",
                        "category": "forms",
                        "supportedPresets": ["default"],
                        "registryDependencies": [],
                        "pubDependencies": {},
                        "files": {
                            "default": [{
                                "name": "just_input.dart",
                                "path": "components/input/just_input.dart",
                                "checksum": "sha256:222"
                            }]
                        }
                    }
                ]
            }))
            .unwrap(),
        )
        .unwrap();

        std::fs::write(registry_dir.join("components/button/just_button.dart"), "class JustButton {}").unwrap();
        std::fs::write(registry_dir.join("components/input/just_input.dart"), "class JustInput {}").unwrap();

        std::fs::write(dir.path().join("pubspec.yaml"), "name: test_app\n").unwrap();
        std::fs::write(
            dir.path().join("justui.config.yaml"),
            format!(
                "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\nregistry_url: {}\n",
                registry_dir.display()
            ),
        )
        .unwrap();

        // 1. Test `info`
        justui()
            .current_dir(dir.path())
            .args(["info", "button"])
            .assert()
            .success()
            .stderr(predicates::str::contains("button"))
            .stdout(predicates::str::contains("Button component"));

        justui()
            .current_dir(dir.path())
            .args(["info", "invalid_comp"])
            .assert()
            .failure()
            .stderr(predicates::str::contains("not found"));

        // 2. Test `search`
        justui()
            .current_dir(dir.path())
            .args(["search", "input"])
            .assert()
            .success()
            .stdout(predicates::str::contains("input"));

        justui()
            .current_dir(dir.path())
            .args(["search", "nonexistent_query_xyz"])
            .assert()
            .success()
            .stdout(predicates::str::contains("Tidak ditemukan"));

        // 3. Test `view`
        justui()
            .current_dir(dir.path())
            .args(["view", "button"])
            .assert()
            .success()
            .stdout(predicates::str::contains("class JustButton"));

        justui()
            .current_dir(dir.path())
            .args(["view", "button", "--raw"])
            .assert()
            .success()
            .stdout(predicates::str::contains("class JustButton"));

        // 4. Test `list`
        justui()
            .current_dir(dir.path())
            .args(["list", "--json"])
            .assert()
            .success()
            .stdout(predicates::str::contains("\"name\": \"button\""));

        justui()
            .current_dir(dir.path())
            .args(["list", "--category", "primitives"])
            .assert()
            .success()
            .stdout(predicates::str::contains("button"));
    }

    #[test]
    fn diff_and_update_commands_work() {
        let dir = tempfile::TempDir::new().unwrap();
        let registry_dir = dir.path().join("mock_registry");
        std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();

        let remote_content = "class JustButton { void render() {} }";
        let hash = {
            use sha2::{Digest, Sha256};
            let mut h = Sha256::new();
            h.update(remote_content.as_bytes());
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
                    "description": "Button",
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

        std::fs::write(registry_dir.join("components/button/just_button.dart"), remote_content).unwrap();

        std::fs::write(dir.path().join("pubspec.yaml"), "name: test_app\n").unwrap();
        std::fs::write(
            dir.path().join("justui.config.yaml"),
            format!(
                "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\nregistry_url: {}\n",
                registry_dir.display()
            ),
        )
        .unwrap();

        // Install button first
        justui().current_dir(dir.path()).args(["add", "button"]).assert().success();

        // 1. Diff on up-to-date component
        justui()
            .current_dir(dir.path())
            .args(["diff", "button"])
            .assert()
            .success();

        // 2. Modify local file
        let installed_file = dir.path().join("lib/ui/button/just_button.dart");
        std::fs::write(&installed_file, "// local change\nclass JustButton {}").unwrap();

        // Diff should show local modifications
        justui()
            .current_dir(dir.path())
            .args(["diff", "button"])
            .assert()
            .success();

        // Accept remote diff
        justui()
            .current_dir(dir.path())
            .args(["diff", "button", "--accept"])
            .assert()
            .success();

        // Update command when up to date
        justui()
            .current_dir(dir.path())
            .args(["update"])
            .assert()
            .success()
            .stdout(predicates::str::contains("Semua komponen sudah menggunakan versi terbaru"));

        // Test `upgrade --check`
        justui()
            .current_dir(dir.path())
            .args(["upgrade", "--check"])
            .assert()
            .success();
    }

    #[test]
    fn add_all_overwrite_dependencies_and_internal_components() {
        let dir = tempfile::TempDir::new().unwrap();
        let registry_dir = dir.path().join("mock_registry");
        std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();
        std::fs::create_dir_all(registry_dir.join("components/shared")).unwrap();

        let button_content = "import '../shared/just_pressable.dart';\nclass JustButton {}";
        let pressable_content = "class JustPressable {}";

        let button_hash = {
            use sha2::{Digest, Sha256};
            let mut h = Sha256::new();
            h.update(button_content.as_bytes());
            hex::encode(h.finalize())
        };
        let pressable_hash = {
            use sha2::{Digest, Sha256};
            let mut h = Sha256::new();
            h.update(pressable_content.as_bytes());
            hex::encode(h.finalize())
        };

        std::fs::write(
            registry_dir.join("index.json"),
            serde_json::to_string(&serde_json::json!({
                "version": "0.1.0",
                "presets": ["default"],
                "components": [
                    {
                        "name": "button",
                        "version": "0.1.0",
                        "description": "Button",
                        "category": "primitives",
                        "supportedPresets": ["default"],
                        "registryDependencies": ["pressable"],
                        "pubDependencies": { "flutter_svg": "^2.0.0" },
                        "files": {
                            "default": [{
                                "name": "just_button.dart",
                                "path": "components/button/just_button.dart",
                                "checksum": format!("sha256:{}", button_hash)
                            }]
                        }
                    },
                    {
                        "name": "pressable",
                        "version": "0.1.0",
                        "description": "Pressable",
                        "category": "shared",
                        "internal": true,
                        "supportedPresets": ["default"],
                        "registryDependencies": [],
                        "pubDependencies": {},
                        "files": {
                            "default": [{
                                "name": "_shared_pressable.dart",
                                "path": "components/shared/_shared_pressable.dart",
                                "checksum": format!("sha256:{}", pressable_hash)
                            }]
                        }
                    }
                ]
            }))
            .unwrap(),
        )
        .unwrap();

        std::fs::write(registry_dir.join("components/button/just_button.dart"), button_content).unwrap();
        std::fs::write(registry_dir.join("components/shared/_shared_pressable.dart"), pressable_content).unwrap();

        std::fs::write(
            dir.path().join("pubspec.yaml"),
            "name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n",
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

        // Add all components with --all and --yes
        justui()
            .current_dir(dir.path())
            .args(["add", "--all", "--yes"])
            .assert()
            .success()
            .stderr(predicates::str::contains("komponen berhasil ditambahkan"));

        // Verify button and shared pressable were written
        let button_file = dir.path().join("lib/ui/button/just_button.dart");
        let pressable_file = dir.path().join("lib/ui/shared/just_pressable.dart");
        assert!(button_file.exists());
        assert!(pressable_file.exists());

        // Test `add --all --overwrite --yes`
        justui()
            .current_dir(dir.path())
            .args(["add", "--all", "--overwrite", "--yes"])
            .assert()
            .success();

        // Verify pubspec.yaml updated with flutter_svg
        let pubspec = std::fs::read_to_string(dir.path().join("pubspec.yaml")).unwrap();
        assert!(pubspec.contains("flutter_svg"));

        // Test update command when a local component is outdated
        std::fs::write(&button_file, "// outdated local copy\nclass JustButton {}").unwrap();

        // `justui list` should report button as modified/outdated
        justui()
            .current_dir(dir.path())
            .args(["list"])
            .assert()
            .success();

        // `justui update --yes` should update the outdated component
        justui()
            .current_dir(dir.path())
            .args(["update", "--yes"])
            .assert()
            .success()
            .stderr(predicates::str::contains("Diperbarui"));
    }

    #[test]
    fn init_command_with_custom_flags() {
        let dir = tempfile::TempDir::new().unwrap();
        std::fs::write(dir.path().join("pubspec.yaml"), "name: custom_app").unwrap();

        justui()
            .current_dir(dir.path())
            .args(["init", "--yes", "--components-dir", "lib/components", "--tokens-dir", "lib/design_tokens"])
            .assert()
            .success();

        let config = std::fs::read_to_string(dir.path().join("justui.config.yaml")).unwrap();
        assert!(config.contains("components_dir: lib/components"));
        assert!(config.contains("tokens_dir: lib/design_tokens"));
    }

    #[test]
    fn diff_verbose_preset_info_and_create_dry_run() {
        let dir = tempfile::TempDir::new().unwrap();
        let registry_dir = dir.path().join("mock_registry");
        std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();

        let button_content = "class JustButton {}";
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
                            "checksum": format!("sha256:{}", hash)
                        }]
                    }
                }]
            }))
            .unwrap(),
        )
        .unwrap();

        std::fs::write(registry_dir.join("components/button/just_button.dart"), button_content).unwrap();

        std::fs::write(dir.path().join("pubspec.yaml"), "name: my_app").unwrap();
        std::fs::write(
            dir.path().join("justui.config.yaml"),
            format!(
                "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\nregistry_url: {}\npreset: default\n",
                registry_dir.display()
            ),
        )
        .unwrap();

        // 1. Install button
        justui().current_dir(dir.path()).args(["add", "button"]).assert().success();

        // 2. Modify local file and run `justui diff --verbose`
        let installed_file = dir.path().join("lib/ui/button/just_button.dart");
        std::fs::write(&installed_file, "// modified\nclass JustButton {}").unwrap();

        justui()
            .current_dir(dir.path())
            .args(["diff", "--verbose"])
            .assert()
            .success();

        // 3. Test `preset info neobrutalism`
        justui()
            .current_dir(dir.path())
            .args(["preset", "info", "neobrutalism"])
            .assert()
            .success();

        // 4. Test `create --dry-run` and custom category
        justui()
            .current_dir(dir.path())
            .args(["create", "my_custom_widget", "--category", "primitives", "--dry-run"])
            .assert()
            .success();
    }
}



