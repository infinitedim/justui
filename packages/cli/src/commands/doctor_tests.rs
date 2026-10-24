use super::*;
use std::fs;

#[test]
fn test_doctor_all_ok_and_toolchain_edge_cases() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());

    // 1. Create pubspec with just_ui_core dependency
    fs::write(
        "pubspec.yaml",
        "name: test_app\ndependencies:\n  just_ui_core: ^1.0.0\n",
    )
    .unwrap();

    // 2. Create index.json for local directory registry URL
    let registry_dir = temp_dir.path().join("registry");
    fs::create_dir_all(&registry_dir).unwrap();
    fs::write(
        registry_dir.join("index.json"),
        r#"{"version":"1.0.0","components":[],"presets":[]}"#,
    )
    .unwrap();

    let components_dir = temp_dir.path().join("lib/components");
    let tokens_dir = temp_dir.path().join("lib/tokens");
    let shared_dir = temp_dir.path().join("lib/shared");
    fs::create_dir_all(&components_dir).unwrap();
    fs::create_dir_all(&tokens_dir).unwrap();
    fs::create_dir_all(&shared_dir).unwrap();

    // Write config with local directory registry_url
    let config_yaml = format!(
        "version: '1.0'\ncomponents_dir: '{}'\ntokens_dir: '{}'\nshared_dir: '{}'\nregistry_url: '{}'\npreset: default\ndart_target: primary\n",
        components_dir.display(),
        tokens_dir.display(),
        shared_dir.display(),
        registry_dir.display()
    );
    fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // Run checks - confirms registry reachability and OK outcome
    let checks = perform_checks();
    assert!(
        checks
            .iter()
            .any(|c| c.title == "Registry Index" && c.status == CheckStatus::Ok)
    );
    assert!(
        checks
            .iter()
            .any(|c| c.title == "JustUI Packages" && c.status == CheckStatus::Ok)
    );

    // Mock toolchain binaries are `#!/bin/sh` scripts, so this part is unix only.
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;

        let bin_dir = temp_dir.path().join("mock_bin");
        fs::create_dir_all(&bin_dir).unwrap();

        // Mock Dart script returning empty stdout and stderr
        let dart_empty_bin = bin_dir.join("dart");
        fs::write(&dart_empty_bin, "#!/bin/sh\n").unwrap();
        fs::set_permissions(&dart_empty_bin, fs::Permissions::from_mode(0o755)).unwrap();

        set_test_toolchain_dir(Some(bin_dir));

        let checks_empty_dart = perform_checks();
        let dart_check = checks_empty_dart
            .iter()
            .find(|c| c.title == "Dart SDK")
            .unwrap();
        assert_eq!(dart_check.message, "Dart SDK active");
    }

    // Set override to test CLI missing warning
    set_test_toolchain_dir(None);
    set_test_override_empty_path(true);
    let checks_missing_tools = perform_checks();
    assert!(
        checks_missing_tools
            .iter()
            .any(|c| c.title == "Dart SDK" && c.status == CheckStatus::Warning)
    );
    assert!(
        checks_missing_tools
            .iter()
            .any(|c| c.title == "Flutter SDK" && c.status == CheckStatus::Warning)
    );

    set_test_override_empty_path(false);
}

