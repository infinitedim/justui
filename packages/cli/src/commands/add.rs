use anyhow::Result;
use sha2::{Digest, Sha256};
use std::collections::HashSet;

use crate::config::JustUIConfig;
use crate::registry::{RegistryClient, RegistryIndex};
use crate::utils::{diff_formatter, import_rewriter, logger, prompt, pubspec_editor};
use crate::utils::logger::SummaryItem;

/// Accumulates counters during a dry-run for the final summary.
#[derive(Default)]
pub struct DryRunStats {
    pub will_write: usize,
    pub skipped: usize,
    pub conflicts: usize,
}

impl DryRunStats {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn merge(&mut self, other: &DryRunStats) {
        self.will_write += other.will_write;
        self.skipped += other.skipped;
        self.conflicts += other.conflicts;
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum OperationStatus {
    Copied,
    UpToDate,
    SkippedLocalCustomization,
    Overwritten,
    ConflictResolvedOverwrite,
    ConflictResolvedSkip,
}

#[derive(Debug, Clone)]
pub struct OperationDetail {
    pub file_name: String,
    pub status: OperationStatus,
    pub path: String,
}

/// Runs the `justui add [component...]` command.
pub fn run(
    components: Vec<String>,
    dry_run: bool,
    show_diff: bool,
    auto_yes: bool,
) -> Result<()> {
    // If --diff is set, dry_run is implicitly enabled
    let effective_dry_run = dry_run || show_diff;

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

    // Show a spinner while fetching registry index
    let pb_index = indicatif::ProgressBar::new_spinner();
    pb_index.set_message("Fetching registry index...");
    pb_index.enable_steady_tick(std::time::Duration::from_millis(100));

    let client = RegistryClient::new(config.registry_url.clone());
    let index = match client.fetch_index() {
        Ok(idx) => {
            pb_index.finish_and_clear();
            idx
        }
        Err(e) => {
            pb_index.finish_and_clear();
            logger::error(&format!("Failed to add components: {}", e));
            return Ok(());
        }
    };

    let components_to_add: Vec<String> = if components.is_empty() {
        // Interactive selection — bypass if auto_yes
        let component_names: Vec<String> = index
            .components
            .iter()
            .map(|c| format!("{} ({})", c.name, c.description))
            .collect();

        if component_names.is_empty() {
            logger::error("No components found in the registry.");
            return Ok(());
        }

        if auto_yes {
            // Select all components
            let names: Vec<String> = index.components.iter().map(|c| c.name.clone()).collect();
            let names_str = names.join(", ");
            logger::stdout(&format!("[auto] Memilih semua komponen: {}", names_str));
            names
        } else {
            logger::stdout("Select components to add:");
            let refs: Vec<&str> = component_names.iter().map(|s| s.as_str()).collect();
            let selected_indices = prompt::select_multiple("Choose components", &refs);

            if selected_indices.is_empty() {
                logger::warning("No components selected.");
                return Ok(());
            }

            selected_indices
                .into_iter()
                .map(|idx| index.components[idx].name.clone())
                .collect()
        }
    } else {
        components
    };

    // Calculate total files for progress bar
    let mut resolved_components = Vec::new();
    let mut dep_visited = HashSet::new();
    for comp_name in &components_to_add {
        if let Err(e) = resolve_dependencies_recursive(comp_name, &index, &mut dep_visited, &mut resolved_components) {
            logger::error(&format!("Dependency resolution error: {}", e));
            return Ok(());
        }
    }

    let total_files: usize = resolved_components
        .iter()
        .map(|name| {
            index
                .components
                .iter()
                .find(|c| c.name == *name)
                .map(|c| c.files.len())
                .unwrap_or(0)
        })
        .sum();

    let pb_files = if effective_dry_run || total_files == 0 {
        None
    } else {
        let bar = indicatif::ProgressBar::new(total_files as u64);
        bar.set_style(
            indicatif::ProgressStyle::default_bar()
                .template("{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {pos}/{len} {msg}")
                .unwrap()
                .progress_chars("#>-")
        );
        bar.set_message("Copying component files...");
        Some(bar)
    };

    let mut visited: HashSet<String> = HashSet::new();
    let mut last_error: Option<anyhow::Error> = None;
    let mut total_stats = DryRunStats::new();
    let mut all_details = Vec::new();

    for comp_name in &components_to_add {
        match add_component(
            comp_name,
            &index,
            &client,
            &config.components_dir,
            &config.tokens_dir,
            &config.shared_dir,
            &mut visited,
            effective_dry_run,
            show_diff,
            auto_yes,
            &pb_files,
        ) {
            Ok((stats, details)) => {
                total_stats.merge(&stats);
                all_details.extend(details);
            }
            Err(e) => {
                last_error = Some(e);
                break;
            }
        }
    }

    if let Some(ref bar) = pb_files {
        bar.finish_with_message("Done!");
    }

    if let Some(e) = last_error {
        logger::error(&format!("Failed to add components: {}", e));
    }

    // Print dry-run summary
    if effective_dry_run {
        logger::stdout(&format!(
            "\nRingkasan dry-run: {} file akan ditulis, {} dilewati, {} konflik",
            total_stats.will_write, total_stats.skipped, total_stats.conflicts
        ));
    } else {
        // Modern, minimalist summary output
        let mut copied_count = 0;
        let mut skipped_count = 0;
        let mut success_details = Vec::new();
        let mut skip_details = Vec::new();

        for detail in &all_details {
            match detail.status {
                OperationStatus::Copied => {
                    copied_count += 1;
                    success_details.push(format!("  \x1B[32m✔\x1B[0m {} (Baru) -> {}", detail.file_name, detail.path));
                }
                OperationStatus::Overwritten => {
                    copied_count += 1;
                    success_details.push(format!("  \x1B[32m✔\x1B[0m {} (Diperbarui) -> {}", detail.file_name, detail.path));
                }
                OperationStatus::ConflictResolvedOverwrite => {
                    copied_count += 1;
                    success_details.push(format!("  \x1B[32m✔\x1B[0m {} (Konflik ditimpa) -> {}", detail.file_name, detail.path));
                }
                OperationStatus::UpToDate => {
                    skipped_count += 1;
                    skip_details.push(format!("  \x1B[33m⚠\x1B[0m {} (Sudah terbaru) -> {}", detail.file_name, detail.path));
                }
                OperationStatus::SkippedLocalCustomization => {
                    skipped_count += 1;
                    skip_details.push(format!("  \x1B[33m⚠\x1B[0m {} (Dilewati, kustomisasi lokal) -> {}", detail.file_name, detail.path));
                }
                OperationStatus::ConflictResolvedSkip => {
                    skipped_count += 1;
                    skip_details.push(format!("  \x1B[33m⚠\x1B[0m {} (Konflik dilewati) -> {}", detail.file_name, detail.path));
                }
            }
        }

        logger::stdout("");
        if copied_count > 0 {
            logger::stdout(&format!("\x1B[32m✔\x1B[0m {} file berhasil ditambahkan/diperbarui:", copied_count));
            for line in success_details {
                logger::stdout(&line);
            }
        }
        if skipped_count > 0 {
            logger::stdout(&format!("\x1B[33m⚠\x1B[0m {} file dilewati:", skipped_count));
            for line in skip_details {
                logger::stdout(&line);
            }
        }
    }

    // Kumpulkan hasil untuk summary
    let mut summary_items: Vec<SummaryItem> = Vec::new();

    for name in &components_to_add {
        // Cari komponen di index untuk dapat versi dan target path
        if let Some(component) = index.components.iter().find(|c| c.name == *name) {
            let target_dir = if component.category == "tokens" || component.category == "core" {
                config.tokens_dir.clone()
            } else if component.internal {
                config.shared_dir.clone()
            } else {
                format!("{}/{}", config.components_dir, component.name)
            };

            summary_items.push(SummaryItem {
                label: name.clone(),
                value: format!("v{}  {}/", component.version, target_dir),
            });
        }
    }

    if !summary_items.is_empty() && !dry_run {
        logger::summary(
            &format!("{} komponen berhasil ditambahkan", summary_items.len()),
            &summary_items,
        );
    }

    Ok(())
}

fn resolve_dependencies_recursive(
    name: &str,
    index: &RegistryIndex,
    visited: &mut HashSet<String>,
    resolved: &mut Vec<String>,
) -> Result<()> {
    if visited.contains(name) {
        return Ok(());
    }
    visited.insert(name.to_string());
    
    let component = index
        .components
        .iter()
        .find(|c| c.name == name)
        .ok_or_else(|| anyhow::anyhow!("Component \"{}\" not found in registry", name))?;
        
    for dep in &component.registry_dependencies {
        resolve_dependencies_recursive(dep, index, visited, resolved)?;
    }
    resolved.push(name.to_string());
    Ok(())
}

/// Adds a single component (and its dependencies recursively) to the project.
/// Shared between `add` and `update` commands.
#[allow(clippy::too_many_arguments)]
pub fn add_component(
    name: &str,
    index: &RegistryIndex,
    client: &RegistryClient,
    components_dir: &str,
    tokens_dir: &str,
    shared_dir: &str,
    visited: &mut HashSet<String>,
    dry_run: bool,
    show_diff: bool,
    auto_yes: bool,
    pb: &Option<indicatif::ProgressBar>,
) -> Result<(DryRunStats, Vec<OperationDetail>)> {
    // Circular dependency check and double-copy guard
    if visited.contains(name) {
        return Ok((DryRunStats::new(), Vec::new()));
    }
    visited.insert(name.to_string());

    let component = index
        .components
        .iter()
        .find(|c| c.name == name)
        .ok_or_else(|| anyhow::anyhow!("Component \"{}\" not found in registry", name))?;

    // 1. Recursively resolve registry dependencies first
    let deps: Vec<String> = component.registry_dependencies.clone();
    let mut stats = DryRunStats::new();
    let mut details = Vec::new();
    for dep in &deps {
        let (dep_stats, dep_details) = add_component(
            dep,
            index,
            client,
            components_dir,
            tokens_dir,
            shared_dir,
            visited,
            dry_run,
            show_diff,
            auto_yes,
            pb,
        )?;
        stats.merge(&dep_stats);
        details.extend(dep_details);
    }

    logger::info(&format!(
        "Adding component \"{}\" (v{})...",
        component.name, component.version
    ));

    // 2. Map target directory based on category and shared status
    let target_dir = if component.category == "tokens" || component.category == "core" {
        tokens_dir.to_string()
    } else if component.internal {
        shared_dir.to_string()
    } else {
        format!("{}/{}", components_dir, component.name)
    };

    // 3. Download, validate, rewrite, and write each file
    let files: Vec<_> = component.files.clone();
    let comp_name = component.name.clone();
    let pub_deps: Vec<(String, String)> = component
        .pub_dependencies
        .iter()
        .map(|(k, v)| (k.clone(), v.clone()))
        .collect();

    for file in &files {
        if let Some(ref bar) = pb {
            bar.inc(1);
            bar.set_message(format!("Processing {}...", file.name));
        }

        let content = client
            .fetch_file_content(&file.path)
            .map_err(|e| anyhow::anyhow!("Failed to fetch \"{}\": {}", file.name, e))?;

        // Verify SHA-256 checksum integrity
        let downloaded_hash = sha256_hex(content.as_bytes());
        let expected_hash = file.checksum.replace("sha256:", "").trim().to_string();

        if downloaded_hash != expected_hash {
            return Err(anyhow::anyhow!(
                "Security check failed: Checksum mismatch for downloaded file \"{}\".\n  \
                 Expected: {}\n  Got:      {}\n\
                 The download might be corrupted or tampered with.",
                file.name,
                expected_hash,
                downloaded_hash
            ));
        }

        // Apply import rewriting
        let rewritten_content = import_rewriter::rewrite(
            &content,
            &file.path,
            &comp_name,
            index,
            components_dir,
            tokens_dir,
            shared_dir,
        );

        let local_rewritten_hash = sha256_hex(rewritten_content.as_bytes());
        let final_content = import_rewriter::inject_metadata(
            &rewritten_content,
            &expected_hash,
            &local_rewritten_hash,
        );

        let local_file_name = if component.internal {
            import_rewriter::normalize_shared_file_name(&file.name)
        } else {
            file.name.clone()
        };
        let target_path = std::path::Path::new(&target_dir).join(&local_file_name);

        // --- Determine should_write (with dry-run / auto-yes overrides) ---
        let file_exists = target_path.exists();

        // Track the local "clean" content for diff display (populated if file exists)
        let mut local_clean_for_diff = String::new();

        let (should_write, conflict_detected, status) = if file_exists {
            if dry_run {
                // In dry-run mode we read to compute status but never prompt
                let (sw, conflict, local_clean, st) = resolve_conflict_dry(
                    &target_path,
                    &local_file_name,
                    &expected_hash,
                    &rewritten_content,
                    auto_yes,
                )?;
                local_clean_for_diff = local_clean;
                (sw, conflict, st)
            } else {
                let (sw, st) = resolve_conflict(
                    &target_path,
                    &local_file_name,
                    &expected_hash,
                    &rewritten_content,
                    &final_content,
                    auto_yes,
                )?;
                (sw, false, st)
            }
        } else {
            (true, false, OperationStatus::Copied)
        };

        // --- Show diff block (before writing) ---
        if show_diff {
            if file_exists {
                // Show unified diff between local and new registry content
                diff_formatter::print_unified_diff(
                    &local_file_name,
                    &local_clean_for_diff,
                    &rewritten_content,
                    3,
                );
            } else {
                // Show entire new file with "+" prefix
                logger::stdout(&format!("[registry] {} (file baru)", local_file_name));
                for line in rewritten_content.lines() {
                    logger::stdout(&format!("+ {}", line));
                }
            }
        }

        // --- Track stats & write ---
        if dry_run {
            if conflict_detected {
                stats.conflicts += 1;
                logger::stdout(&format!(
                    "  [dry-run] Konflik (akan ditulis jika dipilih): {}",
                    local_file_name
                ));
            } else if should_write {
                stats.will_write += 1;
                logger::stdout(&format!(
                    "  [dry-run] Akan ditulis: {}",
                    target_path.display()
                ));
            } else {
                stats.skipped += 1;
                // Message was already printed by resolve_conflict_dry
            }
        } else if should_write {
            // Normal write
            if let Some(parent) = target_path.parent() {
                std::fs::create_dir_all(parent)?;
            }
            std::fs::write(&target_path, &final_content)?;
            logger::stdout(&format!(
                "  - Copied {} to {}/",
                local_file_name, target_dir
            ));
        }

        details.push(OperationDetail {
            file_name: local_file_name.clone(),
            status,
            path: format!("{}/{}", target_dir, local_file_name),
        });
    }

    // 4. Inject pub dependencies into pubspec.yaml (skip in dry-run mode)
    if !pub_deps.is_empty() && !dry_run {
        let pubspec_path = std::path::Path::new("pubspec.yaml");
        for (dep, version) in &pub_deps {
            match pubspec_editor::add_dependency(pubspec_path, dep, version) {
                Ok(_) => {
                    logger::success(&format!(
                        "Added dependency \"{}: {}\" to pubspec.yaml.",
                        dep, version
                    ));
                }
                Err(e) => {
                    logger::warning(&format!("Could not add dependency \"{}\": {}", dep, e));
                }
            }
        }
    }

    if !dry_run {
        logger::success(&format!("Component \"{}\" added successfully.", comp_name));
    }
    Ok((stats, details))
}

/// Resolves a conflict when a local file already exists (normal mode, may show prompt).
/// Returns true if the file should be overwritten.
#[allow(clippy::needless_return)]
fn resolve_conflict(
    target_path: &std::path::Path,
    local_file_name: &str,
    expected_hash: &str,
    rewritten_content: &str,
    _final_content: &str,
    auto_yes: bool,
) -> Result<(bool, OperationStatus)> {
    let raw = std::fs::read_to_string(target_path)?;
    let local_content = raw.replace("\r\n", "\n");

    if let Some(meta) = import_rewriter::parse_metadata(&local_content) {
        let local_clean = import_rewriter::strip_metadata(&local_content);
        let current_local_hash = sha256_hex(local_clean.as_bytes());

        if current_local_hash == meta.local_hash {
            // Unmodified locally
            if meta.registry_hash == expected_hash {
                logger::stdout(&format!("  - {} is already up-to-date.", local_file_name));
                return Ok((false, OperationStatus::UpToDate));
            } else {
                if auto_yes {
                    logger::stdout(&format!(
                        "[auto] Overwrite {} (tidak dimodifikasi lokal)",
                        local_file_name
                    ));
                    return Ok((true, OperationStatus::Overwritten));
                }
                logger::info(&format!(
                    "  - Updating {} to latest registry version.",
                    local_file_name
                ));
                return Ok((true, OperationStatus::Overwritten));
            }
        } else {
            // Locally modified
            if meta.registry_hash == expected_hash {
                if auto_yes {
                    logger::stdout(&format!(
                        "[auto] Lewati {} (dimodifikasi lokal)",
                        local_file_name
                    ));
                    return Ok((false, OperationStatus::SkippedLocalCustomization));
                }
                logger::stdout(&format!(
                    "  - {} has been customized locally. Skipping.",
                    local_file_name
                ));
                return Ok((false, OperationStatus::SkippedLocalCustomization));
            } else {
                // True conflict: prompt
                if auto_yes {
                    logger::stdout(&format!(
                        "[auto] Lewati {} (dimodifikasi lokal)",
                        local_file_name
                    ));
                    return Ok((false, OperationStatus::ConflictResolvedSkip));
                }
                logger::warning(&format!(
                    "Conflict: Local file \"{}\" has been modified, and a registry update is available.",
                    local_file_name
                ));
                let proceed = conflict_prompt(local_file_name, &local_clean, rewritten_content)?;
                if proceed {
                    return Ok((true, OperationStatus::ConflictResolvedOverwrite));
                } else {
                    return Ok((false, OperationStatus::ConflictResolvedSkip));
                }
            }
        }
    } else {
        // No metadata header: compare raw hash against expected
        let local_hash = sha256_hex(local_content.as_bytes());
        if local_hash == expected_hash {
            logger::stdout(&format!(
                "  - {} is already up-to-date (no metadata).",
                local_file_name
            ));
            return Ok((false, OperationStatus::UpToDate));
        } else {
            if auto_yes {
                logger::stdout(&format!(
                    "[auto] Overwrite {} (tidak dimodifikasi lokal)",
                    local_file_name
                ));
                return Ok((true, OperationStatus::ConflictResolvedOverwrite));
            }
            logger::warning(&format!(
                "Conflict: Local file \"{}\" exists and differs (no metadata).",
                local_file_name
            ));
            let proceed = conflict_prompt(local_file_name, &local_content, rewritten_content)?;
            if proceed {
                return Ok((true, OperationStatus::ConflictResolvedOverwrite));
            } else {
                return Ok((false, OperationStatus::ConflictResolvedSkip));
            }
        }
    }
}

/// Resolves conflict in dry-run mode — never prompts, never writes.
/// Returns (should_write_preview, is_conflict, local_clean_content, status).
fn resolve_conflict_dry(
    target_path: &std::path::Path,
    local_file_name: &str,
    expected_hash: &str,
    _rewritten_content: &str,
    _auto_yes: bool,
) -> Result<(bool, bool, String, OperationStatus)> {
    let raw = std::fs::read_to_string(target_path)?;
    let local_content = raw.replace("\r\n", "\n");

    if let Some(meta) = import_rewriter::parse_metadata(&local_content) {
        let local_clean = import_rewriter::strip_metadata(&local_content);
        let current_local_hash = sha256_hex(local_clean.as_bytes());

        if current_local_hash == meta.local_hash {
            // Unmodified locally
            if meta.registry_hash == expected_hash {
                logger::stdout(&format!(
                    "  [dry-run] Sudah up-to-date: {}",
                    local_file_name
                ));
                Ok((false, false, local_clean, OperationStatus::UpToDate))
            } else {
                // Update available — treat as will_write
                Ok((true, false, local_clean, OperationStatus::Overwritten))
            }
        } else {
            // Locally modified
            if meta.registry_hash == expected_hash {
                logger::stdout(&format!(
                    "  [dry-run] Dilewati (dimodifikasi lokal): {}",
                    local_file_name
                ));
                Ok((false, false, local_clean, OperationStatus::SkippedLocalCustomization))
            } else {
                // Conflict: show as will_write for preview purposes
                Ok((true, true, local_clean, OperationStatus::ConflictResolvedOverwrite))
            }
        }
    } else {
        // No metadata
        let local_hash = sha256_hex(local_content.as_bytes());
        if local_hash == expected_hash {
            logger::stdout(&format!(
                "  [dry-run] Sudah up-to-date: {}",
                local_file_name
            ));
            Ok((false, false, local_content, OperationStatus::UpToDate))
        } else {
            logger::stdout(&format!(
                "  [dry-run] Dilewati (dimodifikasi lokal): {}",
                local_file_name
            ));
            Ok((false, false, local_content, OperationStatus::SkippedLocalCustomization))
        }
    }
}

/// Interactive conflict resolution prompt loop.
/// Returns true if the file should be overwritten.
fn conflict_prompt(
    local_file_name: &str,
    local_content: &str,
    rewritten_content: &str,
) -> Result<bool> {
    loop {
        let action = prompt::ask(
            "  Choose action: [o] Overwrite, [s] Skip, [d] Show Diff",
            "s",
        )
        .to_lowercase();

        match action.as_str() {
            "o" => return Ok(true),
            "s" => return Ok(false),
            "d" => {
                diff_formatter::print_unified_diff(
                    local_file_name,
                    local_content,
                    rewritten_content,
                    3,
                );
            }
            _ => {
                logger::error("Invalid option. Choose o, s, or d.");
            }
        }
    }
}

pub fn sha256_hex(data: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(data);
    hex::encode(hasher.finalize())
}
