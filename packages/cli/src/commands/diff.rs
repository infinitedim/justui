use anyhow::Result;
use std::collections::HashSet;

use crate::commands::add::sha256_hex;
use crate::config::JustUIConfig;
use crate::registry::{RegistryClient, RegistryFile, RegistryIndex};
use crate::utils::{diff_formatter, import_rewriter, logger, prompt};

#[derive(Debug, Clone, PartialEq)]
pub enum DiffStatusType {
    UpToDate,
    LocallyModified,
    UpdateAvailable,
    Conflict,
    Missing,
}

struct DiffFileStatus {
    file: RegistryFile,
    target_path: String,
    status_type: DiffStatusType,
    local_content: String,
    expected_hash: String,
    #[allow(dead_code)]
    remote_content: Option<String>,
}

/// Runs the `justui diff <component> [--verbose]` command.
pub fn run(component_name: String, verbose: bool) -> Result<()> {
    // 1. Verify initialization config exists
    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if !config_path.exists() {
        logger::error(
            "Project not initialized. Please run \"justui init\" in the root directory first.",
        );
        return Ok(());
    }

    // 2. Parse configuration
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

    logger::info(&format!(
        "Comparing component \"{}\" with registry...",
        component_name
    ));

    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!(
                "Failed to run diff for \"{}\": {}",
                component_name, e
            ));
            return Ok(());
        }
    };

    let component = match index.components.iter().find(|c| c.name == component_name) {
        Some(c) => c,
        None => {
            logger::error(&format!(
                "Failed to run diff for \"{}\": Component \"{}\" not found in registry",
                component_name, component_name
            ));
            return Ok(());
        }
    };

    let shared_components = index.compute_shared_components();

    let target_dir = if component.category == "tokens" || component.category == "core" {
        config.tokens_dir.clone()
    } else if shared_components.contains(&component.name) {
        config.shared_dir.clone()
    } else {
        format!("{}/{}", config.components_dir, component.name)
    };

    let mut files_status: Vec<DiffFileStatus> = Vec::new();

    for file in &component.files {
        let local_file_name = if shared_components.contains(&component.name) {
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
                // Unmodified locally
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
                // Locally modified
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
            // No metadata: compare raw hash against expected
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

    // Print status overview
    for fs in &files_status {
        match fs.status_type {
            DiffStatusType::UpToDate => logger::success(&format!("{}: Up to date.", fs.file.name)),
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
                &shared_components,
            );
            print_line_diff(&fs.file.name, &fs.local_content, &remote_rewritten);
        }
        return Ok(());
    }

    // Pre-fetch and rewrite remote content for changed files
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
            &shared_components,
        );
        remote_rewritten_map.insert(idx, rr);
    }

    // Show initial diffs
    show_all_diffs(&files_status, &changed_files, &remote_rewritten_map, 3);

    // Prompt loop
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
                        apply_file_change(fs, rr, &component_name, &index, &shared_components)?;
                    }
                }
                logger::success("All changes applied successfully.");
                break;
            }
            "s" => {
                for &idx in &changed_files {
                    let fs = &files_status[idx];
                    let confirm =
                        prompt::confirm(&format!("Apply changes to \"{}\"?", fs.file.name), false);
                    if confirm {
                        if let Some(rr) = remote_rewritten_map.get(&idx) {
                            apply_file_change(fs, rr, &component_name, &index, &shared_components)?;
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
    _index: &RegistryIndex,
    _shared_components: &HashSet<String>,
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
