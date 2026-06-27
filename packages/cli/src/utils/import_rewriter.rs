use regex::Regex;
use std::sync::OnceLock;

use crate::{registry::RegistryIndex, utils::logger};

fn import_regex() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"import\s+['"]([^'"]+)['"]\s*;"#).unwrap())
}

fn meta_regex() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r"^// justui-meta: registry=([0-9a-f]{64}) local=([0-9a-f]{64})\r?\n").unwrap()
    })
}

/// Metadata parsed from the header line of a JustUI-managed file.
pub struct JustUIMetadata {
    pub registry_hash: String,
    pub local_hash: String,
}

/// Strips `_shared_` prefix from a filename when copying to user's project.
/// e.g. `"_shared_pressable.dart"` → `"just_pressable.dart"`
pub fn normalize_shared_file_name(file_name: &str) -> String {
    if let Some(rest) = file_name.strip_prefix("_shared_") {
        format!("just_{}", rest)
    } else {
        file_name.to_string()
    }
}

/// Parses the `JustUIMetadata` from the top of the file content, if present.
pub fn parse_metadata(content: &str) -> Option<JustUIMetadata> {
    let caps = meta_regex().captures(content)?;
    Some(JustUIMetadata {
        registry_hash: caps[1].to_string(),
        local_hash: caps[2].to_string(),
    })
}

/// Strips the `// justui-meta` header line from the file content if it exists.
pub fn strip_metadata(content: &str) -> String {
    if meta_regex().is_match(content) {
        meta_regex().replace(content, "").into_owned()
    } else {
        content.to_string()
    }
}

/// Prepends the metadata header line containing registry and local hashes to the content.
pub fn inject_metadata(content: &str, registry_hash: &str, local_hash: &str) -> String {
    let clean = strip_metadata(content);
    format!(
        "// justui-meta: registry={} local={}\n{}",
        registry_hash, local_hash, clean
    )
}

// ─── Unix-style path helpers (registry paths are always '/' separated) ────────

fn unix_dirname(path: &str) -> &str {
    match path.rfind('/') {
        Some(idx) => &path[..idx],
        None => ".",
    }
}

fn unix_join(base: &str, path: &str) -> String {
    if path.starts_with('/') {
        return path.to_string();
    }
    if base == "." || base.is_empty() {
        return path.to_string();
    }
    format!("{}/{}", base, path)
}

fn normalize_unix_path(path: &str) -> String {
    let mut segments: Vec<&str> = Vec::new();
    for segment in path.split('/') {
        match segment {
            "" | "." => {}
            ".." => {
                segments.pop();
            }
            s => segments.push(s),
        }
    }
    if segments.is_empty() {
        ".".to_string()
    } else {
        segments.join("/")
    }
}

