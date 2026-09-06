use crate::utils::fvm_detector::detect_local_fvm_version;
use crate::utils::pubspec_editor::supports_primary_constructors;
use serde::{Deserialize, Serialize};
use std::path::Path;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum DartTarget {
    Primary,
    #[default]
    Standard,
}

/// Resolves the target Dart constructor syntax for a Flutter project.
///
/// Hierarchy of Truth:
/// 1. `pubspec.yaml` constraint check (must be >= 3.13.0 for Dart or >= 3.47.0 for Flutter).
/// 2. If FVM local version is present, it can override or boost:
///    - If FVM version < 3.47.0, forces `DartTarget::Standard` (safety override).
///    - If FVM version >= 3.47.0, boosts to `DartTarget::Primary`.
/// 3. Fail-safe fallback: `DartTarget::Standard`.
pub fn resolve_dart_target(project_root: &Path) -> DartTarget {
    let pubspec_path = project_root.join("pubspec.yaml");

    let local_fvm = detect_local_fvm_version(project_root);
    let pubspec_supports = supports_primary_constructors(&pubspec_path).unwrap_or(false);

    if let Some(ref fvm_ver) = local_fvm {
        if (fvm_ver.major, fvm_ver.minor) < (3, 47) {
            return DartTarget::Standard;
        }
        if (fvm_ver.major, fvm_ver.minor) >= (3, 47) {
            return DartTarget::Primary;
        }
    }

    if pubspec_supports {
        return DartTarget::Primary;
    }

    DartTarget::Standard
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_resolve_dart_target_pubspec_primary_no_fvm() {
        let dir = tempdir().unwrap();
        let pubspec = dir.path().join("pubspec.yaml");
        std::fs::write(&pubspec, "environment:\n  sdk: '>=3.13.0 <4.0.0'\n").unwrap();

        assert_eq!(resolve_dart_target(dir.path()), DartTarget::Primary);
    }

    #[test]
    fn test_resolve_dart_target_pubspec_primary_with_older_fvm_override() {
        let dir = tempdir().unwrap();
        let pubspec = dir.path().join("pubspec.yaml");
        std::fs::write(&pubspec, "environment:\n  sdk: '>=3.13.0 <4.0.0'\n").unwrap();

        let fvm_dir = dir.path().join(".fvm");
        std::fs::create_dir_all(&fvm_dir).unwrap();
        std::fs::write(fvm_dir.join("fvm_config.json"), r#"{"flutter": "3.22.0"}"#).unwrap();

        // Older local FVM overrides pubspec to Standard for team safety
        assert_eq!(resolve_dart_target(dir.path()), DartTarget::Standard);
    }

    #[test]
    fn test_resolve_dart_target_pubspec_standard_with_newer_fvm_boost() {
        let dir = tempdir().unwrap();
        let pubspec = dir.path().join("pubspec.yaml");
        std::fs::write(&pubspec, "environment:\n  sdk: '>=3.0.0 <4.0.0'\n").unwrap();

        let fvm_dir = dir.path().join(".fvm");
        std::fs::create_dir_all(&fvm_dir).unwrap();
        std::fs::write(fvm_dir.join("fvm_config.json"), r#"{"flutter": "3.47.0"}"#).unwrap();

        // Newer local FVM boosts target to Primary
        assert_eq!(resolve_dart_target(dir.path()), DartTarget::Primary);
    }

    #[test]
    fn test_resolve_dart_target_fallback_standard() {
        let dir = tempdir().unwrap();
        let pubspec = dir.path().join("pubspec.yaml");
        std::fs::write(&pubspec, "environment:\n  sdk: '>=3.0.0 <4.0.0'\n").unwrap();

        assert_eq!(resolve_dart_target(dir.path()), DartTarget::Standard);
    }

    #[test]
    fn test_resolve_dart_target_missing_pubspec_fallback() {
        let dir = tempdir().unwrap();
        assert_eq!(resolve_dart_target(dir.path()), DartTarget::Standard);
    }
}
