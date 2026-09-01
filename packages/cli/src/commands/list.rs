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

use crate::commands::add::{
    add_component, resolve_dependencies_recursive, sha256_hex, OperationDetail,
};
use crate::config::JustUIConfig;
use crate::registry::{RegistryClient, RegistryComponent, RegistryIndex};
use crate::utils::logger;

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

    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let loop_result = run_interactive_tui(
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
    );

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;

    loop_result
}

fn run_interactive_tui<W: io::Write, E: FnMut() -> Result<Option<Event>>>(
    terminal: &mut Terminal<CrosstermBackend<W>>,
    mut next_event: E,
    index: &RegistryIndex,
    config: &JustUIConfig,
) -> Result<()> {
    let mut list_state = ListState::default();
    list_state.select(Some(0));

    let mut selected_names = HashSet::<String>::new();
    let mut search_query = String::new();
    let mut input_mode = InputMode::Normal;

    loop {
        let query_lc = search_query.to_lowercase();
        let filtered_components: Vec<&RegistryComponent> = index
            .components
            .iter()
            .filter(|c| {
                c.name.to_lowercase().contains(&query_lc)
                    || c.description.to_lowercase().contains(&query_lc)
            })
            .collect();

        if let Some(selected) = list_state.selected() {
            if filtered_components.is_empty() {
                list_state.select(None);
            } else if selected >= filtered_components.len() {
                list_state.select(Some(filtered_components.len() - 1));
            }
        } else if !filtered_components.is_empty() {
            list_state.select(Some(0));
        }

        terminal.draw(|f| {
            draw_ui(
                f,
                &mut list_state,
                &search_query,
                input_mode,
                &filtered_components,
                config,
                &selected_names,
                index,
            );
        })?;

        if let Some(Event::Key(key)) = next_event()? {
            let action = handle_key_code(
                key.code,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                filtered_components.len(),
            );

            match action {
                KeyAction::Quit => break,
                KeyAction::ToggleSelect(selected_idx) => {
                    if let Some(comp) = filtered_components.get(selected_idx) {
                        if selected_names.contains(&comp.name) {
                            selected_names.remove(&comp.name);
                        } else {
                            selected_names.insert(comp.name.clone());
                        }
                    }
                }
                KeyAction::SelectAll => {
                    for comp in &filtered_components {
                        selected_names.insert(comp.name.clone());
                    }
                }
                KeyAction::DeselectAll => {
                    for comp in &filtered_components {
                        selected_names.remove(&comp.name);
                    }
                }
                KeyAction::Install(selected_idx) => {
                    if let Some(comp) = filtered_components.get(selected_idx) {
                        selected_names.insert(comp.name.clone());
                    }
                }
                KeyAction::InstallSelected => {
                    let to_install: Vec<String> = if selected_names.is_empty() {
                        if let Some(selected_idx) = list_state.selected() {
                            if let Some(comp) = filtered_components.get(selected_idx) {
                                vec![comp.name.clone()]
                            } else {
                                vec![]
                            }
                        } else {
                            vec![]
                        }
                    } else {
                        index
                            .components
                            .iter()
                            .filter(|c| selected_names.contains(&c.name))
                            .map(|c| c.name.clone())
                            .collect()
                    };

                    if !to_install.is_empty() {
                        let mut dep_visited = HashSet::new();
                        let mut resolved_components = Vec::new();
                        for comp_name in &to_install {
                            if let Err(e) = resolve_dependencies_recursive(
                                comp_name,
                                index,
                                &mut dep_visited,
                                &mut resolved_components,
                            ) {
                                logger::error(&format!(
                                    "Dependency resolution failed for \"{}\": {}",
                                    comp_name, e
                                ));
                            }
                        }

                        let total_files: usize = resolved_components
                            .iter()
                            .map(|name| {
                                index
                                    .components
                                    .iter()
                                    .find(|c| c.name == *name)
                                    .map(|c| c.files_for_preset(&config.preset).len())
                                    .unwrap_or(0)
                            })
                            .sum();

                        disable_raw_mode()?;
                        execute!(terminal.backend_mut(), LeaveAlternateScreen)?;

                        println!("\nInstalling {} component(s)...", resolved_components.len());

                        let pb_files = if total_files > 0 {
                            let pb = indicatif::ProgressBar::new(total_files as u64);
                            pb.set_style(
                                indicatif::ProgressStyle::default_bar()
                                    .template(
                                        "{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {pos}/{len} {msg}",
                                    )
                                    .expect("Valid progress bar template")
                                    .progress_chars("#>-"),
                            );
                            Some(pb)
                        } else {
                            None
                        };

                        let mut visited = HashSet::new();
                        let mut all_details = Vec::<OperationDetail>::new();
                        let client = RegistryClient::new(config.registry_url.clone());

                        for comp_name in &resolved_components {
                            match add_component(
                                comp_name,
                                index,
                                &client,
                                &config.components_dir,
                                &config.tokens_dir,
                                &config.shared_dir,
                                &mut visited,
                                false,
                                false,
                                true,
                                &pb_files,
                                &config.preset,
                                config.dart_target,
                            ) {
                                Ok((_stats, details)) => {
                                    all_details.extend(details);
                                }
                                Err(e) => {
                                    logger::error(&format!(
                                        "Failed to install component \"{}\": {}",
                                        comp_name, e
                                    ));
                                }
                            }
                        }

                        if let Some(ref pb) = pb_files {
                            pb.finish_and_clear();
                        }

                        logger::success(&format!(
                            "Bulk installation completed ({} component(s) processed).",
                            resolved_components.len()
                        ));

                        if !all_details.is_empty() {
                            let mut summary_items = Vec::new();
                            for detail in all_details {
                                summary_items.push(logger::SummaryItem {
                                    label: detail.file_name,
                                    value: detail.path,
                                });
                            }
                            logger::summary("File Summary", &summary_items);
                        }

                        selected_names.clear();

                        print!("\nPress Enter to return to the component list...");
                        io::stdout().flush()?;
                        let mut buffer = String::new();
                        if std::env::var("CI").is_err()
                            && std::env::var("JUSTUI_NON_INTERACTIVE").is_err()
                            && crate::utils::prompt::is_interactive()
                        {
                            let _ = io::stdin().read_line(&mut buffer);
                        }

                        let _ = enable_raw_mode();
                        let _ = execute!(terminal.backend_mut(), EnterAlternateScreen);
                        let _ = terminal.clear();
                    }
                }
                KeyAction::None => {}
            }
        }
    }
    Ok(())
}

