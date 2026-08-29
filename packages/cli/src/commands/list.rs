use anyhow::Result;
use crossterm::{
    event::{self, Event, KeyCode},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style, Stylize},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph, Wrap},
    Terminal,
};
use std::collections::HashSet;
use std::io::{self, Write};

use crate::commands::add::{add_component, sha256_hex};
use crate::config::JustUIConfig;
use crate::registry::{RegistryClient, RegistryComponent, RegistryIndex};
use crate::utils::logger;

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub(crate) enum InputMode {
    Normal,
    Searching,
}

#[derive(Debug, PartialEq, Eq)]
pub(crate) enum AppAction {
    Continue,
    Quit,
    Install,
}

pub(crate) fn adjust_selection(list_state: &mut ListState, filtered_len: usize) {
    if let Some(selected) = list_state.selected() {
        if filtered_len == 0 {
            list_state.select(None);
        } else if selected >= filtered_len {
            list_state.select(Some(filtered_len - 1));
        }
    } else if filtered_len > 0 {
        list_state.select(Some(0));
    }
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

    let is_tty = crossterm::tty::IsTty::is_tty(&io::stdout());
    if !is_tty || enable_raw_mode().is_err() {
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

    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let loop_result = run_app_loop(&mut terminal, &index, &config, None);

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;

    loop_result
}

pub(crate) fn run_app_loop<B: ratatui::backend::Backend>(
    terminal: &mut Terminal<B>,
    index: &RegistryIndex,
    config: &JustUIConfig,
    max_loops: Option<usize>,
) -> Result<()>
where
    <B as ratatui::backend::Backend>::Error: Send + Sync + 'static,
{
    let mut list_state = ListState::default();
    list_state.select(Some(0));

    let mut search_query = String::new();
    let mut input_mode = InputMode::Normal;
    let mut iterations = 0;

    let client = RegistryClient::new(config.registry_url.clone());

    loop {
        if let Some(max) = max_loops {
            if iterations >= max {
                break;
            }
        }
        iterations += 1;

        let query_lc = search_query.to_lowercase();
        let filtered_components: Vec<&RegistryComponent> = index
            .components
            .iter()
            .filter(|c| {
                c.name.to_lowercase().contains(&query_lc)
                    || c.description.to_lowercase().contains(&query_lc)
            })
            .collect();

        adjust_selection(&mut list_state, filtered_components.len());

        terminal.draw(|f| {
            render_ui(
                f,
                config,
                &mut list_state,
                &search_query,
                input_mode,
                &filtered_components,
            );
        })?;

        if event::poll(std::time::Duration::from_millis(1))? {
            if let Event::Key(key) = event::read()? {
                let action = handle_key(
                    key,
                    &mut input_mode,
                    &mut search_query,
                    &mut list_state,
                    filtered_components.len(),
                );

                match action {
                    AppAction::Quit => break,
                    AppAction::Install => {
                        if let Some(selected_idx) = list_state.selected() {
                            if let Some(comp) = filtered_components.get(selected_idx) {
                                let comp_name = comp.name.clone();

                                 disable_raw_mode()?;
                                execute!(io::stdout(), LeaveAlternateScreen)?;
                                println!("\nInstalling component \"{}\"...", comp_name);

                                let mut visited = HashSet::new();
                                let pb_files = indicatif::ProgressBar::new_spinner();
                                pb_files.set_message("Installing files...");
                                pb_files.enable_steady_tick(std::time::Duration::from_millis(100));

                                match add_component(
                                    &comp_name,
                                    index,
                                    &client,
                                    &config.components_dir,
                                    &config.tokens_dir,
                                    &config.shared_dir,
                                    &mut visited,
                                    false,
                                    false,
                                    true,
                                    &Some(pb_files.clone()),
                                    &config.preset,
                                    config.dart_target,
                                ) {
                                    Ok((_stats, details)) => {
                                        pb_files.finish_and_clear();
                                        logger::success(&format!(
                                            "Component \"{}\" added successfully.",
                                            comp_name
                                        ));

                                        let mut summary_items = Vec::new();
                                        for detail in details {
                                            summary_items.push(logger::SummaryItem {
                                                label: detail.file_name,
                                                value: detail.path,
                                            });
                                        }
                                        logger::summary("File Summary", &summary_items);
                                    }
                                    Err(e) => {
                                        pb_files.finish_and_clear();
                                        logger::error(&format!(
                                            "Failed to install \"{}\": {}",
                                            comp_name, e
                                        ));
                                    }
                                }

                                print!("\nPress Enter to return to the component list...");
                                io::stdout().flush()?;
                                let mut buffer = String::new();
                                io::stdin().read_line(&mut buffer)?;

                                enable_raw_mode()?;
                                execute!(io::stdout(), EnterAlternateScreen)?;
                                terminal.clear()?;
                            }
                        }
                    }
                    AppAction::Continue => {}
                }
            }
        }
    }
    Ok(())
}

pub(crate) fn render_ui(
    f: &mut ratatui::Frame,
    config: &JustUIConfig,
    list_state: &mut ListState,
    search_query: &str,
    input_mode: InputMode,
    filtered_components: &[&RegistryComponent],
) {
    let size = f.area();

    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),
            Constraint::Min(0),
            Constraint::Length(3),
        ])
        .split(size);

    let header = Paragraph::new(" JustUI Component Explorer ")
        .alignment(ratatui::layout::Alignment::Center)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_style(Style::default().fg(Color::Cyan))
                .style(Style::default().add_modifier(Modifier::BOLD)),
        );
    f.render_widget(header, chunks[0]);

    let main_chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(35), Constraint::Percentage(65)])
        .split(chunks[1]);

    let list_title = if input_mode == InputMode::Searching {
        format!(" Components (Filter: {}) ", search_query)
    } else {
        " Components ".to_string()
    };

    let items: Vec<ListItem> = filtered_components
        .iter()
        .map(|comp| {
            let status = get_component_status(comp, config);
            let status_style = match status.as_str() {
                "Installed" => Style::default().fg(Color::Green),
                "Outdated / Modified" => Style::default().fg(Color::Yellow),
                "Partially Installed" => Style::default().fg(Color::LightYellow),
                _ => Style::default().fg(Color::DarkGray),
            };

            let content = ratatui::text::Line::from(vec![
                ratatui::text::Span::raw(format!("{:<18}", comp.name)),
                ratatui::text::Span::styled(format!(" [{}]", status), status_style),
            ]);
            ListItem::new(content)
        })
        .collect();

    let list_block = Block::default()
        .borders(Borders::ALL)
        .title(list_title)
        .border_style(if input_mode == InputMode::Searching {
            Style::default().fg(Color::Yellow)
        } else {
            Style::default().fg(Color::Gray)
        });

    let list_widget = List::new(items)
        .block(list_block)
        .highlight_style(
            Style::default()
                .bg(Color::Rgb(59, 130, 246))
                .fg(Color::White)
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("▶ ");
    f.render_stateful_widget(list_widget, main_chunks[0], list_state);

    let details_block = Block::default()
        .borders(Borders::ALL)
        .title(" Component Details ")
        .border_style(Style::default().fg(Color::Gray));

    if let Some(selected_idx) = list_state.selected() {
        if let Some(comp) = filtered_components.get(selected_idx) {
            let mut detail_lines = vec![
                ratatui::text::Line::from(vec![
                    ratatui::text::Span::styled(
                        &comp.name,
                        Style::default()
                            .fg(Color::Cyan)
                            .add_modifier(Modifier::BOLD),
                    ),
                    ratatui::text::Span::raw(format!(" (v{})", comp.version)),
                ]),
                ratatui::text::Line::from(vec![
                    ratatui::text::Span::styled(
                        "Category:     ",
                        Style::default().fg(Color::DarkGray),
                    ),
                    ratatui::text::Span::raw(&comp.category),
                ]),
            ];

            let presets_str = if comp.supported_presets.is_empty() {
                "default".to_string()
            } else {
                comp.supported_presets.join(", ")
            };
            detail_lines.push(ratatui::text::Line::from(vec![
                ratatui::text::Span::styled(
                    "Presets:      ",
                    Style::default().fg(Color::DarkGray),
                ),
                ratatui::text::Span::raw(presets_str),
            ]));

            let reg_deps = if comp.registry_dependencies.is_empty() {
                "none".to_string()
            } else {
                comp.registry_dependencies.join(", ")
            };
            detail_lines.push(ratatui::text::Line::from(vec![
                ratatui::text::Span::styled(
                    "Registry Deps:",
                    Style::default().fg(Color::DarkGray),
                ),
                ratatui::text::Span::raw(reg_deps),
            ]));

            let pub_deps = if comp.pub_dependencies.is_empty() {
                "none".to_string()
            } else {
                comp.pub_dependencies
                    .iter()
                    .map(|(k, v)| format!("{}: {}", k, v))
                    .collect::<Vec<_>>()
                    .join(", ")
            };
            detail_lines.push(ratatui::text::Line::from(vec![
                ratatui::text::Span::styled(
                    "Pub.dev Deps: ",
                    Style::default().fg(Color::DarkGray),
                ),
                ratatui::text::Span::raw(pub_deps),
            ]));

            detail_lines.push(ratatui::text::Line::from(""));
            detail_lines.push(ratatui::text::Line::from(ratatui::text::Span::styled(
                "Description:",
                Style::default()
                    .fg(Color::DarkGray)
                    .add_modifier(Modifier::UNDERLINED),
            )));
            detail_lines.push(ratatui::text::Line::from(comp.description.as_str()));

            detail_lines.push(ratatui::text::Line::from(""));
            detail_lines.push(ratatui::text::Line::from(ratatui::text::Span::styled(
                "Files:",
                Style::default()
                    .fg(Color::DarkGray)
                    .add_modifier(Modifier::UNDERLINED),
            )));

            let files = comp.files_for_preset(&config.preset);
            for file in &files {
                detail_lines.push(ratatui::text::Line::from(vec![
                    ratatui::text::Span::raw("  • "),
                    ratatui::text::Span::styled(
                        &file.name,
                        Style::default().fg(Color::LightGreen),
                    ),
                    ratatui::text::Span::styled(
                        format!(" ({})", file.path),
                        Style::default().fg(Color::DarkGray),
                    ),
                ]));
            }

            let details_paragraph = Paragraph::new(detail_lines)
                .block(details_block)
                .wrap(Wrap { trim: true });
            f.render_widget(details_paragraph, main_chunks[1]);
        }
    } else {
        let no_selection = Paragraph::new("No component selected.")
            .block(details_block)
            .alignment(ratatui::layout::Alignment::Center);
        f.render_widget(no_selection, main_chunks[1]);
    }

    let footer_text = match input_mode {
        InputMode::Normal => {
            vec![
                "[↑/↓] Navigate".cyan(),
                "  |  ".into(),
                "[/] Search".yellow(),
                "  |  ".into(),
                "[i/Enter] Install".green(),
                "  |  ".into(),
                "[q/Esc] Quit".red(),
            ]
        }
        InputMode::Searching => {
            vec![
                "[Esc] Normal Mode".yellow(),
                "  |  ".into(),
                "[Type] Filter".cyan(),
            ]
        }
    };

    let footer = Paragraph::new(ratatui::text::Line::from(footer_text))
        .alignment(ratatui::layout::Alignment::Center)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_style(Style::default().fg(Color::Gray)),
        );
    f.render_widget(footer, chunks[2]);
}

