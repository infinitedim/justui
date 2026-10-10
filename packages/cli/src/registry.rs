#![expect(clippy::missing_errors_doc, reason = "legacy: fix when touched")]

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
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

#[derive(Debug, Clone, Serialize, Deserialize)]
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

    /// Directory (relative to the project root) where this component's files are installed.
    ///
    /// Token/core kernel components go to `tokens_dir`, internal shared components are
    /// placed flat inside `shared_dir`, and every other component gets its own folder
    /// under `components_dir`.
    pub fn install_dir(&self, components_dir: &str, tokens_dir: &str, shared_dir: &str) -> String {
        if self.category == "tokens" || self.category == "core" {
            tokens_dir.to_string()
        } else if self.internal {
            shared_dir.to_string()
        } else {
            format!("{}/{}", components_dir, self.name)
        }
    }

    /// Local file name for one of this component's registry files. Internal shared files
    /// have their `_shared_` prefix rewritten to `just_`.
    pub fn local_file_name(&self, file_name: &str) -> String {
        if self.internal {
            crate::utils::import_rewriter::normalize_shared_file_name(file_name)
        } else {
            file_name.to_string()
        }
    }
}

#[derive(Debug, Clone, Deserialize)]
pub struct RegistryIndex {
    #[serde(default = "default_version")]
    pub version: String,

    #[serde(default)]
    pub presets: Vec<String>,

    #[serde(default)]
    pub components: Vec<RegistryComponent>,
}

/// Environment variable that overrides the registry request timeout, in whole seconds.
pub const REGISTRY_TIMEOUT_ENV: &str = "JUSTUI_HTTP_TIMEOUT";

const DEFAULT_REGISTRY_TIMEOUT_SECS: u64 = 15;

/// Resolves the total request timeout for registry fetches.
///
/// A positive integer in `JUSTUI_HTTP_TIMEOUT` wins; anything else (unset, empty,
/// zero or not a number) falls back to the default, which is generous enough for
/// slow or high-latency connections.
pub fn registry_timeout(env_value: Option<&str>) -> std::time::Duration {
    let secs = env_value
        .and_then(|raw| raw.trim().parse::<u64>().ok())
        .filter(|secs| *secs > 0)
        .unwrap_or(DEFAULT_REGISTRY_TIMEOUT_SECS);
    std::time::Duration::from_secs(secs)
}

