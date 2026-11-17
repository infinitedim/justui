use crate::utils::fvm_detector::{detect_local_fvm_version, detect_system_flutter_version};
use crate::utils::pubspec_editor::{
    has_dependency, has_flutter_constraint_below_350, supports_material_ui,
    supports_primary_constructors,
};
use regex::Regex;
use serde::{Deserialize, Serialize};
use std::path::Path;
use std::sync::LazyLock;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default, clap::ValueEnum)]
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

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum MaterialTarget {
    MaterialUi,
    #[default]
    FlutterMaterial,
}

impl MaterialTarget {
    #[must_use]
    pub const fn import_uri(self) -> &'static str {
        match self {
            Self::MaterialUi => "package:material_ui/material_ui.dart",
            Self::FlutterMaterial => "package:flutter/material.dart",
        }
    }
}

static MATERIAL_IMPORT_REGEX: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(
        r#"(?m)^(\s*(?:import|export)\s+['"])package:(?:flutter/material\.dart|material_ui/material_ui\.dart)(['"])"#,
    )
    .expect("invariant: material import regex literal is valid")
});

/// Resolves which Material package import to emit for a Flutter project.
///
/// Rules:
/// 1. If `pubspec.yaml` does not list `material_ui` in `dependencies`, always returns
///    [`MaterialTarget::FlutterMaterial`] (`package:flutter/material.dart`).
/// 2. If local FVM version is present: `< 3.50` -> `FlutterMaterial`, `>= 3.50` -> `MaterialUi`.
/// 3. If `pubspec.yaml` constrains `flutter < 3.50` -> `FlutterMaterial`; if `flutter >= 3.50`
///    or `sdk >= 3.14` -> `MaterialUi`.
/// 4. If system `flutter --version` on the device is `>= 3.50` -> `MaterialUi`.
/// 5. Fallback -> `FlutterMaterial`.
#[must_use]
pub fn resolve_material_target(project_root: &Path) -> MaterialTarget {
    let pubspec_path = project_root.join("pubspec.yaml");
    if !has_dependency(&pubspec_path, "material_ui") {
        return MaterialTarget::FlutterMaterial;
    }

    if let Some(fvm_ver) = detect_local_fvm_version(project_root) {
        if (fvm_ver.major, fvm_ver.minor) < (3, 50) {
            return MaterialTarget::FlutterMaterial;
        }
        return MaterialTarget::MaterialUi;
    }

    if has_flutter_constraint_below_350(&pubspec_path) {
        return MaterialTarget::FlutterMaterial;
    }

    if supports_material_ui(&pubspec_path).unwrap_or(false) {
        return MaterialTarget::MaterialUi;
    }

    if let Some(sys_ver) = detect_system_flutter_version()
        && (sys_ver.major, sys_ver.minor) >= (3, 50)
    {
        return MaterialTarget::MaterialUi;
    }

    MaterialTarget::FlutterMaterial
}

