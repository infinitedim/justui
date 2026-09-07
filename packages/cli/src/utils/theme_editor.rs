use anyhow::{Context, Result};
use std::path::Path;

/// Registers a component's `ThemeExtension` class inside `lib/core/theme/theme_data_material.dart`.
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

    let reg_marker = "// CLI:REGISTER_EXTENSIONS";

    if !content.contains(reg_marker) {
        return Ok(false);
    }

    let import_line = format!("import '{}';", component_import_path);
    let mut lines: Vec<String> = content.lines().map(|s| s.to_string()).collect();

    // Insert import statement respecting Dart directives_ordering:
    // package: imports are placed with existing package imports and before relative imports
    if !lines.iter().any(|l| l.contains(component_import_path)) {
        let mut last_pkg_import_idx = None;
        let mut last_import_idx = 0;

        for (idx, line) in lines.iter().enumerate() {
            let trimmed = line.trim();
            if trimmed.starts_with("import ") {
                last_import_idx = idx + 1;
                if trimmed.starts_with("import 'package:") || trimmed.starts_with("import \"package:") {
                    last_pkg_import_idx = Some(idx + 1);
                }
            }
        }

        let insert_idx = if component_import_path.starts_with("package:") {
            last_pkg_import_idx.unwrap_or(last_import_idx)
        } else {
            last_import_idx
        };
        lines.insert(insert_idx, import_line);
    }

    let updated_content = lines.join("\n");

    let indent = updated_content
        .lines()
        .find(|l| l.contains(reg_marker))
        .map(|l| {
            l.chars()
                .take_while(|c| c.is_whitespace())
                .collect::<String>()
        })
        .unwrap_or_else(|| "        ".to_string());

    let search = format!("{}{}", indent, reg_marker);
    let replacement = format!("{}{}.defaults,\n{}{}", indent, theme_class_name, indent, reg_marker);
    let final_content = if updated_content.contains(&search) {
        updated_content.replace(&search, &replacement)
    } else {
        updated_content.replace(reg_marker, &replacement)
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
        let theme_path = dir.path().join("theme_data_material.dart");

        // 1. Non-existent file
        assert!(!register_theme_extension(
            &theme_path,
            "my_app",
            "widgets/button/just_button_theme.dart",
            "JustButtonTheme"
        )
        .unwrap());

        // 2. Initial theme file with 8-space indented marker
        let initial_code = r#"import 'package:flutter/material.dart';

import 'theme_data.dart';

      extensions: const [
        // CLI:REGISTER_EXTENSIONS
      ],
"#;
        std::fs::write(&theme_path, initial_code).unwrap();

        // 3. Register first extension
        let registered = register_theme_extension(
            &theme_path,
            "my_app",
            "package:my_app/widgets/button/just_button_theme.dart",
            "JustButtonTheme",
        )
        .unwrap();
        assert!(registered);

        let updated = std::fs::read_to_string(&theme_path).unwrap();
        assert!(updated.contains("import 'package:my_app/widgets/button/just_button_theme.dart';"));
        assert!(updated.contains("        JustButtonTheme.defaults,\n        // CLI:REGISTER_EXTENSIONS"));

        // 4. Register duplicate extension (should return false)
        let duplicate = register_theme_extension(
            &theme_path,
            "my_app",
            "package:my_app/widgets/button/just_button_theme.dart",
            "JustButtonTheme",
        )
        .unwrap();
        assert!(!duplicate);

        // 5. Register second extension
        let second_registered = register_theme_extension(
            &theme_path,
            "my_app",
            "package:my_app/widgets/card/just_card_theme.dart",
            "JustCardTheme",
        )
        .unwrap();
        assert!(second_registered);

        let second_updated = std::fs::read_to_string(&theme_path).unwrap();
        assert!(second_updated.contains("import 'package:my_app/widgets/card/just_card_theme.dart';"));
        assert!(second_updated.contains("        JustButtonTheme.defaults,\n        JustCardTheme.defaults,\n        // CLI:REGISTER_EXTENSIONS"));

        // 6. Legacy pattern check
        let legacy_path = dir.path().join("legacy_theme.dart");
        std::fs::write(&legacy_path, "const JustButtonTheme()\n// CLI:REGISTER_EXTENSIONS").unwrap();
        assert!(!register_theme_extension(
            &legacy_path,
            "my_app",
            "button.dart",
            "JustButtonTheme"
        )
        .unwrap());

        // 7. Theme file without marker
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
