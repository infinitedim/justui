use anyhow::Result;
use colored::Colorize;
use std::path::Path;
use std::process::Command;

use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::logger;

pub struct DoctorCheck {
    pub category: String,
    pub title: String,
    pub status: CheckStatus,
    pub message: String,
}

#[derive(Debug, PartialEq, Eq)]
pub enum CheckStatus {
    Ok,
    Warning,
    Error,
}

pub fn run() -> Result<()> {
    logger::panel("JustUI Environment & Project Doctor");
    let checks = perform_checks();
    print_doctor_report(&checks);
    Ok(())
}

pub fn print_doctor_report(checks: &[DoctorCheck]) {
    let mut ok_count = 0;
    let mut warn_count = 0;
    let mut error_count = 0;

    let mut summary_items = Vec::new();

    for check in checks {
        let (icon, label) = match check.status {
            CheckStatus::Ok => {
                ok_count += 1;
                ("✔".green().bold(), "OK")
            }
            CheckStatus::Warning => {
                warn_count += 1;
                ("⚠".yellow().bold(), "WARN")
            }
            CheckStatus::Error => {
                error_count += 1;
                ("✗".red().bold(), "ERROR")
            }
        };

        logger::stdout(&format!(
            "  {} [{}] {} — {}",
            icon,
            check.category.bold(),
            check.title,
            check.message
        ));

        summary_items.push(logger::SummaryItem {
            label: format!("[{}] {}", check.category, check.title),
            value: format!("{} - {}", label, check.message),
        });
    }

    logger::stdout("");

    if error_count == 0 && warn_count == 0 {
        logger::success("Everything looks good! Your JustUI environment is healthy.");
    } else if error_count == 0 {
        logger::stdout(&format!(
            "{}",
            "⚠ All critical checks passed, but there are minor warnings.".yellow()
        ));
    } else {
        logger::error(&format!(
            "Found {} error(s) and {} warning(s). Please resolve the issues above.",
            error_count, warn_count
        ));
    }

    logger::summary(
        &format!(
            "Doctor Summary: {} OK, {} Warning(s), {} Error(s)",
            ok_count, warn_count, error_count
        ),
        &summary_items,
    );
}

pub fn check_toolchain(cmd: &str, name: &str) -> DoctorCheck {
    match Command::new(cmd).arg("--version").output() {
        Ok(out) if out.status.success() => {
            let stdout_str = String::from_utf8_lossy(&out.stdout).trim().to_string();
            let stderr_str = String::from_utf8_lossy(&out.stderr).trim().to_string();
            let version_str = if !stdout_str.is_empty() {
                stdout_str
            } else {
                stderr_str
            };

            let first_line = version_str.lines().next().unwrap_or("").to_string();

            DoctorCheck {
                category: "Toolchain".to_string(),
                title: format!("{} SDK", name),
                status: CheckStatus::Ok,
                message: if first_line.is_empty() {
                    format!("{} SDK active", name)
                } else {
                    first_line
                },
            }
        }
        _ => DoctorCheck {
            category: "Toolchain".to_string(),
            title: format!("{} SDK", name),
            status: CheckStatus::Warning,
            message: format!("{} CLI binary not found in system PATH.", name),
        },
    }
}

