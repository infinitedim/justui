use anyhow::Result;
use regex::Regex;

use crate::config::JustUIConfig;
use crate::utils::{embedded_templates, logger, prompt, pubspec_editor};

fn normalize_preset(input: &str) -> String {
    match input.to_lowercase().as_str() {
        "neo" => "neobrutalism".to_string(),
        "d" => "default".to_string(),
        other => other.to_string(),
    }
}

fn to_lib_path(input: &str) -> String {
    let trimmed = input.trim();
    if trimmed.starts_with("lib/") {
        trimmed.to_string()
    } else {
        format!("lib/{}", trimmed)
    }
}

fn resolve_shared_dir(raw_input: &str, components_dir: &str, default_full_path: &str) -> String {
    let trimmed = raw_input.trim();

    if trimmed.is_empty() {
        return default_full_path.to_string();
    }

    if trimmed.contains('/') || trimmed.starts_with("lib") {
        return to_lib_path(trimmed);
    }

    format!("{}/{}", components_dir, trimmed)
}

#[derive(Debug, Clone, Default)]
pub struct InitArgs {
    pub preset: Option<String>,
    pub color_space: Option<String>,
    pub components_dir: Option<String>,
    pub tokens_dir: Option<String>,
    pub auto_yes: bool,
    pub experimental: Option<String>,
    pub dart_target: Option<String>,
    pub seed: Option<String>,
    pub dark: bool,
}