pub(crate) fn handle_key(
    key: event::KeyEvent,
    input_mode: &mut InputMode,
    search_query: &mut String,
    list_state: &mut ListState,
    filtered_len: usize,
) -> AppAction {
    match *input_mode {
        InputMode::Normal => match key.code {
            KeyCode::Char('q') | KeyCode::Esc => AppAction::Quit,
            KeyCode::Up | KeyCode::Char('k') => {
                if let Some(selected) = list_state.selected() {
                    if selected > 0 {
                        list_state.select(Some(selected - 1));
                    }
                }
                AppAction::Continue
            }
            KeyCode::Down | KeyCode::Char('j') => {
                if let Some(selected) = list_state.selected() {
                    if filtered_len > 0 && selected < filtered_len - 1 {
                        list_state.select(Some(selected + 1));
                    }
                }
                AppAction::Continue
            }
            KeyCode::Char('/') => {
                *input_mode = InputMode::Searching;
                AppAction::Continue
            }
            KeyCode::Char('i') | KeyCode::Enter => AppAction::Install,
            _ => AppAction::Continue,
        },
        InputMode::Searching => match key.code {
            KeyCode::Esc => {
                *input_mode = InputMode::Normal;
                AppAction::Continue
            }
            KeyCode::Backspace => {
                search_query.pop();
                AppAction::Continue
            }
            KeyCode::Char(c) => {
                search_query.push(c);
                AppAction::Continue
            }
            _ => AppAction::Continue,
        },
    }
}

