use anyhow::Result;
use regex::Regex;

use crate::config::JustUIConfig;
use crate::utils::{logger, prompt};

/// Normalizes preset aliases to their canonical names.
fn normalize_preset(input: &str) -> String {
    match input.to_lowercase().as_str() {
        "neo" => "neobrutalism".to_string(),
        "d" => "default".to_string(),
        other => other.to_string(),
    }
}

/// Converts a subfolder name to a lib-rooted path.
/// Strips any accidental leading 'lib/' prefix before prepending 'lib/'.
fn to_lib_path(input: &str) -> String {
    let trimmed = input.trim();
    if trimmed.starts_with("lib/") {
        trimmed.to_string()
    } else {
        format!("lib/{}", trimmed)
    }
}

/// Runs the `justui init` command.
pub fn run(preset_arg: Option<String>, auto_yes: bool) -> Result<()> {
    // 1. Verify we are in a valid project root containing pubspec.yaml
    if !std::path::Path::new("pubspec.yaml").exists() {
        logger::error(
            "No pubspec.yaml found in the current directory.\n\
             Please run \"justui init\" from the root of your Flutter project.",
        );
        return Ok(());
    }

    // 2. Check if configuration file already exists
    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if config_path.exists() {
        logger::warning(&format!(
            "{} already exists in this project.",
            JustUIConfig::CONFIG_FILE_NAME
        ));
        return Ok(());
    }

    logger::stdout("=== JustUI Initialization Wizard ===");

    // ── Preset selection ──────────────────────────────────────────────────────
    let preset = if let Some(p) = preset_arg {
        normalize_preset(&p)
    } else if auto_yes {
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

    // ── Components directory selection ────────────────────────────────────────
    let components_dir = if auto_yes {
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

    // ── Tokens directory ──────────────────────────────────────────────────────
    let tokens_dir = if auto_yes {
        let dir = "lib/tokens".to_string();
        logger::stdout(&format!("[auto] Using tokens dir: {}", dir));
        dir
    } else {
        logger::stdout("");
        let tokens_input = prompt::ask("Enter design tokens folder name (under lib/)", "tokens");
        to_lib_path(&tokens_input)
    };

    // ── Shared components directory ───────────────────────────────────────────
    let shared_dir_default = format!("{}/shared", components_dir);
    let shared_dir = if auto_yes {
        logger::stdout(&format!(
            "[auto] Using shared dir: {}",
            shared_dir_default
        ));
        shared_dir_default
    } else {
        let raw_shared_dir = prompt::ask(
            "Enter shared components folder (leave blank for default)",
            &shared_dir_default,
        );
        if raw_shared_dir.is_empty() {
            shared_dir_default
        } else {
            to_lib_path(&raw_shared_dir)
        }
    };

    // ── Brand seed color ──────────────────────────────────────────────────────
    let hex_regex = Regex::new(r"^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$").unwrap();
    let brand_color = if auto_yes {
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

    // Standardize hex → 0xFFRRGGBB
    let mut clean_hex = brand_color.replace('#', "").to_uppercase();
    if clean_hex.len() == 3 {
        clean_hex = clean_hex.chars().flat_map(|c| [c, c]).collect();
    }
    let hex_code = format!("0xFF{}", clean_hex);

    // ── Write justui.config.yaml ──────────────────────────────────────────────
    let config = JustUIConfig {
        components_dir: components_dir.clone(),
        tokens_dir: tokens_dir.clone(),
        shared_dir: shared_dir.clone(),
        registry_url: JustUIConfig::DEFAULT_REGISTRY_URL.to_string(),
        preset: preset.clone(),
    };
    std::fs::write(config_path, config.to_yaml_string())
        .map_err(|e| anyhow::anyhow!("Failed to initialize JustUI: {}", e))?;

    logger::success("JustUI configuration initialized.");
    logger::info(&format!(
        "Configuration written to {}",
        JustUIConfig::CONFIG_FILE_NAME
    ));

    // ── Scaffold lib/theme/just_theme.dart ────────────────────────────────────
    std::fs::create_dir_all("lib/theme")
        .map_err(|e| anyhow::anyhow!("Failed to create lib/theme: {}", e))?;

    let preset_param = if preset == "neobrutalism" {
        "\n  preset: JustThemePreset.neobrutalism,"
    } else {
        ""
    };

    let theme_content = format!(
        "import 'package:flutter/widgets.dart';\n\
         import 'package:just_ui_core/just_ui_core.dart';\n\
         \n\
         /// Dynamically generated light theme from brand seed color.\n\
         final JustThemeData justThemeLight = JustThemeData.fromSeed(\n\
           const Color({}),\n\
           isDark: false,{}\n\
         );\n\
         \n\
         /// Dynamically generated dark theme from brand seed color.\n\
         final JustThemeData justThemeDark = JustThemeData.fromSeed(\n\
           const Color({}),\n\
           isDark: true,{}\n\
         );\n",
        hex_code, preset_param, hex_code, preset_param
    );

    std::fs::write("lib/theme/just_theme.dart", theme_content)
        .map_err(|e| anyhow::anyhow!("Failed to write theme file: {}", e))?;

    logger::success("Bootstrap theme created at lib/theme/just_theme.dart");

    Ok(())
}