pub fn run(args: InitArgs) -> Result<()> {
    if !std::path::Path::new("pubspec.yaml").exists() {
        anyhow::bail!(
            "No pubspec.yaml found in the current directory.\n\
             Please run \"justui init\" from the root of your Flutter project."
        );
    }

    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if config_path.exists() {
        logger::warning(&format!(
            "{} already exists in this project.",
            JustUIConfig::CONFIG_FILE_NAME
        ));
        return Ok(());
    }

    logger::stdout("=== JustUI Initialization Wizard ===");

    let preset = if let Some(p) = args.preset {
        normalize_preset(&p)
    } else if args.auto_yes {
        logger::stdout("[auto] Using preset: default");
        "default".to_string()
    } else {
        logger::stdout("");
        logger::stdout("Select visual style preset:");
        let preset_idx = prompt::select_one(
            "Choose preset",
            &["default", "neobrutalism (alias: neo)"],
            0,
        );
        if preset_idx == 1 {
            "neobrutalism".to_string()
        } else {
            "default".to_string()
        }
    };

    let color_space = if let Some(cs) = args.color_space {
        cs.to_lowercase()
    } else if args.auto_yes {
        logger::stdout("[auto] Using color space: hsl");
        "hsl".to_string()
    } else {
        logger::stdout("");
        logger::stdout("Select color space engine:");
        let cs_idx = prompt::select_one(
            "Choose color space",
            &[
                "hsl (classic)",
                "oklch (perceptual uniform)",
                "hsluv (gamut-safe)",
            ],
            0,
        );
        match cs_idx {
            1 => "oklch".to_string(),
            2 => "hsluv".to_string(),
            _ => "hsl".to_string(),
        }
    };

    let components_dir = if let Some(d) = args.components_dir {
        to_lib_path(&d)
    } else if args.auto_yes {
        let dir = "lib/widgets".to_string();
        logger::stdout(&format!("[auto] Using components dir: {}", dir));
        dir
    } else {
        logger::stdout("");
        logger::stdout("Select UI components directory (will be created under lib/):");
        let comp_choices = &["widgets", "components", "Custom..."];
        let comp_idx = prompt::select_one("Choose components dir", comp_choices, 0);

        if comp_idx == 2 {
            let custom_name = prompt::ask("Enter folder name (under lib/)", "ui");
            to_lib_path(&custom_name)
        } else {
            format!("lib/{}", comp_choices[comp_idx])
        }
    };

    let tokens_dir = if let Some(t) = args.tokens_dir {
        to_lib_path(&t)
    } else if args.auto_yes {
        let dir = "lib/tokens".to_string();
        logger::stdout(&format!("[auto] Using tokens dir: {}", dir));
        dir
    } else {
        logger::stdout("");
        let tokens_input = prompt::ask("Enter design tokens folder name (under lib/)", "tokens");
        to_lib_path(&tokens_input)
    };

    let shared_dir_default = format!("{}/shared", components_dir);
    let shared_dir = if args.auto_yes {
        logger::stdout(&format!("[auto] Using shared dir: {}", shared_dir_default));
        shared_dir_default
    } else {
        logger::stdout(&format!(
            "  (This folder will be created relative to '{}', e.g. '{}')",
            components_dir, shared_dir_default
        ));
        let raw_shared_dir = prompt::ask(
            "Enter shared components folder name (leave blank for default)",
            "shared",
        );
        resolve_shared_dir(&raw_shared_dir, &components_dir, &shared_dir_default)
    };

    let hex_regex = Regex::new(r"^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$").unwrap();
    let brand_color = if let Some(ref s) = args.seed {
        let trimmed = s.trim();
        if !hex_regex.is_match(trimmed) {
            anyhow::bail!(
                "Invalid HEX color format: \"{}\". Expected format e.g. #3b82f6 or 3b82f6.",
                trimmed
            );
        }
        if trimmed.starts_with('#') {
            trimmed.to_string()
        } else {
            format!("#{}", trimmed)
        }
    } else if args.auto_yes {
        let color = "#3b82f6".to_string();
        logger::stdout(&format!("[auto] Using brand color: {}", color));
        color
    } else {
        loop {
            let input = prompt::ask("Enter your brand seed color (HEX)", "#3b82f6");
            if hex_regex.is_match(&input) {
                break input;
            }
            logger::error("Invalid HEX color format. Please try again (e.g. #3b82f6 or FFF).");
        }
    };

    let mut clean_hex = brand_color.replace('#', "").to_uppercase();
    if clean_hex.len() == 3 {
        clean_hex = clean_hex.chars().flat_map(|c| [c, c]).collect();
    }
    let hex_code = format!("0xFF{}", clean_hex);

    if let Some(ref feat) = args.experimental
        && feat != "auto-detect-flutter-version"
    {
        logger::warning(&format!(
            "Unknown experimental feature: \"{}\". Ignoring.",
            feat
        ));
    }

    let dart_target = if let Some(dt) = args.dart_target {
        match dt.to_lowercase().as_str() {
            "primary" => crate::utils::env_resolver::DartTarget::Primary,
            "standard" => crate::utils::env_resolver::DartTarget::Standard,
            other => {
                logger::warning(&format!(
                    "Unknown dart_target: \"{}\". Falling back to auto-detection.",
                    other
                ));
                crate::utils::env_resolver::resolve_dart_target(std::path::Path::new("."))
            }
        }
    } else {
        let target = crate::utils::env_resolver::resolve_dart_target(std::path::Path::new("."));
        logger::info(&format!("Auto-detected dart_target: {:?}", target));
        target
    };

    let config = JustUIConfig {
        components_dir: components_dir.clone(),
        tokens_dir: tokens_dir.clone(),
        shared_dir: shared_dir.clone(),
        registry_url: JustUIConfig::DEFAULT_REGISTRY_URL.to_string(),
        preset: preset.clone(),
        color_space: color_space.clone(),
        dart_target,
    };
    std::fs::write(config_path, config.to_yaml_string())
        .map_err(|e| anyhow::anyhow!("Failed to initialize JustUI: {}", e))?;

    logger::success("JustUI configuration initialized.");
    logger::info(&format!(
        "Configuration written to {}",
        JustUIConfig::CONFIG_FILE_NAME
    ));

    let pkg_name = pubspec_editor::get_package_name(std::path::Path::new("pubspec.yaml"))
        .unwrap_or_else(|_| "flutter_app".to_string());

    embedded_templates::extract_tokens(std::path::Path::new(&tokens_dir), &pkg_name, dart_target)?;
    embedded_templates::extract_core(
        std::path::Path::new("lib/core"),
        &pkg_name,
        &tokens_dir,
        dart_target,
    )?;

    logger::success("Design tokens & Core engine scaffolded locally.");

    std::fs::create_dir_all("lib/core/theme")
        .map_err(|e| anyhow::anyhow!("Failed to create lib/core/theme: {}", e))?;

    let preset_param = if preset == "neobrutalism" {
        "\n  preset: JustThemePreset.neobrutalism,"
    } else {
        ""
    };

    let color_space_param = match color_space.as_str() {
        "oklch" => "\n  colorSpace: JustColorSpaceEngine.oklch,",
        "hsluv" => "\n  colorSpace: JustColorSpaceEngine.hsluv,",
        _ => "",
    };

    let default_theme_ref = if args.dark {
        "justThemeDark"
    } else {
        "justThemeLight"
    };
    let theme_content = format!(
        "import 'package:flutter/material.dart' show Color;\n\
         import '../just_ui_core.dart';\n\
         \n\
         /// Dynamically generated light theme from brand seed color.\n\
         final JustThemeData justThemeLight = JustThemeData.fromSeed(\n\
           const Color({}),\n\
           isDark: false,{}{}\n\
         );\n\
         \n\
         /// Dynamically generated dark theme from brand seed color.\n\
         final JustThemeData justThemeDark = JustThemeData.fromSeed(\n\
           const Color({}),\n\
           isDark: true,{}{}\n\
         );\n\
         \n\
         /// Default bootstrap theme matching configuration.\n\
         final JustThemeData justTheme = {};\n",
        hex_code,
        preset_param,
        color_space_param,
        hex_code,
        preset_param,
        color_space_param,
        default_theme_ref
    );

    std::fs::write("lib/core/theme/just_theme.dart", theme_content)
        .map_err(|e| anyhow::anyhow!("Failed to write theme file: {}", e))?;
    crate::utils::dart_formatter::format_and_refresh_metadata(std::path::Path::new(
        "lib/core/theme/just_theme.dart",
    ));

    logger::success("Bootstrap theme created at lib/core/theme/just_theme.dart");

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    use crate::utils::set_dir;

    #[test]
    fn test_init_helpers() {
        assert_eq!(normalize_preset("neo"), "neobrutalism");
        assert_eq!(normalize_preset("d"), "default");
        assert_eq!(normalize_preset("custom"), "custom");

        assert_eq!(to_lib_path("widgets"), "lib/widgets");
        assert_eq!(to_lib_path("lib/components"), "lib/components");

        assert_eq!(
            resolve_shared_dir("", "lib/widgets", "lib/widgets/shared"),
            "lib/widgets/shared"
        );
        assert_eq!(
            resolve_shared_dir("common", "lib/widgets", "lib/widgets/shared"),
            "lib/widgets/common"
        );
        assert_eq!(
            resolve_shared_dir("lib/shared_custom", "lib/widgets", "lib/widgets/shared"),
            "lib/shared_custom"
        );
    }

    #[test]
    fn test_init_run_execution() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        // 1. Without pubspec -> fails with error
        assert!(
            run(InitArgs {
                auto_yes: true,
                ..Default::default()
            })
            .is_err()
        );

        // 2. With pubspec -> succeeds in auto_yes mode
        std::fs::write(temp_dir.path().join("pubspec.yaml"), "name: test_app").unwrap();
        assert!(
            run(InitArgs {
                preset: Some("neo".to_string()),
                color_space: Some("oklch".to_string()),
                auto_yes: true,
                ..Default::default()
            })
            .is_ok()
        );

        let theme_path = temp_dir.path().join("lib/core/theme/just_theme.dart");
        let theme_file = std::fs::read_to_string(&theme_path).unwrap();
        assert!(!theme_file.contains("justThemeExtensions"));

        // The scaffolded theme file must already be dart-format-clean, so it
        // isn't immediately flagged as "modified" the moment a contributor
        // (or their editor) runs `dart format` on a fresh project.
        let format_check = std::process::Command::new("dart")
            .arg("format")
            .arg("--output=none")
            .arg("--set-exit-if-changed")
            .arg(&theme_path)
            .status();
        if let Ok(status) = format_check {
            assert!(
                status.success(),
                "scaffolded theme file must already be dart-format-clean"
            );
        }

        // 3. Already initialized -> warns and returns Ok
        assert!(
            run(InitArgs {
                auto_yes: true,
                ..Default::default()
            })
            .is_ok()
        );
    }

    #[test]
    fn test_init_default_auto_detect_primary() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        std::fs::write(
            temp_dir.path().join("pubspec.yaml"),
            "name: test_app\nenvironment:\n  sdk: '>=3.13.0 <4.0.0'\n",
        )
        .unwrap();

        let result = run(InitArgs {
            preset: Some("default".to_string()),
            auto_yes: true,
            ..Default::default()
        });
        assert!(result.is_ok());

        let config_content =
            std::fs::read_to_string(temp_dir.path().join("justui.config.yaml")).unwrap();
        assert!(config_content.contains("dart_target: primary"));
    }

    #[test]
    fn test_init_default_auto_detect_standard_older_sdk() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        std::fs::write(
            temp_dir.path().join("pubspec.yaml"),
            "name: test_app\nenvironment:\n  sdk: '>=3.0.0 <4.0.0'\n",
        )
        .unwrap();

        let result = run(InitArgs {
            preset: Some("default".to_string()),
            auto_yes: true,
            ..Default::default()
        });
        assert!(result.is_ok());

        let config_content =
            std::fs::read_to_string(temp_dir.path().join("justui.config.yaml")).unwrap();
        assert!(config_content.contains("dart_target: standard"));
    }

    #[test]
    fn test_init_explicit_dart_target_override() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        // Even with older sdk, --dart-target primary overrides to primary
        std::fs::write(
            temp_dir.path().join("pubspec.yaml"),
            "name: test_app\nenvironment:\n  sdk: '>=3.0.0 <4.0.0'\n",
        )
        .unwrap();

        let result = run(InitArgs {
            preset: Some("default".to_string()),
            dart_target: Some("primary".to_string()),
            auto_yes: true,
            ..Default::default()
        });
        assert!(result.is_ok());

        let config_content =
            std::fs::read_to_string(temp_dir.path().join("justui.config.yaml")).unwrap();
        assert!(config_content.contains("dart_target: primary"));
    }

    #[test]
    fn test_init_unknown_experimental_warns() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        std::fs::write(temp_dir.path().join("pubspec.yaml"), "name: test_app").unwrap();

        let result = run(InitArgs {
            preset: Some("default".to_string()),
            experimental: Some("unknown-feature".to_string()),
            auto_yes: true,
            ..Default::default()
        });
        assert!(result.is_ok());

        let config_content =
            std::fs::read_to_string(temp_dir.path().join("justui.config.yaml")).unwrap();
        assert!(config_content.contains("dart_target: standard"));
    }

    #[test]
    fn test_init_with_seed_and_dark_flags() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        std::fs::write(temp_dir.path().join("pubspec.yaml"), "name: test_app").unwrap();

        let result = run(InitArgs {
            preset: Some("default".to_string()),
            color_space: Some("hsl".to_string()),
            seed: Some("#e11d48".to_string()),
            dark: true,
            auto_yes: true,
            ..Default::default()
        });
        assert!(result.is_ok());

        let theme_path = temp_dir.path().join("lib/core/theme/just_theme.dart");
        let theme_content = std::fs::read_to_string(&theme_path).unwrap();
        assert!(theme_content.contains("0xFFE11D48"));
        assert!(theme_content.contains("final JustThemeData justTheme = justThemeDark;"));
    }
}
