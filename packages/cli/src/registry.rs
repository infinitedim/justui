use anyhow::{Context, Result};
use serde::Deserialize;
use std::collections::HashMap;

#[derive(Debug, Clone, Deserialize)]
pub struct RegistryFile {
    pub name: String,

    pub path: String,

    pub checksum: String,
}

#[allow(dead_code)]
fn default_category() -> String {
    "general".to_string()
}

#[allow(dead_code)]
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
    pub fn files_for_preset(&self, preset: &str) -> Vec<RegistryFile> {
        let mut result = Vec::new();
        if let Some(common_files) = self.files.get("common") {
            result.extend(common_files.clone());
        }
        if let Some(preset_files) = self.files.get(preset).or_else(|| self.files.get("default")) {
            result.extend(preset_files.clone());
        }
        result
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

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_registry_client_local_and_remote() {
        let remote_client = RegistryClient::new("https://example.com/registry".to_string());
        assert!(remote_client.is_remote());

        let remote_client_slash = RegistryClient::new("http://example.com/registry/".to_string());
        assert!(remote_client_slash.is_remote());

        let local_dir = tempdir().unwrap();
        let local_client = RegistryClient::new(local_dir.path().to_string_lossy().to_string());
        assert!(!local_client.is_remote());

        // Local non-existent file
        assert!(local_client.fetch_file_content("nonexistent.json").is_err());
        assert!(local_client.fetch_index().is_err());

        // Local valid file
        let index_path = local_dir.path().join("index.json");
        std::fs::write(
            &index_path,
            r#"{"version": "1.0", "presets": ["default"], "components": []}"#,
        )
        .unwrap();

        let index = local_client.fetch_index().unwrap();
        assert_eq!(index.version, "1.0");
        assert_eq!(index.presets, vec!["default"]);
    }

    #[test]
    fn test_files_for_preset_fallback() {
        let comp = RegistryComponent {
            name: "test".to_string(),
            version: "1.0".to_string(),
            description: "".to_string(),
            category: "general".to_string(),
            internal: false,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: HashMap::new(),
        };
        assert!(comp.files_for_preset("unknown_preset").is_empty());
    }
}
