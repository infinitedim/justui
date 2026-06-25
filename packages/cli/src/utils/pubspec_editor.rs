use anyhow::{Context, Result};
use std::path::Path;

/// Safely adds a dependency to the target `pubspec.yaml` if not already present.
///
/// Preserves all user formatting, indentation, anchors, and comments by using
/// targeted string insertion instead of parsing and re-serializing the entire file.
pub fn add_dependency(
    pubspec_path: &Path,
    dependency_name: &str,
    version_constraint: &str,
) -> Result<()> {
    let content = std::fs::read_to_string(pubspec_path).with_context(|| {
        format!(
            "Target project pubspec.yaml not found at: {}",
            pubspec_path.display()
        )
    })?;

    // 1. Verify if dependency already exists using YAML parser
    if let Ok(doc) = serde_yaml::from_str::<serde_yaml::Value>(&content) {
        if let Some(deps) = doc.get("dependencies") {
            if deps.get(dependency_name).is_some() {
                // Already present, skip to avoid double addition
                return Ok(());
            }
        }
    }

    // 2. Create backup of pubspec.yaml before modification
    let backup_path = format!("{}.bak", pubspec_path.display());
    std::fs::write(&backup_path, &content)
        .with_context(|| format!("Failed to write backup to {}", backup_path))?;

    // 3. Perform targeted line insertion
    let lines: Vec<&str> = content.split('\n').collect();
    let mut dependencies_line_index: Option<usize> = None;

    for (i, line) in lines.iter().enumerate() {
        // Search for top-level 'dependencies:' definition at column 0
        if line.trim() == "dependencies:" {
            let spaces = line.find("dependencies:").unwrap_or(1);
            if spaces == 0 {
                dependencies_line_index = Some(i);
                break;
            }
        }
    }

    let dep_idx = dependencies_line_index
        .ok_or_else(|| anyhow::anyhow!("Root \"dependencies:\" key not found in pubspec.yaml."))?;

    // Insert dependency with two spaces indentation
    let dependency_line = format!("  {}: \"{}\"", dependency_name, version_constraint);
    let mut new_lines: Vec<String> = lines.iter().map(|l| l.to_string()).collect();
    new_lines.insert(dep_idx + 1, dependency_line);

    // Write modified content back
    std::fs::write(pubspec_path, new_lines.join("\n"))
        .context("Failed to write modified pubspec.yaml")?;

    Ok(())
}
