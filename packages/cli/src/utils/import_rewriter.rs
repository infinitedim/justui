use regex::Regex;
use std::collections::HashMap;
use std::sync::OnceLock;

use crate::{
    registry::{RegistryComponent, RegistryFile, RegistryIndex},
    utils::logger,
};

fn import_regex() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| Regex::new(r#"(import|export)\s+['"]([^'"]+)['"]([^;]*);"#).unwrap())
}

fn meta_regex() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(r"^// justui-meta: registry=([0-9a-f]{64}) local=([0-9a-f]{64})\r?\n").unwrap()
    })
}

pub struct JustUIMetadata {
    pub registry_hash: String,
    pub local_hash: String,
}

/// Maps a path inside the `just_ui_core` / `just_ui_tokens` packages to its
/// location in the user project. `init` extracts package files with the
/// leading `src/` removed but keeps every other directory, so imports must
/// preserve the same subpath (e.g. `src/theme/schemes/x.dart` -> `theme/schemes/x.dart`).
pub fn local_package_subpath(subpath: &str) -> &str {
    subpath.strip_prefix("src/").unwrap_or(subpath)
}

pub fn normalize_shared_file_name(file_name: &str) -> String {
    if let Some(rest) = file_name.strip_prefix("_shared_") {
        format!("just_{}", rest)
    } else {
        file_name.to_string()
    }
}

pub fn parse_metadata(content: &str) -> Option<JustUIMetadata> {
    let caps = meta_regex().captures(content)?;
    Some(JustUIMetadata {
        registry_hash: caps[1].to_string(),
        local_hash: caps[2].to_string(),
    })
}

pub fn strip_metadata(content: &str) -> String {
    if meta_regex().is_match(content) {
        meta_regex().replace(content, "").into_owned()
    } else {
        content.to_string()
    }
}

pub fn inject_metadata(content: &str, registry_hash: &str, local_hash: &str) -> String {
    let clean = strip_metadata(content);
    format!(
        "// justui-meta: registry={} local={}\n{}",
        registry_hash, local_hash, clean
    )
}

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

fn path_relative_unix(target: &str, from_dir: &str) -> String {
    let target_parts: Vec<&str> = target.split('/').filter(|s| !s.is_empty()).collect();
    let from_parts: Vec<&str> = from_dir.split('/').filter(|s| !s.is_empty()).collect();

    let common_len = target_parts
        .iter()
        .zip(from_parts.iter())
        .take_while(|(a, b)| a == b)
        .count();

    let up_count = from_parts.len() - common_len;
    let rel: Vec<String> = std::iter::repeat_n("..".to_string(), up_count)
        .chain(target_parts[common_len..].iter().map(|s| s.to_string()))
        .collect();

    if rel.is_empty() {
        ".".to_string()
    } else {
        rel.join("/")
    }
}

/// Canonicalizes a registry relative path into a flat logical path without any preset folder.
///
/// Examples:
/// - "components/accordion/neobrutalism/just_accordion.dart" -> "components/accordion/just_accordion.dart"
/// - "components/shared/default/_shared_pressable.dart" -> "components/shared/_shared_pressable.dart"
/// - "components/button/just_button_theme.dart" -> "components/button/just_button_theme.dart"
pub fn canonicalize_registry_path(path: &str) -> String {
    let parts: Vec<&str> = path.split('/').filter(|s| !s.is_empty()).collect();
    if parts.len() == 4 && parts[0] == "components" {
        format!("{}/{}/{}", parts[0], parts[1], parts[3])
    } else {
        path.to_string()
    }
}

#[derive(Clone)]
pub struct ResolvedTarget<'a> {
    pub comp: &'a RegistryComponent,
    pub file: RegistryFile,
}

/// Inverted Index for fast O(1) canonical registry path resolution.
pub struct CanonicalRegistryResolver<'a> {
    index_by_logical_path: HashMap<String, ResolvedTarget<'a>>,
}

