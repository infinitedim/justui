use anyhow::Result;
use std::io::{self, Write};

use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::logger;

pub fn run(
    component: String,
    file_filter: Option<String>,
    _raw: bool,
    auto_yes: bool,
) -> Result<()> {
    let (registry_url, preset) =
        if let Ok(content) = std::fs::read_to_string(JustUIConfig::CONFIG_FILE_NAME) {
            let config = JustUIConfig::from_yaml(&content);
            (config.registry_url, config.preset)
        } else {
            (
                JustUIConfig::DEFAULT_REGISTRY_URL.to_string(),
                "default".to_string(),
            )
        };

    let client = RegistryClient::new(registry_url);
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!("Failed to fetch registry: {}", e));
            return Ok(());
        }
    };

    let comp = match index.components.iter().find(|c| c.name == component) {
        Some(c) => c,
        None => {
            logger::stdout(&format!(
                "Component \"{}\" not found in registry.",
                component
            ));

            let query_lc = component.to_lowercase();
            let suggestions: Vec<&str> = index
                .components
                .iter()
                .filter(|c| c.name.to_lowercase().contains(&query_lc))
                .map(|c| c.name.as_str())
                .collect();

            if !suggestions.is_empty() {
                logger::stdout("Did you mean one of these?");
                for s in &suggestions {
                    logger::stdout(&format!("  - {}", s));
                }
            }

            return Ok(());
        }
    };

    let name_ver = format!("  {} (v{})  ", comp.name, comp.version);
    let desc_line = format!("  {}  ", comp.description);
    let inner_width = name_ver.len().max(desc_line.len()).max(44);

    let top_border = format!("╔{}╗", "═".repeat(inner_width));
    let bot_border = format!("╚{}╝", "═".repeat(inner_width));

    let name_ver_padded = format!("║{:<width$}║", name_ver, width = inner_width);
    let desc_padded = format!("║{:<width$}║", desc_line, width = inner_width);

    logger::stdout(&top_border);
    logger::stdout(&name_ver_padded);
    logger::stdout(&desc_padded);
    logger::stdout(&bot_border);

    let reg_deps = if comp.registry_dependencies.is_empty() {
        "(none)".to_string()
    } else {
        comp.registry_dependencies.join(", ")
    };

    let pub_deps_str = if comp.pub_dependencies.is_empty() {
        "(none)".to_string()
    } else {
        comp.pub_dependencies
            .iter()
            .map(|(k, v)| format!("{}: {}", k, v))
            .collect::<Vec<_>>()
            .join(", ")
    };

    logger::stdout(&format!("Category      : {}", comp.category));
    logger::stdout(&format!("Dependencies  : {}", reg_deps));
    logger::stdout(&format!("Pub deps      : {}", pub_deps_str));
    let preset_files = comp.files_for_preset(&preset);
    logger::stdout(&format!("File count    : {} file(s)", preset_files.len()));
    logger::stdout("");

    let files_to_show: Vec<_> = if let Some(ref name_filter) = file_filter {
        let found = preset_files.into_iter().find(|f| &f.name == name_filter);
        match found {
            Some(f) => vec![f],
            None => {
                logger::error(&format!(
                    "File \"{}\" not found in component \"{}\".",
                    name_filter, comp.name
                ));
                return Ok(());
            }
        }
    } else {
        preset_files
    };

    let total_files = files_to_show.len();
    for (file_idx, file) in files_to_show.iter().enumerate() {
        let content = match client.fetch_file_content(&file.path) {
            Ok(c) => c,
            Err(e) => {
                logger::error(&format!("Failed to fetch \"{}\": {}", file.name, e));
                return Ok(());
            }
        };

        let header_prefix = format!("── {} ", file.name);
        let dash_fill = if header_prefix.len() < 48 {
            "─".repeat(48 - header_prefix.len())
        } else {
            String::new()
        };
        logger::stdout(&format!("{}{}", header_prefix, dash_fill));

        let lines: Vec<&str> = content.lines().collect();
        let total_lines = lines.len();
        let line_num_width = if total_lines >= 100 {
            3
        } else if total_lines >= 10 {
            2
        } else {
            1
        };

        for (i, line) in lines.iter().enumerate() {
            logger::stdout(&format!(
                "  {:>width$} │ {}",
                i + 1,
                line,
                width = line_num_width
            ));
        }

        logger::stdout(&"─".repeat(48));

        if file_idx < total_files - 1 && !auto_yes {
            print!("Show next file? [Y/n]: ");
            io::stdout().flush().unwrap_or(());
            let mut input = String::new();
            io::stdin().read_line(&mut input).unwrap_or(0);
            let trimmed = input.trim();
            if trimmed.eq_ignore_ascii_case("n") {
                break;
            }
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_view_run_uninitialized() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = crate::utils::set_dir(temp_dir.path());

        assert!(run("button".to_string(), None, false, true).is_ok());

        // Initialized with local registry
        let registry_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();

        let multiline_code = (0..105)
            .map(|i| format!("// line {}", i))
            .collect::<Vec<_>>()
            .join("\n");

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
                        "pubDependencies": {"flutter_svg": "^2.0.0"},
                        "files": {
                            "default": [
                                {
                                    "name": "just_button.dart",
                                    "path": "components/button/just_button.dart",
                                    "checksum": "sha256:111"
                                },
                                {
                                    "name": "just_button_theme.dart",
                                    "path": "components/button/just_button_theme.dart",
                                    "checksum": "sha256:222"
                                }
                            ]
                        }
                    },
                    {
                        "name": "empty_dep_comp",
                        "version": "1.0.0",
                        "description": "Empty deps",
                        "category": "primitives",
                        "supportedPresets": ["default"],
                        "registryDependencies": [],
                        "pubDependencies": {},
                        "files": {
                            "default": [
                                {
                                    "name": "missing_file.dart",
                                    "path": "components/button/missing_file.dart",
                                    "checksum": "sha256:333"
                                }
                            ]
                        }
                    }
                ]
            }))
            .unwrap(),
        )
        .unwrap();

        std::fs::write(
            registry_dir.join("components/button/just_button.dart"),
            multiline_code,
        )
        .unwrap();
        std::fs::write(
            registry_dir.join("components/button/just_button_theme.dart"),
            "class Theme {}",
        )
        .unwrap();
        std::fs::write("pubspec.yaml", "name: test_app").unwrap();
        std::fs::write(
            "justui.config.yaml",
            format!("components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\npreset: default\nregistry_url: {}\n", registry_dir.display()),
        )
        .unwrap();

        // 1. View button with auto_yes = true (multi-file with >100 lines)
        assert!(run("button".to_string(), None, false, true).is_ok());

        // 2. View button with single file filter
        assert!(run(
            "button".to_string(),
            Some("just_button.dart".to_string()),
            false,
            true
        )
        .is_ok());

        // 4. View with file_filter not found
        assert!(run(
            "button".to_string(),
            Some("nonexistent.dart".to_string()),
            false,
            true
        )
        .is_ok());

        // 5. View component not found with suggestion
        assert!(run("btn".to_string(), None, false, true).is_ok());

        // 6. View component not found without suggestion
        assert!(run("xyz_123_456".to_string(), None, false, true).is_ok());

        // 7. View component with empty deps and missing file on disk
        assert!(run("empty_dep_comp".to_string(), None, false, true).is_ok());
    }
}