fn get_component_status(comp: &RegistryComponent, config: &JustUIConfig) -> String {
    let target_dir = if comp.category == "tokens" || comp.category == "core" {
        config.tokens_dir.clone()
    } else if comp.name == "_shared_theme_provider" {
        "lib/theme".to_string()
    } else if comp.internal {
        config.shared_dir.clone()
    } else {
        format!("{}/{}", config.components_dir, comp.name)
    };

    let files = comp.files_for_preset(&config.preset);
    if files.is_empty() {
        return "N/A".to_string();
    }

    let mut existing_count = 0;
    let mut matching_count = 0;

    for file in &files {
        let local_file_name = if comp.name == "_shared_theme_provider" {
            file.name.clone()
        } else if comp.internal {
            crate::utils::import_rewriter::normalize_shared_file_name(&file.name)
        } else {
            file.name.clone()
        };
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
mod tests {
    use super::*;
    use crate::utils::import_rewriter;
    use ratatui::backend::TestBackend;
    use std::collections::HashMap;
    use std::fs;

    #[test]
    fn test_get_component_status_matrix() {
        let config = JustUIConfig::default();

        // 1. Empty files -> N/A
        let comp_empty = RegistryComponent {
            name: "empty".to_string(),
            version: "1.0".to_string(),
            description: "".to_string(),
            category: "general".to_string(),
            internal: false,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: HashMap::new(),
        };
        assert_eq!(get_component_status(&comp_empty, &config), "N/A");

        // 2. Uninstalled component
        let comp_not_installed = RegistryComponent {
            name: "uninstalled_comp".to_string(),
            version: "1.0".to_string(),
            description: "".to_string(),
            category: "general".to_string(),
            internal: false,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![crate::registry::RegistryFile {
                        name: "missing.dart".to_string(),
                        path: "missing.dart".to_string(),
                        checksum: "sha256:123".to_string(),
                    }],
                );
                map
            },
        };
        assert_eq!(
            get_component_status(&comp_not_installed, &config),
            "Not Installed"
        );

        // 3. Tokens category & core category & internal & _shared_theme_provider
        let temp_dir = tempfile::tempdir().unwrap();
        let tokens_dir = temp_dir.path().join("tokens");
        let shared_dir = temp_dir.path().join("shared");
        std::fs::create_dir_all(&tokens_dir).unwrap();
        std::fs::create_dir_all(&shared_dir).unwrap();

        let config_custom = JustUIConfig {
            tokens_dir: tokens_dir.to_string_lossy().to_string(),
            shared_dir: shared_dir.to_string_lossy().to_string(),
            ..Default::default()
        };

        // Tokens component file
        let token_file = tokens_dir.join("colors.dart");
        let raw_token = "class Colors {}";
        let hash_token = sha256_hex(raw_token.as_bytes());
        std::fs::write(&token_file, import_rewriter::inject_metadata(raw_token, &hash_token, &hash_token)).unwrap();

        let comp_tokens = RegistryComponent {
            name: "tokens".to_string(),
            version: "1.0".to_string(),
            description: "".to_string(),
            category: "tokens".to_string(),
            internal: false,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![crate::registry::RegistryFile {
                        name: "colors.dart".to_string(),
                        path: token_file.to_string_lossy().to_string(),
                        checksum: format!("sha256:{}", hash_token),
                    }],
                );
                map
            },
        };
        assert_eq!(get_component_status(&comp_tokens, &config_custom), "Installed");

        // Internal component file
        let internal_file = shared_dir.join("just_utils.dart");
        let raw_internal = "class SharedUtils {}";
        let hash_internal = sha256_hex(raw_internal.as_bytes());
        std::fs::write(&internal_file, import_rewriter::inject_metadata(raw_internal, &hash_internal, &hash_internal)).unwrap();

        let comp_internal = RegistryComponent {
            name: "shared_utils".to_string(),
            version: "1.0".to_string(),
            description: "".to_string(),
            category: "utils".to_string(),
            internal: true,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![crate::registry::RegistryFile {
                        name: "_shared_utils.dart".to_string(),
                        path: internal_file.to_string_lossy().to_string(),
                        checksum: format!("sha256:{}", hash_internal),
                    }],
                );
                map
            },
        };
        assert_eq!(get_component_status(&comp_internal, &config_custom), "Installed");

        // Theme provider component
        let comp_theme = RegistryComponent {
            name: "_shared_theme_provider".to_string(),
            version: "1.0".to_string(),
            description: "".to_string(),
            category: "theme".to_string(),
            internal: false,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![crate::registry::RegistryFile {
                        name: "theme_provider.dart".to_string(),
                        path: "lib/theme/theme_provider.dart".to_string(),
                        checksum: "sha256:999".to_string(),
                    }],
                );
                map
            },
        };
        assert_eq!(get_component_status(&comp_theme, &config_custom), "Not Installed");

        // 4. Regular component Installed, Modified, Partially Installed
        let config_installed = JustUIConfig {
            components_dir: temp_dir.path().to_string_lossy().to_string(),
            ..Default::default()
        };

        let comp_dir = temp_dir.path().join("installed_comp");
        std::fs::create_dir_all(&comp_dir).unwrap();
        let file1 = comp_dir.join("file1.dart");
        let file2 = comp_dir.join("file2.dart");

        let raw1 = "class File1 {}";
        let raw2 = "class File2 {}";
        let hash1 = sha256_hex(raw1.as_bytes());
        let hash2 = sha256_hex(raw2.as_bytes());

        let content1 = import_rewriter::inject_metadata(raw1, &hash1, &hash1);
        let content2 = import_rewriter::inject_metadata(raw2, &hash2, &hash2);
        std::fs::write(&file1, content1).unwrap();
        std::fs::write(&file2, content2).unwrap();

        let comp_installed = RegistryComponent {
            name: "installed_comp".to_string(),
            version: "1.0".to_string(),
            description: "".to_string(),
            category: "general".to_string(),
            internal: false,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![
                        crate::registry::RegistryFile {
                            name: "file1.dart".to_string(),
                            path: file1.to_string_lossy().to_string(),
                            checksum: format!("sha256:{}", hash1),
                        },
                        crate::registry::RegistryFile {
                            name: "file2.dart".to_string(),
                            path: file2.to_string_lossy().to_string(),
                            checksum: format!("sha256:{}", hash2),
                        },
                    ],
                );
                map
            },
        };

        assert_eq!(get_component_status(&comp_installed, &config_installed), "Installed");

        std::fs::write(&file1, "class Modified {}").unwrap();
        assert_eq!(get_component_status(&comp_installed, &config_installed), "Outdated / Modified");

        std::fs::remove_file(&file2).unwrap();
        assert_eq!(get_component_status(&comp_installed, &config_installed), "Partially Installed");
    }

    #[test]
    fn test_adjust_selection() {
        let mut state = ListState::default();
        state.select(Some(5));
        adjust_selection(&mut state, 3);
        assert_eq!(state.selected(), Some(2));

        adjust_selection(&mut state, 0);
        assert_eq!(state.selected(), None);

        adjust_selection(&mut state, 4);
        assert_eq!(state.selected(), Some(0));
    }

    #[test]
    fn test_handle_key_matrix() {
        use crossterm::event::KeyModifiers;

        let mut mode = InputMode::Normal;
        let mut query = String::new();
        let mut state = ListState::default();
        state.select(Some(0));

        // 'q' or Esc -> Quit
        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Char('q'), KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Quit
        );
        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Esc, KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Quit
        );

        // Down / 'j' navigation
        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Down, KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Continue
        );
        assert_eq!(state.selected(), Some(1));

        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Char('j'), KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Continue
        );
        assert_eq!(state.selected(), Some(2));

        // Up / 'k' navigation
        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Up, KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Continue
        );
        assert_eq!(state.selected(), Some(1));

        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Char('k'), KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Continue
        );
        assert_eq!(state.selected(), Some(0));

        // Enter '/' -> switch to search mode
        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Char('/'), KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Continue
        );
        assert_eq!(mode, InputMode::Searching);

        // Typing in search mode
        handle_key(
            event::KeyEvent::new(KeyCode::Char('a'), KeyModifiers::NONE),
            &mut mode,
            &mut query,
            &mut state,
            5
        );
        handle_key(
            event::KeyEvent::new(KeyCode::Char('b'), KeyModifiers::NONE),
            &mut mode,
            &mut query,
            &mut state,
            5
        );
        assert_eq!(query, "ab");

        handle_key(
            event::KeyEvent::new(KeyCode::Backspace, KeyModifiers::NONE),
            &mut mode,
            &mut query,
            &mut state,
            5
        );
        assert_eq!(query, "a");

        // Esc in search mode -> switch back to Normal mode
        handle_key(
            event::KeyEvent::new(KeyCode::Esc, KeyModifiers::NONE),
            &mut mode,
            &mut query,
            &mut state,
            5
        );
        assert_eq!(mode, InputMode::Normal);

        // Unhandled key in Normal and Searching mode
        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Char('x'), KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Continue
        );

        mode = InputMode::Searching;
        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Tab, KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Continue
        );
        mode = InputMode::Normal;

        // 'i' or Enter in normal mode -> Install action
        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Char('i'), KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Install
        );
        assert_eq!(
            handle_key(
                event::KeyEvent::new(KeyCode::Enter, KeyModifiers::NONE),
                &mut mode,
                &mut query,
                &mut state,
                5
            ),
            AppAction::Install
        );
    }

    #[test]
    fn test_render_ui_rendering_and_styles() {
        use ratatui::Terminal;

        let backend = TestBackend::new(100, 30);
        let mut terminal = Terminal::new(backend).unwrap();
        let config = JustUIConfig::default();

        // 1. Component with empty presets, empty registry deps, empty pub deps
        let comp_empty_details = RegistryComponent {
            name: "minimal".to_string(),
            version: "1.0.0".to_string(),
            description: "Minimal component".to_string(),
            category: "components".to_string(),
            internal: false,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: HashMap::new(),
        };

        // 2. Component with populated presets, registry deps, pub deps
        let mut map_files = HashMap::new();
        map_files.insert(
            "default".to_string(),
            vec![crate::registry::RegistryFile {
                name: "button.dart".to_string(),
                path: "lib/components/button.dart".to_string(),
                checksum: "sha256:123".to_string(),
            }],
        );

        let mut pub_deps = HashMap::new();
        pub_deps.insert("flutter_hooks".to_string(), "^0.20.0".to_string());

        let comp_full = RegistryComponent {
            name: "button".to_string(),
            version: "1.0.0".to_string(),
            description: "A customizable button component".to_string(),
            category: "components".to_string(),
            internal: false,
            supported_presets: vec!["default".to_string(), "shadcn".to_string()],
            registry_dependencies: vec!["tokens".to_string()],
            pub_dependencies: pub_deps,
            files: map_files,
        };

        let comp_list = vec![&comp_empty_details, &comp_full];
        let mut state = ListState::default();
        state.select(Some(0));

        // Render Normal Mode
        terminal
            .draw(|f| {
                render_ui(
                    f,
                    &config,
                    &mut state,
                    "",
                    InputMode::Normal,
                    &comp_list,
                );
            })
            .unwrap();

        state.select(Some(1));
        terminal
            .draw(|f| {
                render_ui(
                    f,
                    &config,
                    &mut state,
                    "",
                    InputMode::Normal,
                    &comp_list,
                );
            })
            .unwrap();

        // Render Searching Mode with empty selection
        let mut empty_state = ListState::default();
        terminal
            .draw(|f| {
                render_ui(
                    f,
                    &config,
                    &mut empty_state,
                    "btn",
                    InputMode::Searching,
                    &comp_list,
                );
            })
            .unwrap();
    }

    #[test]
    fn test_run_app_loop_and_run_non_tty_matrix() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        // Create local registry index.json
        let registry_dir = temp_dir.path().join("registry");
        fs::create_dir_all(&registry_dir).unwrap();
        let index_json = r#"{
            "version": "1.0.0",
            "components": [
                {
                    "name": "card",
                    "version": "1.0.0",
                    "description": "Card component",
                    "category": "components",
                    "internal": false,
                    "supported_presets": ["default"],
                    "registry_dependencies": [],
                    "pub_dependencies": {},
                    "files": {}
                }
            ],
            "presets": []
        }"#;
        fs::write(registry_dir.join("index.json"), index_json).unwrap();

        let config_yaml = format!(
            "version: '1.0'\ncomponents_dir: lib/components\ntokens_dir: lib/tokens\nshared_dir: lib/shared\nregistry_url: '{}'\npreset: default\ndart_target: standard\n",
            registry_dir.display()
        );
        fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // 1. Run json mode
        assert!(run(None, true).is_ok());

        // 2. Run category filter mode non-TTY
        assert!(run(Some("components".to_string()), false).is_ok());

        // 3. Run with empty category match
        assert!(run(Some("non_existent_category".to_string()), false).is_ok());

        // 4. Test run_app_loop with TestBackend for 1 iteration
        let backend = TestBackend::new(100, 30);
        let mut terminal = Terminal::new(backend).unwrap();
        let index: RegistryIndex = serde_json::from_str(index_json).unwrap();
        let config = JustUIConfig::default();

        assert!(run_app_loop(&mut terminal, &index, &config, Some(1)).is_ok());
    }
}
