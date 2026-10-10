//! Typed error definitions and exit code mappings for the `JustUI` CLI.
//!
//! Invariants:
//! - Exit codes follow the table defined in `rust-cli.md`.
//! - Advice for the user is formatted via `logger::hint`, not embedded inside the error string.

use std::path::PathBuf;

/// High-level typed CLI errors corresponding to exit codes.
#[derive(Debug, thiserror::Error)]
pub enum CliError {
    /// Usage error or required interactive prompt without a TTY (exit code 2).
    #[error("usage error: {0}")]
    Usage(String),

    /// Network or registry unreachable error (exit code 3).
    #[error("network or registry unreachable: {0}")]
    Network(String),

    /// Integrity verification failure, such as checksum or signature mismatch (exit code 4).
    #[error("integrity verification failed for {target}: expected {expected}, found {actual}")]
    Integrity {
        target: String,
        expected: String,
        actual: String,
    },

    /// File conflict that the user must resolve (exit code 5).
    #[error("file conflict in {path}: {message}")]
    Conflict { path: PathBuf, message: String },

    /// Operation cancelled by the user via signal or prompt escape (exit code 130).
    #[error("operation cancelled by user")]
    Cancelled,
}

/// Typed errors when loading or parsing project configuration.
#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    /// Configuration file not found.
    #[error("configuration file '{0}' not found")]
    NotFound(String),

    /// IO error while reading or writing configuration.
    #[error("failed to read configuration file '{path}': {source}")]
    Io {
        path: String,
        source: std::io::Error,
    },

    /// YAML syntax or deserialization error.
    #[error("failed to parse configuration file '{path}': {source}")]
    Yaml {
        path: String,
        source: serde_yaml::Error,
    },

    /// Unsupported configuration version.
    #[error("unsupported config version {found}, expected <= {max_supported}")]
    UnsupportedVersion { found: u32, max_supported: u32 },
}

/// Typed errors when querying or fetching from a component registry.
#[derive(Debug, thiserror::Error)]
pub enum RegistryError {
    /// Registry host is unreachable or network is disabled.
    #[error("registry unreachable: {0}")]
    Unreachable(String),

    /// HTTP request failed.
    #[error("network request failed for {url}: {source}")]
    Http {
        url: String,
        #[source]
        source: reqwest::Error,
    },

    /// Non-2xx HTTP response from registry.
    #[error("failed to fetch from registry ({url}): HTTP {status}")]
    HttpStatus { url: String, status: u16 },

    /// Failed to parse registry index JSON.
    #[error("failed to parse registry index: {0}")]
    Json(#[from] serde_json::Error),

    /// Local registry file not found.
    #[error("registry file not found at: {0}")]
    FileNotFound(PathBuf),

    /// General IO error while reading registry file.
    #[error("io error: {0}")]
    Io(#[from] std::io::Error),

    /// Cryptographic signature verification failed.
    #[error("signature verification failed: {0}")]
    SignatureVerification(String),

    /// Checksum integrity failure.
    #[error("integrity check failed for {file}: expected {expected}, got {actual}")]
    IntegrityFailure {
        file: String,
        expected: String,
        actual: String,
    },
}

/// Maps an error to an application exit code according to the `JustUI` CLI specification:
/// - 0: success
/// - 1: other error
/// - 2: usage error / non-interactive prompt without -y
/// - 3: network or registry unreachable
/// - 4: integrity failure (checksum, signature, magic)
/// - 5: file conflict the user must resolve
/// - 130: cancelled by user
#[must_use]
pub fn exit_code_for_error(err: &anyhow::Error) -> i32 {
    if let Some(cli_err) = err.downcast_ref::<CliError>() {
        return match cli_err {
            CliError::Usage(_) => 2,
            CliError::Network(_) => 3,
            CliError::Integrity { .. } => 4,
            CliError::Conflict { .. } => 5,
            CliError::Cancelled => 130,
        };
    }

    if let Some(reg_err) = err.downcast_ref::<RegistryError>() {
        return match reg_err {
            RegistryError::Unreachable(_)
            | RegistryError::Http { .. }
            | RegistryError::HttpStatus { .. } => 3,
            RegistryError::SignatureVerification(_) | RegistryError::IntegrityFailure { .. } => 4,
            RegistryError::Json(_) | RegistryError::FileNotFound(_) | RegistryError::Io(_) => 1,
        };
    }

    // Inspect error text or causes for known categories
    let err_msg = format!("{err:#}");
    if err_msg.contains("offline")
        || err_msg.contains("unreachable")
        || err_msg.contains("Failed to fetch from registry")
        || err_msg.contains("Network requests disabled")
    {
        return 3;
    }

    if err_msg.contains("checksum")
        || err_msg.contains("integrity")
        || err_msg.contains("Signature")
        || err_msg.contains("signature")
    {
        return 4;
    }

    if err_msg.contains("Conflict") || err_msg.contains("conflict") {
        return 5;
    }

    if err_msg.contains("cancelled") || err_msg.contains("canceled") {
        return 130;
    }

    1
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_exit_code_mapping_cli_errors() {
        let err2 = anyhow::Error::new(CliError::Usage("bad usage".to_string()));
        assert_eq!(exit_code_for_error(&err2), 2);

        let err3 = anyhow::Error::new(CliError::Network("timeout".to_string()));
        assert_eq!(exit_code_for_error(&err3), 3);

        let err4 = anyhow::Error::new(CliError::Integrity {
            target: "button.dart".to_string(),
            expected: "aaa".to_string(),
            actual: "bbb".to_string(),
        });
        assert_eq!(exit_code_for_error(&err4), 4);

        let err5 = anyhow::Error::new(CliError::Conflict {
            path: PathBuf::from("foo.dart"),
            message: "modified locally".to_string(),
        });
        assert_eq!(exit_code_for_error(&err5), 5);

        let err130 = anyhow::Error::new(CliError::Cancelled);
        assert_eq!(exit_code_for_error(&err130), 130);
    }

    #[test]
    fn test_exit_code_mapping_registry_errors() {
        let err_unreachable = anyhow::Error::new(RegistryError::Unreachable("offline".to_string()));
        assert_eq!(exit_code_for_error(&err_unreachable), 3);

        let err_integrity = anyhow::Error::new(RegistryError::IntegrityFailure {
            file: "test.dart".to_string(),
            expected: "abc".to_string(),
            actual: "def".to_string(),
        });
        assert_eq!(exit_code_for_error(&err_integrity), 4);
    }

    #[test]
    fn test_exit_code_string_fallbacks() {
        let net_err = anyhow::anyhow!("Network requests disabled (JUSTUI_OFFLINE is set)");
        assert_eq!(exit_code_for_error(&net_err), 3);

        let checksum_err = anyhow::anyhow!("checksum mismatch in file");
        assert_eq!(exit_code_for_error(&checksum_err), 4);

        let generic_err = anyhow::anyhow!("some random unexpected failure");
        assert_eq!(exit_code_for_error(&generic_err), 1);
    }
}
