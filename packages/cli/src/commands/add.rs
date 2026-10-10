#![expect(
    clippy::fn_params_excessive_bools,
    clippy::implicit_hasher,
    clippy::missing_errors_doc,
    clippy::missing_panics_doc,
    clippy::redundant_else,
    clippy::similar_names,
    clippy::too_many_lines,
    clippy::unwrap_used,
    reason = "legacy: fix when touched"
)]

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
        anyhow::bail!(
            "Project not initialized. Please run \"justui init\" in the root directory first."
        );
    }

    let config = match std::fs::read_to_string(config_path) {
        Ok(content) => JustUIConfig::from_yaml(&content),
        Err(e) => {
            anyhow::bail!("Failed to parse {}: {}", JustUIConfig::CONFIG_FILE_NAME, e);
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

    let trust_flag = crate::utils::trust_store::get_trust_registry_flag();
    crate::utils::trust_store::ensure_registry_trusted(&config.registry_url, trust_flag)?;

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
            anyhow::bail!("Failed to add components: {e}");
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
            anyhow::bail!("No components found in the registry.");
        }

        if auto_yes {
            let names: Vec<String> = index.components.iter().map(|c| c.name.clone()).collect();
            let names_str = names.join(", ");
            logger::stdout(&format!("[auto] Selecting all components: {names_str}"));
            names
        } else {
            logger::stdout("Select components to add:");
            let refs: Vec<&str> = component_names
                .iter()
                .map(std::string::String::as_str)
                .collect();
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
            anyhow::bail!("Dependency resolution error: {e}");
        }
    }

    let mut missing_pub_deps = Vec::new();
    if !effective_dry_run {
        let pubspec_path = std::path::Path::new("pubspec.yaml");
        let content = std::fs::read_to_string(pubspec_path).unwrap_or_default();
        let doc: Option<serde_yaml::Value> = serde_yaml::from_str(&content).ok();
        let existing_deps = doc.as_ref().and_then(|d| d.get("dependencies"));

        for comp_name in &resolved_components {
            if let Some(comp) = index.components.iter().find(|c| c.name == *comp_name) {
                for (dep, ver) in &comp.pub_dependencies {
                    let already_present = existing_deps.and_then(|d| d.get(dep)).is_some();
                    if !already_present && !missing_pub_deps.iter().any(|(d, _)| d == dep) {
                        missing_pub_deps.push((dep.clone(), ver.clone()));
                    }
                }
            }
        }

        if !missing_pub_deps.is_empty() && !auto_yes {
            if !crate::utils::prompt::is_interactive() {
                logger::hint("use -y to run non-interactively");
                return Err(anyhow::Error::new(crate::errors::CliError::Usage(
                    "adding required pub dependencies requires confirmation".to_string(),
                )));
            }

            logger::stdout("The following pub dependencies will be added to pubspec.yaml:");
            for (dep, ver) in &missing_pub_deps {
                logger::stdout(&format!("  - {dep}: \"{ver}\""));
            }
            let proceed = prompt::confirm("Add these dependencies to pubspec.yaml?", true);
            if !proceed {
                logger::warning("Skipping pub dependency installation.");
            }
        }
    }

    let total_files: usize = resolved_components
        .iter()
        .map(|name| {
            index
                .components
                .iter()
                .find(|c| c.name == *name)
                .map_or(0, |c| c.files_for_preset(&config.preset).len())
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
        anyhow::bail!("Failed to add components: {e}");
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
                "\x1B[32m✔\x1B[0m {copied_count} file(s) added/updated:"
            ));
            for line in success_details {
                logger::stdout(&line);
            }
        }
        if skipped_count > 0 {
            logger::stdout(&format!(
                "\x1B[33m⚠\x1B[0m {skipped_count} file(s) skipped:"
            ));
            for line in skip_details {
                logger::stdout(&line);
            }
        }
    }

    let mut summary_items: Vec<SummaryItem> = Vec::new();

    for name in &components_to_add {
        if let Some(component) = index.components.iter().find(|c| c.name == *name) {
            let target_dir = component.install_dir(
                &config.components_dir,
                &config.tokens_dir,
                &config.shared_dir,
            );

            summary_items.push(SummaryItem {
                label: name.clone(),
                value: format!("v{}  {}/", component.version, target_dir),
            });
        }
    }

    if !summary_items.is_empty() && !dry_run {
        logger::success("Components added successfully");
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
    let mut stack = Vec::new();
    resolve_deps_inner(name, index, visited, &mut stack, resolved)
}

