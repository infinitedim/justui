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

pub fn parse_min_version(constraint_str: &str) -> Option<semver::Version> {
    let cleaned = constraint_str.trim().trim_matches('\'').trim_matches('"');
    let normalized = cleaned.split_whitespace().collect::<Vec<_>>().join(",");
    let req = semver::VersionReq::parse(&normalized).ok()?;
    let mut min_version: Option<semver::Version> = None;

    for comp in &req.comparators {
        let v = semver::Version {
            major: comp.major,
            minor: comp.minor.unwrap_or(0),
            patch: comp.patch.unwrap_or(0),
            pre: comp.pre.clone(),
            build: semver::BuildMetadata::EMPTY,
        };

        match comp.op {
            semver::Op::GreaterEq | semver::Op::Greater | semver::Op::Caret | semver::Op::Exact => {
                if let Some(ref current_min) = min_version {
                    if v > *current_min {
                        min_version = Some(v);
                    }
                } else {
                    min_version = Some(v);
                }
            }
            _ => {}
        }
    }

    min_version
}

pub fn supports_primary_constructors(pubspec_path: &Path) -> Result<bool> {
    let content = match std::fs::read_to_string(pubspec_path) {
        Ok(c) => c,
        Err(_) => return Ok(false),
    };

    let doc: serde_yaml::Value = match serde_yaml::from_str(&content) {
        Ok(d) => d,
        Err(_) => return Ok(false),
    };

    let env = match doc.get("environment") {
        Some(e) if e.is_mapping() => e,
        _ => return Ok(false),
    };

    let mut dart_supported = false;
    let mut checked = false;

    if let Some(sdk_str) = env.get("sdk").and_then(|v| v.as_str()) {
        checked = true;
        if let Some(min_sdk) = parse_min_version(sdk_str) {
            if (min_sdk.major, min_sdk.minor) >= (3, 13) {
                dart_supported = true;
            }
        }
    }

    if let Some(flutter_str) = env.get("flutter").and_then(|v| v.as_str()) {
        if let Some(min_flutter) = parse_min_version(flutter_str) {
            if (min_flutter.major, min_flutter.minor) < (3, 47) {
                return Ok(false);
            }
            if env.get("sdk").is_none() {
                checked = true;
                dart_supported = true;
            }
        }
    }

    if checked {
        Ok(dart_supported)
    } else {
        Ok(false)
    }
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

        // Test pubspec missing name key
        let no_name_path = dir.path().join("no_name_pubspec.yaml");
        std::fs::write(
            &no_name_path,
            "dependencies:\n  flutter:\n    sdk: flutter\n",
        )
        .unwrap();
        assert!(get_package_name(&no_name_path).is_err());
    }

    #[test]
    fn test_supports_primary_constructors_edge_cases() {
        let dir = tempdir().unwrap();

        // 1. Dart >= 3.13.0 (True)
        let p1 = dir.path().join("p1.yaml");
        std::fs::write(&p1, "environment:\n  sdk: '>=3.13.0 <4.0.0'\n").unwrap();
        assert!(supports_primary_constructors(&p1).unwrap());

        // 2. Dart >= 3.10.0 (False)
        let p2 = dir.path().join("p2.yaml");
        std::fs::write(&p2, "environment:\n  sdk: '>=3.10.0 <4.0.0'\n").unwrap();
        assert!(!supports_primary_constructors(&p2).unwrap());

        // 3. Caret ^3.13.0 (True)
        let p3 = dir.path().join("p3.yaml");
        std::fs::write(&p3, "environment:\n  sdk: '^3.13.0'\n").unwrap();
        assert!(supports_primary_constructors(&p3).unwrap());

        // 4. Caret ^3.10.0 (False)
        let p4 = dir.path().join("p4.yaml");
        std::fs::write(&p4, "environment:\n  sdk: '^3.10.0'\n").unwrap();
        assert!(!supports_primary_constructors(&p4).unwrap());

        // 5. Prerelease >=3.13.0-0.0.pre (True)
        let p5 = dir.path().join("p5.yaml");
        std::fs::write(&p5, "environment:\n  sdk: '>=3.13.0-0.0.pre <4.0.0'\n").unwrap();
        assert!(supports_primary_constructors(&p5).unwrap());

        // 6. Flutter >= 3.47.0 (True)
        let p6 = dir.path().join("p6.yaml");
        std::fs::write(
            &p6,
            "environment:\n  sdk: '>=3.13.0 <4.0.0'\n  flutter: '>=3.47.0'\n",
        )
        .unwrap();
        assert!(supports_primary_constructors(&p6).unwrap());

        // 7. Dart >= 3.13.0 but Flutter < 3.47.0 (False - Fail Safe)
        let p7 = dir.path().join("p7.yaml");
        std::fs::write(
            &p7,
            "environment:\n  sdk: '>=3.13.0 <4.0.0'\n  flutter: '>=3.22.0'\n",
        )
        .unwrap();
        assert!(!supports_primary_constructors(&p7).unwrap());

        // 8. Missing environment (False)
        let p8 = dir.path().join("p8.yaml");
        std::fs::write(&p8, "name: test_app\n").unwrap();
        assert!(!supports_primary_constructors(&p8).unwrap());

        // 9. Non-existent file (False)
        let p9 = dir.path().join("non_existent.yaml");
        assert!(!supports_primary_constructors(&p9).unwrap());

        // 10. Malformed YAML (False)
        let p10 = dir.path().join("malformed.yaml");
        std::fs::write(&p10, "environment: [invalid yaml").unwrap();
        assert!(!supports_primary_constructors(&p10).unwrap());

        // 11. Flutter >= 3.47.0 without sdk (True)
        let p11 = dir.path().join("p11.yaml");
        std::fs::write(&p11, "environment:\n  flutter: '>=3.47.0'\n").unwrap();
        assert!(supports_primary_constructors(&p11).unwrap());
    }
}