pub fn perform_checks() -> Vec<DoctorCheck> {
    let mut checks = Vec::new();

    // 1. Flutter SDK Check
    checks.push(check_toolchain("flutter", "Flutter"));

    // 2. Dart SDK Check
    checks.push(check_toolchain("dart", "Dart"));

    // 3. Flutter Project Context Check (pubspec.yaml)
    let pubspec_path = Path::new("pubspec.yaml");
    if pubspec_path.exists() {
        checks.push(DoctorCheck {
            category: "Project".to_string(),
            title: "pubspec.yaml".to_string(),
            status: CheckStatus::Ok,
            message: "Flutter project root detected.".to_string(),
        });

        if let Ok(content) = std::fs::read_to_string(pubspec_path) {
            let has_tokens = content.contains("just_ui_tokens");
            let has_core = content.contains("just_ui_core");

            if has_tokens || has_core {
                checks.push(DoctorCheck {
                    category: "Dependencies".to_string(),
                    title: "JustUI Packages".to_string(),
                    status: CheckStatus::Ok,
                    message: "JustUI core/tokens dependencies detected in pubspec.yaml."
                        .to_string(),
                });
            } else {
                checks.push(DoctorCheck {
                    category: "Dependencies".to_string(),
                    title: "JustUI Packages".to_string(),
                    status: CheckStatus::Warning,
                    message:
                        "just_ui_tokens or just_ui_core not listed in pubspec.yaml dependencies."
                            .to_string(),
                });
            }
        }
    } else {
        checks.push(DoctorCheck {
            category: "Project".to_string(),
            title: "pubspec.yaml".to_string(),
            status: CheckStatus::Error,
            message: "No pubspec.yaml found in the current working directory.".to_string(),
        });
    }

    // 4. JustUI Config File Check (justui.config.yaml)
    let config_path = Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if config_path.exists() {
        checks.push(DoctorCheck {
            category: "Configuration".to_string(),
            title: "justui.config.yaml".to_string(),
            status: CheckStatus::Ok,
            message: "Config file present.".to_string(),
        });

        if let Ok(content) = std::fs::read_to_string(config_path) {
            let config = JustUIConfig::from_yaml(&content);

            // Check components dir
            if Path::new(&config.components_dir).exists() {
                checks.push(DoctorCheck {
                    category: "Directory".to_string(),
                    title: "Components Directory".to_string(),
                    status: CheckStatus::Ok,
                    message: format!("\"{}\" exists.", config.components_dir),
                });
            } else {
                checks.push(DoctorCheck {
                    category: "Directory".to_string(),
                    title: "Components Directory".to_string(),
                    status: CheckStatus::Warning,
                    message: format!(
                        "Configured directory \"{}\" does not exist on disk yet.",
                        config.components_dir
                    ),
                });
            }

            // Check tokens dir
            if Path::new(&config.tokens_dir).exists() {
                checks.push(DoctorCheck {
                    category: "Directory".to_string(),
                    title: "Tokens Directory".to_string(),
                    status: CheckStatus::Ok,
                    message: format!("\"{}\" exists.", config.tokens_dir),
                });
            } else {
                checks.push(DoctorCheck {
                    category: "Directory".to_string(),
                    title: "Tokens Directory".to_string(),
                    status: CheckStatus::Warning,
                    message: format!(
                        "Configured directory \"{}\" does not exist on disk yet.",
                        config.tokens_dir
                    ),
                });
            }

            // Check shared dir
            if Path::new(&config.shared_dir).exists() {
                checks.push(DoctorCheck {
                    category: "Directory".to_string(),
                    title: "Shared Directory".to_string(),
                    status: CheckStatus::Ok,
                    message: format!("\"{}\" exists.", config.shared_dir),
                });
            } else {
                checks.push(DoctorCheck {
                    category: "Directory".to_string(),
                    title: "Shared Directory".to_string(),
                    status: CheckStatus::Warning,
                    message: format!(
                        "Configured directory \"{}\" does not exist on disk yet.",
                        config.shared_dir
                    ),
                });
            }

            // Dart Target Check
            let target_label = match config.dart_target {
                crate::utils::env_resolver::DartTarget::Primary => "primary (Dart 3.10+)",
                crate::utils::env_resolver::DartTarget::Standard => "standard",
            };
            checks.push(DoctorCheck {
                category: "Configuration".to_string(),
                title: "Dart Target".to_string(),
                status: CheckStatus::Ok,
                message: format!("Constructor syntax target: {}", target_label),
            });

            // Check registry client reachability
            let client = RegistryClient::new(config.registry_url.clone());
            match client.fetch_index() {
                Ok(index) => {
                    checks.push(DoctorCheck {
                        category: "Registry".to_string(),
                        title: "Registry Index".to_string(),
                        status: CheckStatus::Ok,
                        message: format!(
                            "Reachable (v{}, {} components, {} presets).",
                            index.version,
                            index.components.len(),
                            index.presets.len()
                        ),
                    });
                }
                Err(e) => {
                    checks.push(DoctorCheck {
                        category: "Registry".to_string(),
                        title: "Registry Index".to_string(),
                        status: CheckStatus::Warning,
                        message: format!(
                            "Could not fetch index from \"{}\": {}",
                            config.registry_url, e
                        ),
                    });
                }
            }
        }
    } else {
        checks.push(DoctorCheck {
            category: "Configuration".to_string(),
            title: "justui.config.yaml".to_string(),
            status: CheckStatus::Warning,
            message: "Project is uninitialized. Run \"justui init\" to generate configuration."
                .to_string(),
        });
    }

    checks
}

#[cfg(test)]
mod tests {
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
        assert!(checks
            .iter()
            .any(|c| c.title == "Registry Index" && c.status == CheckStatus::Ok));
        assert!(checks
            .iter()
            .any(|c| c.title == "JustUI Packages" && c.status == CheckStatus::Ok));

        // Create mock binary dir for toolchain edge cases
        let bin_dir = temp_dir.path().join("mock_bin");
        fs::create_dir_all(&bin_dir).unwrap();

