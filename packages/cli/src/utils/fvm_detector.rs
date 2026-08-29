use crate::utils::pubspec_editor::parse_min_version;
use semver::Version;
use std::path::Path;

/// Detects the local Flutter version configured for a project via FVM.
/// Checks `.fvm/fvm_config.json`, `.fvmrc`, or `.fvm/flutter_sdk/version`.
pub fn detect_local_fvm_version(project_root: &Path) -> Option<Version> {
    // 1. Check .fvm/fvm_config.json
    let config_path = project_root.join(".fvm").join("fvm_config.json");
    if let Ok(content) = std::fs::read_to_string(&config_path) {
        if let Ok(doc) = serde_json::from_str::<serde_json::Value>(&content) {
            if let Some(v_str) = doc
                .get("flutter")
                .or_else(|| doc.get("flutterSdkVersion"))
                .or_else(|| doc.get("target"))
                .and_then(|v| v.as_str())
            {
                if let Some(version) = parse_min_version(v_str) {
                    return Some(version);
                }
            }
        }
    }

    // 2. Check .fvmrc
    let fvmrc_path = project_root.join(".fvmrc");
    if let Ok(content) = std::fs::read_to_string(&fvmrc_path) {
        if let Ok(doc) = serde_json::from_str::<serde_json::Value>(&content) {
            if let Some(v_str) = doc
                .get("flutter")
                .or_else(|| doc.get("flutterSdkVersion"))
                .and_then(|v| v.as_str())
            {
                if let Some(version) = parse_min_version(v_str) {
                    return Some(version);
                }
            }
        }
    }

    // 3. Check .fvm/flutter_sdk/version
    let version_file_path = project_root.join(".fvm").join("flutter_sdk").join("version");
    if let Ok(content) = std::fs::read_to_string(&version_file_path) {
        if let Some(version) = parse_min_version(&content) {
            return Some(version);
        }
    }

    None
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_detect_local_fvm_version_config_json() {
        let dir = tempdir().unwrap();
        let fvm_dir = dir.path().join(".fvm");
        std::fs::create_dir_all(&fvm_dir).unwrap();

        let config_file = fvm_dir.join("fvm_config.json");
        std::fs::write(&config_file, r#"{"flutter": "3.47.0"}"#).unwrap();

        let version = detect_local_fvm_version(dir.path()).unwrap();
        assert_eq!(version, Version::new(3, 47, 0));
    }

    #[test]
    fn test_detect_local_fvm_version_fvmrc() {
        let dir = tempdir().unwrap();
        let fvmrc_file = dir.path().join(".fvmrc");
        std::fs::write(&fvmrc_file, r#"{"flutterSdkVersion": "3.24.0"}"#).unwrap();

        let version = detect_local_fvm_version(dir.path()).unwrap();
        assert_eq!(version, Version::new(3, 24, 0));
    }

    #[test]
    fn test_detect_local_fvm_version_file() {
        let dir = tempdir().unwrap();
        let sdk_dir = dir.path().join(".fvm").join("flutter_sdk");
        std::fs::create_dir_all(&sdk_dir).unwrap();

        let version_file = sdk_dir.join("version");
        std::fs::write(&version_file, "3.47.0-0.1.pre\n").unwrap();

        let version = detect_local_fvm_version(dir.path()).unwrap();
        assert_eq!(version.major, 3);
        assert_eq!(version.minor, 47);
        assert_eq!(version.patch, 0);
    }

    #[test]
    fn test_detect_local_fvm_version_none() {
        let dir = tempdir().unwrap();
        assert!(detect_local_fvm_version(dir.path()).is_none());
    }

    #[test]
    fn test_detect_local_fvm_version_malformed_json() {
        let dir = tempdir().unwrap();
        let fvmrc_file = dir.path().join(".fvmrc");
        std::fs::write(&fvmrc_file, "invalid json {").unwrap();

        assert!(detect_local_fvm_version(dir.path()).is_none());
    }
}
