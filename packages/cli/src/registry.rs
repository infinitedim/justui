#![expect(clippy::missing_errors_doc, reason = "legacy: fix when touched")]

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};
use std::sync::LazyLock;

/// Maximum allowable download or read size for a single registry response (10MB).
pub const MAX_RESPONSE_BYTES: usize = 10 * 1024 * 1024;

static COMPONENT_NAME_REGEX: LazyLock<regex::Regex> = LazyLock::new(|| {
    regex::Regex::new(r"^_?[a-z][a-z0-9_-]*$").expect("invariant: component name regex is valid")
});

static FILE_NAME_REGEX: LazyLock<regex::Regex> = LazyLock::new(|| {
    regex::Regex::new(r"^[a-z0-9_]+\.dart$").expect("invariant: file name regex is valid")
});

/// Validates component name format (`^_?[a-z][a-z0-9_-]*$`).
///
/// # Errors
/// Returns error if format does not match.
pub fn validate_component_name(name: &str) -> Result<()> {
    if !COMPONENT_NAME_REGEX.is_match(name) {
        anyhow::bail!("invalid component name '{name}': must match ^_?[a-z][a-z0-9_-]*$");
    }
    Ok(())
}

/// Validates file name format (`^[a-z0-9_]+\.dart$`).
///
/// # Errors
/// Returns error if format does not match.
pub fn validate_file_name(name: &str) -> Result<()> {
    if !FILE_NAME_REGEX.is_match(name) {
        anyhow::bail!("invalid file name '{name}': must match ^[a-z0-9_]+\\.dart$");
    }
    Ok(())
}

/// Validates relative registry paths (no leading `/`, backslashes, colons, or `..` segments).
///
/// # Errors
/// Returns error if path escapes relative boundaries or contains invalid characters.
pub fn validate_registry_path(path: &str) -> Result<()> {
    if path.is_empty() {
        anyhow::bail!("registry path cannot be empty");
    }
    if path.starts_with('/') {
        anyhow::bail!("registry path '{path}' cannot start with leading '/'");
    }
    if path.contains('\\') {
        anyhow::bail!("registry path '{path}' cannot contain backslashes");
    }
    if path.contains(':') {
        anyhow::bail!("registry path '{path}' cannot contain colons or URL schemes");
    }
    for segment in path.split('/') {
        if segment == ".." {
            anyhow::bail!("registry path '{path}' cannot contain '..' segments");
        }
    }
    Ok(())
}

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
    #[serde(default = "default_version")]
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
            format!("{components_dir}/{}", self.name)
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

