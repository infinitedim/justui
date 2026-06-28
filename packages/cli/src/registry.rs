use std::collections::HashMap;
use serde::Deserialize;
use anyhow::{Context, Result};

/// Represents a file within a registry component.
#[derive(Debug, Clone, Deserialize)]
pub struct RegistryFile {
    /// File basename (e.g., 'just_button.dart').
    pub name: String,
    /// Relative path within the registry (e.g., 'components/button/just_button.dart').
    pub path: String,
    /// Expected SHA-256 checksum prefixed with 'sha256:'.
    pub checksum: String,
}

fn default_category() -> String {
    "general".to_string()
}

fn default_version() -> String {
    "1".to_string()
}

/// Represents a component defined in the registry.
#[derive(Debug, Clone, Deserialize)]
#[allow(dead_code)]
pub struct RegistryComponent {
    /// Unique component name identifier (e.g., 'button').
    pub name: String,
    /// Type safety, dynamic variant logic, etc.
    pub version: String,
    /// Brief description.
    #[serde(default)]
    pub description: String,
    /// Classification category (e.g. 'primitives', 'layout').
    #[serde(default = "default_category")]
    pub category: String,
    /// Apakah komponen ini merupakan internal shared utility.
    /// Jika true, file-nya akan diletakkan di `shared_dir`, bukan di subfolder komponen.
    #[serde(default)]
    pub internal: bool,
    /// Presets supported by this component.
    #[serde(rename = "supportedPresets", default)]
    pub supported_presets: Vec<String>,
    /// Names of other registry components this component depends on.
    #[serde(rename = "registryDependencies", default)]
    pub registry_dependencies: Vec<String>,
    /// External packages from pub.dev required by this component.
    #[serde(rename = "pubDependencies", default)]
    pub pub_dependencies: HashMap<String, String>,
    /// List of files that comprise this component, grouped by preset.
    #[serde(default)]
    pub files: HashMap<String, Vec<RegistryFile>>,
}

impl RegistryComponent {
    /// Mengembalikan files untuk preset yang diminta.
    /// Jika preset tidak ditemukan, fallback ke "default".
    /// Jika "default" juga tidak ada, return empty vec.
    pub fn files_for_preset<'a>(&'a self, preset: &str) -> &'a Vec<RegistryFile> {
        static EMPTY: Vec<RegistryFile> = Vec::new();
        self.files
            .get(preset)
            .or_else(|| self.files.get("default"))
            .unwrap_or(&EMPTY)
    }
}

/// Represents the top-level index file of the registry.
#[derive(Debug, Clone, Deserialize)]
#[allow(dead_code)]
pub struct RegistryIndex {
    /// Index schema version.
    #[serde(default = "default_version")]
    pub version: String,
    /// Supported presets.
    #[serde(default)]
    pub presets: Vec<String>,
    /// Registered components list.
    #[serde(default)]
    pub components: Vec<RegistryComponent>,
}

impl RegistryIndex {
}

/// Client for fetching the registry index and files from local or remote sources.
pub struct RegistryClient {
    /// Base URL or directory path.
    pub base_url: String,
}

impl RegistryClient {
    pub fn new(base_url: String) -> Self {
        Self { base_url }
    }

    fn is_remote(&self) -> bool {
        self.base_url.starts_with("http://") || self.base_url.starts_with("https://")
    }

    /// Fetches and parses the registry index.
    pub fn fetch_index(&self) -> Result<RegistryIndex> {
        let content = self.fetch_file_content("index.json")?;
        let index: RegistryIndex =
            serde_json::from_str(&content).context("Failed to parse registry index.json")?;
        Ok(index)
    }

    /// Fetches content of a registry file by its relative path.
    pub fn fetch_file_content(&self, relative_path: &str) -> Result<String> {
        if self.is_remote() {
            let clean_base = if self.base_url.ends_with('/') {
                self.base_url.clone()
            } else {
                format!("{}/", self.base_url)
            };
            let url = format!("{}{}", clean_base, relative_path);
            let response = reqwest::blocking::get(&url)
                .with_context(|| format!("Failed to fetch from registry ({})", url))?;
            if !response.status().is_success() {
                return Err(anyhow::anyhow!(
                    "Failed to fetch from registry ({}): HTTP {}",
                    url,
                    response.status().as_u16()
                ));
            }
            Ok(response.text()?)
        } else {
            // Local filesystem path
            let path = std::path::Path::new(&self.base_url).join(relative_path);
            std::fs::read_to_string(&path)
                .with_context(|| format!("Registry file not found at: {}", path.display()))
        }
    }
}