#[test]
fn test_doctor_run_all_status_outcomes() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());

    // Uninitialized: returns warnings
    assert!(run().is_ok());

    // Create valid config and pubspec for OK status
    fs::write(
        "pubspec.yaml",
        "name: test_app\ndependencies:\n  just_ui_tokens: ^1.0.0\n",
    )
    .unwrap();

    let components_dir = temp_dir.path().join("lib/components");
    let tokens_dir = temp_dir.path().join("lib/tokens");
    let shared_dir = temp_dir.path().join("lib/shared");
    let registry_dir = temp_dir.path().join("registry");
    fs::create_dir_all(&components_dir).unwrap();
    fs::create_dir_all(&tokens_dir).unwrap();
    fs::create_dir_all(&shared_dir).unwrap();
    fs::create_dir_all(&registry_dir).unwrap();
    fs::write(
        registry_dir.join("index.json"),
        r#"{"version":"1.0.0","components":[],"presets":[]}"#,
    )
    .unwrap();

    let config_yaml = format!(
        "version: '1.0'\ncomponents_dir: '{}'\ntokens_dir: '{}'\nshared_dir: '{}'\nregistry_url: '{}'\npreset: default\ndart_target: primary\n",
        components_dir.display(),
        tokens_dir.display(),
        shared_dir.display(),
        registry_dir.display()
    );
    fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

    // Mock PATH with working flutter and dart
    let bin_dir = temp_dir.path().join("bin");
    fs::create_dir_all(&bin_dir).unwrap();
    let flutter_bin = bin_dir.join("flutter");
    let dart_bin = bin_dir.join("dart");
    fs::write(&flutter_bin, "#!/bin/sh\necho 'Flutter 3.19.0'\n").unwrap();
    fs::write(&dart_bin, "#!/bin/sh\necho 'Dart 3.3.0'\n").unwrap();
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        fs::set_permissions(&flutter_bin, fs::Permissions::from_mode(0o755)).unwrap();
        fs::set_permissions(&dart_bin, fs::Permissions::from_mode(0o755)).unwrap();
    }
    set_test_toolchain_dir(Some(bin_dir));

    // Run when all checks are OK (triggers line 68)
    assert!(run().is_ok());

    set_test_toolchain_dir(None);
}

#[test]
fn test_doctor_perform_checks_comprehensive() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());

    // 1. Check uninitialized (no pubspec.yaml, no config)
    let checks_uninit = perform_checks();
    assert!(
        checks_uninit
            .iter()
            .any(|c| c.status == CheckStatus::Error && c.title == "pubspec.yaml")
    );
    assert!(
        checks_uninit
            .iter()
            .any(|c| c.status == CheckStatus::Warning && c.title == "justui.config.yaml")
    );

    // 2. Add pubspec without just_ui dependencies
    fs::write("pubspec.yaml", "name: my_app\n").unwrap();
    let checks_no_deps = perform_checks();
    assert!(
        checks_no_deps
            .iter()
            .any(|c| c.status == CheckStatus::Warning && c.title == "JustUI Packages")
    );

    // 3. Add pubspec with just_ui_core
    fs::write(
        "pubspec.yaml",
        "name: my_app\ndependencies:\n  just_ui_core: 1.0.0\n",
    )
    .unwrap();
    let checks_core_dep = perform_checks();
    assert!(
        checks_core_dep
            .iter()
            .any(|c| c.status == CheckStatus::Ok && c.title == "JustUI Packages")
    );

    // 4. Add config with non-existent directories and invalid registry URL
    let config_yaml = r"
version: '1.0'
components_dir: lib/non_existent_components
tokens_dir: lib/non_existent_tokens
shared_dir: lib/non_existent_shared
registry_url: http://127.0.0.1:59999/non_existent_registry_index.json
preset: default
dart_target: standard
";
    fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();
    let checks_config = perform_checks();
    assert!(
        checks_config
            .iter()
            .any(|c| c.title == "Components Directory" && c.status == CheckStatus::Warning)
    );
    assert!(
        checks_config
            .iter()
            .any(|c| c.title == "Tokens Directory" && c.status == CheckStatus::Warning)
    );
    assert!(
        checks_config
            .iter()
            .any(|c| c.title == "Shared Directory" && c.status == CheckStatus::Warning)
    );
    assert!(
        checks_config
            .iter()
            .any(|c| c.title == "Dart Target" && c.message.contains("standard"))
    );
    assert!(
        checks_config
            .iter()
            .any(|c| c.title == "Registry Index" && c.status == CheckStatus::Warning)
    );
}

