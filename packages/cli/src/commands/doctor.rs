#![expect(
    clippy::missing_errors_doc,
    clippy::too_many_lines,
    reason = "legacy: fix when touched"
)]

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
            "Found {error_count} error(s) and {warn_count} warning(s). Please resolve the issues above."
        ));
    }

    logger::summary(
        &format!("Doctor Summary: {ok_count} OK, {warn_count} Warning(s), {error_count} Error(s)"),
        &summary_items,
    );
}

#[cfg(test)]
thread_local! {
    static TEST_TOOLCHAIN_DIR: std::cell::RefCell<Option<std::path::PathBuf>> = const { std::cell::RefCell::new(None) };
    static TEST_OVERRIDE_EMPTY_PATH: std::cell::Cell<bool> = const { std::cell::Cell::new(false) };
}

#[cfg(test)]
pub fn set_test_toolchain_dir(dir: Option<std::path::PathBuf>) {
    TEST_TOOLCHAIN_DIR.with(|d| *d.borrow_mut() = dir);
}

#[cfg(test)]
pub fn set_test_override_empty_path(val: bool) {
    TEST_OVERRIDE_EMPTY_PATH.with(|b| b.set(val));
}

pub fn check_toolchain(cmd: &str, name: &str) -> DoctorCheck {
    #[cfg(test)]
    if TEST_OVERRIDE_EMPTY_PATH.with(std::cell::Cell::get) {
        return DoctorCheck {
            category: "Toolchain".to_string(),
            title: format!("{name} SDK"),
            status: CheckStatus::Warning,
            message: format!("{name} CLI binary not found in system PATH."),
        };
    }

    #[cfg(test)]
    let mut command = if let Some(bin_dir) = TEST_TOOLCHAIN_DIR.with(|d| d.borrow().clone()) {
        let binary_path = bin_dir.join(cmd);
        if binary_path.exists() {
            Command::new(binary_path)
        } else {
            Command::new(cmd)
        }
    } else {
        Command::new(cmd)
    };

    #[cfg(not(test))]
    let mut command = Command::new(cmd);

    match command.arg("--version").output() {
        Ok(out) if out.status.success() => {
            let stdout_str = String::from_utf8_lossy(&out.stdout).trim().to_string();
            let stderr_str = String::from_utf8_lossy(&out.stderr).trim().to_string();
            let version_str = if stdout_str.is_empty() {
                stderr_str
            } else {
                stdout_str
            };

            let first_line = version_str.lines().next().unwrap_or("").to_string();

            DoctorCheck {
                category: "Toolchain".to_string(),
                title: format!("{name} SDK"),
                status: CheckStatus::Ok,
                message: if first_line.is_empty() {
                    format!("{name} SDK active")
                } else {
                    first_line
                },
            }
        }
        _ => DoctorCheck {
            category: "Toolchain".to_string(),
            title: format!("{name} SDK"),
            status: CheckStatus::Warning,
            message: format!("{name} CLI binary not found in system PATH."),
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
                message: format!("Constructor syntax target: {target_label}"),
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
#[path = "doctor_tests.rs"]
mod tests;
