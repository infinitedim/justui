use crate::utils::fvm_detector::{detect_local_fvm_version, detect_system_flutter_version};
use crate::utils::pubspec_editor::{
    has_dependency, has_flutter_constraint_below_350, supports_material_ui,
    supports_primary_constructors,
};
use regex::Regex;
use serde::{Deserialize, Serialize};
use std::path::Path;
use std::sync::LazyLock;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default, clap::ValueEnum)]
#[serde(rename_all = "snake_case")]
pub enum DartTarget {
    Primary,
    #[default]
    Standard,
}

/// Resolves the target Dart constructor syntax for a Flutter project.
///
/// Hierarchy of Truth:
/// 1. `pubspec.yaml` constraint check (must be >= 3.13.0 for Dart or >= 3.47.0 for Flutter).
/// 2. If FVM local version is present, it can override or boost:
///    - If FVM version < 3.47.0, forces `DartTarget::Standard` (safety override).
///    - If FVM version >= 3.47.0, boosts to `DartTarget::Primary`.
/// 3. Fail-safe fallback: `DartTarget::Standard`.
pub fn resolve_dart_target(project_root: &Path) -> DartTarget {
    let pubspec_path = project_root.join("pubspec.yaml");

    let local_fvm = detect_local_fvm_version(project_root);
    let pubspec_supports = supports_primary_constructors(&pubspec_path).unwrap_or(false);

    if let Some(ref fvm_ver) = local_fvm {
        if (fvm_ver.major, fvm_ver.minor) < (3, 47) {
            return DartTarget::Standard;
        }
        if (fvm_ver.major, fvm_ver.minor) >= (3, 47) {
            return DartTarget::Primary;
        }
    }

    if pubspec_supports {
        return DartTarget::Primary;
    }

    DartTarget::Standard
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub(crate) enum MaterialTarget {
    MaterialUi,
    #[default]
    FlutterMaterial,
}

impl MaterialTarget {
    #[must_use]
    pub(crate) const fn import_uri(self) -> &'static str {
        match self {
            Self::MaterialUi => "package:material_ui/material_ui.dart",
            Self::FlutterMaterial => "package:flutter/material.dart",
        }
    }
}

static MATERIAL_IMPORT_REGEX: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(
        r#"(?m)^(\s*(?:import|export)\s+['"])package:(?:flutter/material\.dart|material_ui/material_ui\.dart)(['"])"#,
    )
    .expect("invariant: material import regex literal is valid")
});

/// Resolves which Material package import to emit for a Flutter project.
///
/// Rules:
/// 1. If `pubspec.yaml` does not list `material_ui` in `dependencies`, always returns
///    [`MaterialTarget::FlutterMaterial`] (`package:flutter/material.dart`).
/// 2. If local FVM version is present: `< 3.50` -> `FlutterMaterial`, `>= 3.50` -> `MaterialUi`.
/// 3. If `pubspec.yaml` constrains `flutter < 3.50` -> `FlutterMaterial`; if `flutter >= 3.50`
///    or `sdk >= 3.14` -> `MaterialUi`.
/// 4. If system `flutter --version` on the device is `>= 3.50` -> `MaterialUi`.
/// 5. Fallback -> `FlutterMaterial`.
#[must_use]
pub(crate) fn resolve_material_target(project_root: &Path) -> MaterialTarget {
    let pubspec_path = project_root.join("pubspec.yaml");
    if !has_dependency(&pubspec_path, "material_ui") {
        return MaterialTarget::FlutterMaterial;
    }

    if let Some(fvm_ver) = detect_local_fvm_version(project_root) {
        if (fvm_ver.major, fvm_ver.minor) < (3, 50) {
            return MaterialTarget::FlutterMaterial;
        }
        return MaterialTarget::MaterialUi;
    }

    if has_flutter_constraint_below_350(&pubspec_path) {
        return MaterialTarget::FlutterMaterial;
    }

    if supports_material_ui(&pubspec_path) {
        return MaterialTarget::MaterialUi;
    }

    if let Some(sys_ver) = detect_system_flutter_version()
        && (sys_ver.major, sys_ver.minor) >= (3, 50)
    {
        return MaterialTarget::MaterialUi;
    }

    MaterialTarget::FlutterMaterial
}

/// Rewrites `package:material_ui/material_ui.dart` and `package:flutter/material.dart`
/// directive URIs in `code` to match `target`.
#[must_use]
pub(crate) fn apply_material_target(code: &str, target: MaterialTarget) -> String {
    let uri = target.import_uri();
    MATERIAL_IMPORT_REGEX
        .replace_all(code, |caps: &regex::Captures| {
            format!("{}{uri}{}", &caps[1], &caps[2])
        })
        .into_owned()
}

#[cfg(test)]
#[path = "env_resolver_tests.rs"]
mod tests;
