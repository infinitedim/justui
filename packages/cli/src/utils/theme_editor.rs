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
    } else if updated_content.contains("final List<ThemeExtension<dynamic>> justThemeExtensions = [") {
        let search = "final List<ThemeExtension<dynamic>> justThemeExtensions = [";
        let replacement = format!("{}\n  {}.defaults,", search, theme_class_name);
        updated_content.replace(search, &replacement)
    } else {
        updated_content
    };

    if final_content != content {
        std::fs::write(theme_file_path, &final_content)
            .with_context(|| format!("Failed to update theme file at {}", theme_file_path.display()))?;
        Ok(true)
    } else {
        Ok(false)
    }
}
