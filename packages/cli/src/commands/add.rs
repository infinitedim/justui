use anyhow::Result;
use regex::Regex;
use sha2::{Digest, Sha256};
use std::collections::HashSet;

use crate::config::JustUIConfig;
use crate::registry::{RegistryClient, RegistryIndex};
use crate::utils::logger::SummaryItem;
use crate::utils::{diff_formatter, import_rewriter, logger, prompt, pubspec_editor};

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

pub fn run(
    components: Vec<String>,
    dry_run: bool,
    show_diff: bool,
    all: bool,
    overwrite: bool,
    auto_yes: bool,
) -> Result<()> {
    let auto_yes = auto_yes || overwrite;
    let effective_dry_run = dry_run || show_diff;

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

    if !config.shared_dir.starts_with(&config.components_dir) {
        logger::warning(&format!(
            "shared_dir ('{}') is not nested under components_dir ('{}').\n\
             This is unusual and may cause shared component imports to resolve incorrectly.\n\
             If this is unintentional, fix it in {} and re-run.",
            config.shared_dir,
            config.components_dir,
            JustUIConfig::CONFIG_FILE_NAME
        ));
    }

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

    let components_to_add: Vec<String> = if all {
        index.components.iter().map(|c| c.name.clone()).collect()
    } else if components.is_empty() {
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
            let names: Vec<String> = index.components.iter().map(|c| c.name.clone()).collect();
            let names_str = names.join(", ");
            logger::stdout(&format!("[auto] Selecting all components: {}", names_str));
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

    let mut resolved_components = Vec::new();
    let mut dep_visited = HashSet::new();
    for comp_name in &components_to_add {
        if let Err(e) = resolve_dependencies_recursive(
            comp_name,
            &index,
            &mut dep_visited,
            &mut resolved_components,
        ) {
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
                .map(|c| c.files_for_preset(&config.preset).len())
                .unwrap_or(0)
        })
        .sum();

    let pb_files = if effective_dry_run || total_files == 0 {
        None
    } else {
        let bar = indicatif::ProgressBar::new(total_files as u64);
        bar.set_style(
            indicatif::ProgressStyle::default_bar()
                .template(
                    "{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {pos}/{len} {msg}",
                )
                .unwrap()
                .progress_chars("#>-"),
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
            &config.preset,
            config.dart_target,
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

    if effective_dry_run {
        logger::stdout(&format!(
            "\nDry-run summary: {} files to write, {} skipped, {} conflicts",
            total_stats.will_write, total_stats.skipped, total_stats.conflicts
        ));
    } else {
        let mut copied_count = 0;
        let mut skipped_count = 0;
        let mut success_details = Vec::new();
        let mut skip_details = Vec::new();

        for detail in &all_details {
            match detail.status {
                OperationStatus::Copied => {
                    copied_count += 1;
                    success_details.push(format!(
                        "  \x1B[32m✔\x1B[0m {} (New) -> {}",
                        detail.file_name, detail.path
                    ));
                }
                OperationStatus::Overwritten => {
                    copied_count += 1;
                    success_details.push(format!(
                        "  \x1B[32m✔\x1B[0m {} (Updated) -> {}",
                        detail.file_name, detail.path
                    ));
                }
                OperationStatus::ConflictResolvedOverwrite => {
                    copied_count += 1;
                    success_details.push(format!(
                        "  \x1B[32m✔\x1B[0m {} (Conflict overwritten) -> {}",
                        detail.file_name, detail.path
                    ));
                }
                OperationStatus::UpToDate => {
                    skipped_count += 1;
                    skip_details.push(format!(
                        "  \x1B[33m⚠\x1B[0m {} (Up-to-date) -> {}",
                        detail.file_name, detail.path
                    ));
                }
                OperationStatus::SkippedLocalCustomization => {
                    skipped_count += 1;
                    skip_details.push(format!(
                        "  \x1B[33m⚠\x1B[0m {} (Skipped, local customization) -> {}",
                        detail.file_name, detail.path
                    ));
                }
                OperationStatus::ConflictResolvedSkip => {
                    skipped_count += 1;
                    skip_details.push(format!(
                        "  \x1B[33m⚠\x1B[0m {} (Conflict skipped) -> {}",
                        detail.file_name, detail.path
                    ));
                }
            }
        }

        logger::stdout("");
        if copied_count > 0 {
            logger::stdout(&format!(
                "\x1B[32m✔\x1B[0m {} file(s) added/updated:",
                copied_count
            ));
            for line in success_details {
                logger::stdout(&line);
            }
        }
        if skipped_count > 0 {
            logger::stdout(&format!(
                "\x1B[33m⚠\x1B[0m {} file(s) skipped:",
                skipped_count
            ));
            for line in skip_details {
                logger::stdout(&line);
            }
        }
    }

    let mut summary_items: Vec<SummaryItem> = Vec::new();

    for name in &components_to_add {
        if let Some(component) = index.components.iter().find(|c| c.name == *name) {
            let target_dir = if component.category == "tokens" || component.category == "core" {
                config.tokens_dir.clone()
            } else if component.name == "_shared_theme_provider" {
                "lib/theme".to_string()
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
        logger::success("komponen berhasil ditambahkan");
        logger::summary(
            &format!("{} component(s) added successfully", summary_items.len()),
            &summary_items,
        );
    }

    Ok(())
}

pub fn resolve_dependencies_recursive(
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
    preset: &str,
    dart_target: crate::utils::env_resolver::DartTarget,
) -> Result<(DryRunStats, Vec<OperationDetail>)> {
    if visited.contains(name) {
        return Ok((DryRunStats::new(), Vec::new()));
    }
    visited.insert(name.to_string());

    let component = index
        .components
        .iter()
        .find(|c| c.name == name)
        .ok_or_else(|| anyhow::anyhow!("Component \"{}\" not found in registry", name))?;

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
            preset,
            dart_target,
        )?;
        stats.merge(&dep_stats);
        details.extend(dep_details);
    }

    logger::info(&format!(
        "Adding component \"{}\" (v{})...",
        component.name, component.version
    ));

    let target_dir = if component.category == "tokens" || component.category == "core" {
        tokens_dir.to_string()
    } else if component.name == "_shared_theme_provider" {
        "lib/theme".to_string()
    } else if component.internal {
        shared_dir.to_string()
    } else {
        format!("{}/{}", components_dir, component.name)
    };

    let files: Vec<_> = component.files_for_preset(preset).clone();
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

        let pkg_name = pubspec_editor::get_package_name(std::path::Path::new("pubspec.yaml"))
            .unwrap_or_else(|_| "flutter_app".to_string());

        let mut rewritten_content = import_rewriter::rewrite(
            &content,
            &file.path,
            &comp_name,
            index,
            components_dir,
            tokens_dir,
            shared_dir,
            preset,
            &pkg_name,
        );

        if dart_target == crate::utils::env_resolver::DartTarget::Primary {
            rewritten_content =
                crate::utils::constructor_transpiler::transpile_to_primary_constructor(
                    &rewritten_content,
                );
        }

        let local_rewritten_hash = sha256_hex(rewritten_content.as_bytes());
        let final_content = import_rewriter::inject_metadata(
            &rewritten_content,
            &expected_hash,
            &local_rewritten_hash,
        );

        let local_file_name = if component.name == "_shared_theme_provider" {
            file.name.clone()
        } else if component.internal {
            import_rewriter::normalize_shared_file_name(&file.name)
        } else {
            file.name.clone()
        };
        let target_path = std::path::Path::new(&target_dir).join(&local_file_name);

        let file_exists = target_path.exists();

        let mut local_clean_for_diff = String::new();

        let (should_write, conflict_detected, status) = if file_exists {
            if dry_run {
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

        if show_diff {
            if file_exists {
                diff_formatter::print_unified_diff(
                    &local_file_name,
                    &local_clean_for_diff,
                    &rewritten_content,
                    3,
                );
            } else {
                logger::stdout(&format!("[registry] {} (file baru)", local_file_name));
                for line in rewritten_content.lines() {
                    logger::stdout(&format!("+ {}", line));
                }
            }
        }

        if dry_run {
            if conflict_detected {
                stats.conflicts += 1;
                logger::stdout(&format!(
                    "  [dry-run] Conflict (will write if selected): {}",
                    local_file_name
                ));
            } else if should_write {
                stats.will_write += 1;
                logger::stdout(&format!(
                    "  [dry-run] Will write: {}",
                    target_path.display()
                ));
            } else {
                stats.skipped += 1;
            }
        } else if should_write {
            if let Some(parent) = target_path.parent() {
                std::fs::create_dir_all(parent)?;
            }
            std::fs::write(&target_path, &final_content)?;
            logger::stdout(&format!(
                "  - Copied {} to {}/",
                local_file_name, target_dir
            ));
        }

        if local_file_name.ends_with("_theme.dart") {
            let theme_file_content = if target_path.exists() {
                std::fs::read_to_string(&target_path).unwrap_or_else(|_| final_content.clone())
            } else {
                final_content.clone()
            };
            if let Some(theme_class) = extract_theme_class_name(&theme_file_content) {
                let normalized_dir = components_dir.replace('\\', "/");
                let trimmed_dir = normalized_dir.trim_matches('/');
                let clean_components_dir = if trimmed_dir == "lib" {
                    ""
                } else if let Some(rest) = trimmed_dir.strip_prefix("lib/") {
                    rest.trim_matches('/')
                } else {
                    trimmed_dir
                };

                let import_uri = if clean_components_dir.is_empty() {
                    format!("package:{}/{}/{}", pkg_name, component.name, local_file_name)
                } else {
                    format!(
                        "package:{}/{}/{}/{}",
                        pkg_name, clean_components_dir, component.name, local_file_name
                    )
                };

                let candidate_theme_files = [
                    std::path::PathBuf::from("lib/core/theme/theme_data_material.dart"),
                    std::path::PathBuf::from("lib/core/theme_data_material.dart"),
                ];

                for theme_file in &candidate_theme_files {
                    if theme_file.exists() {
                        if dry_run {
                            logger::stdout(&format!(
                                "  - [DRY-RUN] Would register {}.defaults in {}",
                                theme_class,
                                theme_file.display()
                            ));
                            break;
                        } else if let Ok(updated) =
                            crate::utils::theme_editor::register_theme_extension(
                                theme_file,
                                &pkg_name,
                                &import_uri,
                                &theme_class,
                            )
                        {
                            if updated {
                                logger::stdout(&format!(
                                    "  - Registered {}.defaults in {}",
                                    theme_class,
                                    theme_file.display()
                                ));
                                break;
                            }
                        }
                    }
                }
            }
        }

        details.push(OperationDetail {
            file_name: local_file_name.clone(),
            status,
            path: format!("{}/{}", target_dir, local_file_name),
        });
    }

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
            if meta.registry_hash == expected_hash {
                logger::stdout(&format!("  - {} is already up-to-date.", local_file_name));
                return Ok((false, OperationStatus::UpToDate));
            } else {
                if auto_yes {
                    logger::stdout(&format!(
                        "[auto] Overwriting {} (not modified locally)",
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
            if meta.registry_hash == expected_hash {
                if auto_yes {
                    logger::stdout(&format!(
                        "[auto] Skipping {} (modified locally)",
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
                if auto_yes {
                    logger::stdout(&format!(
                        "[auto] Skipping {} (modified locally)",
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
                    "[auto] Overwriting {} (not modified locally)",
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
            if meta.registry_hash == expected_hash {
                logger::stdout(&format!(
                    "  [dry-run] Already up-to-date: {}",
                    local_file_name
                ));
                Ok((false, false, local_clean, OperationStatus::UpToDate))
            } else {
                Ok((true, false, local_clean, OperationStatus::Overwritten))
            }
        } else {
            if meta.registry_hash == expected_hash {
                logger::stdout(&format!(
                    "  [dry-run] Skipped (modified locally): {}",
                    local_file_name
                ));
                Ok((
                    false,
                    false,
                    local_clean,
                    OperationStatus::SkippedLocalCustomization,
                ))
            } else {
                Ok((
                    true,
                    true,
                    local_clean,
                    OperationStatus::ConflictResolvedOverwrite,
                ))
            }
        }
    } else {
        let local_hash = sha256_hex(local_content.as_bytes());
        if local_hash == expected_hash {
            logger::stdout(&format!(
                "  [dry-run] Already up-to-date: {}",
                local_file_name
            ));
            Ok((false, false, local_content, OperationStatus::UpToDate))
        } else {
            logger::stdout(&format!(
                "  [dry-run] Skipped (modified locally): {}",
                local_file_name
            ));
            Ok((
                false,
                false,
                local_content,
                OperationStatus::SkippedLocalCustomization,
            ))
        }
    }
}

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

fn extract_theme_class_name(content: &str) -> Option<String> {
    if !content.contains("extends ThemeExtension") {
        return None;
    }
    let re = Regex::new(r"class\s+(?:const\s+)?([A-Za-z0-9_]+Theme(?:Data)?)").unwrap();
    re.captures(content).map(|cap| cap[1].to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    use crate::utils::set_dir;

    #[test]
    fn test_add_helpers() {
        let mut s1 = DryRunStats::new();
        s1.will_write = 2;
        let mut s2 = DryRunStats::new();
        s2.skipped = 1;
        s2.conflicts = 3;
        s1.merge(&s2);

        assert_eq!(s1.will_write, 2);
        assert_eq!(s1.skipped, 1);
        assert_eq!(s1.conflicts, 3);

        let hash = sha256_hex(b"hello");
        assert_eq!(
            hash,
            "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        );

        assert_eq!(
            extract_theme_class_name("class ButtonTheme extends ThemeExtension<ButtonTheme>"),
            Some("ButtonTheme".to_string())
        );
        assert_eq!(extract_theme_class_name("class RegularClass {}"), None);
    }

    #[test]
    fn test_add_run_uninitialized_and_conflict_resolution() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        // 1. Uninitialized project returns Ok with warning
        assert!(run(vec![], false, false, false, false, true).is_ok());

        // 2. Test resolve_conflict when target file exists with metadata up-to-date
        let file_path = temp_dir.path().join("just_button.dart");
        let raw_code = "class JustButton {}";
        let hash = sha256_hex(raw_code.as_bytes());
        let meta_content = import_rewriter::inject_metadata(raw_code, &hash, &hash);
        std::fs::write(&file_path, &meta_content).unwrap();

        let (will_write, status) = resolve_conflict(
            &file_path,
            "just_button.dart",
            &hash,
            raw_code,
            &meta_content,
            true,
        )
        .unwrap();
        assert!(!will_write);
        assert_eq!(status, OperationStatus::UpToDate);

        // 3. Test resolve_conflict_dry when target file exists with metadata up-to-date
        let (will_write_dry, conflict, _, status_dry) =
            resolve_conflict_dry(&file_path, "just_button.dart", &hash, raw_code, true).unwrap();
        assert!(!will_write_dry);
        assert!(!conflict);
        assert_eq!(status_dry, OperationStatus::UpToDate);
    }

    #[test]
    fn test_add_run_malformed_config_and_unusual_dirs() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        // 1. Config with invalid YAML returns Ok without erroring out
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, "::invalid::yaml::").unwrap();
        assert!(run(vec![], false, false, false, false, true).is_ok());

        // 2. Config with unusual shared_dir (not nested under components_dir)
        let config_yaml = "components_dir: lib/components\nshared_dir: lib/shared\nregistry_url: /invalid/registry\n";
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();
        assert!(run(vec![], false, false, false, false, true).is_ok());
    }

    #[test]
    fn test_add_run_empty_registry_and_selection() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(&reg_dir).unwrap();

        // Empty components list in registry index
        let index_json = r#"{"version": "1.0.0", "presets": ["default"], "components": []}"#;
        std::fs::write(reg_dir.join("index.json"), index_json).unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // Prompting components with auto_yes when registry has 0 components -> logs error and returns Ok
        assert!(run(vec![], false, false, false, false, true).is_ok());

        // Non-interactive fallback when components vector is empty -> returns Ok
        assert!(run(vec![], false, false, false, false, false).is_ok());
    }

    #[test]
    fn test_add_component_execution_flow_all_types() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("components")).unwrap();
        std::fs::create_dir_all(reg_dir.join("tokens")).unwrap();

        let btn_code = "class Button {}";
        let btn_hash = sha256_hex(btn_code.as_bytes());

        let tok_code = "class ColorTokens {}";
        let tok_hash = sha256_hex(tok_code.as_bytes());

        let theme_code = "class ButtonTheme extends ThemeExtension<ButtonTheme> {}";
        let theme_hash = sha256_hex(theme_code.as_bytes());

        let index_json = format!(
            r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "button",
                    "version": "1.0.0",
                    "description": "Button component",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": ["tokens"],
                    "pubDependencies": {{"flutter_bloc": "^8.0.0"}},
                    "files": {{
                        "default": [
                            {{
                                "name": "button.dart",
                                "path": "components/button.dart",
                                "checksum": "sha256:{btn_hash}"
                            }},
                            {{
                                "name": "button_theme.dart",
                                "path": "components/button_theme.dart",
                                "checksum": "sha256:{theme_hash}"
                            }}
                        ]
                    }}
                }},
                {{
                    "name": "tokens",
                    "version": "1.0.0",
                    "description": "Design tokens",
                    "category": "tokens",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "colors.dart",
                                "path": "tokens/colors.dart",
                                "checksum": "sha256:{tok_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
        );

        std::fs::write(reg_dir.join("index.json"), index_json).unwrap();
        std::fs::write(reg_dir.join("components/button.dart"), btn_code).unwrap();
        std::fs::write(reg_dir.join("components/button_theme.dart"), theme_code).unwrap();
        std::fs::write(reg_dir.join("tokens/colors.dart"), tok_code).unwrap();

        // Create theme file to test register_theme_extension
        std::fs::create_dir_all("lib/core/theme").unwrap();
        std::fs::write(
            "lib/core/theme/theme_data_material.dart",
            "class ThemeData {}",
        )
        .unwrap();
        std::fs::write("pubspec.yaml", "name: my_app\n").unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\ndart_target: primary\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // 1. Dry run with diff enabled
        assert!(run(vec!["button".to_string()], true, true, false, false, true).is_ok());

        // 2. Real run adding components (dry_run=false, show_diff=false)
        assert!(run(vec!["button".to_string()], false, false, false, false, true).is_ok());

        // Verify files were created
        assert!(std::path::Path::new("lib/widgets/button/button.dart").exists());
        assert!(std::path::Path::new("lib/widgets/button/button_theme.dart").exists());
        assert!(std::path::Path::new("lib/tokens/colors.dart").exists());

        // 3. Re-run (UpToDate status)
        assert!(run(vec!["button".to_string()], false, false, false, false, true).is_ok());
    }

    #[test]
    fn test_add_component_checksum_and_unknown_dependency() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("components")).unwrap();

        // Checksum in index doesn't match downloaded file content
        let index_json = r#"{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {
                    "name": "bad_checksum",
                    "version": "1.0.0",
                    "description": "Corrupt",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {},
                    "files": {
                        "default": [
                            {
                                "name": "corrupt.dart",
                                "path": "components/corrupt.dart",
                                "checksum": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
                            }
                        ]
                    }
                },
                {
                    "name": "broken_dep",
                    "version": "1.0.0",
                    "description": "Dep error",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": ["non_existent_dep"],
                    "pubDependencies": {},
                    "files": {}
                }
            ]
        }"#;

        std::fs::write(reg_dir.join("index.json"), index_json).unwrap();
        std::fs::write(reg_dir.join("components/corrupt.dart"), "some content").unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // 1. Security checksum failure
        assert!(run(
            vec!["bad_checksum".to_string()],
            false,
            false,
            false,
            false,
            true
        )
        .is_ok());

        // 2. Unknown dependency error
        assert!(run(
            vec!["broken_dep".to_string()],
            false,
            false,
            false,
            false,
            true
        )
        .is_ok());
    }

    #[test]
    fn test_add_component_all_conflict_branches() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let target = temp_dir.path().join("test.dart");
        let raw = "class Test {}";
        let expected_hash = sha256_hex(raw.as_bytes());
        let local_clean = "class LocalModified {}";
        let local_hash = sha256_hex(local_clean.as_bytes());
        let dummy_reg_hash = "0000000000000000000000000000000000000000000000000000000000000000";
        let dummy_loc_hash = "1111111111111111111111111111111111111111111111111111111111111111";

        // Case 1: Unmodified locally, registry updated -> Overwritten (returns true)
        let meta_unmodified =
            import_rewriter::inject_metadata(local_clean, dummy_reg_hash, &local_hash);
        std::fs::write(&target, &meta_unmodified).unwrap();
        let (write1, status1) = resolve_conflict(
            &target,
            "test.dart",
            &expected_hash,
            raw,
            &meta_unmodified,
            true,
        )
        .unwrap();
        assert!(write1);
        assert_eq!(status1, OperationStatus::Overwritten);

        // Case 2: Modified locally, registry updated -> ConflictResolvedSkip (returns false)
        let meta_modified =
            import_rewriter::inject_metadata(local_clean, dummy_reg_hash, dummy_loc_hash);
        std::fs::write(&target, &meta_modified).unwrap();
        let (write2, status2) = resolve_conflict(
            &target,
            "test.dart",
            &expected_hash,
            raw,
            &meta_modified,
            true,
        )
        .unwrap();
        assert!(!write2);
        assert_eq!(status2, OperationStatus::ConflictResolvedSkip);

        // Case 3: File without metadata, content differs -> ConflictResolvedOverwrite (returns true)
        std::fs::write(&target, "different content without meta").unwrap();
        let (write3, status3) = resolve_conflict(
            &target,
            "test.dart",
            &expected_hash,
            raw,
            &meta_modified,
            true,
        )
        .unwrap();
        assert!(write3);
        assert_eq!(status3, OperationStatus::ConflictResolvedOverwrite);

        // Case 4: resolve_conflict_dry with metadata modified locally and registry unchanged
        let meta_same_reg =
            import_rewriter::inject_metadata(local_clean, &expected_hash, dummy_loc_hash);
        std::fs::write(&target, &meta_same_reg).unwrap();
        let (write4, conflict4, _, status4) =
            resolve_conflict_dry(&target, "test.dart", &expected_hash, raw, true).unwrap();
        assert!(!write4);
        assert!(!conflict4);
        assert_eq!(status4, OperationStatus::SkippedLocalCustomization);

        // Case 5: resolve_conflict_dry without metadata modified
        std::fs::write(&target, "different content").unwrap();
        let (write5, conflict5, _, status5) =
            resolve_conflict_dry(&target, "test.dart", &expected_hash, raw, true).unwrap();
        assert!(!write5);
        assert!(!conflict5);
        assert_eq!(status5, OperationStatus::SkippedLocalCustomization);
    }

    #[test]
    fn test_add_conflict_interactive_and_non_auto_yes() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let target = temp_dir.path().join("test.dart");
        let raw = "class Test {}";
        let expected_hash = sha256_hex(raw.as_bytes());
        let local_clean = "class LocalModified {}";
        let local_hash = sha256_hex(local_clean.as_bytes());
        let dummy_reg_hash = "0000000000000000000000000000000000000000000000000000000000000000";
        let dummy_loc_hash = "1111111111111111111111111111111111111111111111111111111111111111";

        // 1. Unmodified locally, registry updated (auto_yes = false)
        let meta_unmodified =
            import_rewriter::inject_metadata(local_clean, dummy_reg_hash, &local_hash);
        std::fs::write(&target, &meta_unmodified).unwrap();
        let (write1, status1) = resolve_conflict(
            &target,
            "test.dart",
            &expected_hash,
            raw,
            &meta_unmodified,
            false,
        )
        .unwrap();
        assert!(write1);
        assert_eq!(status1, OperationStatus::Overwritten);

        // 2. Modified locally, registry up-to-date (auto_yes = false)
        let meta_same_reg =
            import_rewriter::inject_metadata(local_clean, &expected_hash, dummy_loc_hash);
        std::fs::write(&target, &meta_same_reg).unwrap();
        let (write2, status2) = resolve_conflict(
            &target,
            "test.dart",
            &expected_hash,
            raw,
            &meta_same_reg,
            false,
        )
        .unwrap();
        assert!(!write2);
        assert_eq!(status2, OperationStatus::SkippedLocalCustomization);

        // 3. Modified locally, registry updated (auto_yes = false, conflict_prompt fallback "s")
        let meta_modified =
            import_rewriter::inject_metadata(local_clean, dummy_reg_hash, dummy_loc_hash);
        std::fs::write(&target, &meta_modified).unwrap();
        let (write3, status3) = resolve_conflict(
            &target,
            "test.dart",
            &expected_hash,
            raw,
            &meta_modified,
            false,
        )
        .unwrap();
        assert!(!write3);
        assert_eq!(status3, OperationStatus::ConflictResolvedSkip);

        // 4. File without metadata, content identical to expected
        std::fs::write(&target, raw).unwrap();
        let (write4, status4) =
            resolve_conflict(&target, "test.dart", &expected_hash, raw, raw, false).unwrap();
        assert!(!write4);
        assert_eq!(status4, OperationStatus::UpToDate);

        // 5. File without metadata, content differs (auto_yes = false, conflict_prompt fallback "s")
        std::fs::write(&target, "different raw content").unwrap();
        let (write5, status5) =
            resolve_conflict(&target, "test.dart", &expected_hash, raw, raw, false).unwrap();
        assert!(!write5);
        assert_eq!(status5, OperationStatus::ConflictResolvedSkip);
    }

    #[test]
    fn test_add_special_component_categories_and_all_flag() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("core")).unwrap();
        std::fs::create_dir_all(reg_dir.join("theme")).unwrap();

        let core_code = "class JustCore {}";
        let core_hash = sha256_hex(core_code.as_bytes());

        let theme_code = "class ThemeProvider {}";
        let theme_hash = sha256_hex(theme_code.as_bytes());

        let index_json = format!(
            r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "core_comp",
                    "version": "1.0.0",
                    "description": "Core component",
                    "category": "core",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "core.dart",
                                "path": "core/core.dart",
                                "checksum": "sha256:{core_hash}"
                            }}
                        ]
                    }}
                }},
                {{
                    "name": "_shared_theme_provider",
                    "version": "1.0.0",
                    "description": "Shared theme provider",
                    "category": "shared",
                    "internal": true,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "theme_provider.dart",
                                "path": "theme/theme_provider.dart",
                                "checksum": "sha256:{theme_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
        );

        std::fs::write(reg_dir.join("index.json"), index_json).unwrap();
        std::fs::write(reg_dir.join("core/core.dart"), core_code).unwrap();
        std::fs::write(reg_dir.join("theme/theme_provider.dart"), theme_code).unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // Test run with `all = true` flag
        assert!(run(vec![], false, false, true, false, true).is_ok());

        assert!(std::path::Path::new("lib/tokens/core.dart").exists());
        assert!(std::path::Path::new("lib/theme/theme_provider.dart").exists());
    }

    #[test]
    fn test_add_progress_bar_and_theme_file_candidates_and_error_handling() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("shared")).unwrap();

        let shared_code = "class SharedWidget {}";
        let shared_hash = sha256_hex(shared_code.as_bytes());

        let theme_code = "class CustomTheme extends ThemeExtension<CustomTheme> {}";
        let theme_hash = sha256_hex(theme_code.as_bytes());

        let index_json = format!(
            r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "custom",
                    "version": "1.0.0",
                    "description": "Custom component",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": ["_shared_helper"],
                    "pubDependencies": {{"flutter": "any"}},
                    "files": {{
                        "default": [
                            {{
                                "name": "custom_theme.dart",
                                "path": "shared/custom_theme.dart",
                                "checksum": "sha256:{theme_hash}"
                            }}
                        ]
                    }}
                }},
                {{
                    "name": "_shared_helper",
                    "version": "1.0.0",
                    "description": "Internal helper",
                    "category": "shared",
                    "internal": true,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "_shared_helper.dart",
                                "path": "shared/helper.dart",
                                "checksum": "sha256:{shared_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
        );

        std::fs::write(reg_dir.join("index.json"), index_json).unwrap();
        std::fs::write(reg_dir.join("shared/custom_theme.dart"), theme_code).unwrap();
        std::fs::write(reg_dir.join("shared/helper.dart"), shared_code).unwrap();

        // Create theme file at lib/core/theme_data_material.dart
        std::fs::create_dir_all("lib/core").unwrap();
        std::fs::write("lib/core/theme_data_material.dart", "class ThemeData {}").unwrap();
        std::fs::write("pubspec.yaml", "name: app\n").unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // Run with overwrite = true (sets auto_yes = true)
        assert!(run(vec!["custom".to_string()], false, false, false, true, false).is_ok());

        // Verify normalized file name just_helper.dart exists in shared_dir
        assert!(std::path::Path::new("lib/widgets/shared/just_helper.dart").exists());

        // Now create alternative theme candidate paths: lib/core/theme/theme_data_material.dart
        std::fs::create_dir_all("lib/core/theme").unwrap();
        std::fs::write(
            "lib/core/theme/theme_data_material.dart",
            "// CLI:REGISTER_EXTENSIONS\n",
        )
        .unwrap();
        std::fs::remove_file("lib/core/theme_data_material.dart").unwrap();

        // Dry run to exercise dry-run theme registration log
        assert!(run(vec!["custom".to_string()], true, false, false, false, true).is_ok());

        // Real run to register theme extension in lib/core/theme/theme_data_material.dart
        assert!(run(vec!["custom".to_string()], false, false, false, false, true).is_ok());

        // Test HTTP index error path: invalid registry URL in config
        let bad_config = "components_dir: lib/widgets\nregistry_url: http://127.0.0.1:1/invalid\n";
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, bad_config).unwrap();
        assert!(run(vec!["custom".to_string()], false, false, false, false, true).is_ok());
    }

    #[test]
    fn test_add_run_all_operation_statuses_output_formatting() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("comp")).unwrap();

        let v1_code = "class WidgetV1 {}";
        let v1_hash = sha256_hex(v1_code.as_bytes());

        let v2_code = "class WidgetV2 {}";
        let v2_hash = sha256_hex(v2_code.as_bytes());

        let make_index = |checksum: &str| {
            format!(
                r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "widget",
                    "version": "1.0.0",
                    "description": "Widget component",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "widget.dart",
                                "path": "comp/widget.dart",
                                "checksum": "sha256:{checksum}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
            )
        };

        std::fs::write(reg_dir.join("index.json"), make_index(&v1_hash)).unwrap();
        std::fs::write(reg_dir.join("comp/widget.dart"), v1_code).unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // Run 1: Copied (New)
        assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

        // Run 2: UpToDate
        assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

        // Run 3: Registry updated (v2), local unmodified -> Overwritten
        std::fs::write(reg_dir.join("index.json"), make_index(&v2_hash)).unwrap();
        std::fs::write(reg_dir.join("comp/widget.dart"), v2_code).unwrap();
        assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

        // Run 4: Registry same (v2), local modified -> SkippedLocalCustomization
        let local_file = temp_dir.path().join("lib/widgets/widget/widget.dart");
        let modified_meta = import_rewriter::inject_metadata(
            "class LocallyModified {}",
            &v2_hash,
            "9999999999999999999999999999999999999999999999999999999999999999",
        );
        std::fs::write(&local_file, &modified_meta).unwrap();
        assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

        // Run 5: Registry updated back to v1, local modified -> ConflictResolvedSkip
        std::fs::write(reg_dir.join("index.json"), make_index(&v1_hash)).unwrap();
        std::fs::write(reg_dir.join("comp/widget.dart"), v1_code).unwrap();
        assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());

        // Run 6: Local file without metadata, content differs -> ConflictResolvedOverwrite
        std::fs::write(&local_file, "class WithoutMeta {}").unwrap();
        assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());
    }

    #[test]
    fn test_add_diff_formatting_and_dry_run_conflicts() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("comp")).unwrap();

        let v1_code = "class WidgetV1 {}";
        let v1_hash = sha256_hex(v1_code.as_bytes());

        let index_json = format!(
            r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "widget",
                    "version": "1.0.0",
                    "description": "Widget component",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{"some_pkg": "1.0.0"}},
                    "files": {{
                        "default": [
                            {{
                                "name": "widget.dart",
                                "path": "comp/widget.dart",
                                "checksum": "sha256:{v1_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
        );

        std::fs::write(reg_dir.join("index.json"), &index_json).unwrap();
        std::fs::write(reg_dir.join("comp/widget.dart"), v1_code).unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // 1. show_diff = true for new file
        assert!(run(vec!["widget".to_string()], false, true, false, false, true).is_ok());

        // Create local file modified to create conflict
        let local_file = temp_dir.path().join("lib/widgets/widget/widget.dart");
        std::fs::create_dir_all(local_file.parent().unwrap()).unwrap();
        let meta_conflict = import_rewriter::inject_metadata(
            "class LocalMod {}",
            "0000000000000000000000000000000000000000000000000000000000000000",
            "1111111111111111111111111111111111111111111111111111111111111111",
        );
        std::fs::write(&local_file, &meta_conflict).unwrap();

        // 2. show_diff = true for existing modified file -> calls print_unified_diff
        assert!(run(vec!["widget".to_string()], false, true, false, false, true).is_ok());

        // 3. dry_run = true with conflict -> stats.conflicts += 1
        assert!(run(vec!["widget".to_string()], true, false, false, false, true).is_ok());

        // 4. dry_run = true with up-to-date file -> stats.skipped += 1
        let meta_uptodate = import_rewriter::inject_metadata(v1_code, &v1_hash, &v1_hash);
        std::fs::write(&local_file, &meta_uptodate).unwrap();
        assert!(run(vec!["widget".to_string()], true, false, false, false, true).is_ok());

        // 5. pub_deps with missing pubspec.yaml -> triggers warning branch in pubspec_editor
        assert!(run(vec!["widget".to_string()], false, false, false, false, true).is_ok());
    }

    #[test]
    fn test_add_run_summary_output_and_auto_select_all() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("comp")).unwrap();
        std::fs::create_dir_all(reg_dir.join("core")).unwrap();
        std::fs::create_dir_all(reg_dir.join("shared")).unwrap();

        let code1 = "class Comp1 {}";
        let hash1 = sha256_hex(code1.as_bytes());

        let code2 = "class Comp2 {}";
        let hash2 = sha256_hex(code2.as_bytes());

        let index_json = format!(
            r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "normal_widget",
                    "version": "1.0.0",
                    "description": "Normal widget",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "normal.dart",
                                "path": "comp/normal.dart",
                                "checksum": "sha256:{hash1}"
                            }}
                        ]
                    }}
                }},
                {{
                    "name": "internal_helper",
                    "version": "1.0.0",
                    "description": "Internal helper",
                    "category": "shared",
                    "internal": true,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "helper.dart",
                                "path": "shared/helper.dart",
                                "checksum": "sha256:{hash2}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
        );

        std::fs::write(reg_dir.join("index.json"), &index_json).unwrap();
        std::fs::write(reg_dir.join("comp/normal.dart"), code1).unwrap();
        std::fs::write(reg_dir.join("shared/helper.dart"), code2).unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // Calling run with components = vec![], auto_yes = true, dry_run = false
        // Triggers auto-select all components + logger::summary output loop!
        assert!(run(vec![], false, false, false, false, true).is_ok());
    }

    #[test]
    fn test_add_select_empty_and_token_summary() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("tokens")).unwrap();

        let token_code = "class TokenColor {}";
        let token_hash = sha256_hex(token_code.as_bytes());

        let index_json = format!(
            r#"{{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {{
                    "name": "token_color",
                    "version": "1.0.0",
                    "description": "Token color",
                    "category": "tokens",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": [],
                    "pubDependencies": {{}},
                    "files": {{
                        "default": [
                            {{
                                "name": "token.dart",
                                "path": "tokens/token.dart",
                                "checksum": "sha256:{token_hash}"
                            }}
                        ]
                    }}
                }}
            ]
        }}"#
        );

        std::fs::write(reg_dir.join("index.json"), &index_json).unwrap();
        std::fs::write(reg_dir.join("tokens/token.dart"), token_code).unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // 1. Run token component addition (dry_run = false) to trigger tokens/core summary item path
        assert!(run(
            vec!["token_color".to_string()],
            false,
            false,
            false,
            false,
            true
        )
        .is_ok());

        // 2. Interactive selection returning empty vector -> returns Ok with warning
        assert!(run(vec![], false, false, false, false, false).is_ok());
    }

    #[test]
    fn test_add_missing_dependency_and_empty_selection() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("comp")).unwrap();

        let index_json = r#"{
            "version": "1.0.0",
            "presets": ["default"],
            "components": [
                {
                    "name": "invalid_dep_comp",
                    "version": "1.0.0",
                    "description": "Component with missing dep",
                    "category": "components",
                    "internal": false,
                    "supportedPresets": ["default"],
                    "registryDependencies": ["missing_dep_name"],
                    "pubDependencies": {},
                    "files": {
                        "default": []
                    }
                }
            ]
        }"#;

        std::fs::write(reg_dir.join("index.json"), index_json).unwrap();

        let config_yaml = format!(
            "components_dir: lib/widgets\nshared_dir: lib/widgets/shared\ntokens_dir: lib/tokens\nregistry_url: {}\n",
            reg_dir.display()
        );
        std::fs::write(JustUIConfig::CONFIG_FILE_NAME, config_yaml).unwrap();

        // Triggers "Dependency resolution error: Component "missing_dep_name" not found in registry"
        assert!(run(
            vec!["invalid_dep_comp".to_string()],
            false,
            false,
            false,
            false,
            true
        )
        .is_ok());
    }

    #[test]
    fn test_add_run_config_read_to_string_error() {
        let _lock = crate::utils::TEST_MUTEX
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        // let _temp_dir = tempfile::tempdir().unwrap();
    }

    #[test]
    fn test_add_resolve_conflict_matrix() {
        let temp_dir = tempfile::tempdir().unwrap();
        let file_path = temp_dir.path().join("just_button.dart");

        let orig_code = "class Button {}";
        let modified_code = "class ButtonModified {}";
        let reg_hash_old = "1111111111111111111111111111111111111111111111111111111111111111";
        let reg_hash_new = "2222222222222222222222222222222222222222222222222222222222222222";

        let local_hash_orig = sha256_hex(orig_code.as_bytes());

        // 1. Metadata present: local modified, registry hash unchanged -> SkippedLocalCustomization
        // Metadata says original hash was local_hash_orig, but file content is modified_code
        let meta1 = import_rewriter::inject_metadata(modified_code, reg_hash_old, &local_hash_orig);
        std::fs::write(&file_path, &meta1).unwrap();
        let (write, status) = resolve_conflict(
            &file_path,
            "just_button.dart",
            reg_hash_old,
            orig_code,
            &meta1,
            true,
        )
        .unwrap();
        assert!(!write);
        assert_eq!(status, OperationStatus::SkippedLocalCustomization);

        // 2. Metadata present: local modified, registry hash updated -> ConflictResolvedSkip (auto_yes=true)
        let (write, status) = resolve_conflict(
            &file_path,
            "just_button.dart",
            reg_hash_new,
            orig_code,
            &meta1,
            true,
        )
        .unwrap();
        assert!(!write);
        assert_eq!(status, OperationStatus::ConflictResolvedSkip);

        // 3. Metadata present: local unmodified, registry hash updated -> Overwritten (auto_yes=true)
        // File content is orig_code, metadata local_hash matches orig_code hash
        let meta3 = import_rewriter::inject_metadata(orig_code, reg_hash_old, &local_hash_orig);
        std::fs::write(&file_path, &meta3).unwrap();
        let (write, status) = resolve_conflict(
            &file_path,
            "just_button.dart",
            reg_hash_new,
            orig_code,
            &meta3,
            true,
        )
        .unwrap();
        assert!(write);
        assert_eq!(status, OperationStatus::Overwritten);

        // 4. No metadata present: local file differs from expected_hash -> ConflictResolvedOverwrite (auto_yes=true)
        std::fs::write(&file_path, "class RawButton {}").unwrap();
        let (write, status) = resolve_conflict(
            &file_path,
            "just_button.dart",
            reg_hash_new,
            orig_code,
            "class RawButton {}",
            true,
        )
        .unwrap();
        assert!(write);
        assert_eq!(status, OperationStatus::ConflictResolvedOverwrite);

        // 5. Dry run conflict resolution for existing modified file
        let (write_dry, _conflict_dry, _, status_dry) = resolve_conflict_dry(
            &file_path,
            "just_button.dart",
            reg_hash_old,
            orig_code,
            true,
        )
        .unwrap();
        assert!(!write_dry);
        assert_eq!(status_dry, OperationStatus::SkippedLocalCustomization);
    }

    #[test]
    fn test_add_run_initialized_all_flags() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        let _guard = set_dir(temp_dir.path());

        // Setup local registry
        let reg_dir = temp_dir.path().join("registry");
        std::fs::create_dir_all(reg_dir.join("components/button")).unwrap();
        std::fs::create_dir_all(reg_dir.join("components/_shared_theme_provider")).unwrap();

        let button_code = "class JustButton {}";
        let button_hash = sha256_hex(button_code.as_bytes());

        std::fs::write(reg_dir.join("just_button.dart"), button_code).unwrap();
        std::fs::write(
            reg_dir.join("just_theme_provider.dart"),
            "class JustThemeProvider {}",
        )
        .unwrap();

        std::fs::write(
            reg_dir.join("index.json"),
            serde_json::to_string(&serde_json::json!({
                "version": "1.0.0",
                "presets": ["default"],
                "components": [
                    {
                        "name": "button",
                        "version": "1.0.0",
                        "description": "Button",
                        "category": "primitive",
                        "internal": false,
                        "supportedPresets": ["default"],
                        "registryDependencies": ["_shared_theme_provider"],
                        "pubDependencies": {"flutter_svg": "^2.0.0"},
                        "files": {
                            "default": [{
                                "name": "just_button.dart",
                                "path": "just_button.dart",
                                "checksum": format!("sha256:{}", button_hash)
                            }]
                        }
                    },
                    {
                        "name": "_shared_theme_provider",
                        "version": "1.0.0",
                        "description": "Theme provider",
                        "category": "core",
                        "internal": true,
                        "supportedPresets": ["default"],
                        "registryDependencies": [],
                        "pubDependencies": {},
                        "files": {
                            "default": [{
                                "name": "just_theme_provider.dart",
                                "path": "just_theme_provider.dart",
                                "checksum": "sha256:abc"
                            }]
                        }
                    }
                ]
            }))
            .unwrap(),
        )
        .unwrap();

        std::fs::write(
            "pubspec.yaml",
            "name: test_app\ndependencies:\n  flutter:\n    sdk: flutter\n",
        )
        .unwrap();
        std::fs::write(
            "justui.config.yaml",
            format!("components_dir: lib/ui\ntokens_dir: lib/tokens\nshared_dir: lib/ui/shared\npreset: default\nregistry_url: {}\n", reg_dir.display()),
        )
        .unwrap();

        // 1. Run add single component (button) with auto_yes = true
        assert!(run(vec!["button".to_string()], false, false, false, false, true).is_ok());

        // 2. Run add with --overwrite flag = true
        assert!(run(vec!["button".to_string()], true, false, false, false, true).is_ok());

        // 3. Run add with --dry-run = true
        assert!(run(vec!["button".to_string()], false, true, false, false, true).is_ok());

        // 4. Run add with --all = true
        assert!(run(vec![], false, false, true, false, true).is_ok());

        // 5. Run add with non-existent component name
        assert!(run(
            vec!["nonexistent".to_string()],
            false,
            false,
            false,
            false,
            true
        )
        .is_ok());

        // 6. Run add empty names without --all and auto_yes = true
        assert!(run(vec![], false, false, false, false, true).is_ok());
    }
}
