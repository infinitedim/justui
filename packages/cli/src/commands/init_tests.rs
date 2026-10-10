use super::*;

use crate::utils::set_dir;

#[test]
fn test_init_helpers() {
    assert_eq!(PresetArg::Default.as_str(), "default");
    assert_eq!(PresetArg::Neobrutalism.as_str(), "neobrutalism");
    assert_eq!(ColorSpaceArg::Hsl.as_str(), "hsl");
    assert_eq!(ColorSpaceArg::Oklch.as_str(), "oklch");
    assert_eq!(ColorSpaceArg::Hsluv.as_str(), "hsluv");

    assert_eq!(to_lib_path("widgets"), "lib/widgets");
    assert_eq!(to_lib_path("lib/components"), "lib/components");

    assert_eq!(
        resolve_shared_dir("", "lib/widgets", "lib/widgets/shared"),
        "lib/widgets/shared"
    );
    assert_eq!(
        resolve_shared_dir("common", "lib/widgets", "lib/widgets/shared"),
        "lib/widgets/common"
    );
    assert_eq!(
        resolve_shared_dir("lib/shared_custom", "lib/widgets", "lib/widgets/shared"),
        "lib/shared_custom"
    );
}

#[test]
fn test_init_run_execution() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    // 1. Without pubspec -> fails with error
    assert!(
        run(InitArgs {
            auto_yes: true,
            ..Default::default()
        })
        .is_err()
    );

    // 2. With pubspec -> succeeds in auto_yes mode
    std::fs::write(temp_dir.path().join("pubspec.yaml"), "name: test_app").unwrap();
    assert!(
        run(InitArgs {
            preset: Some(PresetArg::Neobrutalism),
            color_space: Some(ColorSpaceArg::Oklch),
            auto_yes: true,
            ..Default::default()
        })
        .is_ok()
    );

    let theme_path = temp_dir.path().join("lib/core/theme/just_theme.dart");
    let theme_file = std::fs::read_to_string(&theme_path).unwrap();
    assert!(!theme_file.contains("justThemeExtensions"));

    // The scaffolded theme file must already be dart-format-clean, so it
    // isn't immediately flagged as "modified" the moment a contributor
    // (or their editor) runs `dart format` on a fresh project.
    let format_check = std::process::Command::new("dart")
        .arg("format")
        .arg("--output=none")
        .arg("--set-exit-if-changed")
        .arg(&theme_path)
        .status();
    if let Ok(status) = format_check {
        assert!(
            status.success(),
            "scaffolded theme file must already be dart-format-clean"
        );
    }

    // 3. Already initialized -> warns and returns Ok
    assert!(
        run(InitArgs {
            auto_yes: true,
            ..Default::default()
        })
        .is_ok()
    );
}

#[test]
fn test_init_default_auto_detect_primary() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    std::fs::write(
        temp_dir.path().join("pubspec.yaml"),
        "name: test_app\nenvironment:\n  sdk: '>=3.13.0 <4.0.0'\n",
    )
    .unwrap();

    let result = run(InitArgs {
        preset: Some(PresetArg::Default),
        auto_yes: true,
        ..Default::default()
    });
    assert!(result.is_ok());

    let config_content =
        std::fs::read_to_string(temp_dir.path().join("justui.config.yaml")).unwrap();
    assert!(config_content.contains("dart_target: primary"));
}

#[test]
fn test_init_default_auto_detect_standard_older_sdk() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    std::fs::write(
        temp_dir.path().join("pubspec.yaml"),
        "name: test_app\nenvironment:\n  sdk: '>=3.0.0 <4.0.0'\n",
    )
    .unwrap();

    let result = run(InitArgs {
        preset: Some(PresetArg::Default),
        auto_yes: true,
        ..Default::default()
    });
    assert!(result.is_ok());

    let config_content =
        std::fs::read_to_string(temp_dir.path().join("justui.config.yaml")).unwrap();
    assert!(config_content.contains("dart_target: standard"));
}

#[test]
fn test_init_explicit_dart_target_override() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    // Even with older sdk, --dart-target primary overrides to primary
    std::fs::write(
        temp_dir.path().join("pubspec.yaml"),
        "name: test_app\nenvironment:\n  sdk: '>=3.0.0 <4.0.0'\n",
    )
    .unwrap();

    let result = run(InitArgs {
        preset: Some(PresetArg::Default),
        dart_target: Some(crate::utils::env_resolver::DartTarget::Primary),
        auto_yes: true,
        ..Default::default()
    });
    assert!(result.is_ok());

    let config_content =
        std::fs::read_to_string(temp_dir.path().join("justui.config.yaml")).unwrap();
    assert!(config_content.contains("dart_target: primary"));
}

#[test]
fn test_init_unknown_experimental_warns() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    std::fs::write(temp_dir.path().join("pubspec.yaml"), "name: test_app").unwrap();

    let result = run(InitArgs {
        preset: Some(PresetArg::Default),
        experimental: Some("unknown-feature".to_string()),
        auto_yes: true,
        ..Default::default()
    });
    assert!(result.is_ok());

    let config_content =
        std::fs::read_to_string(temp_dir.path().join("justui.config.yaml")).unwrap();
    assert!(config_content.contains("dart_target: standard"));
}

#[test]
fn test_init_with_seed_and_dark_flags() {
    let _lock = crate::utils::lock_test_mutex();
    let temp_dir = tempfile::tempdir().unwrap();
    let _guard = set_dir(temp_dir.path());

    std::fs::write(temp_dir.path().join("pubspec.yaml"), "name: test_app").unwrap();

    let result = run(InitArgs {
        preset: Some(PresetArg::Default),
        color_space: Some(ColorSpaceArg::Hsl),
        seed: Some("#e11d48".to_string()),
        dark: true,
        auto_yes: true,
        ..Default::default()
    });
    assert!(result.is_ok());

    let theme_path = temp_dir.path().join("lib/core/theme/just_theme.dart");
    let theme_content = std::fs::read_to_string(&theme_path).unwrap();
    assert!(theme_content.contains("0xFFE11D48"));
    assert!(theme_content.contains("final JustThemeData justTheme = justThemeDark;"));
}
