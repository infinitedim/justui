use anyhow::Result;
use std::collections::HashSet;

use crate::commands::add::{add_component, sha256_hex};
use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::{diff_formatter, import_rewriter, logger, prompt, pubspec_editor};

#[derive(Debug, Clone, PartialEq)]
pub enum DiffStatusType {
    UpToDate,
    LocallyModified,
    UpdateAvailable,
    Conflict,
    Missing,
}

struct DiffFileStatus {
    file: crate::registry::RegistryFile,
    target_path: String,
    status_type: DiffStatusType,
    local_content: String,
    expected_hash: String,
    #[allow(dead_code)]
    remote_content: Option<String>,
}

pub fn run(
    component_name: Option<String>,
    verbose: bool,
    accept: bool,
    auto_yes: bool,
) -> Result<()> {
    let auto_yes = auto_yes || accept;
    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if !config_path.exists() {
        logger::error(
            "Project not initialized. Please run \"justui init\" in the root directory first.",
        );
        return Ok(());
    }

    let config = match std::fs::read_to_string(config_path) {
        Ok(content) => JustUIConfig::from_yaml(&content),
        Err(e) => {
            logger::error(&format!(
                "Failed to parse {}: {}",
                JustUIConfig::CONFIG_FILE_NAME,
                e
            ));
            return Ok(());
        }
    };

    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!("Failed to run diff: {}", e));
            return Ok(());
        }
    };

    let target_components: Vec<_> = if let Some(ref name) = component_name {
        match index.components.iter().find(|c| c.name == *name) {
            Some(c) => vec![c],
            None => {
                logger::error(&format!(
                    "Failed to run diff for \"{}\": Component \"{}\" not found in registry",
                    name, name
                ));
                return Ok(());
            }
        }
    } else {
        index.components.iter().collect()
    };

    for component in target_components {
        let component_name = component.name.clone();
        logger::info(&format!(
            "Comparing component \"{}\" with registry...",
            component_name
        ));

        let target_dir = if component.category == "tokens" || component.category == "core" {
            config.tokens_dir.clone()
        } else if component.name == "_shared_theme_provider" {
            "lib/theme".to_string()
        } else if component.internal {
            config.shared_dir.clone()
        } else {
            format!("{}/{}", config.components_dir, component.name)
        };

        let mut files_status: Vec<DiffFileStatus> = Vec::new();

        for file in component.files_for_preset(&config.preset) {
            let local_file_name = if component.name == "_shared_theme_provider" {
                file.name.clone()
            } else if component.internal {
                import_rewriter::normalize_shared_file_name(&file.name)
            } else {
                file.name.clone()
            };
            let target_path = format!("{}/{}", target_dir, local_file_name);
            let local_file_path = std::path::Path::new(&target_path);
            let expected_hash = file.checksum.replace("sha256:", "").trim().to_string();

            if !local_file_path.exists() {
                files_status.push(DiffFileStatus {
                    file: file.clone(),
                    target_path: target_path.clone(),
                    status_type: DiffStatusType::Missing,
                    local_content: String::new(),
                    expected_hash,
                    remote_content: None,
                });
                continue;
            }

            let raw = std::fs::read_to_string(local_file_path).unwrap_or_default();
            let local_content = raw.replace("\r\n", "\n");

            let status = if let Some(meta) = import_rewriter::parse_metadata(&local_content) {
                let local_clean = import_rewriter::strip_metadata(&local_content);
                let current_local_hash = sha256_hex(local_clean.as_bytes());

                if current_local_hash == meta.local_hash {
                    if meta.registry_hash == expected_hash {
                        DiffFileStatus {
                            file: file.clone(),
                            target_path: target_path.clone(),
                            status_type: DiffStatusType::UpToDate,
                            local_content: local_clean,
                            expected_hash,
                            remote_content: None,
                        }
                    } else {
                        DiffFileStatus {
                            file: file.clone(),
                            target_path: target_path.clone(),
                            status_type: DiffStatusType::UpdateAvailable,
                            local_content: local_clean,
                            expected_hash,
                            remote_content: None,
                        }
                    }
                } else {
                    if meta.registry_hash == expected_hash {
                        DiffFileStatus {
                            file: file.clone(),
                            target_path: target_path.clone(),
                            status_type: DiffStatusType::LocallyModified,
                            local_content: local_clean,
                            expected_hash,
                            remote_content: None,
                        }
                    } else {
                        DiffFileStatus {
                            file: file.clone(),
                            target_path: target_path.clone(),
                            status_type: DiffStatusType::Conflict,
                            local_content: local_clean,
                            expected_hash,
                            remote_content: None,
                        }
                    }
                }
            } else {
                let local_hash = sha256_hex(local_content.as_bytes());
                if local_hash == expected_hash {
                    DiffFileStatus {
                        file: file.clone(),
                        target_path: target_path.clone(),
                        status_type: DiffStatusType::UpToDate,
                        local_content,
                        expected_hash,
                        remote_content: None,
                    }
                } else {
                    DiffFileStatus {
                        file: file.clone(),
                        target_path: target_path.clone(),
                        status_type: DiffStatusType::LocallyModified,
                        local_content,
                        expected_hash,
                        remote_content: None,
                    }
                }
            };
            files_status.push(status);
        }

        for fs in &files_status {
            match fs.status_type {
                DiffStatusType::UpToDate => {
                    logger::success(&format!("{}: Up to date.", fs.file.name))
                }
                DiffStatusType::LocallyModified => {
                    logger::warning(&format!("{}: Modified locally.", fs.file.name))
                }
                DiffStatusType::UpdateAvailable => {
                    logger::info(&format!("{}: Update available.", fs.file.name))
                }
                DiffStatusType::Conflict => {
                    logger::warning(&format!("{}: Conflict (both modified).", fs.file.name))
                }
                DiffStatusType::Missing => logger::warning(&format!(
                    "File {} is missing locally (needs to be added).",
                    fs.file.name
                )),
            }
        }

        let changed_files: Vec<usize> = files_status
            .iter()
            .enumerate()
            .filter(|(_, fs)| fs.status_type != DiffStatusType::UpToDate)
            .map(|(i, _)| i)
            .collect();

        if changed_files.is_empty() {
            return Ok(());
        }

        let pkg_name = pubspec_editor::get_package_name(std::path::Path::new("pubspec.yaml"))
            .unwrap_or_else(|_| "flutter_app".to_string());

        if verbose {
            for &idx in &changed_files {
                let fs = &files_status[idx];
                if fs.status_type == DiffStatusType::Missing {
                    continue;
                }
                let remote_raw = client.fetch_file_content(&fs.file.path).unwrap_or_default();
                let remote_rewritten = import_rewriter::rewrite(
                    &remote_raw,
                    &fs.file.path,
                    &component_name,
                    &index,
                    &config.components_dir,
                    &config.tokens_dir,
                    &config.shared_dir,
                    &config.preset,
                    &pkg_name,
                );
                print_line_diff(&fs.file.name, &fs.local_content, &remote_rewritten);
            }
            return Ok(());
        }

        let mut remote_rewritten_map: std::collections::HashMap<usize, String> =
            std::collections::HashMap::new();
        for &idx in &changed_files {
            let fs = &files_status[idx];
            if fs.status_type == DiffStatusType::Missing {
                continue;
            }
            let remote_raw = client.fetch_file_content(&fs.file.path).unwrap_or_default();
            let rr = import_rewriter::rewrite(
                &remote_raw,
                &fs.file.path,
                &component_name,
                &index,
                &config.components_dir,
                &config.tokens_dir,
                &config.shared_dir,
                &config.preset,
                &pkg_name,
            );
            remote_rewritten_map.insert(idx, rr);
        }

        show_all_diffs(&files_status, &changed_files, &remote_rewritten_map, 3);

        if auto_yes {
            logger::stdout("[auto] Applying all changes");
            let mut visited: HashSet<String> = HashSet::new();

            add_component(
                &component_name,
                &index,
                &client,
                &config.components_dir,
                &config.tokens_dir,
                &config.shared_dir,
                &mut visited,
                false,
                false,
                true,
                &None,
                &config.preset,
                config.dart_target,
            )?;
            logger::success("All changes applied successfully.");
            continue;
        }

        loop {
            logger::stdout("\nOptions:");
            logger::stdout("  [a] Apply all changes");
            logger::stdout("  [s] Select changes to apply");
            logger::stdout("  [v] View full diff");
            logger::stdout("  [q] Quit");

            let choice = prompt::ask("Choose option", "q").to_lowercase();

            match choice.as_str() {
                "q" => break,
                "v" => {
                    show_all_diffs(&files_status, &changed_files, &remote_rewritten_map, 99999);
                }
                "a" => {
                    for &idx in &changed_files {
                        let fs = &files_status[idx];
                        if let Some(rr) = remote_rewritten_map.get(&idx) {
                            apply_file_change(fs, rr, &component_name, &index)?;
                        }
                    }
                    logger::success("All changes applied successfully.");
                    break;
                }
                "s" => {
                    for &idx in &changed_files {
                        let fs = &files_status[idx];
                        let confirm = prompt::confirm(
                            &format!("Apply changes to \"{}\"?", fs.file.name),
                            false,
                        );
                        if confirm {
                            if let Some(rr) = remote_rewritten_map.get(&idx) {
                                apply_file_change(fs, rr, &component_name, &index)?;
                            }
                        }
                    }
                    logger::success("Selected changes applied successfully.");
                    break;
                }
                _ => {
                    logger::error("Invalid option.");
                }
            }
        }
    }

    Ok(())
}

