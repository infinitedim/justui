//! Per-user trusted registry storage and verification.
//!
//! # Invariants
//! - Official registries (matching `is_official_registry`) are inherently trusted.
//! - Non-default registries require explicit user trust recorded in user-level storage.
//! - Non-TTY runs require `--trust-registry` to authorize untrusted custom registries.

use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::sync::atomic::{AtomicBool, Ordering};

static TRUST_REGISTRY_FLAG: AtomicBool = AtomicBool::new(false);

#[cfg(test)]
static TEST_CONFIG_DIR: std::sync::Mutex<Option<PathBuf>> = std::sync::Mutex::new(None);

#[cfg(test)]
pub fn set_test_config_dir(dir: Option<PathBuf>) {
    let mut lock = TEST_CONFIG_DIR
        .lock()
        .unwrap_or_else(std::sync::PoisonError::into_inner);
    *lock = dir;
}

#[cfg(test)]
pub struct TestTrustGuard {
    prev: bool,
}

#[cfg(test)]
impl TestTrustGuard {
    #[must_use]
    pub fn new() -> Self {
        let prev = TRUST_REGISTRY_FLAG.swap(true, Ordering::SeqCst);
        Self { prev }
    }
}

#[cfg(test)]
impl Default for TestTrustGuard {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
impl Drop for TestTrustGuard {
    fn drop(&mut self) {
        TRUST_REGISTRY_FLAG.store(self.prev, Ordering::SeqCst);
    }
}

/// Sets the global `--trust-registry` CLI flag state.
pub fn set_trust_registry_flag(val: bool) {
    TRUST_REGISTRY_FLAG.store(val, Ordering::Relaxed);
}

/// Retrieves the current `--trust-registry` flag state or env override.
#[must_use]
pub fn get_trust_registry_flag() -> bool {
    TRUST_REGISTRY_FLAG.load(Ordering::Relaxed)
        || std::env::var("JUSTUI_TRUST_REGISTRY").is_ok_and(|v| v == "1" || v == "true")
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TrustStore {
    #[serde(default = "default_version")]
    pub version: u32,
    #[serde(default)]
    pub trusted_registries: Vec<String>,
}

fn default_version() -> u32 {
    1
}

impl Default for TrustStore {
    fn default() -> Self {
        Self {
            version: 1,
            trusted_registries: Vec::new(),
        }
    }
}

impl TrustStore {
    /// Resolves platform-specific user configuration directory.
    #[must_use]
    pub fn config_dir() -> PathBuf {
        #[cfg(test)]
        if let Some(ref custom) = *TEST_CONFIG_DIR
            .lock()
            .unwrap_or_else(std::sync::PoisonError::into_inner)
        {
            return custom.clone();
        }

        if let Ok(custom) = std::env::var("JUSTUI_CONFIG_DIR")
            && !custom.trim().is_empty()
        {
            return PathBuf::from(custom.trim());
        }

        #[cfg(target_os = "windows")]
        {
            if let Ok(appdata) = std::env::var("APPDATA") {
                return PathBuf::from(appdata).join("justui");
            }
            if let Ok(userprofile) = std::env::var("USERPROFILE") {
                return PathBuf::from(userprofile).join(".justui");
            }
        }

        #[cfg(not(target_os = "windows"))]
        {
            if let Ok(xdg) = std::env::var("XDG_CONFIG_HOME")
                && !xdg.trim().is_empty()
            {
                return PathBuf::from(xdg.trim()).join("justui");
            }
            if let Ok(home) = std::env::var("HOME")
                && !home.trim().is_empty()
            {
                return PathBuf::from(home).join(".config").join("justui");
            }
        }

        std::env::temp_dir().join(".justui")
    }

    /// Path to `trusted_registries.json`.
    #[must_use]
    pub fn trust_store_path() -> PathBuf {
        Self::config_dir().join("trusted_registries.json")
    }

    /// Loads the trust store from disk.
    #[must_use]
    pub fn load() -> Self {
        let path = Self::trust_store_path();
        if !path.exists() {
            return Self::default();
        }
        std::fs::read_to_string(&path)
            .ok()
            .and_then(|content| serde_json::from_str(&content).ok())
            .unwrap_or_default()
    }

    /// Saves the trust store to disk atomically.
    ///
    /// # Errors
    /// Returns error if saving fails.
    pub fn save(&self) -> Result<()> {
        let path = Self::trust_store_path();
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        let json = serde_json::to_string_pretty(self)?;
        crate::utils::path_guard::atomic_write(&path, json)?;
        Ok(())
    }

    /// Checks if a registry URL is in the trusted registries list.
    #[must_use]
    pub fn is_trusted(&self, url: &str) -> bool {
        let trimmed = url.trim().trim_end_matches('/');
        self.trusted_registries
            .iter()
            .any(|r| r.trim().trim_end_matches('/') == trimmed)
    }

    /// Adds a registry URL to the trust store.
    ///
    /// # Errors
    /// Returns error if persistence fails.
    pub fn add_trust(&mut self, url: &str) -> Result<()> {
        let trimmed = url.trim().trim_end_matches('/').to_string();
        if !self.is_trusted(&trimmed) {
            self.trusted_registries.push(trimmed);
            self.save()?;
        }
        Ok(())
    }
}

/// Checks whether a registry URL is currently trusted.
#[must_use]
pub fn is_registry_trusted(registry_url: &str) -> bool {
    if crate::utils::crypto::is_official_registry(registry_url)
        || registry_url == crate::config::JustUIConfig::DEFAULT_REGISTRY_URL
    {
        return true;
    }
    TrustStore::load().is_trusted(registry_url)
}

/// Ensures that a registry URL is trusted before performing operations.
///
/// Prompts in interactive environments, accepts `--trust-registry`,
/// and fails with exit code 2 in non-TTY mode.
///
/// # Errors
/// Returns error if untrusted or user cancels.
pub fn ensure_registry_trusted(registry_url: &str, trust_flag: bool) -> Result<()> {
    if crate::utils::crypto::is_official_registry(registry_url)
        || registry_url == crate::config::JustUIConfig::DEFAULT_REGISTRY_URL
    {
        return Ok(());
    }

    crate::utils::http_client::validate_url(registry_url)?;

    let mut store = TrustStore::load();
    if store.is_trusted(registry_url) {
        return Ok(());
    }

    if trust_flag || get_trust_registry_flag() {
        store.add_trust(registry_url)?;
        crate::utils::logger::info(&format!(
            "Added \"{registry_url}\" to trusted registries store."
        ));
        return Ok(());
    }

    if !crate::utils::prompt::is_interactive() {
        crate::utils::logger::hint(
            "pass --trust-registry to trust this custom registry non-interactively",
        );
        return Err(anyhow::Error::new(crate::errors::CliError::Usage(format!(
            "custom registry \"{registry_url}\" is untrusted and requires confirmation"
        ))));
    }

    crate::utils::logger::warning(&format!(
        "Custom component registry detected: {registry_url}\n\
         Custom registries can distribute code that runs in your project."
    ));

    let proceed =
        crate::utils::prompt::confirm(&format!("Do you trust registry \"{registry_url}\"?"), false);

    if proceed {
        store.add_trust(registry_url)?;
        crate::utils::logger::success(&format!("Trusted registry \"{registry_url}\"."));
        Ok(())
    } else {
        anyhow::bail!("custom registry \"{registry_url}\" was not trusted: operation cancelled");
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_trust_store_lifecycle() {
        let _lock = crate::utils::lock_test_mutex();
        let temp_dir = tempfile::tempdir().unwrap();
        set_test_config_dir(Some(temp_dir.path().to_path_buf()));

        let mut store = TrustStore::load();
        assert!(!store.is_trusted("https://custom.example.com"));

        store.add_trust("https://custom.example.com").unwrap();
        assert!(store.is_trusted("https://custom.example.com"));
        assert!(store.is_trusted("https://custom.example.com/"));

        let reloaded = TrustStore::load();
        assert!(reloaded.is_trusted("https://custom.example.com"));

        set_test_config_dir(None);
    }

    #[test]
    fn test_ensure_registry_trusted_official() {
        assert!(
            ensure_registry_trusted(
                "https://raw.githubusercontent.com/infinitedim/justui/v0.15.0/registry",
                false
            )
            .is_ok()
        );
    }

    #[test]
    fn test_ensure_registry_trusted_non_interactive_fails() {
        let _lock = crate::utils::lock_test_mutex();
        set_trust_registry_flag(false);
        let temp_dir = tempfile::tempdir().unwrap();
        set_test_config_dir(Some(temp_dir.path().to_path_buf()));

        let res = ensure_registry_trusted("https://untrusted.registry.io", false);
        assert!(res.is_err());
        assert!(
            res.unwrap_err()
                .downcast_ref::<crate::errors::CliError>()
                .is_some()
        );

        let res_trusted = ensure_registry_trusted("https://untrusted.registry.io", true);
        assert!(res_trusted.is_ok());

        set_test_config_dir(None);
    }
}
