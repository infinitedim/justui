//! Interactive ratatui front-end for `justui list`: event loop, key handling and
//! rendering. Command entry, status resolution and installation live in `mod.rs`.

use anyhow::Result;
use crossterm::event::{Event, KeyCode};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style, Stylize},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph, Wrap},
    Terminal,
};
use std::collections::HashSet;
use std::io::{self, Write};

use crate::commands::add::{add_component, resolve_dependencies_recursive, OperationDetail};
use crate::config::JustUIConfig;
use crate::registry::{RegistryClient, RegistryComponent, RegistryIndex};
use crate::utils::logger;

use super::{get_component_status, InputMode, KeyAction};

pub(super) fn run_interactive_tui<W: io::Write, E: FnMut() -> Result<Option<Event>>>(
    terminal: &mut Terminal<CrosstermBackend<W>>,
    mut next_event: E,
    index: &RegistryIndex,
    config: &JustUIConfig,
    guard: &mut crate::utils::terminal_guard::TerminalGuard,
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

                        guard.leave_temporarily()?;

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

                        let _ = guard.re_enter();
                        let _ = terminal.clear();
                    }
                }
                KeyAction::None => {}
            }
        }
    }
    Ok(())
}

pub(super) fn handle_key_code(
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

#[allow(clippy::too_many_arguments)]
pub(super) fn draw_ui(
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
                ratatui::text::Span::styled("Category:     ", Style::default().fg(Color::DarkGray)),
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
            format!(
                "─── Selection Summary ({} components) ───",
                selected_names.len()
            ),
            Style::default()
                .fg(Color::Yellow)
                .add_modifier(Modifier::BOLD),
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
                    Style::default()
                        .fg(Color::Green)
                        .add_modifier(Modifier::BOLD),
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
                Style::default()
                    .fg(Color::DarkGray)
                    .add_modifier(Modifier::UNDERLINED),
            )));
            for dep in &additional_deps {
                let normalized = if dep.starts_with("_shared_") {
                    crate::utils::import_rewriter::normalize_shared_file_name(&format!(
                        "{}.dart",
                        dep
                    ))
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
            ratatui::text::Span::styled(
                "Total files to write: ",
                Style::default().fg(Color::DarkGray),
            ),
            ratatui::text::Span::styled(
                format!("{}", total_files),
                Style::default()
                    .fg(Color::Cyan)
                    .add_modifier(Modifier::BOLD),
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