#[derive(Debug, Clone)]
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

    pub async fn fetch_index_async(&self) -> Result<RegistryIndex> {
        if !crate::utils::crypto::is_official_registry(&self.base_url) {
            crate::utils::logger::warning(&format!(
                "Using non-default registry URL: {}. Ensure this source is trusted.",
                self.base_url
            ));
        }

        let content = self.fetch_file_content_async("index.json").await?;

        match self.fetch_file_content_async("index.json.sig").await {
            Ok(sig_str) => {
                crate::utils::crypto::verify_signature(
                    content.as_bytes(),
                    &sig_str,
                    crate::utils::crypto::JUSTUI_REGISTRY_PUBKEY,
                )?;
            }
            Err(err) => {
                if self.is_remote() && crate::utils::crypto::is_official_registry(&self.base_url) {
                    return Err(anyhow::anyhow!(
                        "Official registry is missing cryptographic signature (index.json.sig): {err}"
                    ));
                }
            }
        }

        let index: RegistryIndex =
            serde_json::from_str(&content).context("Failed to parse registry index.json")?;
        Ok(index)
    }

    pub fn fetch_index(&self) -> Result<RegistryIndex> {
        if !self.is_remote() {
            let path = std::path::Path::new(&self.base_url).join("index.json");
            let content = std::fs::read_to_string(&path)
                .with_context(|| format!("Registry file not found at: {}", path.display()))?;
            let sig_path = std::path::Path::new(&self.base_url).join("index.json.sig");
            if let Ok(sig_str) = std::fs::read_to_string(&sig_path) {
                crate::utils::crypto::verify_signature(
                    content.as_bytes(),
                    &sig_str,
                    crate::utils::crypto::JUSTUI_REGISTRY_PUBKEY,
                )?;
            }
            let index: RegistryIndex =
                serde_json::from_str(&content).context("Failed to parse registry index.json")?;
            return Ok(index);
        }
        if let Ok(handle) = tokio::runtime::Handle::try_current() {
            if handle.runtime_flavor() == tokio::runtime::RuntimeFlavor::MultiThread {
                tokio::task::block_in_place(|| handle.block_on(self.fetch_index_async()))
            } else {
                std::thread::scope(|s| {
                    s.spawn(|| {
                        tokio::runtime::Builder::new_current_thread()
                            .enable_all()
                            .build()
                            .map_err(|e| anyhow::anyhow!("{e}"))?
                            .block_on(self.fetch_index_async())
                    })
                    .join()
                    .unwrap_or_else(|_| Err(anyhow::anyhow!("Worker thread panicked")))
                })
            }
        } else {
            tokio::runtime::Runtime::new()?.block_on(self.fetch_index_async())
        }
    }

    pub fn fetch_index_blocking(&self) -> Result<RegistryIndex> {
        self.fetch_index()
    }

    pub async fn fetch_file_content_async(&self, relative_path: &str) -> Result<String> {
        if self.is_remote() {
            #[cfg(test)]
            if std::env::var("JUSTUI_ALLOW_NET_TESTS").is_err() {
                return Err(anyhow::anyhow!("Network requests disabled in test mode"));
            }
            if std::env::var("JUSTUI_OFFLINE").is_ok() {
                return Err(anyhow::anyhow!(
                    "Network requests disabled (JUSTUI_OFFLINE is set)"
                ));
            }

            let clean_base = if self.base_url.ends_with('/') {
                self.base_url.clone()
            } else {
                format!("{}/", self.base_url)
            };
            let url = format!("{clean_base}{relative_path}");

            let client = crate::utils::http_client::make_client()?;
            match crate::utils::http_client::get_with_retry_text(&client, &url).await {
                Ok(text) => Ok(text),
                Err(e) => {
                    let tag_pattern = format!("/v{}/", env!("CARGO_PKG_VERSION"));
                    if url.contains(&tag_pattern) {
                        let fallback_url = url.replace(&tag_pattern, "/main/");
                        if let Ok(fallback_text) =
                            crate::utils::http_client::get_with_retry_text(&client, &fallback_url)
                                .await
                        {
                            return Ok(fallback_text);
                        }
                    }
                    Err(anyhow::anyhow!(
                        "Failed to fetch from registry ({url}): {e}"
                    ))
                }
            }
        } else {
            let path = std::path::Path::new(&self.base_url).join(relative_path);
            tokio::fs::read_to_string(&path)
                .await
                .with_context(|| format!("Registry file not found at: {}", path.display()))
        }
    }

    pub fn fetch_file_content(&self, relative_path: &str) -> Result<String> {
        if !self.is_remote() {
            let path = std::path::Path::new(&self.base_url).join(relative_path);
            return std::fs::read_to_string(&path)
                .with_context(|| format!("Registry file not found at: {}", path.display()));
        }
        if let Ok(handle) = tokio::runtime::Handle::try_current() {
            if handle.runtime_flavor() == tokio::runtime::RuntimeFlavor::MultiThread {
                tokio::task::block_in_place(|| {
                    handle.block_on(self.fetch_file_content_async(relative_path))
                })
            } else {
                std::thread::scope(|s| {
                    s.spawn(|| {
                        tokio::runtime::Builder::new_current_thread()
                            .enable_all()
                            .build()
                            .map_err(|e| anyhow::anyhow!("{e}"))?
                            .block_on(self.fetch_file_content_async(relative_path))
                    })
                    .join()
                    .unwrap_or_else(|_| Err(anyhow::anyhow!("Worker thread panicked")))
                })
            }
        } else {
            tokio::runtime::Runtime::new()?.block_on(self.fetch_file_content_async(relative_path))
        }
    }

    pub fn fetch_file_content_blocking(&self, relative_path: &str) -> Result<String> {
        self.fetch_file_content(relative_path)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[tokio::test]
    async fn test_registry_client_local_and_remote() {
        let remote_client = RegistryClient::new("https://example.com/registry".to_string());
        assert!(remote_client.is_remote());

        let remote_client_slash = RegistryClient::new("http://example.com/registry/".to_string());
        assert!(remote_client_slash.is_remote());

        let local_dir = tempdir().unwrap();
        let local_client = RegistryClient::new(local_dir.path().to_string_lossy().to_string());
        assert!(!local_client.is_remote());

        // Local non-existent file
        assert!(
            local_client
                .fetch_file_content_async("nonexistent.json")
                .await
                .is_err()
        );
        assert!(local_client.fetch_index_async().await.is_err());
        assert!(local_client.fetch_file_content("nonexistent.json").is_err());
        assert!(local_client.fetch_index().is_err());

        // Local valid file
        let index_path = local_dir.path().join("index.json");
        std::fs::write(
            &index_path,
            r#"{"version": "1.0", "presets": ["default"], "components": []}"#,
        )
        .unwrap();

        let index = local_client.fetch_index_async().await.unwrap();
        assert_eq!(index.version, "1.0");
        assert_eq!(index.presets, vec!["default"]);
        let index_sync = local_client.fetch_index().unwrap();
        assert_eq!(index_sync.version, "1.0");
    }

    #[test]
    fn test_registry_timeout_env_override() {
        use std::time::Duration;
        assert_eq!(registry_timeout(None), Duration::from_secs(15));
        assert_eq!(registry_timeout(Some("")), Duration::from_secs(15));
        assert_eq!(registry_timeout(Some("abc")), Duration::from_secs(15));
        assert_eq!(registry_timeout(Some("0")), Duration::from_secs(15));
        assert_eq!(registry_timeout(Some("-5")), Duration::from_secs(15));
        assert_eq!(registry_timeout(Some(" 42 ")), Duration::from_secs(42));
    }

    #[test]
    fn test_files_for_preset_fallback() {
        let comp = RegistryComponent {
            name: "test".to_string(),
            version: "1.0".to_string(),
            description: String::new(),
            category: "general".to_string(),
            internal: false,
            supported_presets: vec![],
            registry_dependencies: vec![],
            pub_dependencies: HashMap::new(),
            files: HashMap::new(),
        };
        assert!(comp.files_for_preset("unknown_preset").is_empty());
    }

    #[tokio::test]
    async fn test_registry_signature_verification_success_and_tampered() {
        let dir = tempdir().unwrap();
        let client = RegistryClient::new(dir.path().to_string_lossy().to_string());
        let index_path = dir.path().join("index.json");
        let sig_path = dir.path().join("index.json.sig");

        let content = r#"{"version": "1.0", "presets": ["default"], "components": []}"#;
        std::fs::write(&index_path, content).unwrap();

        let keypair = crate::utils::crypto::official_keypair();
        let sig = crate::utils::crypto::sign_content(content.as_bytes(), &keypair);
        std::fs::write(&sig_path, &sig).unwrap();

        // Valid signature verifies cleanly
        let fetched = client.fetch_index_async().await;
        assert!(fetched.is_ok());

        // Tampering with content causes signature verification to fail
        let tampered_content =
            r#"{"version": "1.0", "presets": ["default"], "components": [{"name": "evil"}]}"#;
        std::fs::write(&index_path, tampered_content).unwrap();
        let fail_res = client.fetch_index_async().await;
        assert!(fail_res.is_err());
        let err = fail_res.unwrap_err().to_string();
        assert!(err.contains("tampered with"));

        // Malformed signature hex fails
        std::fs::write(&sig_path, "not-a-valid-hex-signature").unwrap();
        let bad_hex_res = client.fetch_index_async().await;
        assert!(bad_hex_res.is_err());
        assert!(bad_hex_res.unwrap_err().to_string().contains("Invalid hex"));
    }
}
