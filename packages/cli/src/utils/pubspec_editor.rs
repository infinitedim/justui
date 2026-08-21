use anyhow::{Context, Result};
use std::path::Path;

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

    if let Ok(doc) = serde_yaml::from_str::<serde_yaml::Value>(&content) {
        if let Some(deps) = doc.get("dependencies") {
            if deps.get(dependency_name).is_some() {
                return Ok(());
            }
        }
    }

    let backup_path = format!("{}.bak", pubspec_path.display());
    std::fs::write(&backup_path, &content)
        .with_context(|| format!("Failed to write backup to {}", backup_path))?;

    let lines: Vec<&str> = content.split('\n').collect();
    let mut dependencies_line_index: Option<usize> = None;

    for (i, line) in lines.iter().enumerate() {
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

    let dependency_line = format!("  {}: \"{}\"", dependency_name, version_constraint);
    let mut new_lines: Vec<String> = lines.iter().map(|l| l.to_string()).collect();
    new_lines.insert(dep_idx + 1, dependency_line);

    std::fs::write(pubspec_path, new_lines.join("\n"))
        .context("Failed to write modified pubspec.yaml")?;

    Ok(())
}

pub fn get_package_name(pubspec_path: &Path) -> Result<String> {
    let content = std::fs::read_to_string(pubspec_path).with_context(|| {
        format!(
            "Target project pubspec.yaml not found at: {}",
            pubspec_path.display()
        )
    })?;

    if let Ok(doc) = serde_yaml::from_str::<serde_yaml::Value>(&content) {
        if let Some(name) = doc.get("name").and_then(|v| v.as_str()) {
            return Ok(name.to_string());
        }
    }

    anyhow::bail!("Could not parse 'name:' from pubspec.yaml")
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_add_dependency_and_get_package_name() {
        let dir = tempdir().unwrap();
        let pubspec_path = dir.path().join("pubspec.yaml");

        // Test non-existent pubspec
        assert!(add_dependency(&pubspec_path, "flutter_svg", "^2.0.0").is_err());
        assert!(get_package_name(&pubspec_path).is_err());

        // Test valid pubspec
        let content = "name: my_test_app\ndependencies:\n  flutter:\n    sdk: flutter\n";
        std::fs::write(&pubspec_path, content).unwrap();

        assert_eq!(get_package_name(&pubspec_path).unwrap(), "my_test_app");

        // Add dependency
        assert!(add_dependency(&pubspec_path, "flutter_svg", "^2.0.0").is_ok());
        let updated = std::fs::read_to_string(&pubspec_path).unwrap();
        assert!(updated.contains("flutter_svg: \"^2.0.0\""));

        // Adding duplicate dependency should succeed without duplication
        assert!(add_dependency(&pubspec_path, "flutter_svg", "^2.0.0").is_ok());

        // Test pubspec missing dependencies section
        let no_deps_path = dir.path().join("no_deps_pubspec.yaml");
        std::fs::write(&no_deps_path, "name: simple_app\n").unwrap();
        assert_eq!(get_package_name(&no_deps_path).unwrap(), "simple_app");
        assert!(add_dependency(&no_deps_path, "flutter_svg", "^2.0.0").is_err());
    }
}