        // Mock Dart script returning empty stdout and stderr
        let dart_empty_bin = bin_dir.join("dart");
        fs::write(&dart_empty_bin, "#!/bin/sh\n").unwrap();
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            fs::set_permissions(&dart_empty_bin, fs::Permissions::from_mode(0o755)).unwrap();
        }

        let old_path = std::env::var("PATH").unwrap_or_default();
        std::env::set_var("PATH", format!("{}:{}", bin_dir.display(), old_path));

        let checks_empty_dart = perform_checks();
        let dart_check = checks_empty_dart
            .iter()
            .find(|c| c.title == "Dart SDK")
            .unwrap();
        assert_eq!(dart_check.message, "Dart SDK active");

        // Set PATH to empty directory to test CLI missing warning
        std::env::set_var("PATH", temp_dir.path().display().to_string());
        let checks_missing_tools = perform_checks();
        assert!(checks_missing_tools
            .iter()
            .any(|c| c.title == "Dart SDK" && c.status == CheckStatus::Warning));
        assert!(checks_missing_tools
            .iter()
            .any(|c| c.title == "Flutter SDK" && c.status == CheckStatus::Warning));

        std::env::set_var("PATH", old_path);
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
        let old_path = std::env::var("PATH").unwrap_or_default();
        std::env::set_var("PATH", format!("{}:{}", bin_dir.display(), old_path));

        // Run when all checks are OK (triggers line 68)
        assert!(run().is_ok());

        std::env::set_var("PATH", old_path);
    }

    #[test]
    fn test_doctor_perform_checks_comprehensive() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = crate::utils::set_dir(temp_dir.path());

        // 1. Check uninitialized (no pubspec.yaml, no config)
        let checks_uninit = perform_checks();
        assert!(checks_uninit
            .iter()
            .any(|c| c.status == CheckStatus::Error && c.title == "pubspec.yaml"));
        assert!(checks_uninit
            .iter()
            .any(|c| c.status == CheckStatus::Warning && c.title == "justui.config.yaml"));

        // 2. Add pubspec without just_ui dependencies
        fs::write("pubspec.yaml", "name: my_app\n").unwrap();
        let checks_no_deps = perform_checks();
        assert!(checks_no_deps
            .iter()
            .any(|c| c.status == CheckStatus::Warning && c.title == "JustUI Packages"));

        // 3. Add pubspec with just_ui_core
        fs::write(
            "pubspec.yaml",
            "name: my_app\ndependencies:\n  just_ui_core: 1.0.0\n",
        )
        .unwrap();
        let checks_core_dep = perform_checks();
        assert!(checks_core_dep
            .iter()
            .any(|c| c.status == CheckStatus::Ok && c.title == "JustUI Packages"));

        // 4. Add config with non-existent directories and invalid registry URL
        let config_yaml = r#"
version: '1.0'
components_dir: lib/non_existent_components
tokens_dir: lib/non_existent_tokens
shared_dir: lib/non_existent_shared
registry_url: http://127.0.0.1:59999/non_existent_registry_index.json
preset: default
dart_target: standard
"#;
        fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();
        let checks_config = perform_checks();
        assert!(checks_config
            .iter()
            .any(|c| c.title == "Components Directory" && c.status == CheckStatus::Warning));
        assert!(checks_config
            .iter()
            .any(|c| c.title == "Tokens Directory" && c.status == CheckStatus::Warning));
        assert!(checks_config
            .iter()
            .any(|c| c.title == "Shared Directory" && c.status == CheckStatus::Warning));
        assert!(checks_config
            .iter()
            .any(|c| c.title == "Dart Target" && c.message.contains("standard")));
        assert!(checks_config
            .iter()
            .any(|c| c.title == "Registry Index" && c.status == CheckStatus::Warning));
    }

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
            "#!/bin/sh\necho 'Flutter 3.19.0 • channel stable'\n",
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

        let old_path = std::env::var("PATH").unwrap_or_default();
        let new_path = format!("{}:{}", bin_dir.display(), old_path);
        std::env::set_var("PATH", &new_path);

        let checks = perform_checks();
        let flutter_check = checks.iter().find(|c| c.title == "Flutter SDK").unwrap();
        assert_eq!(flutter_check.status, CheckStatus::Ok);
        assert!(flutter_check.message.contains("Flutter 3.19.0"));

        let dart_check = checks.iter().find(|c| c.title == "Dart SDK").unwrap();
        assert_eq!(dart_check.status, CheckStatus::Ok);
        assert!(dart_check.message.contains("Dart SDK version: 3.3.0"));

        std::env::set_var("PATH", old_path);
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
        assert!(checks
            .iter()
            .any(|c| c.title == "JustUI Packages" && c.status == CheckStatus::Ok));
        assert!(checks
            .iter()
            .any(|c| c.title == "Components Directory" && c.status == CheckStatus::Ok));
        assert!(checks
            .iter()
            .any(|c| c.title == "Registry Index" && c.status == CheckStatus::Ok));

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
        assert!(checks
            .iter()
            .any(|c| c.title == "JustUI Packages" && c.status == CheckStatus::Warning));
        assert!(checks
            .iter()
            .any(|c| c.title == "Components Directory" && c.status == CheckStatus::Warning));
        assert!(checks
            .iter()
            .any(|c| c.title == "Tokens Directory" && c.status == CheckStatus::Warning));
        assert!(checks
            .iter()
            .any(|c| c.title == "Shared Directory" && c.status == CheckStatus::Warning));
        assert!(checks
            .iter()
            .any(|c| c.title == "Registry Index" && c.status == CheckStatus::Warning));

        assert!(run().is_ok());
    }

    #[test]
    fn test_doctor_errors_matrix() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = crate::utils::set_dir(temp_dir.path());

        // No pubspec.yaml -> triggers CheckStatus::Error
        let checks = perform_checks();
        assert!(checks
            .iter()
            .any(|c| c.title == "pubspec.yaml" && c.status == CheckStatus::Error));

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
}