/// Compute the relative path from `from_dir` to `target` (both Unix-style).
fn path_relative_unix(target: &str, from_dir: &str) -> String {
    let target_parts: Vec<&str> = target.split('/').filter(|s| !s.is_empty()).collect();
    let from_parts: Vec<&str> = from_dir.split('/').filter(|s| !s.is_empty()).collect();

    // Find common prefix length
    let common_len = target_parts
        .iter()
        .zip(from_parts.iter())
        .take_while(|(a, b)| a == b)
        .count();

    // Build relative path
    let up_count = from_parts.len() - common_len;
    let rel: Vec<String> = std::iter::repeat("..".to_string())
        .take(up_count)
        .chain(target_parts[common_len..].iter().map(|s| s.to_string()))
        .collect();

    if rel.is_empty() {
        ".".to_string()
    } else {
        rel.join("/")
    }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Rewrites relative imports inside `content` to align with the local directory setup.
/// Matches the Dart `ImportRewriter.rewrite` behavior exactly.
pub fn rewrite(
    content: &str,
    source_registry_path: &str,
    current_component_name: &str,
    registry_index: &RegistryIndex,
    components_dir: &str,
    tokens_dir: &str,
    shared_dir: &str,
) -> String {
    let clean_content = strip_metadata(content);

    // Determine the current component's local target directory
    let current_component = registry_index
        .components
        .iter()
        .find(|c| c.name == current_component_name);

    let current_dir = match current_component {
        Some(comp) => {
            if comp.category == "tokens" || comp.category == "core" {
                tokens_dir.to_string()
            } else if comp.internal {
                shared_dir.to_string()
            } else {
                format!("{}/{}", components_dir, current_component_name)
            }
        }
        None => format!("{}/{}", components_dir, current_component_name),
    };

    let filename = source_registry_path
        .split('/')
        .last()
        .unwrap_or(source_registry_path);
    let local_filename = if current_component.map(|c| c.internal).unwrap_or(false) {
        normalize_shared_file_name(filename)
    } else {
        filename.to_string()
    };
    let current_file_path = format!("{}/{}", current_dir, local_filename);

    // Theme file suffixes (matches Dart heuristic exactly)
    const THEME_SUFFIXES: &[&str] = &[
        "theme_provider.dart",
        "theme_data.dart",
        "theme_aspects.dart",
        "theme_data_material.dart",
    ];

    let source_reg_dir = unix_dirname(source_registry_path);
    let current_file_dir = unix_dirname(&current_file_path);

    import_regex()
        .replace_all(&clean_content, |caps: &regex::Captures| {
            let import_path = &caps[1];

            // Skip absolute imports (dart: and package:)
            if import_path.starts_with("package:") || import_path.starts_with("dart:") {
                return caps[0].to_string();
            }

            // Resolve registry-relative path
            let joined = unix_join(source_reg_dir, import_path);
            let resolved_reg_path = normalize_unix_path(&joined);

            // Theme import heuristic
            let is_theme_import = resolved_reg_path.starts_with("components/theme/")
                || THEME_SUFFIXES
                    .iter()
                    .any(|suffix| resolved_reg_path.ends_with(suffix));

            if is_theme_import {
                return "import 'package:just_ui_core/just_ui_core.dart';".to_string();
            }

            // Find which registry component owns this file
            let mut found_comp = None;
            let mut found_file = None;

            'outer: for comp in &registry_index.components {
                for file in &comp.files {
                    if file.path == resolved_reg_path {
                        found_comp = Some(comp);
                        found_file = Some(file);
                        break 'outer;
                    }
                }
            }

            if let (Some(comp), Some(file)) = (found_comp, found_file) {
                let target_dir = if comp.category == "tokens" || comp.category == "core" {
                    tokens_dir.to_string()
                } else if comp.internal {
                    shared_dir.to_string()
                } else {
                    format!("{}/{}", components_dir, comp.name)
                };

                let local_target_file_name = if comp.internal {
                    normalize_shared_file_name(&file.name)
                } else {
                    file.name.clone()
                };

                let target_file_path = format!("{}/{}", target_dir, local_target_file_name);
                let relative_import = path_relative_unix(&target_file_path, current_file_dir);
                return format!("import '{}';", relative_import);
            }

            // Fallback: unresolved import — emit warning and leave unchanged
            logger::warning(&format!(
                "Relative import \"{}\" in component \"{}\" \
                 (source file: \"{}\") could not be resolved in the \
                 registry. The import will be left as-is and may need manual fixing.",
                import_path, current_component_name, source_registry_path
            ));
            caps[0].to_string()
        })
        .into_owned()
}

// ─── Unit-testable helpers exposed for tests ──────────────────────────────────

#[cfg(test)]
#[allow(dead_code)]
pub(crate) fn path_relative_unix_pub(target: &str, from_dir: &str) -> String {
    path_relative_unix(target, from_dir)
}

#[cfg(test)]
#[allow(dead_code)]
pub(crate) fn normalize_unix_path_pub(path: &str) -> String {
    normalize_unix_path(path)
}