// Mock toolchain binaries are `#!/bin/sh` scripts, which Windows cannot run.
#[cfg(unix)]
#[test]
fn test_doctor_toolchain_version_parsing_fallbacks() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());

    // Create mock binary dir
    let bin_dir = temp_dir.path().join("bin");
    fs::create_dir_all(&bin_dir).unwrap();

    // 1. Flutter script returning stdout version
    let flutter_bin = bin_dir.join("flutter");
    fs::write(
        &flutter_bin,
        "#!/bin/sh\necho 'Flutter 3.19.0 - channel stable'\n",
    )
    .unwrap();

    // 2. Dart script returning version on stderr fallback
    let dart_bin = bin_dir.join("dart");
    fs::write(
        &dart_bin,
        "#!/bin/sh\necho 'Dart SDK version: 3.3.0 (stable)' >&2\n",
    )
    .unwrap();

    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        fs::set_permissions(&flutter_bin, fs::Permissions::from_mode(0o755)).unwrap();
        fs::set_permissions(&dart_bin, fs::Permissions::from_mode(0o755)).unwrap();
    }

    set_test_toolchain_dir(Some(bin_dir));

    let checks = perform_checks();
    let flutter_check = checks.iter().find(|c| c.title == "Flutter SDK").unwrap();
    assert_eq!(flutter_check.status, CheckStatus::Ok);
    assert!(flutter_check.message.contains("Flutter 3.19.0"));

    let dart_check = checks.iter().find(|c| c.title == "Dart SDK").unwrap();
    assert_eq!(dart_check.status, CheckStatus::Ok);
    assert!(dart_check.message.contains("Dart SDK version: 3.3.0"));

    set_test_toolchain_dir(None);
}

#[test]
fn test_doctor_healthy_project() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());

    // Create pubspec.yaml with just_ui_tokens
    std::fs::write(
        temp_dir.path().join("pubspec.yaml"),
        "name: test_app\ndependencies:\n  just_ui_tokens: ^1.0.0\n",
    )
    .unwrap();

    // Create directories
    let comp_dir = temp_dir.path().join("lib/src/components");
    let token_dir = temp_dir.path().join("lib/src/tokens");
    let shared_dir = temp_dir.path().join("lib/src/shared");
    std::fs::create_dir_all(&comp_dir).unwrap();
    std::fs::create_dir_all(&token_dir).unwrap();
    std::fs::create_dir_all(&shared_dir).unwrap();

    // Create local registry directory with index.json
    let reg_dir = temp_dir.path().join("registry");
    std::fs::create_dir_all(&reg_dir).unwrap();
    std::fs::write(
        reg_dir.join("index.json"),
        r#"{"version":"1.0.0","presets":["default"],"components":[]}"#,
    )
    .unwrap();

    // Create justui.config.yaml
    let config_yaml = format!(
        "registry_url: {}\ncomponents_dir: {}\ntokens_dir: {}\nshared_dir: {}\n",
        reg_dir.to_string_lossy(),
        comp_dir.to_string_lossy(),
        token_dir.to_string_lossy(),
        shared_dir.to_string_lossy(),
    );
    std::fs::write(temp_dir.path().join("justui.config.yaml"), config_yaml).unwrap();

    let checks = perform_checks();
    assert!(
        checks
            .iter()
            .any(|c| c.title == "JustUI Packages" && c.status == CheckStatus::Ok)
    );
    assert!(
        checks
            .iter()
            .any(|c| c.title == "Components Directory" && c.status == CheckStatus::Ok)
    );
    assert!(
        checks
            .iter()
            .any(|c| c.title == "Registry Index" && c.status == CheckStatus::Ok)
    );

    assert!(run().is_ok());
}

