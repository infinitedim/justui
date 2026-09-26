//! Invariants between `registry/`, the embedded core/tokens kernel and the
//! import rewriter. These run without a Flutter SDK and guard against:
//! - package imports pointing at files `init` never extracts,
//! - relative imports pointing at files `add` never installs,
//! - `registryDependencies` drifting from the imports a component really has.

use std::collections::{BTreeSet, HashMap, HashSet};
use std::path::PathBuf;

use justui_cli::registry::{RegistryComponent, RegistryIndex};
use justui_cli::utils::embedded_templates::{CoreAssets, TokensAssets};
use justui_cli::utils::import_rewriter;
use regex::Regex;

const PACKAGE: &str = "my_app";
const COMPONENTS_DIR: &str = "lib/widgets";
const TOKENS_DIR: &str = "lib/tokens";
const SHARED_DIR: &str = "lib/widgets/shared";
const PRESETS: [&str; 2] = ["default", "neobrutalism"];

fn registry_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../registry")
}

fn load_index() -> RegistryIndex {
    let raw = std::fs::read_to_string(registry_root().join("index.json"))
        .expect("registry/index.json must be readable");
    serde_json::from_str(&raw).expect("registry/index.json must parse")
}

fn import_regex() -> Regex {
    Regex::new(r#"(?m)^\s*(?:import|export)\s+'([^']+)'"#).expect("valid regex")
}

fn normalize(path: &str) -> String {
    let mut out: Vec<&str> = Vec::new();
    for seg in path.split('/') {
        match seg {
            "" | "." => {}
            ".." => {
                out.pop();
            }
            s => out.push(s),
        }
    }
    out.join("/")
}

/// Paths (relative to `lib/`) produced by `init` when extracting the kernel.
fn extracted_kernel_files() -> (HashSet<String>, HashSet<String>) {
    let strip = |p: &str| p.strip_prefix("src/").unwrap_or(p).to_string();
    let core = CoreAssets::iter()
        .map(|p| strip(p.as_ref()))
        .filter(|p| !p.starts_with("components/"))
        .collect();
    let tokens = TokensAssets::iter().map(|p| strip(p.as_ref())).collect();
    (core, tokens)
}

struct Installed<'a> {
    comp: &'a RegistryComponent,
    registry_path: String,
    target_path: String,
}

fn installed_files<'a>(index: &'a RegistryIndex, preset: &str) -> Vec<Installed<'a>> {
    let mut out = Vec::new();
    for comp in &index.components {
        let dir = comp.install_dir(COMPONENTS_DIR, TOKENS_DIR, SHARED_DIR);
        for file in comp.files_for_preset(preset) {
            out.push(Installed {
                comp,
                registry_path: file.path.clone(),
                target_path: format!("{}/{}", dir, comp.local_file_name(&file.name)),
            });
        }
    }
    out
}

#[test]
fn rewritten_imports_resolve_to_installed_or_extracted_files() {
    let index = load_index();
    let (core_files, token_files) = extracted_kernel_files();
    let imports = import_regex();
    let core_prefix = format!("package:{}/core/", PACKAGE);
    let tokens_prefix = format!(
        "package:{}/{}/",
        PACKAGE,
        TOKENS_DIR.strip_prefix("lib/").unwrap_or(TOKENS_DIR)
    );

    let mut failures = BTreeSet::new();
    for preset in PRESETS {
        let files = installed_files(&index, preset);
        let targets: HashSet<&str> = files.iter().map(|f| f.target_path.as_str()).collect();

        for f in &files {
            let source = std::fs::read_to_string(registry_root().join(&f.registry_path))
                .unwrap_or_else(|e| panic!("missing registry file {}: {}", f.registry_path, e));
            let rewritten = import_rewriter::rewrite(
                &source,
                &f.registry_path,
                &f.comp.name,
                &index,
                COMPONENTS_DIR,
                TOKENS_DIR,
                SHARED_DIR,
                preset,
                PACKAGE,
            );
            let own_dir = f.target_path.rsplit_once('/').map_or("", |(d, _)| d);

            for cap in imports.captures_iter(&rewritten) {
                let target = &cap[1];
                let ok = if let Some(p) = target.strip_prefix(&core_prefix) {
                    core_files.contains(p)
                } else if let Some(p) = target.strip_prefix(&tokens_prefix) {
                    token_files.contains(p)
                } else if target.starts_with("package:") || target.starts_with("dart:") {
                    !target.starts_with("package:just_ui_")
                } else {
                    targets.contains(normalize(&format!("{}/{}", own_dir, target)).as_str())
                };
                if !ok {
                    failures.insert(format!("[{}] {} -> {}", preset, f.registry_path, target));
                }
            }
        }
    }

    assert!(
        failures.is_empty(),
        "Unresolvable imports after rewrite:\n{}",
        failures.into_iter().collect::<Vec<_>>().join("\n")
    );
}