fn show_all_diffs(
    files_status: &[DiffFileStatus],
    changed_files: &[usize],
    remote_rewritten_map: &std::collections::HashMap<usize, String>,
    context: usize,
) {
    for &idx in changed_files {
        let fs = &files_status[idx];
        if fs.status_type == DiffStatusType::Missing {
            logger::info(&format!("\n[File \"{}\" is missing locally]", fs.file.name));
            continue;
        }
        if let Some(rr) = remote_rewritten_map.get(&idx) {
            diff_formatter::print_unified_diff(&fs.file.name, &fs.local_content, rr, context);
        }
    }
}

fn print_line_diff(file_name: &str, local: &str, remote: &str) {
    logger::stdout(&format!("\n--- Line-by-line diff for {} ---", file_name));
    let local_norm = local.replace("\r\n", "\n");
    let remote_norm = remote.replace("\r\n", "\n");
    let local_lines: Vec<&str> = local_norm.split('\n').collect();
    let remote_lines: Vec<&str> = remote_norm.split('\n').collect();
    let max_lines = local_lines.len().max(remote_lines.len());

    for i in 0..max_lines {
        let local_line = local_lines.get(i).copied();
        let remote_line = remote_lines.get(i).copied();

        if local_line != remote_line {
            match (local_line, remote_line) {
                (None, Some(r)) => {
                    logger::stdout(&format!("\x1B[32m+ [Line {}] {}\x1B[0m", i + 1, r))
                }
                (Some(l), None) => {
                    logger::stdout(&format!("\x1B[31m- [Line {}] {}\x1B[0m", i + 1, l))
                }
                (Some(l), Some(r)) => {
                    logger::stdout(&format!(
                        "\x1B[31m- [Line {}] Local:    {}\x1B[0m",
                        i + 1,
                        l
                    ));
                    logger::stdout(&format!(
                        "\x1B[32m+ [Line {}] Registry: {}\x1B[0m",
                        i + 1,
                        r
                    ));
                }
                _ => {}
            }
        }
    }
    logger::stdout("-----------------------------------------\n");
}

