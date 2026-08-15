use anyhow::{Context, Result};
use serde::Deserialize;
use std::collections::HashMap;

#[derive(Debug, Clone, Deserialize)]
pub struct RegistryFile {
    pub name: String,

    pub path: String,

    pub checksum: String,
}

fn default_category() -> String {
    "general".to_string()
}

fn default_version() -> String {
    "1".to_string()
}

#[derive(Debug, Clone, Deserialize)]
#[allow(dead_code)]
pub struct RegistryComponent {
    pub name: String,

    pub version: String,

    #[serde(default)]
    pub description: String,

    #[serde(default = "default_category")]
    pub category: String,

    #[serde(default)]
    pub internal: bool,

    #[serde(rename = "supportedPresets", default)]
    pub supported_presets: Vec<String>,

    #[serde(rename = "registryDependencies", default)]
    pub registry_dependencies: Vec<String>,

    #[serde(rename = "pubDependencies", default)]
    pub pub_dependencies: HashMap<String, String>,

    #[serde(default)]
    pub files: HashMap<String, Vec<RegistryFile>>,
}

impl RegistryComponent {
    pub fn files_for_preset<'a>(&'a self, preset: &str) -> &'a Vec<RegistryFile> {
        static EMPTY: Vec<RegistryFile> = Vec::new();
        self.files
            .get(preset)
            .or_else(|| self.files.get("default"))
            .unwrap_or(&EMPTY)
    }
}

#[derive(Debug, Clone, Deserialize)]
#[allow(dead_code)]
pub struct RegistryIndex {
    #[serde(default = "default_version")]
    pub version: String,

    #[serde(default)]
    pub presets: Vec<String>,

    #[serde(default)]
    pub components: Vec<RegistryComponent>,
}

impl RegistryIndex {}

pub struct RegistryClient {
    pub base_url: String,
}

impl RegistryClient {
    pub fn new(base_url: String) -> Self {
        Self { base_url }
    }

    fn is_remote(&self) -> bool {
        self.base_url.starts_with("http://") || self.base_url.starts_with("https://")
    }

    pub fn fetch_index(&self) -> Result<RegistryIndex> {
        let content = self.fetch_file_content("index.json")?;
        let index: RegistryIndex =
            serde_json::from_str(&content).context("Failed to parse registry index.json")?;
        Ok(index)
    }

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
            let path = std::path::Path::new(&self.base_url).join(relative_path);
            std::fs::read_to_string(&path)
                .with_context(|| format!("Registry file not found at: {}", path.display()))
        }
    }
}