fn handle_key_code(
    code: KeyCode,
    input_mode: &mut InputMode,
    search_query: &mut String,
    list_state: &mut ListState,
    filtered_len: usize,
) -> KeyAction {
    match input_mode {
        InputMode::Normal => match code {
            KeyCode::Char('q') | KeyCode::Esc => KeyAction::Quit,
            KeyCode::Up | KeyCode::Char('k') => {
                if let Some(selected) = list_state.selected() {
                    if selected > 0 {
                        list_state.select(Some(selected - 1));
                    }
                }
                KeyAction::None
            }
            KeyCode::Down | KeyCode::Char('j') => {
                if let Some(selected) = list_state.selected() {
                    if filtered_len > 0 && selected < filtered_len - 1 {
                        list_state.select(Some(selected + 1));
                    }
                }
                KeyAction::None
            }
            KeyCode::Char(' ') => {
                if let Some(selected) = list_state.selected() {
                    if selected < filtered_len {
                        return KeyAction::ToggleSelect(selected);
                    }
                }
                KeyAction::None
            }
            KeyCode::Char('a') | KeyCode::Char('A') => KeyAction::SelectAll,
            KeyCode::Char('n') | KeyCode::Char('N') => KeyAction::DeselectAll,
            KeyCode::Char('/') => {
                *input_mode = InputMode::Searching;
                KeyAction::None
            }
            KeyCode::Char('i') | KeyCode::Enter => KeyAction::InstallSelected,
            _ => KeyAction::None,
        },
        InputMode::Searching => match code {
            KeyCode::Esc | KeyCode::Enter => {
                *input_mode = InputMode::Normal;
                KeyAction::None
            }
            KeyCode::Backspace => {
                search_query.pop();
                KeyAction::None
            }
            KeyCode::Char(c) => {
                search_query.push(c);
                KeyAction::None
            }
            _ => KeyAction::None,
        },
    }
}

