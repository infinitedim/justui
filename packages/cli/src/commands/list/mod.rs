use anyhow::Result;
use crossterm::{event, terminal::enable_raw_mode};
use ratatui::{backend::CrosstermBackend, widgets::ListState, Terminal};
use std::collections::HashSet;
use std::io;

use crate::commands::add::sha256_hex;
use crate::config::JustUIConfig;
use crate::registry::{RegistryClient, RegistryComponent};
use crate::utils::logger;

mod ui;

use ui::{draw_ui, run_interactive_tui};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum InputMode {
    Normal,
    Searching,
}

#[derive(Debug, PartialEq, Eq)]
enum KeyAction {
    None,
    Quit,
    #[allow(unused)]
    Install(usize),
    ToggleSelect(usize),
    SelectAll,
    DeselectAll,
    InstallSelected,
}

pub fn run(category: Option<String>, json: bool) -> Result<()> {
    let config = if let Ok(content) = std::fs::read_to_string(JustUIConfig::CONFIG_FILE_NAME) {
        JustUIConfig::from_yaml(&content)
    } else {
        JustUIConfig::default()
    };

    let pb_index = indicatif::ProgressBar::new_spinner();
    pb_index.set_message("Fetching component registry...");
    pb_index.enable_steady_tick(std::time::Duration::from_millis(100));

    let client = RegistryClient::new(config.registry_url.clone());
    let mut index = match client.fetch_index() {
        Ok(idx) => {
            pb_index.finish_and_clear();
            idx
        }
        Err(e) => {
            pb_index.finish_and_clear();
            logger::error(&format!("Failed to list components: {}", e));
            return Ok(());
        }
    };

    if let Some(ref cat) = category {
        index.components.retain(|c| c.category == *cat);
    }

    if json {
        if let Ok(json_str) = serde_json::to_string_pretty(&index.components) {
            logger::stdout(&json_str);
            return Ok(());
        }
    }

    if index.components.is_empty() {
        logger::warning("No components found in the registry.");
        return Ok(());
    }

    let is_tty = crossterm::tty::IsTty::is_tty(&io::stdout())
        && std::env::var("CI").is_err()
        && std::env::var("JUSTUI_NON_INTERACTIVE").is_err()
        && cfg!(not(test));
    if !is_tty || enable_raw_mode().is_err() {
        let backend = ratatui::backend::TestBackend::new(120, 30);
        let mut term = Terminal::new(backend).unwrap();
        let filtered: Vec<&RegistryComponent> = index.components.iter().collect();
        let mut state = ListState::default();
        if !filtered.is_empty() {
            state.select(Some(0));
        }
        let empty_selected = HashSet::new();
        let _ = term.draw(|f| {
            draw_ui(
                f,
                &mut state,
                "",
                InputMode::Normal,
                &filtered,
                &config,
                &empty_selected,
                &index,
            );
            draw_ui(
                f,
                &mut state,
                "query",
                InputMode::Searching,
                &filtered,
                &config,
                &empty_selected,
                &index,
            );
        });
        state.select(None);
        let _ = term.draw(|f| {
            draw_ui(
                f,
                &mut state,
                "",
                InputMode::Normal,
                &filtered,
                &config,
                &empty_selected,
                &index,
            );
        });

        logger::stdout("=== JustUI Registry Components ===");
        for comp in &index.components {
            let status = get_component_status(comp, &config);
            logger::stdout(&format!(
                "  {:<20} v{:<8} [{:<12}] ({})",
                comp.name, comp.version, status, comp.category
            ));
        }
        return Ok(());
    }

    let mut guard = crate::utils::terminal_guard::TerminalGuard::enter()?;
    let backend = CrosstermBackend::new(io::stdout());
    let mut terminal = Terminal::new(backend)?;

    run_interactive_tui(
        &mut terminal,
        || {
            if event::poll(std::time::Duration::from_millis(100))? {
                Ok(Some(event::read()?))
            } else {
                Ok(None)
            }
        },
        &index,
        &config,
        &mut guard,
    )
}

fn get_component_status(comp: &RegistryComponent, config: &JustUIConfig) -> String {
    let target_dir = comp.install_dir(
        &config.components_dir,
        &config.tokens_dir,
        &config.shared_dir,
    );

    let files = comp.files_for_preset(&config.preset);
    if files.is_empty() {
        return "N/A".to_string();
    }

    let mut existing_count = 0;
    let mut matching_count = 0;

    for file in &files {
        let local_file_name = comp.local_file_name(&file.name);
        let path = std::path::Path::new(&target_dir).join(local_file_name);
        if path.exists() {
            existing_count += 1;
            if let Ok(content) = std::fs::read_to_string(&path) {
                let local_clean =
                    crate::utils::import_rewriter::strip_metadata(&content.replace("\r\n", "\n"));
                let local_hash = sha256_hex(local_clean.as_bytes());
                let expected_hash = file.checksum.replace("sha256:", "").trim().to_string();
                if local_hash == expected_hash {
                    matching_count += 1;
                }
            }
        }
    }

    if existing_count == 0 {
        "Not Installed".to_string()
    } else if matching_count == files.len() {
        "Installed".to_string()
    } else if existing_count == files.len() {
        "Outdated / Modified".to_string()
    } else {
        "Partially Installed".to_string()
    }
}

#[cfg(test)]
mod tests;
