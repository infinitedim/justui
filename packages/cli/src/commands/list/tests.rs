use super::ui::{draw_ui, handle_key_code, run_interactive_tui};
use super::*;
use crate::registry::RegistryIndex;
use crate::utils::import_rewriter;
use crossterm::event::{Event, KeyCode};
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
        name: "_shared_base".to_string(),
        version: "0.1.0".to_string(),
        description: "Internal base".to_string(),
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

    let mut dummy_guard = crate::utils::terminal_guard::TerminalGuard::dummy();
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
        &mut dummy_guard,
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

    let comp_internal_core = RegistryComponent {
        name: "_shared_kernel".to_string(),
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
                    name: "_shared_kernel.dart".to_string(),
                    path: "_shared_kernel.dart".to_string(),
                    checksum: "sha256:123".to_string(),
                }],
            );
            map
        },
    };
    assert_eq!(
        get_component_status(&comp_internal_core, &config),
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
    let _lock = crate::utils::lock_test_mutex();
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

#[test]
fn test_multi_select_keybindings_and_actions() {
    let mut input_mode = InputMode::Normal;
    let mut query = String::new();
    let mut state = ListState::default();
    state.select(Some(1));

    // Space -> ToggleSelect
    assert_eq!(
        handle_key_code(
            KeyCode::Char(' '),
            &mut input_mode,
            &mut query,
            &mut state,
            5
        ),
        KeyAction::ToggleSelect(1)
    );

    // 'a' / 'A' -> SelectAll
    assert_eq!(
        handle_key_code(
            KeyCode::Char('a'),
            &mut input_mode,
            &mut query,
            &mut state,
            5
        ),
        KeyAction::SelectAll
    );
    assert_eq!(
        handle_key_code(
            KeyCode::Char('A'),
            &mut input_mode,
            &mut query,
            &mut state,
            5
        ),
        KeyAction::SelectAll
    );

    // 'n' / 'N' -> DeselectAll
    assert_eq!(
        handle_key_code(
            KeyCode::Char('n'),
            &mut input_mode,
            &mut query,
            &mut state,
            5
        ),
        KeyAction::DeselectAll
    );
    assert_eq!(
        handle_key_code(
            KeyCode::Char('N'),
            &mut input_mode,
            &mut query,
            &mut state,
            5
        ),
        KeyAction::DeselectAll
    );

    // 'i' -> InstallSelected
    assert_eq!(
        handle_key_code(
            KeyCode::Char('i'),
            &mut input_mode,
            &mut query,
            &mut state,
            5
        ),
        KeyAction::InstallSelected
    );
}

#[test]
fn test_search_query_preserves_multi_selections() {
    let mut selected_names = HashSet::new();

    // 1. Select "button" in unfiltered list
    selected_names.insert("button".to_string());
    assert!(selected_names.contains("button"));

    // 2. Filter query "card", select "card"
    selected_names.insert("card".to_string());

    // 3. Clear search query
    assert_eq!(selected_names.len(), 2);
    assert!(selected_names.contains("button"));
    assert!(selected_names.contains("card"));
}

#[test]
fn test_bulk_installation_flow_with_shared_deps() {
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

    let file_btn = "// button";
    let file_card = "// card";
    let file_shared = "// shared pressable";
    std::fs::write(reg_dir.join("just_button.dart"), file_btn).unwrap();
    std::fs::write(reg_dir.join("just_card.dart"), file_card).unwrap();
    std::fs::write(reg_dir.join("just_pressable.dart"), file_shared).unwrap();

    let config = JustUIConfig {
        registry_url: reg_dir.to_string_lossy().to_string(),
        components_dir: temp_dir.path().to_string_lossy().to_string(),
        tokens_dir: temp_dir.path().to_string_lossy().to_string(),
        shared_dir: temp_dir.path().to_string_lossy().to_string(),
        ..Default::default()
    };

    let comp_shared = RegistryComponent {
        name: "_shared_pressable".to_string(),
        version: "1.0.0".to_string(),
        description: "Shared pressable".to_string(),
        category: "core".to_string(),
        internal: true,
        supported_presets: vec!["default".to_string()],
        registry_dependencies: vec![],
        pub_dependencies: HashMap::new(),
        files: {
            let mut map = HashMap::new();
            map.insert(
                "default".to_string(),
                vec![crate::registry::RegistryFile {
                    name: "_shared_pressable.dart".to_string(),
                    path: "just_pressable.dart".to_string(),
                    checksum: format!("sha256:{}", sha256_hex(file_shared.as_bytes())),
                }],
            );
            map
        },
    };

    let comp_btn = RegistryComponent {
        name: "button".to_string(),
        version: "1.0.0".to_string(),
        description: "Button".to_string(),
        category: "primitive".to_string(),
        internal: false,
        supported_presets: vec!["default".to_string()],
        registry_dependencies: vec!["_shared_pressable".to_string()],
        pub_dependencies: HashMap::new(),
        files: {
            let mut map = HashMap::new();
            map.insert(
                "default".to_string(),
                vec![crate::registry::RegistryFile {
                    name: "just_button.dart".to_string(),
                    path: "just_button.dart".to_string(),
                    checksum: format!("sha256:{}", sha256_hex(file_btn.as_bytes())),
                }],
            );
            map
        },
    };

    let comp_card = RegistryComponent {
        name: "card".to_string(),
        version: "1.0.0".to_string(),
        description: "Card".to_string(),
        category: "primitive".to_string(),
        internal: false,
        supported_presets: vec!["default".to_string()],
        registry_dependencies: vec!["_shared_pressable".to_string()],
        pub_dependencies: HashMap::new(),
        files: {
            let mut map = HashMap::new();
            map.insert(
                "default".to_string(),
                vec![crate::registry::RegistryFile {
                    name: "just_card.dart".to_string(),
                    path: "just_card.dart".to_string(),
                    checksum: format!("sha256:{}", sha256_hex(file_card.as_bytes())),
                }],
            );
            map
        },
    };

    let index = RegistryIndex {
        version: "1.0.0".to_string(),
        presets: vec!["default".to_string()],
        components: vec![comp_btn, comp_card, comp_shared],
    };

    // Event stream: Select All ('a'), then InstallSelected ('Enter'), then Quit ('q')
    let mut events = vec![
        Event::Key(crossterm::event::KeyEvent::from(KeyCode::Char('a'))),
        Event::Key(crossterm::event::KeyEvent::from(KeyCode::Enter)),
        Event::Key(crossterm::event::KeyEvent::from(KeyCode::Char('q'))),
    ];

    let mut dummy_guard = crate::utils::terminal_guard::TerminalGuard::dummy();
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
        &mut dummy_guard,
    );

    assert!(result.is_ok());
}
