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

    let mut ok_count = 0;
    let mut warn_count = 0;
    let mut error_count = 0;

    let mut summary_items = Vec::new();

    for check in &checks {
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

    Ok(())
}

pub fn perform_checks() -> Vec<DoctorCheck> {
    let mut checks = Vec::new();

    // 1. Flutter SDK Check
    match Command::new("flutter").arg("--version").output() {
        Ok(out) if out.status.success() => {
            let first_line = String::from_utf8_lossy(&out.stdout)
                .lines()
                .next()
                .unwrap_or("Flutter SDK installed")
                .to_string();
            checks.push(DoctorCheck {
                category: "Toolchain".to_string(),
                title: "Flutter SDK".to_string(),
                status: CheckStatus::Ok,
                message: first_line,
            });
        }
        _ => {
            checks.push(DoctorCheck {
                category: "Toolchain".to_string(),
                title: "Flutter SDK".to_string(),
                status: CheckStatus::Warning,
                message: "Flutter CLI binary not found in system PATH.".to_string(),
            });
        }
    }

    // 2. Dart SDK Check
    match Command::new("dart").arg("--version").output() {
        Ok(out) if out.status.success() => {
            let version_str = String::from_utf8_lossy(&out.stdout)
                .trim()
                .to_string();
            let msg = if version_str.is_empty() {
                String::from_utf8_lossy(&out.stderr).trim().to_string()
            } else {
                version_str
            };
            checks.push(DoctorCheck {
                category: "Toolchain".to_string(),
                title: "Dart SDK".to_string(),
                status: CheckStatus::Ok,
                message: if msg.is_empty() { "Dart SDK active".to_string() } else { msg },
            });
        }
        _ => {
            checks.push(DoctorCheck {
                category: "Toolchain".to_string(),
                title: "Dart SDK".to_string(),
                status: CheckStatus::Warning,
                message: "Dart CLI binary not found in system PATH.".to_string(),
            });
        }
    }

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
                    message: "JustUI core/tokens dependencies detected in pubspec.yaml.".to_string(),
                });
            } else {
                checks.push(DoctorCheck {
                    category: "Dependencies".to_string(),
                    title: "JustUI Packages".to_string(),
                    status: CheckStatus::Warning,
                    message: "just_ui_tokens or just_ui_core not listed in pubspec.yaml dependencies.".to_string(),
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
                        message: format!("Could not fetch index from \"{}\": {}", config.registry_url, e),
                    });
                }
            }
        }
    } else {
        checks.push(DoctorCheck {
            category: "Configuration".to_string(),
            title: "justui.config.yaml".to_string(),
            status: CheckStatus::Warning,
            message: "Project is uninitialized. Run \"justui init\" to generate configuration.".to_string(),
        });
    }

    checks
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_doctor_perform_checks_returns_results() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        let checks = perform_checks();
        assert!(!checks.is_empty());
        assert!(checks.iter().any(|c| c.category == "Project"));
    }

    #[test]
    fn test_doctor_run_uninitialized() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        assert!(run().is_ok());
    }
}