#[test]
fn test_doctor_warnings_matrix() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());

    // Create pubspec.yaml WITHOUT just_ui dependencies
    std::fs::write(
        temp_dir.path().join("pubspec.yaml"),
        "name: test_app\ndependencies:\n  flutter:\n    sdk: flutter\n",
    )
    .unwrap();

    // Create config with non-existent directories and invalid registry URL
    let config_yaml = "registry_url: http://invalid.invalid/registry\ncomponents_dir: non_existent_comp\ntokens_dir: non_existent_token\nshared_dir: non_existent_shared\n";
    std::fs::write(temp_dir.path().join("justui.config.yaml"), config_yaml).unwrap();

    let checks = perform_checks();
    assert!(
        checks
            .iter()
            .any(|c| c.title == "JustUI Packages" && c.status == CheckStatus::Warning)
    );
    assert!(
        checks
            .iter()
            .any(|c| c.title == "Components Directory" && c.status == CheckStatus::Warning)
    );
    assert!(
        checks
            .iter()
            .any(|c| c.title == "Tokens Directory" && c.status == CheckStatus::Warning)
    );
    assert!(
        checks
            .iter()
            .any(|c| c.title == "Shared Directory" && c.status == CheckStatus::Warning)
    );
    assert!(
        checks
            .iter()
            .any(|c| c.title == "Registry Index" && c.status == CheckStatus::Warning)
    );

    assert!(run().is_ok());
}

#[test]
fn test_doctor_errors_matrix() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());

    // No pubspec.yaml -> triggers CheckStatus::Error
    let checks = perform_checks();
    assert!(
        checks
            .iter()
            .any(|c| c.title == "pubspec.yaml" && c.status == CheckStatus::Error)
    );

    assert!(run().is_ok());
}

#[test]
fn test_print_doctor_report_perfect_health() {
    let checks = vec![DoctorCheck {
        category: "Test".to_string(),
        title: "Perfect".to_string(),
        status: CheckStatus::Ok,
        message: "All good".to_string(),
    }];
    print_doctor_report(&checks);
}

#[test]
fn test_check_toolchain_helpers() {
    let check_invalid = check_toolchain("non_existent_binary_xyz_123", "NonExistent");
    assert_eq!(check_invalid.status, CheckStatus::Warning);
}

#[test]
fn test_doctor_registry_source_check() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = crate::utils::set_dir(temp_dir.path());
    crate::utils::trust_store::set_test_config_dir(Some(temp_dir.path().to_path_buf()));

    // 1. Official registry is trusted
    let config_yaml = format!(
        "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\npreset: default\nregistry_url: {}\n",
        JustUIConfig::DEFAULT_REGISTRY_URL
    );
    fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();
    let checks = perform_checks();
    let reg_check = checks
        .iter()
        .find(|c| c.title == "Registry Source")
        .unwrap();
    assert_eq!(reg_check.status, CheckStatus::Ok);
    assert!(reg_check.message.contains("official (trusted)"));

    // 2. Custom registry untrusted initially
    let custom_yaml = "components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\npreset: default\nregistry_url: https://my-custom.reg.io\n";
    fs::write(JustUIConfig::CONFIG_FILE_NAME, custom_yaml).unwrap();
    let checks_custom = perform_checks();
    let reg_check_custom = checks_custom
        .iter()
        .find(|c| c.title == "Registry Source")
        .unwrap();
    assert_eq!(reg_check_custom.status, CheckStatus::Warning);
    assert!(reg_check_custom.message.contains("custom (untrusted)"));

    // 3. Custom registry once trusted becomes Ok
    let mut store = crate::utils::trust_store::TrustStore::load();
    store.add_trust("https://my-custom.reg.io").unwrap();
    let checks_trusted = perform_checks();
    let reg_check_trusted = checks_trusted
        .iter()
        .find(|c| c.title == "Registry Source")
        .unwrap();
    assert_eq!(reg_check_trusted.status, CheckStatus::Ok);
    assert!(reg_check_trusted.message.contains("custom (trusted)"));

    crate::utils::trust_store::set_test_config_dir(None);
}
