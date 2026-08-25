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
use crate::registry::{RegistryClient, RegistryComponent};
use crate::utils::logger;

#[derive(PartialEq, Eq)]
enum InputMode {
    Normal,
    Searching,
}

pub fn run(category: Option<String>) -> Result<()> {
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

    if index.components.is_empty() {
        logger::warning("No components found in the registry.");
        return Ok(());
    }

    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut list_state = ListState::default();
    list_state.select(Some(0));

    let mut search_query = String::new();
    let mut input_mode = InputMode::Normal;

    let loop_result = (|| -> Result<()> {
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
                        let status = get_component_status(comp, &config);
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
                f.render_stateful_widget(list_widget, main_chunks[0], &mut list_state);

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
            })?;

            if event::poll(std::time::Duration::from_millis(100))? {
                if let Event::Key(key) = event::read()? {
                    match input_mode {
                        InputMode::Normal => match key.code {
                            KeyCode::Char('q') | KeyCode::Esc => break,
                            KeyCode::Up | KeyCode::Char('k') => {
                                if let Some(selected) = list_state.selected() {
                                    if selected > 0 {
                                        list_state.select(Some(selected - 1));
                                    }
                                }
                            }
                            KeyCode::Down | KeyCode::Char('j') => {
                                if let Some(selected) = list_state.selected() {
                                    if !filtered_components.is_empty()
                                        && selected < filtered_components.len() - 1
                                    {
                                        list_state.select(Some(selected + 1));
                                    }
                                }
                            }
                            KeyCode::Char('/') => {
                                input_mode = InputMode::Searching;
                            }
                            KeyCode::Char('i') | KeyCode::Enter => {
                                if let Some(selected_idx) = list_state.selected() {
                                    if let Some(comp) = filtered_components.get(selected_idx) {
                                        let comp_name = comp.name.clone();

                                        disable_raw_mode()?;
                                        execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
                                        println!("\nInstalling component \"{}\"...", comp_name);

                                        let mut visited = HashSet::new();
                                        let pb_files = indicatif::ProgressBar::new_spinner();
                                        pb_files.set_message("Installing files...");
                                        pb_files.enable_steady_tick(
                                            std::time::Duration::from_millis(100),
                                        );

                                        match add_component(
                                            &comp_name,
                                            &index,
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
                                        execute!(terminal.backend_mut(), EnterAlternateScreen)?;
                                        terminal.clear()?;
                                    }
                                }
                            }
                            _ => {}
                        },
                        InputMode::Searching => match key.code {
                            KeyCode::Esc => {
                                input_mode = InputMode::Normal;
                            }
                            KeyCode::Backspace => {
                                search_query.pop();
                            }
                            KeyCode::Char(c) => {
                                search_query.push(c);
                            }
                            _ => {}
                        },
                    }
                }
            }
        }
        Ok(())
    })();

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;

    loop_result
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
    use std::collections::HashMap;

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
}