fn apply_file_change(
    fs: &DiffFileStatus,
    remote_rewritten: &str,
    _component_name: &str,
    _index: &crate::registry::RegistryIndex,
) -> Result<()> {
    let local_hash = sha256_hex(remote_rewritten.as_bytes());
    let final_to_write =
        import_rewriter::inject_metadata(remote_rewritten, &fs.expected_hash, &local_hash);

    let path = std::path::Path::new(&fs.target_path);
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(path, &final_to_write)?;
    logger::stdout(&format!("  - Updated {}", fs.file.name));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_diff_helpers_and_uninitialized() {
        let _lock = crate::utils::TEST_MUTEX.lock().unwrap();
        let local = "line 1\nline 2 local\nline 3 local";
        let remote = "line 1\nline 2 remote\nline 4 remote";
        print_line_diff("just_button.dart", local, remote);

        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = std::env::set_current_dir(temp_dir.path());

        // Uninitialized project returns Ok without crashing
        assert!(run(Some("button".to_string()), false, false, true).is_ok());

        // Test apply_file_change
        let target_file = temp_dir.path().join("lib/ui/just_button.dart");
        let fs_status = DiffFileStatus {
            file: crate::registry::RegistryFile {
                name: "just_button.dart".to_string(),
                path: "components/button/just_button.dart".to_string(),
                checksum: "sha256:hash1".to_string(),
            },
            status_type: DiffStatusType::LocallyModified,
            local_content: "class Old {}".to_string(),
            target_path: target_file.to_string_lossy().to_string(),
            expected_hash: "hash1".to_string(),
            remote_content: None,
        };

        let dummy_index = crate::registry::RegistryIndex {
            version: "0.1.0".to_string(),
            presets: vec![],
            components: vec![],
        };

        assert!(apply_file_change(&fs_status, "class New {}", "button", &dummy_index).is_ok());
        assert!(target_file.exists());

        // Test show_all_diffs
        let mut map = std::collections::HashMap::new();
        map.insert(0, "class New {}".to_string());
        show_all_diffs(&[fs_status], &[0], &map, 2);

        // Test run with initialized project and mock local registry
        let registry_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(registry_dir.join("components/button")).unwrap();
        let button_code = "class JustButton {}";
        let button_hash = sha256_hex(button_code.as_bytes());

        std::fs::write(
            registry_dir.join("index.json"),
            serde_json::to_string(&serde_json::json!({
                "version": "0.1.0",
                "presets": ["default"],
                "components": [{
                    "name": "button",
                    "version": "0.1.0",
                    "description": "Button",
                    "category": "primitives",
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [{
                            "name": "just_button.dart",
                            "path": "components/button/just_button.dart",
                            "checksum": format!("sha256:{}", button_hash)
                        }]
                    }
                }]
            }))
            .unwrap(),
        )
        .unwrap();

        std::fs::write(
            registry_dir.join("components/button/just_button.dart"),
            button_code,
        )
        .unwrap();
        std::fs::write("pubspec.yaml", "name: test_app").unwrap();
        std::fs::write(
            "justui.config.yaml",
            format!("components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\npreset: default\nregistry_url: {}\n", registry_dir.display()),
        )
        .unwrap();

        assert!(run(Some("button".to_string()), true, false, true).is_ok());
        assert!(run(Some("button".to_string()), false, false, true).is_ok());

        // Test run with modified local component and auto_yes
        let local_comp_file = temp_dir.path().join("lib/ui/just_button.dart");
        std::fs::create_dir_all(local_comp_file.parent().unwrap()).unwrap();
        std::fs::write(&local_comp_file, "class ModifiedButton {}").unwrap();

        assert!(run(Some("button".to_string()), true, false, true).is_ok());
        assert!(run(Some("button".to_string()), false, false, true).is_ok());

        // Test missing component in registry
        assert!(run(Some("nonexistent_comp".to_string()), false, false, true).is_ok());

        // Test run(None, ...) -> diff all components
        assert!(run(None, false, false, true).is_ok());
        assert!(run(None, true, false, true).is_ok());

        // Test DiffStatusType::Missing in show_all_diffs
        let fs_missing = DiffFileStatus {
            file: crate::registry::RegistryFile {
                name: "missing.dart".to_string(),
                path: "components/button/missing.dart".to_string(),
                checksum: "sha256:hash2".to_string(),
            },
            status_type: DiffStatusType::Missing,
            local_content: String::new(),
            target_path: temp_dir
                .path()
                .join("lib/ui/missing.dart")
                .to_string_lossy()
                .to_string(),
            expected_hash: "hash2".to_string(),
            remote_content: None,
        };
        show_all_diffs(&[fs_missing], &[0], &std::collections::HashMap::new(), 3);

        // Test metadata with UpdateAvailable and Conflict
        let old_reg_hash = "old_reg_hash_123";
        let _new_reg_hash = "new_reg_hash_456";
        let content_unmodified = "class Button {}";
        let content_modified = "class ButtonModified {}";
        let local_hash_unmodified = sha256_hex(content_unmodified.as_bytes());
        let _local_hash_modified = sha256_hex(content_modified.as_bytes());

        // UpdateAvailable metadata
        let meta_update = import_rewriter::inject_metadata(
            content_unmodified,
            old_reg_hash,
            &local_hash_unmodified,
        );
        std::fs::write(&local_comp_file, meta_update).unwrap();
        assert!(run(Some("button".to_string()), false, false, true).is_ok());

        // Conflict metadata
        let meta_conflict = import_rewriter::inject_metadata(
            content_modified,
            old_reg_hash,
            &local_hash_unmodified,
        );
        std::fs::write(&local_comp_file, meta_conflict).unwrap();
        assert!(run(Some("button".to_string()), false, false, true).is_ok());
    }
}