impl<'a> CanonicalRegistryResolver<'a> {
    pub fn new(registry_index: &'a RegistryIndex, active_preset: &str) -> Self {
        let mut map = HashMap::new();
        for comp in &registry_index.components {
            for file in comp.files_for_preset(active_preset) {
                let canonical = canonicalize_registry_path(&file.path);

                // Primary canonical key
                map.insert(
                    canonical.clone(),
                    ResolvedTarget {
                        comp,
                        file: file.clone(),
                    },
                );

                // Also index normalized alias if internal/shared
                if comp.internal {
                    let dir = unix_dirname(&canonical);
                    let filename = canonical.split('/').next_back().unwrap_or(&canonical);
                    if let Some(stripped) = filename.strip_prefix("_shared_") {
                        let just_key = format!("{}/just_{}", dir, stripped);
                        map.insert(
                            just_key,
                            ResolvedTarget {
                                comp,
                                file: file.clone(),
                            },
                        );
                    } else if let Some(stripped) = filename.strip_prefix("just_") {
                        let shared_key = format!("{}/_shared_{}", dir, stripped);
                        map.insert(
                            shared_key,
                            ResolvedTarget {
                                comp,
                                file: file.clone(),
                            },
                        );
                    }
                }
            }
        }
        Self {
            index_by_logical_path: map,
        }
    }

    pub fn resolve(&self, resolved_flat_path: &str) -> Option<&ResolvedTarget<'a>> {
        if let Some(target) = self.index_by_logical_path.get(resolved_flat_path) {
            return Some(target);
        }

        // Secondary fallback: check alternate prefix
        let dir = unix_dirname(resolved_flat_path);
        let filename = resolved_flat_path
            .split('/')
            .next_back()
            .unwrap_or(resolved_flat_path);
        if let Some(stripped) = filename.strip_prefix("_shared_") {
            let just_key = format!("{}/just_{}", dir, stripped);
            if let Some(target) = self.index_by_logical_path.get(&just_key) {
                return Some(target);
            }
        } else if let Some(stripped) = filename.strip_prefix("just_") {
            let shared_key = format!("{}/_shared_{}", dir, stripped);
            if let Some(target) = self.index_by_logical_path.get(&shared_key) {
                return Some(target);
            }
        }

        None
    }
}

