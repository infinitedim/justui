#![expect(
    clippy::manual_let_else,
    clippy::missing_errors_doc,
    reason = "legacy: fix when touched"
)]

use anyhow::{Context, Result};
use std::path::Path;
use std::sync::LazyLock;

static PUB_DEP_NAME_REGEX: LazyLock<regex::Regex> = LazyLock::new(|| {
    regex::Regex::new(r"^[a-z_][a-z0-9_]*$").expect("invariant: pub dependency name regex is valid")
});

/// Validates package name against pub naming rules (`^[a-z_][a-z0-9_]*$`).
///
/// # Errors
/// Returns error if dependency name format is invalid.
pub fn validate_pub_dependency_name(name: &str) -> Result<()> {
    if !PUB_DEP_NAME_REGEX.is_match(name) {
        anyhow::bail!("invalid pub dependency name '{name}': must match ^[a-z_][a-z0-9_]*$");
    }
    Ok(())
}

/// Validates that a version constraint is safe semver without YAML injection.
///
/// # Errors
/// Returns error if constraint is empty, contains quotes, newlines, or invalid semver syntax.
pub fn validate_semver_constraint(constraint: &str) -> Result<()> {
    let trimmed = constraint.trim();
    if trimmed.is_empty() {
        anyhow::bail!("pub dependency semver constraint cannot be empty");
    }
    if trimmed.contains('\n') || trimmed.contains('\r') {
        anyhow::bail!("pub dependency constraint contains newlines");
    }
    if trimmed.contains('"') || trimmed.contains('\'') {
        anyhow::bail!("pub dependency constraint contains quotes");
    }
    if trimmed.contains(':') || trimmed.contains('{') || trimmed.contains('}') {
        anyhow::bail!("pub dependency constraint contains invalid YAML characters");
    }

    if trimmed == "any" {
        return Ok(());
    }

    for ch in trimmed.chars() {
        if !ch.is_ascii_alphanumeric()
            && ch != '.'
            && ch != '-'
            && ch != '+'
            && ch != '^'
            && ch != '>'
            && ch != '<'
            && ch != '='
            && ch != ','
            && ch != ' '
        {
            anyhow::bail!("pub dependency constraint contains invalid character: '{ch}'");
        }
    }

    let normalized = trimmed.split_whitespace().collect::<Vec<_>>().join(",");
    semver::VersionReq::parse(&normalized)
        .map_err(|e| anyhow::anyhow!("invalid semver constraint '{trimmed}': {e}"))?;

    Ok(())
}

/// Validates both dependency name and semver constraint before modifying pubspec.yaml.
///
/// # Errors
/// Returns error if name or constraint is invalid.
pub fn validate_pub_dependency(name: &str, constraint: &str) -> Result<()> {
    validate_pub_dependency_name(name)?;
    validate_semver_constraint(constraint)?;
    Ok(())
}

pub fn add_dependency(
    pubspec_path: &Path,
    dependency_name: &str,
    version_constraint: &str,
) -> Result<()> {
    validate_pub_dependency(dependency_name, version_constraint)?;
    let content = std::fs::read_to_string(pubspec_path).with_context(|| {
        format!(
            "Target project pubspec.yaml not found at: {}",
            pubspec_path.display()
        )
    })?;

    if let Ok(doc) = serde_saphyr::from_str::<serde_json::Value>(&content)
        && let Some(deps) = doc.get("dependencies")
        && deps.get(dependency_name).is_some()
    {
        return Ok(());
    }

    let backup_path = format!("{}.bak", pubspec_path.display());
    std::fs::write(&backup_path, &content)
        .with_context(|| format!("Failed to write backup to {backup_path}"))?;

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

    let dependency_line = format!("  {dependency_name}: \"{version_constraint}\"");
    let mut new_lines: Vec<String> = lines.iter().map(std::string::ToString::to_string).collect();
    new_lines.insert(dep_idx + 1, dependency_line);

    crate::utils::path_guard::atomic_write(pubspec_path, new_lines.join("\n"))
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

    if let Ok(doc) = serde_saphyr::from_str::<serde_json::Value>(&content)
        && let Some(name) = doc.get("name").and_then(|v| v.as_str())
    {
        return Ok(name.to_string());
    }

    anyhow::bail!("Could not parse 'name:' from pubspec.yaml")
}

static OP_SPACE_REGEX: LazyLock<regex::Regex> = LazyLock::new(|| {
    regex::Regex::new(r"([<>]=?|=|\^|~)\s+").expect("invariant: operator space regex is valid")
});