/// Rewrites `package:material_ui/material_ui.dart` and `package:flutter/material.dart`
/// directive URIs in `code` to match `target`.
#[must_use]
pub fn apply_material_target(code: &str, target: MaterialTarget) -> String {
    let uri = target.import_uri();
    MATERIAL_IMPORT_REGEX
        .replace_all(code, |caps: &regex::Captures| {
            format!("{}{uri}{}", &caps[1], &caps[2])
        })
        .into_owned()
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

    #[test]
    fn test_resolve_material_target_flutter_350_with_dependency() {
        let dir = tempdir().unwrap();
        std::fs::write(
            dir.path().join("pubspec.yaml"),
            "name: app\nenvironment:\n  sdk: '>=3.13.0 <4.0.0'\ndependencies:\n  flutter:\n    sdk: flutter\n  material_ui: ^1.11.0\n",
        )
        .unwrap();
        let fvm_dir = dir.path().join(".fvm");
        std::fs::create_dir_all(&fvm_dir).unwrap();
        std::fs::write(fvm_dir.join("version"), "3.50.0\n").unwrap();

        assert_eq!(
            resolve_material_target(dir.path()),
            MaterialTarget::MaterialUi
        );
    }

    #[test]
    fn test_resolve_material_target_flutter_350_without_dependency_uses_flutter_material() {
        let dir = tempdir().unwrap();
        std::fs::write(
            dir.path().join("pubspec.yaml"),
            "name: app\nenvironment:\n  sdk: '>=3.14.0 <4.0.0'\n  flutter: '>=3.50.0'\ndependencies:\n  flutter:\n    sdk: flutter\n",
        )
        .unwrap();
        let fvm_dir = dir.path().join(".fvm");
        std::fs::create_dir_all(&fvm_dir).unwrap();
        std::fs::write(fvm_dir.join("version"), "3.50.0\n").unwrap();

        assert_eq!(
            resolve_material_target(dir.path()),
            MaterialTarget::FlutterMaterial
        );
    }

    #[test]
    fn test_resolve_material_target_older_flutter_with_dependency_uses_flutter_material() {
        let dir = tempdir().unwrap();
        std::fs::write(
            dir.path().join("pubspec.yaml"),
            "name: app\nenvironment:\n  sdk: '>=3.14.0 <4.0.0'\ndependencies:\n  flutter:\n    sdk: flutter\n  material_ui: ^1.11.0\n",
        )
        .unwrap();
        let fvm_dir = dir.path().join(".fvm");
        std::fs::create_dir_all(&fvm_dir).unwrap();
        std::fs::write(fvm_dir.join("version"), "3.47.0\n").unwrap();

        assert_eq!(
            resolve_material_target(dir.path()),
            MaterialTarget::FlutterMaterial
        );
    }

    #[test]
    fn test_resolve_material_target_pubspec_350_with_dependency_no_fvm() {
        let dir = tempdir().unwrap();
        std::fs::write(
            dir.path().join("pubspec.yaml"),
            "name: app\nenvironment:\n  flutter: '>=3.50.0'\ndependencies:\n  flutter:\n    sdk: flutter\n  material_ui: ^1.11.0\n",
        )
        .unwrap();

        assert_eq!(
            resolve_material_target(dir.path()),
            MaterialTarget::MaterialUi
        );
    }

    #[test]
    fn test_resolve_material_target_system_flutter_fallback() {
        let dir = tempdir().unwrap();
        std::fs::write(
            dir.path().join("pubspec.yaml"),
            "name: app\nenvironment:\n  sdk: '>=3.13.0 <4.0.0'\ndependencies:\n  flutter:\n    sdk: flutter\n  material_ui: ^1.11.0\n",
        )
        .unwrap();

        crate::utils::fvm_detector::set_test_system_flutter_version(Some(semver::Version::new(
            3, 50, 0,
        )));
        assert_eq!(
            resolve_material_target(dir.path()),
            MaterialTarget::MaterialUi
        );

        crate::utils::fvm_detector::set_test_system_flutter_version(Some(semver::Version::new(
            3, 47, 0,
        )));
        assert_eq!(
            resolve_material_target(dir.path()),
            MaterialTarget::FlutterMaterial
        );
        crate::utils::fvm_detector::set_test_system_flutter_version(None);
    }

    #[test]
    fn test_apply_material_target_rewrites_imports_and_preserves_comments() {
        let src_material_ui = "import 'package:material_ui/material_ui.dart' show ThemeExtension;\nimport \"package:material_ui/material_ui.dart\";\n/// without importing `package:material_ui/material_ui.dart` in widgets.\n";
        let to_flutter = apply_material_target(src_material_ui, MaterialTarget::FlutterMaterial);
        assert!(to_flutter.contains("import 'package:flutter/material.dart' show ThemeExtension;"));
        assert!(to_flutter.contains("import \"package:flutter/material.dart\";"));
        assert!(
            to_flutter.contains(
                "/// without importing `package:material_ui/material_ui.dart` in widgets."
            )
        );

        let back_to_material_ui = apply_material_target(&to_flutter, MaterialTarget::MaterialUi);
        assert_eq!(back_to_material_ui, src_material_ui);
    }
}