fn resolve_deps_inner(
    name: &str,
    index: &RegistryIndex,
    visited: &mut HashSet<String>,
    stack: &mut Vec<String>,
    resolved: &mut Vec<String>,
) -> Result<()> {
    if stack.iter().any(|s| s == name) {
        let mut cycle_path = stack.join(" -> ");
        cycle_path.push_str(" -> ");
        cycle_path.push_str(name);
        anyhow::bail!("dependency cycle detected: {cycle_path}");
    }
    if visited.contains(name) {
        return Ok(());
    }

    let component = index
        .components
        .iter()
        .find(|c| c.name == name)
        .ok_or_else(|| anyhow::anyhow!("Component \"{name}\" not found in registry"))?;

    stack.push(name.to_string());
    for dep in &component.registry_dependencies {
        resolve_deps_inner(dep, index, visited, stack, resolved)?;
    }
    stack.pop();

    visited.insert(name.to_string());
    resolved.push(name.to_string());
    Ok(())
}

#[allow(
    clippy::too_many_arguments,
    reason = "legacy component installer signature"
)]
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
        .ok_or_else(|| anyhow::anyhow!("Component \"{name}\" not found in registry"))?;

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

    let target_dir = component.install_dir(components_dir, tokens_dir, shared_dir);

    let files: Vec<_> = component.files_for_preset(preset);
    let comp_name = component.name.clone();
    let pub_deps: Vec<(String, String)> = component
        .pub_dependencies
        .iter()
        .map(|(k, v)| (k.clone(), v.clone()))
        .collect();

    let downloaded_contents: Vec<String> = if let Ok(handle) = tokio::runtime::Handle::try_current()
    {
        tokio::task::block_in_place(|| {
            handle.block_on(async {
                use std::sync::Arc;
                use tokio::sync::Semaphore;
                use tokio::task::JoinSet;

                let semaphore = Arc::new(Semaphore::new(4));
                let mut join_set = JoinSet::new();

                for (idx, file) in files.iter().enumerate() {
                    let sem = Arc::clone(&semaphore);
                    let client_ref = client.clone();
                    let path = file.path.clone();
                    let name = file.name.clone();

                    join_set.spawn(async move {
                        let _permit = sem
                            .acquire()
                            .await
                            .map_err(|e| anyhow::anyhow!("Semaphore error: {e}"))?;
                        let content = client_ref
                            .fetch_file_content_async(&path)
                            .await
                            .map_err(|e| anyhow::anyhow!("Failed to fetch \"{name}\": {e}"))?;
                        Ok::<(usize, String), anyhow::Error>((idx, content))
                    });
                }

                let mut results = vec![String::new(); files.len()];
                while let Some(res) = join_set.join_next().await {
                    let (idx, content) =
                        res.map_err(|e| anyhow::anyhow!("Task join error: {e}"))??;
                    results[idx] = content;
                }
                Ok::<Vec<String>, anyhow::Error>(results)
            })
        })?
    } else {
        let mut results = Vec::with_capacity(files.len());
        for file in &files {
            let content = client
                .fetch_file_content(&file.path)
                .map_err(|e| anyhow::anyhow!("Failed to fetch \"{}\": {e}", file.name))?;
            results.push(content);
        }
        results
    };

    for (file, content) in files.iter().zip(downloaded_contents.iter()) {
        if let Some(bar) = pb {
            bar.inc(1);
            bar.set_message(format!("Processing {}...", file.name));
        }

        let downloaded_hash = crate::utils::path_guard::Sha256Hex::from_bytes(content.as_bytes());
        let expected_hash_str = file.checksum.replace("sha256:", "").trim().to_string();
        let expected_hash =
            crate::utils::path_guard::Sha256Hex::new(&expected_hash_str).map_err(|e| {
                anyhow::anyhow!("Invalid registry checksum for \"{}\": {}", file.name, e)
            })?;

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
            content,
            &file.path,
            &comp_name,
            index,
            components_dir,
            tokens_dir,
            shared_dir,
            preset,
            &pkg_name,
        );

        rewritten_content = crate::utils::constructor_transpiler::apply_dart_target(
            &rewritten_content,
            dart_target,
        );

        let local_rewritten_hash = sha256_hex(rewritten_content.as_bytes());
        let final_content = import_rewriter::inject_metadata(
            &rewritten_content,
            expected_hash.as_str(),
            &local_rewritten_hash,
        );

        let local_file_name = component.local_file_name(&file.name);
        let raw_dest = std::path::Path::new(&target_dir).join(&local_file_name);
        let project_rel = if raw_dest.is_absolute() {
            let cwd = std::env::current_dir().unwrap_or_else(|_| std::path::PathBuf::from("."));
            crate::utils::path_guard::ProjectRelPath::from_project_root(&cwd, &raw_dest)
                .map_err(|e| anyhow::anyhow!("Invalid target path: {e}"))?
        } else {
            crate::utils::path_guard::ProjectRelPath::new(&raw_dest)
                .map_err(|e| anyhow::anyhow!("Invalid target path: {e}"))?
        };
        let target_path =
            crate::utils::path_guard::safe_join(std::path::Path::new("."), &project_rel)
                .map_err(|e| anyhow::anyhow!("Unsafe target path: {e}"))?;

        let file_exists = target_path.exists();

        let mut local_clean_for_diff = String::new();

        let (should_write, conflict_detected, status) = if file_exists {
            if dry_run {
                let (sw, conflict, local_clean, st) = resolve_conflict_dry(
                    &target_path,
                    &local_file_name,
                    expected_hash.as_str(),
                    &rewritten_content,
                    auto_yes,
                )?;
                local_clean_for_diff = local_clean;
                (sw, conflict, st)
            } else {
                let (sw, st) = resolve_conflict(
                    &target_path,
                    &local_file_name,
                    expected_hash.as_str(),
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
                logger::stdout(&format!("[registry] {local_file_name} (file baru)"));
                for line in rewritten_content.lines() {
                    logger::stdout(&format!("+ {line}"));
                }
            }
        }

        if dry_run {
            if conflict_detected {
                stats.conflicts += 1;
                logger::stdout(&format!(
                    "  [dry-run] Conflict (will write if selected): {local_file_name}"
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
            crate::utils::path_guard::atomic_write(&target_path, &final_content)?;
            crate::utils::dart_formatter::format_and_refresh_metadata(&target_path);
            logger::stdout(&format!("  - Copied {local_file_name} to {target_dir}/"));
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
                    format!(
                        "package:{}/{}/{}",
                        pkg_name, component.name, local_file_name
                    )
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
                            && updated
                        {
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

        details.push(OperationDetail {
            file_name: local_file_name.clone(),
            status,
            path: format!("{target_dir}/{local_file_name}"),
        });
    }

    if !pub_deps.is_empty() && !dry_run {
        let pubspec_path = std::path::Path::new("pubspec.yaml");
        for (dep, version) in &pub_deps {
            match pubspec_editor::add_dependency(pubspec_path, dep, version) {
                Ok(()) => {
                    logger::success(&format!(
                        "Added dependency \"{dep}: {version}\" to pubspec.yaml."
                    ));
                }
                Err(e) => {
                    logger::warning(&format!("Could not add dependency \"{dep}\": {e}"));
                }
            }
        }
    }

    if !dry_run {
        logger::success(&format!("Component \"{comp_name}\" added successfully."));
    }
    Ok((stats, details))
}

#[allow(
    clippy::needless_return,
    reason = "explicit return for clarity in conflict branch"
)]
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
                if local_clean == rewritten_content {
                    logger::stdout(&format!("  - {local_file_name} is already up-to-date."));
                    return Ok((false, OperationStatus::UpToDate));
                } else if auto_yes {
                    logger::stdout(&format!(
                        "[auto] Overwriting {local_file_name} (updated content generated)"
                    ));
                    return Ok((true, OperationStatus::Overwritten));
                }
                logger::info(&format!(
                    "  - Updating {local_file_name} to newly generated version."
                ));
                return Ok((true, OperationStatus::Overwritten));
            }
            if auto_yes {
                logger::stdout(&format!(
                    "[auto] Overwriting {local_file_name} (not modified locally)"
                ));
                return Ok((true, OperationStatus::Overwritten));
            }
            logger::info(&format!(
                "  - Updating {local_file_name} to latest registry version."
            ));
            return Ok((true, OperationStatus::Overwritten));
        }
        if meta.registry_hash == expected_hash {
            if auto_yes {
                logger::stdout(&format!(
                    "[auto] Skipping {local_file_name} (modified locally)"
                ));
                return Ok((false, OperationStatus::SkippedLocalCustomization));
            }
            logger::stdout(&format!(
                "  - {local_file_name} has been customized locally. Skipping."
            ));
            return Ok((false, OperationStatus::SkippedLocalCustomization));
        } else {
            if auto_yes {
                logger::stdout(&format!(
                    "[auto] Skipping {local_file_name} (modified locally)"
                ));
                return Ok((false, OperationStatus::ConflictResolvedSkip));
            }
            logger::warning(&format!(
                "Conflict: Local file \"{local_file_name}\" has been modified, and a registry update is available."
            ));
            let proceed = conflict_prompt(local_file_name, &local_clean, rewritten_content)?;
            if proceed {
                return Ok((true, OperationStatus::ConflictResolvedOverwrite));
            }
            return Ok((false, OperationStatus::ConflictResolvedSkip));
        }
    } else {
        let local_hash = sha256_hex(local_content.as_bytes());
        if local_hash == expected_hash {
            logger::stdout(&format!(
                "  - {local_file_name} is already up-to-date (no metadata)."
            ));
            return Ok((false, OperationStatus::UpToDate));
        } else {
            if auto_yes {
                logger::stdout(&format!(
                    "[auto] Overwriting {local_file_name} (not modified locally)"
                ));
                return Ok((true, OperationStatus::ConflictResolvedOverwrite));
            }
            logger::warning(&format!(
                "Conflict: Local file \"{local_file_name}\" exists and differs (no metadata)."
            ));
            let proceed = conflict_prompt(local_file_name, &local_content, rewritten_content)?;
            if proceed {
                return Ok((true, OperationStatus::ConflictResolvedOverwrite));
            }
            return Ok((false, OperationStatus::ConflictResolvedSkip));
        }
    }
}

