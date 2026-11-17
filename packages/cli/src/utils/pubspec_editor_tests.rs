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

#[test]
fn test_yaml_parsing_handles_real_world_pubspec_syntax() {
    let dir = tempdir().unwrap();
    let path = dir.path().join("pubspec.yaml");
    let content = "# comment\n\
        name: \"quoted_app\"\n\
        1: numeric key\n\
        versions: &v '>=3.13.0 <4.0.0'\n\
        environment:\n  sdk: *v\n\
        dependencies:\n  flutter: {sdk: flutter}\n  http: ^1.0.0\n";
    std::fs::write(&path, content).unwrap();

    assert_eq!(get_package_name(&path).unwrap(), "quoted_app");
    assert!(supports_primary_constructors(&path).unwrap());
    // Existing dependency is detected, so the file is left untouched.
    add_dependency(&path, "http", "^1.0.0").unwrap();
    assert_eq!(std::fs::read_to_string(&path).unwrap(), content);
}

#[test]
fn test_validate_pub_dependency() {
    assert!(validate_pub_dependency("http", "^1.0.0").is_ok());
    assert!(validate_pub_dependency("path_provider", ">=2.0.0 <3.0.0").is_ok());
    assert!(validate_pub_dependency("_internal_pkg", "any").is_ok());

    // Invalid names
    assert!(validate_pub_dependency("BadName", "^1.0.0").is_err());
    assert!(validate_pub_dependency("123bad", "^1.0.0").is_err());
    assert!(validate_pub_dependency("bad-name", "^1.0.0").is_err());

    // Malicious / invalid semver
    assert!(validate_pub_dependency("http", "^1.0.0\n  evil: true").is_err());
    assert!(validate_pub_dependency("http", "git: https://evil.com").is_err());
    assert!(validate_pub_dependency("http", "\"^1.0.0\"").is_err());
    assert!(validate_pub_dependency("http", "").is_err());
}

#[test]
fn test_has_dependency_and_supports_material_ui() {
    let dir = tempdir().unwrap();

    let with_material_ui = dir.path().join("with_material_ui.yaml");
    std::fs::write(
        &with_material_ui,
        "name: app\nenvironment:\n  sdk: '>=3.14.0 <4.0.0'\n  flutter: '>=3.50.0'\ndependencies:\n  flutter:\n    sdk: flutter\n  material_ui: ^1.11.0\ndev_dependencies:\n  flutter_test:\n    sdk: flutter\n",
    )
    .unwrap();
    assert!(has_dependency(&with_material_ui, "material_ui"));
    assert!(!has_dependency(&with_material_ui, "flutter_test"));
    assert!(!has_dependency(&with_material_ui, "cupertino_ui"));
    assert!(supports_material_ui(&with_material_ui));

    let sdk_314_only = dir.path().join("sdk_314.yaml");
    std::fs::write(&sdk_314_only, "environment:\n  sdk: '^3.14.0'\n").unwrap();
    assert!(supports_material_ui(&sdk_314_only));

    let flutter_350_only = dir.path().join("flutter_350.yaml");
    std::fs::write(&flutter_350_only, "environment:\n  flutter: '>= 3.50.0'\n").unwrap();
    assert!(supports_material_ui(&flutter_350_only));

    let upper_bound_only = dir.path().join("upper_bound_only.yaml");
    std::fs::write(
        &upper_bound_only,
        "environment:\n  sdk: '>=3.14.0 <4.0.0'\n  flutter: '<3.50.0'\n",
    )
    .unwrap();
    assert!(has_flutter_constraint_below_350(&upper_bound_only));

    let older_flutter_override = dir.path().join("older_flutter.yaml");
    std::fs::write(
        &older_flutter_override,
        "environment:\n  sdk: '>=3.14.0 <4.0.0'\n  flutter: '>=3.41.0'\n",
    )
    .unwrap();
    assert!(!supports_material_ui(&older_flutter_override));

    let older_sdk = dir.path().join("older_sdk.yaml");
    std::fs::write(&older_sdk, "environment:\n  sdk: '>=3.13.0 <4.0.0'\n").unwrap();
    assert!(!supports_material_ui(&older_sdk));

    let missing = dir.path().join("missing.yaml");
    assert!(!has_dependency(&missing, "material_ui"));
    assert!(!has_flutter_constraint_below_350(&missing));
    assert!(!supports_material_ui(&missing));
}