#[allow(clippy::too_many_arguments)]
pub fn rewrite(
    content: &str,
    source_registry_path: &str,
    current_component_name: &str,
    registry_index: &RegistryIndex,
    components_dir: &str,
    tokens_dir: &str,
    shared_dir: &str,
    preset: &str,
    package_name: &str,
) -> String {
    let clean_content = strip_metadata(content);

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
        .next_back()
        .unwrap_or(source_registry_path);
    let local_filename = if current_component.map(|c| c.internal).unwrap_or(false) {
        normalize_shared_file_name(filename)
    } else {
        filename.to_string()
    };
    let current_file_path = format!("{}/{}", current_dir, local_filename);

    const THEME_SUFFIXES: &[&str] = &[
        "theme_provider.dart",
        "theme_data.dart",
        "theme_aspects.dart",
        "theme_data_material.dart",
        "preset_tokens.dart",
        "just_overlay_controller.dart",
        "just_overlay_scope.dart",
        "just_theme.dart",
        "just_ui_core.dart",
    ];

    let current_file_dir = unix_dirname(&current_file_path);
    let resolver = CanonicalRegistryResolver::new(registry_index, preset);

    let rewritten = import_regex()
        .replace_all(&clean_content, |caps: &regex::Captures| {
            let kw = &caps[1];
            let import_path = &caps[2];
            let trailing = &caps[3];

            // Rewrite just_ui_tokens and just_ui_core package imports to local package imports
            if let Some(subpath) = import_path.strip_prefix("package:just_ui_tokens/") {
                let tokens_rel = tokens_dir.strip_prefix("lib/").unwrap_or(tokens_dir);
                return format!(
                    "{} 'package:{}/{}/{}'{};",
                    kw,
                    package_name,
                    tokens_rel,
                    local_package_subpath(subpath),
                    trailing
                );
            }
            if let Some(subpath) = import_path.strip_prefix("package:just_ui_core/") {
                return format!(
                    "{} 'package:{}/core/{}'{};",
                    kw,
                    package_name,
                    local_package_subpath(subpath),
                    trailing
                );
            }
            if import_path == "package:just_ui_core" {
                return format!(
                    "{} 'package:{}/core/just_ui_core.dart'{};",
                    kw, package_name, trailing
                );
            }

            if import_path.starts_with("package:") || import_path.starts_with("dart:") {
                return caps[0].to_string();
            }

            let flat_source_path = canonicalize_registry_path(source_registry_path);
            let flat_source_dir = unix_dirname(&flat_source_path);
            let joined = unix_join(flat_source_dir, import_path);
            let resolved_flat_path = normalize_unix_path(&joined);

            let is_theme_import = resolved_flat_path.starts_with("components/theme/")
                || resolved_flat_path.starts_with("theme/")
                || resolved_flat_path.starts_with("overlay/")
                || THEME_SUFFIXES
                    .iter()
                    .any(|suffix| resolved_flat_path.ends_with(suffix));

            if is_theme_import {
                return format!(
                    "{} 'package:{}/core/just_ui_core.dart'{};",
                    kw, package_name, trailing
                );
            }

            if let Some(target) = resolver.resolve(&resolved_flat_path) {
                let comp = target.comp;
                let file = &target.file;

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
                return format!("{} '{}'{};", kw, relative_import, trailing);
            }

            logger::warning(&format!(
                "Relative {} \"{}\" in component \"{}\" \
                 (source file: \"{}\") could not be resolved in the \
                 registry. The import/export will be left as-is and may need manual fixing.",
                kw, import_path, current_component_name, source_registry_path
            ));
            caps[0].to_string()
        })
        .into_owned();

    let core_import_prefix = format!("'package:{}/core/just_ui_core.dart'", package_name);
    let tokens_import_prefix = format!("'package:{}/tokens/just_ui_tokens.dart'", package_name);

    let raw_lines: Vec<&str> = rewritten.lines().collect();
    let has_full_core_import = raw_lines.iter().any(|line| {
        let trimmed = line.trim();
        trimmed.starts_with("import ")
            && trimmed.contains(&core_import_prefix)
            && !trimmed.contains(" show ")
    });

    let mut seen_imports = std::collections::HashSet::new();
    let mut lines = Vec::new();

    for line in raw_lines {
        let trimmed = line.trim();
        if (trimmed.starts_with("import ") || trimmed.starts_with("export "))
            && trimmed.ends_with(';')
        {
            if seen_imports.contains(trimmed) {
                continue;
            }
            if has_full_core_import
                && trimmed.starts_with("import ")
                && trimmed.contains(&tokens_import_prefix)
            {
                continue;
            }
            seen_imports.insert(trimmed.to_string());
        }
        lines.push(line);
    }

    let mut final_result = lines.join("\n");
    if clean_content.ends_with('\n') && !final_result.ends_with('\n') {
        final_result.push('\n');
    }
    final_result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_import_rewriter_path_helpers() {
        assert_eq!(unix_dirname("a/b/c.dart"), "a/b");
        assert_eq!(unix_dirname("c.dart"), ".");

        assert_eq!(unix_join("a/b", "c.dart"), "a/b/c.dart");
        assert_eq!(unix_join(".", "c.dart"), "c.dart");
        assert_eq!(unix_join("a", "/c.dart"), "/c.dart");

        assert_eq!(normalize_unix_path("a/b/../c/./d"), "a/c/d");
        assert_eq!(normalize_unix_path("a/.."), ".");

        assert_eq!(
            path_relative_unix("lib/tokens/color.dart", "lib/widgets/button"),
            "../../tokens/color.dart"
        );
        assert_eq!(
            path_relative_unix("lib/widgets/button/just_button.dart", "lib/widgets/button"),
            "just_button.dart"
        );
    }

    #[test]
    fn test_package_and_unresolved_import_rewriting() {
        let index = RegistryIndex {
            version: "1.0".to_string(),
            presets: vec!["default".to_string()],
            components: vec![],
        };

        let content = "import 'package:just_ui_tokens/src/colors.dart';\nimport 'package:just_ui_core/src/theme.dart';\nimport 'unresolved.dart';\nimport 'unresolved.dart';";
        let rewritten = rewrite(
            content,
            "components/button/just_button.dart",
            "button",
            &index,
            "lib/widgets",
            "lib/tokens",
            "lib/widgets/shared",
            "default",
            "my_app",
        );

        assert!(rewritten.contains("import 'package:my_app/tokens/colors.dart';"));
        assert!(rewritten.contains("import 'package:my_app/core/theme.dart';"));
        assert!(rewritten.contains("import 'unresolved.dart';"));
        // Check line deduplication
        let count = rewritten
            .lines()
            .filter(|l| l.trim() == "import 'unresolved.dart';")
            .count();
        assert_eq!(count, 1);
    }

    #[test]
    fn test_package_imports_preserve_nested_subpaths() {
        let index = RegistryIndex {
            version: "1.0".to_string(),
            presets: vec!["default".to_string()],
            components: vec![],
        };

        let content = "import 'package:just_ui_core/src/theme/preset_tokens.dart';\nimport 'package:just_ui_core/src/theme/schemes/spacing_scheme.dart';\nimport 'package:just_ui_tokens/src/colors/oklch_engine.dart';\n";
        let rewritten = rewrite(
            content,
            "components/slider/default/just_slider.dart",
            "slider",
            &index,
            "lib/widgets",
            "lib/tokens",
            "lib/widgets/shared",
            "default",
            "my_app",
        );

        assert!(rewritten.contains("import 'package:my_app/core/theme/preset_tokens.dart';"));
        assert!(
            rewritten.contains("import 'package:my_app/core/theme/schemes/spacing_scheme.dart';")
        );
        assert!(rewritten.contains("import 'package:my_app/tokens/colors/oklch_engine.dart';"));
    }

    #[test]
    fn test_export_and_trailing_clauses_and_core_rewriting() {
        let index = RegistryIndex {
            version: "1.0".to_string(),
            presets: vec!["default".to_string()],
            components: vec![],
        };

        let content = r#"import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import 'package:flutter/widgets.dart' show BuildContext, Widget;
import 'package:flutter/math.dart' as math;
import '../../../just_ui_core.dart';
export 'just_carousel_style.dart';
"#;

        let rewritten = rewrite(
            content,
            "components/carousel/default/just_carousel.dart",
            "carousel",
            &index,
            "lib/widgets",
            "lib/tokens",
            "lib/widgets/shared",
            "default",
            "my_app",
        );

        assert!(rewritten.contains("import 'package:my_app/core/just_ui_core.dart';"));
        // Redundant tokens import is pruned because core/just_ui_core.dart already re-exports it
        assert!(!rewritten.contains("import 'package:my_app/tokens/just_ui_tokens.dart';"));
        // Trailing clauses preserved
        assert!(
            rewritten.contains("import 'package:flutter/widgets.dart' show BuildContext, Widget;")
        );
        assert!(rewritten.contains("import 'package:flutter/math.dart' as math;"));
        // Export preserved
        assert!(rewritten.contains("export 'just_carousel_style.dart';"));
    }

    #[test]
    fn test_tokens_retained_when_no_core_import() {
        let index = RegistryIndex {
            version: "1.0".to_string(),
            presets: vec!["default".to_string()],
            components: vec![],
        };

        let content = "import 'package:just_ui_tokens/just_ui_tokens.dart';\n";
        let rewritten = rewrite(
            content,
            "components/button/just_button.dart",
            "button",
            &index,
            "lib/widgets",
            "lib/tokens",
            "lib/widgets/shared",
            "default",
            "my_app",
        );

        assert!(rewritten.contains("import 'package:my_app/tokens/just_ui_tokens.dart';"));
    }

    #[test]
    fn test_canonicalize_registry_path() {
        assert_eq!(
            canonicalize_registry_path("components/accordion/neobrutalism/just_accordion.dart"),
            "components/accordion/just_accordion.dart"
        );
        assert_eq!(
            canonicalize_registry_path("components/shared/default/_shared_pressable.dart"),
            "components/shared/_shared_pressable.dart"
        );
        assert_eq!(
            canonicalize_registry_path("components/button/just_button_theme.dart"),
            "components/button/just_button_theme.dart"
        );
        assert_eq!(
            canonicalize_registry_path("tokens/color.dart"),
            "tokens/color.dart"
        );
    }

    #[test]
    fn test_cross_preset_shared_resolution_neobrutalism() {
        let mut shared_files = HashMap::new();
        shared_files.insert(
            "default".to_string(),
            vec![
                RegistryFile {
                    name: "_shared_pressable.dart".to_string(),
                    path: "components/shared/default/_shared_pressable.dart".to_string(),
                    checksum: "sha256:111".to_string(),
                },
                RegistryFile {
                    name: "just_pressable.dart".to_string(),
                    path: "components/shared/default/_shared_pressable.dart".to_string(),
                    checksum: "sha256:111".to_string(),
                },
            ],
        );

        let shared_comp = RegistryComponent {
            name: "_shared_pressable".to_string(),
            version: "0.14.0".to_string(),
            description: "".to_string(),
            category: "internal".to_string(),
            internal: true,
            supported_presets: vec!["default".to_string()],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: shared_files,
        };

        let mut accordion_files = HashMap::new();
        accordion_files.insert(
            "neobrutalism".to_string(),
            vec![RegistryFile {
                name: "just_accordion.dart".to_string(),
                path: "components/accordion/neobrutalism/just_accordion.dart".to_string(),
                checksum: "sha256:222".to_string(),
            }],
        );

        let accordion_comp = RegistryComponent {
            name: "accordion".to_string(),
            version: "0.14.0".to_string(),
            description: "".to_string(),
            category: "primitive".to_string(),
            internal: false,
            supported_presets: vec!["default".to_string(), "neobrutalism".to_string()],
            registry_dependencies: vec!["_shared_pressable".to_string()],
            pub_dependencies: HashMap::new(),
            files: accordion_files,
        };

        let index = RegistryIndex {
            version: "1.0".to_string(),
            presets: vec!["default".to_string(), "neobrutalism".to_string()],
            components: vec![shared_comp, accordion_comp],
        };

        // Case A: Accordion in neobrutalism imports shared component (legacy prefix)
        let content_a = "import '../shared/_shared_pressable.dart';\n";
        let rewritten_a = rewrite(
            content_a,
            "components/accordion/neobrutalism/just_accordion.dart",
            "accordion",
            &index,
            "lib/widgets",
            "lib/tokens",
            "lib/widgets/shared",
            "neobrutalism",
            "showcase",
        );
        assert_eq!(
            rewritten_a.trim(),
            "import '../shared/just_pressable.dart';"
        );

        // Case B: Accordion in neobrutalism imports shared component (modern prefix)
        let content_b = "import '../shared/just_pressable.dart';\n";
        let rewritten_b = rewrite(
            content_b,
            "components/accordion/neobrutalism/just_accordion.dart",
            "accordion",
            &index,
            "lib/widgets",
            "lib/tokens",
            "lib/widgets/shared",
            "neobrutalism",
            "showcase",
        );
        assert_eq!(
            rewritten_b.trim(),
            "import '../shared/just_pressable.dart';"
        );
    }

    #[test]
    fn test_shared_tooltip_overlay_reverse_resolution() {
        let mut tooltip_files = HashMap::new();
        tooltip_files.insert(
            "default".to_string(),
            vec![RegistryFile {
                name: "just_tooltip.dart".to_string(),
                path: "components/tooltip/default/just_tooltip.dart".to_string(),
                checksum: "sha256:333".to_string(),
            }],
        );

        let tooltip_comp = RegistryComponent {
            name: "tooltip".to_string(),
            version: "0.14.0".to_string(),
            description: "".to_string(),
            category: "overlay".to_string(),
            internal: false,
            supported_presets: vec!["default".to_string()],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: tooltip_files,
        };

        let mut shared_overlay_files = HashMap::new();
        shared_overlay_files.insert(
            "default".to_string(),
            vec![RegistryFile {
                name: "just_tooltip_overlay.dart".to_string(),
                path: "components/shared/default/_shared_tooltip_overlay.dart".to_string(),
                checksum: "sha256:444".to_string(),
            }],
        );

        let shared_overlay_comp = RegistryComponent {
            name: "_shared_tooltip_overlay".to_string(),
            version: "0.14.0".to_string(),
            description: "".to_string(),
            category: "internal".to_string(),
            internal: true,
            supported_presets: vec!["default".to_string()],
            registry_dependencies: vec!["tooltip".to_string()],
            pub_dependencies: HashMap::new(),
            files: shared_overlay_files,
        };

        let index = RegistryIndex {
            version: "1.0".to_string(),
            presets: vec!["default".to_string(), "neobrutalism".to_string()],
            components: vec![tooltip_comp, shared_overlay_comp],
        };

        let content = "import '../tooltip/just_tooltip.dart';\n";
        let rewritten = rewrite(
            content,
            "components/shared/default/_shared_tooltip_overlay.dart",
            "_shared_tooltip_overlay",
            &index,
            "lib/widgets",
            "lib/tokens",
            "lib/widgets/shared",
            "neobrutalism",
            "showcase",
        );
        assert_eq!(rewritten.trim(), "import '../tooltip/just_tooltip.dart';");
    }
}