fn resolve_conflict_dry(
    target_path: &std::path::Path,
    local_file_name: &str,
    expected_hash: &str,
    rewritten_content: &str,
    _auto_yes: bool,
) -> Result<(bool, bool, String, OperationStatus)> {
    let raw = std::fs::read_to_string(target_path)?;
    let local_content = raw.replace("\r\n", "\n");

    if let Some(meta) = import_rewriter::parse_metadata(&local_content) {
        let local_clean = import_rewriter::strip_metadata(&local_content);
        let current_local_hash = sha256_hex(local_clean.as_bytes());

        if current_local_hash == meta.local_hash {
            if meta.registry_hash == expected_hash {
                if local_clean == rewritten_content {
                    logger::stdout(&format!(
                        "  [dry-run] Already up-to-date: {local_file_name}"
                    ));
                    Ok((false, false, local_clean, OperationStatus::UpToDate))
                } else {
                    Ok((true, false, local_clean, OperationStatus::Overwritten))
                }
            } else {
                Ok((true, false, local_clean, OperationStatus::Overwritten))
            }
        } else {
            if meta.registry_hash == expected_hash {
                logger::stdout(&format!(
                    "  [dry-run] Skipped (modified locally): {local_file_name}"
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
                "  [dry-run] Already up-to-date: {local_file_name}"
            ));
            Ok((false, false, local_content, OperationStatus::UpToDate))
        } else {
            logger::stdout(&format!(
                "  [dry-run] Skipped (modified locally): {local_file_name}"
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
#[path = "add_tests.rs"]
mod tests;
