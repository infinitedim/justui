use crate::utils::pubspec_editor::parse_min_version;
use semver::Version;
use std::path::Path;

fn check_fvm_version_file(fvm_dir: &Path) -> Option<Version> {
    let version_path = fvm_dir.join("version");
    let content = std::fs::read_to_string(version_path).ok()?;
    parse_min_version(&content)
}

fn check_flutter_version_json(fvm_dir: &Path) -> Option<Version> {
    let json_path = fvm_dir
        .join("flutter_sdk")
        .join("bin")
        .join("cache")
        .join("flutter.version.json");
    let content = std::fs::read_to_string(json_path).ok()?;
    let doc: serde_json::Value = serde_json::from_str(&content).ok()?;
    let v_str = doc
        .get("frameworkVersion")
        .or_else(|| doc.get("flutterVersion"))
        .and_then(|v| v.as_str())?;
    parse_min_version(v_str)
}

fn check_flutter_sdk_version_file(fvm_dir: &Path) -> Option<Version> {
    let version_path = fvm_dir.join("flutter_sdk").join("version");
    let content = std::fs::read_to_string(version_path).ok()?;
    parse_min_version(&content)
}

fn check_fvm_release_file(fvm_dir: &Path) -> Option<Version> {
    let release_path = fvm_dir.join("release");
    let content = std::fs::read_to_string(release_path).ok()?;
    parse_min_version(&content)
}

fn check_fvm_config_json(fvm_dir: &Path) -> Option<Version> {
    let config_path = fvm_dir.join("fvm_config.json");
    let content = std::fs::read_to_string(config_path).ok()?;
    let doc: serde_json::Value = serde_json::from_str(&content).ok()?;
    let v_str = doc
        .get("flutter")
        .or_else(|| doc.get("flutterSdkVersion"))
        .or_else(|| doc.get("flutter_version"))
        .or_else(|| doc.get("version"))
        .or_else(|| doc.get("target"))
        .and_then(|v| v.as_str())?;
    parse_min_version(v_str)
}

fn check_fvmrc(dir: &Path) -> Option<Version> {
    let fvmrc_path = dir.join(".fvmrc");
    let content = std::fs::read_to_string(fvmrc_path).ok()?;
    if let Some(v) = parse_min_version(&content) {
        return Some(v);
    }
    let doc: serde_json::Value = serde_json::from_str(&content).ok()?;
    let v_str = doc
        .get("flutter")
        .or_else(|| doc.get("flutterSdkVersion"))
        .or_else(|| doc.get("flutter_version"))
        .or_else(|| doc.get("version"))
        .and_then(|v| v.as_str())?;
    parse_min_version(v_str)
}

fn check_flutter_binary(fvm_dir: &Path) -> Option<Version> {
    let flutter_bin = fvm_dir.join("flutter_sdk").join("bin").join("flutter");
    if !flutter_bin.is_file() {
        return None;
    }
    let output = std::process::Command::new(&flutter_bin)
        .arg("--version")
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }
    let stdout = String::from_utf8_lossy(&output.stdout);
    for word in stdout.split_whitespace() {
        if let Some(v) = parse_min_version(word) {
            return Some(v);
        }
    }
    None
}

fn check_fvm_in_dir(dir: &Path) -> Option<Version> {
    let fvm_dir = dir.join(".fvm");

    // Tier 1: Check .fvm/version
    if let Some(v) = check_fvm_version_file(&fvm_dir) {
        return Some(v);
    }

    // Tier 2: Check .fvm/release
    if let Some(v) = check_fvm_release_file(&fvm_dir) {
        return Some(v);
    }

    // Tier 3: Check .fvm/flutter_sdk/bin/cache/flutter.version.json
    if let Some(v) = check_flutter_version_json(&fvm_dir) {
        return Some(v);
    }

    // Tier 4: Check .fvm/flutter_sdk/version
    if let Some(v) = check_flutter_sdk_version_file(&fvm_dir) {
        return Some(v);
    }

    // Tier 5: Check .fvm/fvm_config.json
    if let Some(v) = check_fvm_config_json(&fvm_dir) {
        return Some(v);
    }

    // Tier 6: Check .fvmrc
    if let Some(v) = check_fvmrc(dir) {
        return Some(v);
    }

    // Tier 7: Subprocess execution fallback
    if let Some(v) = check_flutter_binary(&fvm_dir) {
        return Some(v);
    }

    None
}

/// Detects the local Flutter version configured for a project via FVM.
/// Checks current directory and all ancestor directories (monorepo support).
pub fn detect_local_fvm_version(project_root: &Path) -> Option<Version> {
    let canonical = project_root
        .canonicalize()
        .or_else(|_| std::env::current_dir().map(|cwd| cwd.join(project_root)))
        .unwrap_or_else(|_| project_root.to_path_buf());

    for dir in canonical.ancestors() {
        if let Some(version) = check_fvm_in_dir(dir) {
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
    fn test_detect_local_fvm_version_direct_file() {
        let dir = tempdir().unwrap();
        let fvm_dir = dir.path().join(".fvm");
        std::fs::create_dir_all(&fvm_dir).unwrap();

        let version_file = fvm_dir.join("version");
        std::fs::write(&version_file, "3.47.0\n").unwrap();

        let version = detect_local_fvm_version(dir.path()).unwrap();
        assert_eq!(version, Version::new(3, 47, 0));
    }

    #[test]
    fn test_detect_local_fvm_version_json_cache() {
        let dir = tempdir().unwrap();
        let cache_dir = dir
            .path()
            .join(".fvm")
            .join("flutter_sdk")
            .join("bin")
            .join("cache");
        std::fs::create_dir_all(&cache_dir).unwrap();

        let json_file = cache_dir.join("flutter.version.json");
        std::fs::write(
            &json_file,
            r#"{"frameworkVersion": "3.47.0", "dartSdkVersion": "3.13.0"}"#,
        )
        .unwrap();

        let version = detect_local_fvm_version(dir.path()).unwrap();
        assert_eq!(version, Version::new(3, 47, 0));
    }

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
    fn test_detect_local_fvm_version_plain_text_fvmrc() {
        let dir = tempdir().unwrap();
        let fvmrc_file = dir.path().join(".fvmrc");
        std::fs::write(&fvmrc_file, "3.47.0\n").unwrap();

        let version = detect_local_fvm_version(dir.path()).unwrap();
        assert_eq!(version, Version::new(3, 47, 0));
    }

    #[test]
    fn test_detect_local_fvm_version_release_file() {
        let dir = tempdir().unwrap();
        let fvm_dir = dir.path().join(".fvm");
        std::fs::create_dir_all(&fvm_dir).unwrap();
        std::fs::write(fvm_dir.join("release"), "3.47.0\n").unwrap();

        let version = detect_local_fvm_version(dir.path()).unwrap();
        assert_eq!(version, Version::new(3, 47, 0));
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
    fn test_detect_local_fvm_ancestor_traversal() {
        let root = tempdir().unwrap();
        let fvm_dir = root.path().join(".fvm");
        std::fs::create_dir_all(&fvm_dir).unwrap();
        std::fs::write(fvm_dir.join("version"), "3.47.0\n").unwrap();

        let nested_app = root.path().join("apps").join("showcase");
        std::fs::create_dir_all(&nested_app).unwrap();

        let version = detect_local_fvm_version(&nested_app).unwrap();
        assert_eq!(version, Version::new(3, 47, 0));
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