#[test]
fn registry_dependencies_match_actual_imports() {
    let index = load_index();
    let imports = import_regex();

    let mut failures = BTreeSet::new();
    for preset in PRESETS {
        let files = installed_files(&index, preset);
        let owner_by_target: HashMap<&str, &str> = files
            .iter()
            .map(|f| (f.target_path.as_str(), f.comp.name.as_str()))
            .collect();

        let mut needed: HashMap<&str, BTreeSet<&str>> = HashMap::new();
        for f in &files {
            let source = std::fs::read_to_string(registry_root().join(&f.registry_path))
                .unwrap_or_else(|e| panic!("missing registry file {}: {}", f.registry_path, e));
            let rewritten = import_rewriter::rewrite(
                &source,
                &f.registry_path,
                &f.comp.name,
                &index,
                COMPONENTS_DIR,
                TOKENS_DIR,
                SHARED_DIR,
                preset,
                PACKAGE,
            );
            let own_dir = f.target_path.rsplit_once('/').map_or("", |(d, _)| d);
            let entry = needed.entry(f.comp.name.as_str()).or_default();
            for cap in imports.captures_iter(&rewritten) {
                let target = &cap[1];
                if target.starts_with("package:") || target.starts_with("dart:") {
                    continue;
                }
                let resolved = normalize(&format!("{}/{}", own_dir, target));
                if let Some(owner) = owner_by_target.get(resolved.as_str()) {
                    if *owner != f.comp.name {
                        entry.insert(owner);
                    }
                }
            }
        }

        for comp in &index.components {
            let declared: BTreeSet<&str> = comp
                .registry_dependencies
                .iter()
                .map(String::as_str)
                .collect();
            let used = needed.get(comp.name.as_str()).cloned().unwrap_or_default();
            let missing: Vec<_> = used.difference(&declared).collect();
            let unused: Vec<_> = declared.difference(&used).collect();
            if !missing.is_empty() {
                failures.insert(format!("[{}] {}: missing {:?}", preset, comp.name, missing));
            }
            if !unused.is_empty() {
                failures.insert(format!("[{}] {}: unused {:?}", preset, comp.name, unused));
            }
        }
    }

    assert!(
        failures.is_empty(),
        "registryDependencies drift:\n{}",
        failures.into_iter().collect::<Vec<_>>().join("\n")
    );
}

fn primary_header_regex() -> Regex {
    Regex::new(r"(?m)^[ \t]*(?:(?:abstract|sealed|base|interface|final|mixin)\s+)*class\s+(?:const\s+)?[A-Za-z_][A-Za-z0-9_]*(?:<[^>{]*(?:<[^>{]*>[^>{]*)*>)?\s*\(")
        .expect("valid regex")
}

#[test]
fn standard_target_removes_every_primary_constructor() {
    use justui_cli::utils::constructor_transpiler::transpile_to_standard_constructor;

    let mut sources: Vec<(String, String)> = Vec::new();
    let index = load_index();
    for comp in &index.components {
        for preset in PRESETS {
            for file in comp.files_for_preset(preset) {
                let path = registry_root().join(&file.path);
                let content = std::fs::read_to_string(&path)
                    .unwrap_or_else(|e| panic!("missing registry file {}: {}", file.path, e));
                sources.push((format!("registry/{}", file.path), content));
            }
        }
    }
    for path in CoreAssets::iter() {
        if let Some(asset) = CoreAssets::get(&path) {
            sources.push((
                format!("core/{}", path),
                String::from_utf8_lossy(&asset.data).into_owned(),
            ));
        }
    }
    for path in TokensAssets::iter() {
        if let Some(asset) = TokensAssets::get(&path) {
            sources.push((
                format!("tokens/{}", path),
                String::from_utf8_lossy(&asset.data).into_owned(),
            ));
        }
    }

    let dump_dir = std::env::var_os("JUSTUI_DUMP_STANDARD").map(PathBuf::from);
    let header = primary_header_regex();
    let new_ctor = Regex::new(r"(?m)^[ \t]*(?:(?:const|factory)[ \t]+)*new\b[ \t]*\w*[ \t]*\(")
        .expect("valid regex");
    let mut failures = BTreeSet::new();
    for (name, content) in &sources {
        let (converted, skipped) = transpile_to_standard_constructor(content);
        if !skipped.is_empty() {
            failures.insert(format!("{}: skipped {:?}", name, skipped));
        }
        if let Some(m) = header.find(&converted) {
            failures.insert(format!(
                "{}: primary header remains: {}",
                name,
                m.as_str().trim()
            ));
        }
        if let Some(m) = new_ctor.find(&converted) {
            failures.insert(format!(
                "{}: `new` constructor remains: {}",
                name,
                m.as_str().trim()
            ));
        }
        if let Some(dir) = &dump_dir {
            let out = dir.join(name);
            if let Some(parent) = out.parent() {
                std::fs::create_dir_all(parent).expect("create dump dir");
            }
            std::fs::write(out, &converted).expect("write dump");
        }
    }

    assert!(
        failures.is_empty(),
        "Standard transpilation incomplete:\n{}",
        failures.into_iter().collect::<Vec<_>>().join("\n")
    );
}