fn draw_ui(
    f: &mut ratatui::Frame,
    list_state: &mut ListState,
    search_query: &str,
    input_mode: InputMode,
    filtered_components: &[&RegistryComponent],
    config: &JustUIConfig,
    selected_names: &HashSet<String>,
    index: &RegistryIndex,
) {
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),
            Constraint::Min(0),
            Constraint::Length(3),
        ])
        .split(f.area());

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

    let list_title = match (
        input_mode == InputMode::Searching,
        selected_names.is_empty(),
    ) {
        (true, true) => format!(" Components (Filter: {}) ", search_query),
        (true, false) => format!(
            " Components (Filter: {}) ({} selected) ",
            search_query,
            selected_names.len()
        ),
        (false, true) => " Components ".to_string(),
        (false, false) => format!(" Components ({} selected) ", selected_names.len()),
    };

    let items: Vec<ListItem> = filtered_components
        .iter()
        .map(|comp| {
            let is_checked = selected_names.contains(&comp.name);
            let checkbox_span = if is_checked {
                ratatui::text::Span::styled(
                    "[x] ",
                    Style::default()
                        .fg(Color::Cyan)
                        .add_modifier(Modifier::BOLD),
                )
            } else {
                ratatui::text::Span::styled("[ ] ", Style::default().fg(Color::DarkGray))
            };

            let status = get_component_status(comp, config);
            let status_style = match status.as_str() {
                "Installed" => Style::default().fg(Color::Green),
                "Outdated / Modified" => Style::default().fg(Color::Yellow),
                "Partially Installed" => Style::default().fg(Color::LightYellow),
                _ => Style::default().fg(Color::DarkGray),
            };

            let content = ratatui::text::Line::from(vec![
                checkbox_span,
                ratatui::text::Span::raw(format!("{:<16}", comp.name)),
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

    let details_title = if selected_names.is_empty() {
        " Component Details ".to_string()
    } else {
        format!(" Component Details ({} Selected) ", selected_names.len())
    };

    let details_block = Block::default()
        .borders(Borders::ALL)
        .title(details_title)
        .border_style(Style::default().fg(Color::Gray));

    let mut detail_lines = Vec::new();

    if let Some(selected_idx) = list_state.selected() {
        if let Some(comp) = filtered_components.get(selected_idx) {
            detail_lines.push(ratatui::text::Line::from(vec![
                ratatui::text::Span::styled(
                    &comp.name,
                    Style::default()
                        .fg(Color::Cyan)
                        .add_modifier(Modifier::BOLD),
                ),
                ratatui::text::Span::raw(format!(" (v{})", comp.version)),
            ]));
            detail_lines.push(ratatui::text::Line::from(vec![
                ratatui::text::Span::styled(
                    "Category:     ",
                    Style::default().fg(Color::DarkGray),
                ),
                ratatui::text::Span::raw(&comp.category),
            ]));

            let presets_str = if comp.supported_presets.is_empty() {
                "default".to_string()
            } else {
                comp.supported_presets.join(", ")
            };
            detail_lines.push(ratatui::text::Line::from(vec![
                ratatui::text::Span::styled("Presets:      ", Style::default().fg(Color::DarkGray)),
                ratatui::text::Span::raw(presets_str),
            ]));

            let reg_deps = if comp.registry_dependencies.is_empty() {
                "none".to_string()
            } else {
                comp.registry_dependencies.join(", ")
            };
            detail_lines.push(ratatui::text::Line::from(vec![
                ratatui::text::Span::styled("Registry Deps:", Style::default().fg(Color::DarkGray)),
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
                ratatui::text::Span::styled("Pub.dev Deps: ", Style::default().fg(Color::DarkGray)),
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
            for file in files {
                detail_lines.push(ratatui::text::Line::from(vec![
                    ratatui::text::Span::raw("  • "),
                    ratatui::text::Span::styled(file.name, Style::default().fg(Color::LightGreen)),
                    ratatui::text::Span::styled(
                        format!(" ({})", file.path),
                        Style::default().fg(Color::DarkGray),
                    ),
                ]));
            }
        }
    }

    if !selected_names.is_empty() {
        if !detail_lines.is_empty() {
            detail_lines.push(ratatui::text::Line::from(""));
        }
        detail_lines.push(ratatui::text::Line::from(ratatui::text::Span::styled(
            format!("─── Selection Summary ({} components) ───", selected_names.len()),
            Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD),
        )));

        for name in index
            .components
            .iter()
            .filter(|c| selected_names.contains(&c.name))
            .map(|c| &c.name)
        {
            detail_lines.push(ratatui::text::Line::from(vec![
                ratatui::text::Span::styled(
                    "  ✓ ",
                    Style::default().fg(Color::Green).add_modifier(Modifier::BOLD),
                ),
                ratatui::text::Span::raw(name.as_str()),
            ]));
        }

        let selected_list: Vec<String> = index
            .components
            .iter()
            .filter(|c| selected_names.contains(&c.name))
            .map(|c| c.name.clone())
            .collect();

        let mut dep_visited = HashSet::new();
        let mut resolved_components = Vec::new();
        for comp_name in &selected_list {
            let _ = resolve_dependencies_recursive(
                comp_name,
                index,
                &mut dep_visited,
                &mut resolved_components,
            );
        }

        let additional_deps: Vec<String> = resolved_components
            .iter()
            .filter(|name| !selected_names.contains(*name))
            .cloned()
            .collect();

        if !additional_deps.is_empty() {
            detail_lines.push(ratatui::text::Line::from(""));
            detail_lines.push(ratatui::text::Line::from(ratatui::text::Span::styled(
                "Auto-resolved Dependencies:",
                Style::default().fg(Color::DarkGray).add_modifier(Modifier::UNDERLINED),
            )));
            for dep in &additional_deps {
                let normalized = if dep.starts_with("_shared_") {
                    crate::utils::import_rewriter::normalize_shared_file_name(&format!("{}.dart", dep))
                } else {
                    format!("{}.dart", dep)
                };
                detail_lines.push(ratatui::text::Line::from(vec![
                    ratatui::text::Span::styled("  • ", Style::default().fg(Color::Cyan)),
                    ratatui::text::Span::raw(format!("{} (→ {})", dep, normalized)),
                ]));
            }
        }

        let total_files: usize = resolved_components
            .iter()
            .map(|name| {
                index
                    .components
                    .iter()
                    .find(|c| c.name == *name)
                    .map(|c| c.files_for_preset(&config.preset).len())
                    .unwrap_or(0)
            })
            .sum();

        detail_lines.push(ratatui::text::Line::from(""));
        detail_lines.push(ratatui::text::Line::from(vec![
            ratatui::text::Span::styled("Total files to write: ", Style::default().fg(Color::DarkGray)),
            ratatui::text::Span::styled(
                format!("{}", total_files),
                Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD),
            ),
        ]));
    }

    if detail_lines.is_empty() {
        let no_selection = Paragraph::new("No component selected.")
            .block(details_block)
            .alignment(ratatui::layout::Alignment::Center);
        f.render_widget(no_selection, main_chunks[1]);
    } else {
        let details_paragraph = Paragraph::new(detail_lines)
            .block(details_block)
            .wrap(Wrap { trim: true });
        f.render_widget(details_paragraph, main_chunks[1]);
    }

    let footer_text = match input_mode {
        InputMode::Normal => {
            let install_span = if selected_names.is_empty() {
                "[Enter] Install".green()
            } else {
                format!("[Enter] Install ({})", selected_names.len()).green()
            };
            vec![
                "[Space] Toggle".cyan(),
                "  |  ".into(),
                "[a] All [n] None".yellow(),
                "  |  ".into(),
                "[↑/↓] Nav".cyan(),
                "  |  ".into(),
                "[/] Search".yellow(),
                "  |  ".into(),
                install_span,
                "  |  ".into(),
                "[q/Esc] Quit".red(),
            ]
        }
        InputMode::Searching => {
            vec![
                "[Esc/Enter] Normal Mode".yellow(),
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

fn get_component_status(comp: &RegistryComponent, config: &JustUIConfig) -> String {
    let target_dir = if comp.name == "_shared_theme_provider" {
        "lib/theme".to_string()
    } else if comp.category == "tokens" || comp.category == "core" {
        config.tokens_dir.clone()
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

    #[test]
    fn test_handle_key_code_normal_and_search_modes() {
        let mut input_mode = InputMode::Normal;
        let mut search_query = String::new();
        let mut list_state = ListState::default();
        list_state.select(Some(1));

        // 1. Normal mode: Up / k
        assert_eq!(
            handle_key_code(
                KeyCode::Up,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(list_state.selected(), Some(0));

        assert_eq!(
            handle_key_code(
                KeyCode::Up,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(list_state.selected(), Some(0));

        // 2. Normal mode: Down / j
        assert_eq!(
            handle_key_code(
                KeyCode::Down,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(list_state.selected(), Some(1));

        assert_eq!(
            handle_key_code(
                KeyCode::Char('j'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(list_state.selected(), Some(2));

        assert_eq!(
            handle_key_code(
                KeyCode::Char('j'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(list_state.selected(), Some(2));

        assert_eq!(
            handle_key_code(
                KeyCode::Char('k'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(list_state.selected(), Some(1));

        // 3. Normal mode: / (Search mode toggle)
        assert_eq!(
            handle_key_code(
                KeyCode::Char('/'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(input_mode, InputMode::Searching);

        // 4. Search mode: Char(c), Backspace, Esc
        assert_eq!(
            handle_key_code(
                KeyCode::Char('b'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(search_query, "b");

        assert_eq!(
            handle_key_code(
                KeyCode::Char('u'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(search_query, "bu");

        assert_eq!(
            handle_key_code(
                KeyCode::Backspace,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(search_query, "b");

        assert_eq!(
            handle_key_code(
                KeyCode::Null,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );

        assert_eq!(
            handle_key_code(
                KeyCode::Esc,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(input_mode, InputMode::Normal);

        // 5. Normal mode: Install, Multi-Select Hotkeys, & Quit
        assert_eq!(
            handle_key_code(
                KeyCode::Char(' '),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::ToggleSelect(1)
        );
        assert_eq!(
            handle_key_code(
                KeyCode::Char('a'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::SelectAll
        );
        assert_eq!(
            handle_key_code(
                KeyCode::Char('n'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::DeselectAll
        );
        assert_eq!(
            handle_key_code(
                KeyCode::Enter,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::InstallSelected
        );
        assert_eq!(
            handle_key_code(
                KeyCode::Char('i'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::InstallSelected
        );

        assert_eq!(
            handle_key_code(
                KeyCode::Char('q'),
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::Quit
        );
        assert_eq!(
            handle_key_code(
                KeyCode::Esc,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::Quit
        );
        assert_eq!(
            handle_key_code(
                KeyCode::Null,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );

        let mut unselected_state = ListState::default();
        assert_eq!(
            handle_key_code(
                KeyCode::Enter,
                &mut input_mode,
                &mut search_query,
                &mut unselected_state,
                3
            ),
            KeyAction::InstallSelected
        );
        unselected_state.select(Some(10));
        assert_eq!(
            handle_key_code(
                KeyCode::Enter,
                &mut input_mode,
                &mut search_query,
                &mut unselected_state,
                3
            ),
            KeyAction::InstallSelected
        );

        list_state.select(Some(0));
        assert_eq!(
            handle_key_code(
                KeyCode::Up,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(list_state.selected(), Some(0));

        list_state.select(Some(2));
        assert_eq!(
            handle_key_code(
                KeyCode::Down,
                &mut input_mode,
                &mut search_query,
                &mut list_state,
                3
            ),
            KeyAction::None
        );
        assert_eq!(list_state.selected(), Some(2));
    }

    #[test]
    fn test_draw_ui_rendering() {
        let backend = TestBackend::new(120, 30);
        let mut terminal = Terminal::new(backend).unwrap();

        let config = JustUIConfig::default();
        let comp1 = RegistryComponent {
            name: "button".to_string(),
            version: "1.0.0".to_string(),
            description: "A nice button component".to_string(),
            category: "primitive".to_string(),
            internal: false,
            supported_presets: vec!["default".to_string(), "neobrutalism".to_string()],
            registry_dependencies: vec!["_shared_pressable".to_string()],
            pub_dependencies: {
                let mut map = HashMap::new();
                map.insert("flutter".to_string(), "sdk".to_string());
                map
            },
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![crate::registry::RegistryFile {
                        name: "just_button.dart".to_string(),
                        path: "lib/button.dart".to_string(),
                        checksum: "sha256:abc".to_string(),
                    }],
                );
                map
            },
        };

        let comp2 = RegistryComponent {
            name: "_shared_theme_provider".to_string(),
            version: "0.1.0".to_string(),
            description: "Internal theme provider".to_string(),
            category: "core".to_string(),
            internal: true,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: HashMap::new(),
        };

        let filtered_components = vec![&comp1, &comp2];
        let test_index = RegistryIndex {
            version: "1.0.0".to_string(),
            presets: vec!["default".to_string()],
            components: vec![comp1.clone(), comp2.clone()],
        };

        // 1. Draw with selection = Some(0) and empty selected_names
        let mut list_state = ListState::default();
        list_state.select(Some(0));
        let mut selected_names = HashSet::new();

        terminal
            .draw(|f| {
                draw_ui(
                    f,
                    &mut list_state,
                    "",
                    InputMode::Normal,
                    &filtered_components,
                    &config,
                    &selected_names,
                    &test_index,
                );
            })
            .unwrap();

        // 2. Draw with selection = Some(1) and button checked in selected_names
        selected_names.insert("button".to_string());
        list_state.select(Some(1));
        terminal
            .draw(|f| {
                draw_ui(
                    f,
                    &mut list_state,
                    "",
                    InputMode::Normal,
                    &filtered_components,
                    &config,
                    &selected_names,
                    &test_index,
                );
            })
            .unwrap();

        // 3. Draw with search mode and selection = None
        list_state.select(None);
        terminal
            .draw(|f| {
                draw_ui(
                    f,
                    &mut list_state,
                    "btn",
                    InputMode::Searching,
                    &filtered_components,
                    &config,
                    &selected_names,
                    &test_index,
                );
            })
            .unwrap();
    }

    #[test]
    fn test_run_interactive_tui_mock() {
        let _lock = crate::utils::lock_test_mutex();
        let backend = CrosstermBackend::new(Vec::<u8>::new());
        let options = ratatui::TerminalOptions {
            viewport: ratatui::Viewport::Fixed(ratatui::layout::Rect::new(0, 0, 80, 24)),
        };
        let mut terminal = Terminal::with_options(backend, options).unwrap();

        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = crate::utils::set_dir(temp_dir.path());
        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(&reg_dir).unwrap();
        let file_content = "// button source";
        std::fs::write(reg_dir.join("just_button.dart"), file_content).unwrap();
        let checksum_hex = sha256_hex(file_content.as_bytes());

        let config = JustUIConfig {
            registry_url: reg_dir.to_string_lossy().to_string(),
            components_dir: temp_dir.path().to_string_lossy().to_string(),
            tokens_dir: temp_dir.path().to_string_lossy().to_string(),
            shared_dir: temp_dir.path().to_string_lossy().to_string(),
            ..Default::default()
        };

        let comp = RegistryComponent {
            name: "button".to_string(),
            version: "1.0.0".to_string(),
            description: "Button".to_string(),
            category: "primitive".to_string(),
            internal: false,
            supported_presets: vec!["default".to_string()],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![crate::registry::RegistryFile {
                        name: "just_button.dart".to_string(),
                        path: "just_button.dart".to_string(),
                        checksum: format!("sha256:{}", checksum_hex),
                    }],
                );
                map
            },
        };

        let comp_error = RegistryComponent {
            name: "invalid_comp".to_string(),
            version: "1.0.0".to_string(),
            description: "Invalid".to_string(),
            category: "primitive".to_string(),
            internal: false,
            supported_presets: vec!["default".to_string()],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![crate::registry::RegistryFile {
                        name: "nonexistent_file.dart".to_string(),
                        path: "nonexistent_file.dart".to_string(),
                        checksum: "sha256:123".to_string(),
                    }],
                );
                map
            },
        };

        let index = RegistryIndex {
            version: "1.0.0".to_string(),
            presets: vec!["default".to_string()],
            components: vec![comp, comp_error],
        };

        let mut events = vec![
            Event::Key(crossterm::event::KeyEvent::from(KeyCode::Char('/'))),
            Event::Key(crossterm::event::KeyEvent::from(KeyCode::Char('b'))),
            Event::Key(crossterm::event::KeyEvent::from(KeyCode::Backspace)),
            Event::Key(crossterm::event::KeyEvent::from(KeyCode::Esc)),
            Event::Key(crossterm::event::KeyEvent::from(KeyCode::Enter)),
            Event::Key(crossterm::event::KeyEvent::from(KeyCode::Down)),
            Event::Key(crossterm::event::KeyEvent::from(KeyCode::Enter)),
            Event::Key(crossterm::event::KeyEvent::from(KeyCode::Char('q'))),
        ];

        let result = run_interactive_tui(
            &mut terminal,
            || {
                Ok(if events.is_empty() {
                    Some(Event::Key(crossterm::event::KeyEvent::from(KeyCode::Char(
                        'q',
                    ))))
                } else {
                    Some(events.remove(0))
                })
            },
            &index,
            &config,
        );

        assert!(result.is_ok());
    }

    #[test]
    fn test_get_component_status_matrix() {
        let config = JustUIConfig::default();
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

        // Test categories & target_dir mapping
        let comp_tokens = RegistryComponent {
            name: "just_ui_tokens".to_string(),
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
                        name: "tokens.dart".to_string(),
                        path: "tokens.dart".to_string(),
                        checksum: "sha256:123".to_string(),
                    }],
                );
                map
            },
        };
        assert_eq!(get_component_status(&comp_tokens, &config), "Not Installed");

        let comp_theme_provider = RegistryComponent {
            name: "_shared_theme_provider".to_string(),
            version: "1.0".to_string(),
            description: "".to_string(),
            category: "core".to_string(),
            internal: true,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![crate::registry::RegistryFile {
                        name: "just_theme_provider.dart".to_string(),
                        path: "just_theme_provider.dart".to_string(),
                        checksum: "sha256:123".to_string(),
                    }],
                );
                map
            },
        };
        assert_eq!(
            get_component_status(&comp_theme_provider, &config),
            "Not Installed"
        );

        let comp_internal = RegistryComponent {
            name: "base".to_string(),
            version: "1.0".to_string(),
            description: "".to_string(),
            category: "primitive".to_string(),
            internal: true,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: {
                let mut map = HashMap::new();
                map.insert(
                    "default".to_string(),
                    vec![crate::registry::RegistryFile {
                        name: "_shared_base.dart".to_string(),
                        path: "_shared_base.dart".to_string(),
                        checksum: "sha256:123".to_string(),
                    }],
                );
                map
            },
        };
        assert_eq!(
            get_component_status(&comp_internal, &config),
            "Not Installed"
        );

        // Temporary directory for file checks
        let temp_dir = tempfile::tempdir().unwrap();
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

        // 1. Up-to-date Installed
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

        assert_eq!(
            get_component_status(&comp_installed, &config_installed),
            "Installed"
        );

        // 2. Outdated / Modified
        std::fs::write(&file1, "class Modified {}").unwrap();
        assert_eq!(
            get_component_status(&comp_installed, &config_installed),
            "Outdated / Modified"
        );

        // 3. Partially Installed
        std::fs::remove_file(&file2).unwrap();
        assert_eq!(
            get_component_status(&comp_installed, &config_installed),
            "Partially Installed"
        );
    }

    #[test]
    fn test_run_command_execution() {
        let temp_dir = tempfile::tempdir().unwrap();
        let registry_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(&registry_dir).unwrap();

        let index_json = r#"{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {
                    "name": "button",
                    "version": "1.0.0",
                    "description": "Button component",
                    "category": "primitive",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {}
                }
            ]
        }"#;
        std::fs::write(registry_dir.join("index.json"), index_json).unwrap();

        let config_file = temp_dir.path().join("justui.config.yaml");
        let config_yaml = format!("registryUrl: \"{}\"", registry_dir.to_string_lossy());
        std::fs::write(&config_file, config_yaml).unwrap();

        let _guard = crate::utils::set_dir(temp_dir.path());

        // 1. JSON output
        assert!(run(None, true).is_ok());

        // 2. Category filter JSON output
        assert!(run(Some("primitive".to_string()), true).is_ok());

        // 3. Non-existent category
        assert!(run(Some("nonexistent".to_string()), false).is_ok());

        // 4. Error case: invalid registry
        let _ = run(None, false);
    }
}