impl RegistryIndex {
    /// Validates the entire index structure against security rules.
    ///
    /// # Errors
    /// Returns error if any component name, file name, path, or dependency is invalid.
    pub fn validate(&self) -> Result<()> {
        let component_names: HashSet<&str> =
            self.components.iter().map(|c| c.name.as_str()).collect();

        for comp in &self.components {
            validate_component_name(&comp.name)?;

            for file_list in comp.files.values() {
                for file in file_list {
                    validate_file_name(&file.name)?;
                    validate_registry_path(&file.path)?;
                }
            }

            for dep in &comp.registry_dependencies {
                validate_component_name(dep)?;
                if !component_names.contains(dep.as_str()) {
                    anyhow::bail!(
                        "component '{}' references unknown registryDependency '{}'",
                        comp.name,
                        dep
                    );
                }
            }

            for (pub_dep, constraint) in &comp.pub_dependencies {
                crate::utils::pubspec_editor::validate_pub_dependency(pub_dep, constraint)?;
            }
        }
        Ok(())
    }
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
        index.validate()?;
        Ok(index)
    }

    pub fn fetch_index(&self) -> Result<RegistryIndex> {
        if !self.is_remote() {
            validate_registry_path("index.json")?;
            let path = std::path::Path::new(&self.base_url).join("index.json");
            let metadata = std::fs::metadata(&path)
                .with_context(|| format!("Registry file not found at: {}", path.display()))?;
            if metadata.len() > MAX_RESPONSE_BYTES as u64 {
                anyhow::bail!(
                    "registry index size exceeded 10MB limit: {} bytes",
                    metadata.len()
                );
            }
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
            index.validate()?;
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
        validate_registry_path(relative_path)?;

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
            match self.fetch_http_capped(&client, &url).await {
                Ok(text) => Ok(text),
                Err(e) => {
                    let tag_pattern = format!("/v{}/", env!("CARGO_PKG_VERSION"));
                    if url.contains(&tag_pattern) {
                        let fallback_url = url.replace(&tag_pattern, "/main/");
                        if let Ok(fallback_text) =
                            self.fetch_http_capped(&client, &fallback_url).await
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
            let metadata = tokio::fs::metadata(&path)
                .await
                .with_context(|| format!("Registry file not found at: {}", path.display()))?;
            if metadata.len() > MAX_RESPONSE_BYTES as u64 {
                anyhow::bail!(
                    "registry file size exceeded 10MB limit: {} bytes",
                    metadata.len()
                );
            }
            tokio::fs::read_to_string(&path)
                .await
                .with_context(|| format!("Registry file not found at: {}", path.display()))
        }
    }

    async fn fetch_http_capped(&self, client: &reqwest::Client, url: &str) -> Result<String> {
        let mut resp = crate::utils::http_client::get_with_retry(client, url).await?;
        if let Some(len) = resp.content_length()
            && len > MAX_RESPONSE_BYTES as u64
        {
            anyhow::bail!("response size exceeded 10MB limit: {len} bytes for {url}");
        }

        let mut bytes = Vec::new();
        while let Some(chunk) = resp.chunk().await? {
            if bytes.len() + chunk.len() > MAX_RESPONSE_BYTES {
                anyhow::bail!("response size exceeded 10MB limit during download for {url}");
            }
            bytes.extend_from_slice(&chunk);
        }

        String::from_utf8(bytes).context("registry response is not valid UTF-8")
    }

    pub fn fetch_file_content(&self, relative_path: &str) -> Result<String> {
        validate_registry_path(relative_path)?;
        if !self.is_remote() {
            let path = std::path::Path::new(&self.base_url).join(relative_path);
            let metadata = std::fs::metadata(&path)
                .with_context(|| format!("Registry file not found at: {}", path.display()))?;
            if metadata.len() > MAX_RESPONSE_BYTES as u64 {
                anyhow::bail!(
                    "registry file size exceeded 10MB limit: {} bytes",
                    metadata.len()
                );
            }
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

    #[test]
    fn test_input_validation_rules() {
        // Component name validation
        assert!(validate_component_name("button").is_ok());
        assert!(validate_component_name("_shared_pressable").is_ok());
        assert!(validate_component_name("icon-button").is_ok());
        assert!(validate_component_name("theme_data_material").is_ok());

        assert!(validate_component_name("").is_err());
        assert!(validate_component_name("../evil").is_err());
        assert!(validate_component_name("Button").is_err());
        assert!(validate_component_name("123bad").is_err());
        assert!(validate_component_name("button/nested").is_err());

        // File name validation
        assert!(validate_file_name("button.dart").is_ok());
        assert!(validate_file_name("just_button.dart").is_ok());
        assert!(validate_file_name("_shared_pressable.dart").is_ok());

        assert!(validate_file_name("button.js").is_err());
        assert!(validate_file_name("Button.dart").is_err());
        assert!(validate_file_name("../button.dart").is_err());
        assert!(validate_file_name("button/sub.dart").is_err());

        // Registry path validation
        assert!(validate_registry_path("index.json").is_ok());
        assert!(validate_registry_path("components/button/just_button.dart").is_ok());

        assert!(validate_registry_path("").is_err());
        assert!(validate_registry_path("/components/button.dart").is_err());
        assert!(validate_registry_path("components/../button.dart").is_err());
        assert!(validate_registry_path("components\\button.dart").is_err());
        assert!(validate_registry_path("https://evil.com/button.dart").is_err());
    }

    #[test]
    fn test_registry_index_validate() {
        let valid_json = r#"{
            "version": "1.0",
            "components": [
                {
                    "name": "_shared_dep",
                    "version": "1.0.0",
                    "files": {
                        "default": [
                            {
                                "name": "dep.dart",
                                "path": "shared/dep.dart",
                                "checksum": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
                            }
                        ]
                    }
                },
                {
                    "name": "comp",
                    "version": "1.0.0",
                    "registryDependencies": ["_shared_dep"],
                    "pubDependencies": {
                        "http": "^1.0.0"
                    },
                    "files": {
                        "default": [
                            {
                                "name": "comp.dart",
                                "path": "comp/comp.dart",
                                "checksum": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
                            }
                        ]
                    }
                }
            ]
        }"#;
        let index: RegistryIndex = serde_json::from_str(valid_json).unwrap();
        assert!(index.validate().is_ok());

        // Unknown dependency
        let unknown_dep_json = r#"{
            "version": "1.0",
            "components": [
                {
                    "name": "comp",
                    "version": "1.0.0",
                    "registryDependencies": ["non_existent"]
                }
            ]
        }"#;
        let bad_index: RegistryIndex = serde_json::from_str(unknown_dep_json).unwrap();
        assert!(bad_index.validate().is_err());

        // Hostile component name
        let hostile_name_json = r#"{
            "version": "1.0",
            "components": [
                {
                    "name": "../hostile",
                    "version": "1.0.0"
                }
            ]
        }"#;
        let hostile_index: RegistryIndex = serde_json::from_str(hostile_name_json).unwrap();
        assert!(hostile_index.validate().is_err());
    }
}