fn parse_version_req(constraint_str: &str) -> Option<semver::VersionReq> {
    let cleaned = constraint_str
        .trim()
        .trim_matches('\'')
        .trim_matches('"')
        .replace(',', " ");
    let collapsed = OP_SPACE_REGEX.replace_all(&cleaned, "$1");
    let normalized = collapsed.split_whitespace().collect::<Vec<_>>().join(",");
    semver::VersionReq::parse(&normalized).ok()
}

pub fn parse_min_version(constraint_str: &str) -> Option<semver::Version> {
    let req = parse_version_req(constraint_str)?;
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

    let doc: serde_json::Value = match serde_saphyr::from_str(&content) {
        Ok(d) => d,
        Err(_) => return Ok(false),
    };

    let env = match doc.get("environment") {
        Some(e) if e.is_object() => e,
        _ => return Ok(false),
    };

    let mut dart_supported = false;
    let mut checked = false;

    if let Some(sdk_str) = env.get("sdk").and_then(|v| v.as_str()) {
        checked = true;
        if let Some(min_sdk) = parse_min_version(sdk_str)
            && (min_sdk.major, min_sdk.minor) >= (3, 13)
        {
            dart_supported = true;
        }
    }

    if let Some(flutter_str) = env.get("flutter").and_then(|v| v.as_str())
        && let Some(min_flutter) = parse_min_version(flutter_str)
    {
        if (min_flutter.major, min_flutter.minor) < (3, 47) {
            return Ok(false);
        }
        if env.get("sdk").is_none() {
            checked = true;
            dart_supported = true;
        }
    }

    if checked {
        Ok(dart_supported)
    } else {
        Ok(false)
    }
}

/// Checks whether `pubspec.yaml` declares `dependency_name` under root `dependencies`.
#[must_use]
pub(crate) fn has_dependency(pubspec_path: &Path, dependency_name: &str) -> bool {
    let Ok(content) = std::fs::read_to_string(pubspec_path) else {
        return false;
    };
    let Ok(doc) = serde_saphyr::from_str::<serde_json::Value>(&content) else {
        return false;
    };
    doc.get("dependencies")
        .and_then(|deps| deps.get(dependency_name))
        .is_some()
}

/// Checks whether `pubspec.yaml` explicitly constrains `environment.flutter` below `3.50.0`.
#[must_use]
pub(crate) fn has_flutter_constraint_below_350(pubspec_path: &Path) -> bool {
    let Ok(content) = std::fs::read_to_string(pubspec_path) else {
        return false;
    };
    let Ok(doc) = serde_saphyr::from_str::<serde_json::Value>(&content) else {
        return false;
    };
    let Some(env) = doc.get("environment").filter(|e| e.is_object()) else {
        return false;
    };
    let Some(flutter_str) = env.get("flutter").and_then(|v| v.as_str()) else {
        return false;
    };
    if parse_min_version(flutter_str)
        .is_some_and(|min_flutter| (min_flutter.major, min_flutter.minor) < (3, 50))
    {
        return true;
    }
    parse_version_req(flutter_str).is_some_and(|req| {
        req.comparators.iter().any(|comp| {
            let minor = comp.minor.unwrap_or(0);
            match comp.op {
                semver::Op::Less => (comp.major, minor) <= (3, 50),
                semver::Op::LessEq => (comp.major, minor) < (3, 50),
                _ => false,
            }
        })
    })
}

/// Checks whether `pubspec.yaml` `environment` constraints target Flutter `>= 3.50.0`
/// or Dart SDK `>= 3.14.0` (without an explicit `flutter < 3.50.0` constraint).
#[must_use]
pub(crate) fn supports_material_ui(pubspec_path: &Path) -> bool {
    if has_flutter_constraint_below_350(pubspec_path) {
        return false;
    }
    let Ok(content) = std::fs::read_to_string(pubspec_path) else {
        return false;
    };
    let Ok(doc) = serde_saphyr::from_str::<serde_json::Value>(&content) else {
        return false;
    };
    let Some(env) = doc.get("environment").filter(|e| e.is_object()) else {
        return false;
    };

    if let Some(flutter_str) = env.get("flutter").and_then(|v| v.as_str())
        && let Some(min_flutter) = parse_min_version(flutter_str)
    {
        return (min_flutter.major, min_flutter.minor) >= (3, 50);
    }

    if let Some(sdk_str) = env.get("sdk").and_then(|v| v.as_str())
        && let Some(min_sdk) = parse_min_version(sdk_str)
    {
        return (min_sdk.major, min_sdk.minor) >= (3, 14);
    }

    false
}

#[cfg(test)]
#[path = "pubspec_editor_tests.rs"]
mod tests;
