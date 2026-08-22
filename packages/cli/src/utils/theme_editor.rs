use anyhow::{Context, Result};
use std::path::Path;

/// Registers a component's `ThemeExtension` class inside `lib/core/theme/just_theme.dart`.
pub fn register_theme_extension(
    theme_file_path: &Path,
    _package_name: &str,
    component_import_path: &str,
    theme_class_name: &str,
) -> Result<bool> {
    if !theme_file_path.exists() {
        return Ok(false);
    }

    let content = std::fs::read_to_string(theme_file_path)
        .with_context(|| format!("Failed to read theme file at {}", theme_file_path.display()))?;

    // Check if the theme class instance or defaults is already registered
    let class_instance_pattern = format!("{}.defaults", theme_class_name);
    let legacy_instance_pattern = format!("const {}()", theme_class_name);
    if content.contains(&class_instance_pattern) || content.contains(&legacy_instance_pattern) {
        return Ok(false);
    }

    let import_line = format!("import '{}';", component_import_path);
    let mut lines: Vec<String> = content.lines().map(|s| s.to_string()).collect();

    // Insert import statement after the last existing import line
    if !lines.iter().any(|l| l.contains(component_import_path)) {
        let mut last_import_idx = 0;
        for (idx, line) in lines.iter().enumerate() {
            if line.trim().starts_with("import ") {
                last_import_idx = idx + 1;
            }
        }
        lines.insert(last_import_idx, import_line);
    }

    let updated_content = lines.join("\n");
    let reg_marker = "// CLI:REGISTER_EXTENSIONS";

    let final_content = if updated_content.contains(reg_marker) {
        let replacement = format!("  {}.defaults,\n  {}", theme_class_name, reg_marker);
        updated_content.replace(reg_marker, &replacement)
    } else if updated_content
        .contains("final List<ThemeExtension<dynamic>> justThemeExtensions = [")
    {
        let search = "final List<ThemeExtension<dynamic>> justThemeExtensions = [";
        let replacement = format!("{}\n  {}.defaults,", search, theme_class_name);
        updated_content.replace(search, &replacement)
    } else {
        updated_content
    };

    if final_content != content {
        std::fs::write(theme_file_path, &final_content).with_context(|| {
            format!(
                "Failed to update theme file at {}",
                theme_file_path.display()
            )
        })?;
        Ok(true)
    } else {
        Ok(false)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_register_theme_extension() {
        let dir = tempdir().unwrap();
        let theme_path = dir.path().join("just_theme.dart");

        // 1. Non-existent file
        assert!(!register_theme_extension(
            &theme_path,
            "my_app",
            "button/just_button.dart",
            "JustButtonTheme"
        )
        .unwrap());

        // 2. Initial theme file with marker
        let initial_code = r#"import 'package:flutter/material.dart';

final List<ThemeExtension<dynamic>> justThemeExtensions = [
  // CLI:REGISTER_EXTENSIONS
];
"#;
        std::fs::write(&theme_path, initial_code).unwrap();

        // 3. Register first extension
        let registered = register_theme_extension(
            &theme_path,
            "my_app",
            "button/just_button.dart",
            "JustButtonTheme",
        )
        .unwrap();
        assert!(registered);

        let updated = std::fs::read_to_string(&theme_path).unwrap();
        assert!(updated.contains("import 'button/just_button.dart';"));
        assert!(updated.contains("JustButtonTheme.defaults,"));

        // 4. Register duplicate extension (should return false)
        let duplicate = register_theme_extension(
            &theme_path,
            "my_app",
            "button/just_button.dart",
            "JustButtonTheme",
        )
        .unwrap();
        assert!(!duplicate);

        // 5. Fallback registration without marker
        let fallback_path = dir.path().join("fallback_theme.dart");
        let fallback_code = r#"import 'package:flutter/material.dart';

final List<ThemeExtension<dynamic>> justThemeExtensions = [
];
"#;
        std::fs::write(&fallback_path, fallback_code).unwrap();

        let fallback_registered = register_theme_extension(
            &fallback_path,
            "my_app",
            "card/just_card.dart",
            "JustCardTheme",
        )
        .unwrap();
        assert!(fallback_registered);
        let fallback_updated = std::fs::read_to_string(&fallback_path).unwrap();
        assert!(fallback_updated.contains("JustCardTheme.defaults,"));

        // 6. Legacy pattern check
        let legacy_path = dir.path().join("legacy_theme.dart");
        std::fs::write(&legacy_path, "const JustButtonTheme()\n").unwrap();
        assert!(!register_theme_extension(
            &legacy_path,
            "my_app",
            "button.dart",
            "JustButtonTheme"
        )
        .unwrap());

        // 7. Theme file without extensions list
        let no_match_path = dir.path().join("no_match_theme.dart");
        std::fs::write(&no_match_path, "// simple file without theme extensions\n").unwrap();
        assert!(!register_theme_extension(
            &no_match_path,
            "my_app",
            "button.dart",
            "JustButtonTheme"
        )
        .unwrap());
    }
}
