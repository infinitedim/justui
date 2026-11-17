use super::*;
use proptest::prelude::*;
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
fn test_resolve_material_target_upper_bound_below_350_overrides_sdk_314() {
    let dir = tempdir().unwrap();
    std::fs::write(
        dir.path().join("pubspec.yaml"),
        "name: app\nenvironment:\n  sdk: '>=3.14.0 <4.0.0'\n  flutter: '<3.50.0'\ndependencies:\n  flutter:\n    sdk: flutter\n  material_ui: ^1.11.0\n",
    )
    .unwrap();

    assert_eq!(
        resolve_material_target(dir.path()),
        MaterialTarget::FlutterMaterial
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
fn test_apply_material_target_snapshot() {
    let src = "\
import 'package:material_ui/material_ui.dart' show ThemeExtension;
import \"package:material_ui/material_ui.dart\" show Icons;
export 'package:material_ui/material_ui.dart';
/// without importing `package:material_ui/material_ui.dart` in widgets.
import 'package:flutter/widgets.dart';
";

    let to_flutter = apply_material_target(src, MaterialTarget::FlutterMaterial);
    insta::assert_snapshot!(to_flutter, @r#"
    import 'package:flutter/material.dart' show ThemeExtension;
    import "package:flutter/material.dart" show Icons;
    export 'package:flutter/material.dart';
    /// without importing `package:material_ui/material_ui.dart` in widgets.
    import 'package:flutter/widgets.dart';
    "#);

    let back_to_material_ui = apply_material_target(&to_flutter, MaterialTarget::MaterialUi);
    assert_eq!(back_to_material_ui, src);
}

proptest! {
    #[test]
    fn proptest_apply_material_target_preserves_unrelated_input(
        input in "[a-zA-Z0-9_ \n;:'\"./(){}=+-]{0,200}"
    ) {
        prop_assume!(!input.contains("flutter/material.dart"));
        prop_assume!(!input.contains("material_ui/material_ui.dart"));
        let to_flutter = apply_material_target(&input, MaterialTarget::FlutterMaterial);
        let to_mui = apply_material_target(&input, MaterialTarget::MaterialUi);
        prop_assert_eq!(to_flutter.as_str(), input.as_str());
        prop_assert_eq!(to_mui.as_str(), input.as_str());
    }
}
