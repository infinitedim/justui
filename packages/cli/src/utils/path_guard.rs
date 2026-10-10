//! Path safety, domain types, and atomic persistence guards.
//!
//! # Invariants
//! - `ProjectRelPath` never escapes the project root (`..` segments cannot escape).
//! - `safe_join` normalizes paths lexically and rejects symlinks anywhere in the path.
//! - `atomic_write` writes through a temporary file in the destination directory and persists atomically.

use std::fmt;
use std::io::Write;
use std::path::{Component, Path, PathBuf};
use tempfile::NamedTempFile;
use thiserror::Error;

/// Errors arising from path guard and atomic persistence operations.
#[derive(Debug, Error)]
pub enum PathGuardError {
    /// Attempted path escape via `..` or absolute path.
    #[error("path escapes project root: {0}")]
    PathEscape(String),

    /// Symlinks are strictly forbidden in target paths.
    #[error("symlink detected in path: {0}")]
    SymlinkForbidden(String),

    /// The relative path is empty or invalid.
    #[error("invalid relative path: {0}")]
    InvalidPath(String),

    /// Invalid sha256 hex string.
    #[error("invalid sha256 checksum: {0}")]
    InvalidHash(String),

    /// Underlying IO error.
    #[error("io error on {path}: {source}")]
    Io {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },
}

/// A validated relative path guaranteed to stay inside a project root.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct ProjectRelPath(PathBuf);

impl ProjectRelPath {
    /// Constructs and validates a `ProjectRelPath`.
    ///
    /// # Errors
    /// Returns `PathGuardError::PathEscape` or `PathGuardError::InvalidPath` if the path
    /// is absolute or escapes via `..`.
    pub fn new(path: impl AsRef<Path>) -> Result<Self, PathGuardError> {
        let path = path.as_ref();
        if path.is_absolute() {
            return Err(PathGuardError::PathEscape(path.display().to_string()));
        }

        let mut depth: usize = 0;
        let mut normalized = PathBuf::new();

        for comp in path.components() {
            match comp {
                Component::Normal(c) => {
                    depth += 1;
                    normalized.push(c);
                }
                Component::CurDir => {}
                Component::ParentDir => {
                    if depth == 0 {
                        return Err(PathGuardError::PathEscape(path.display().to_string()));
                    }
                    depth -= 1;
                    normalized.pop();
                }
                Component::RootDir | Component::Prefix(_) => {
                    return Err(PathGuardError::PathEscape(path.display().to_string()));
                }
            }
        }

        if normalized.as_os_str().is_empty() {
            return Err(PathGuardError::InvalidPath("empty path".to_string()));
        }

        Ok(Self(normalized))
    }

    /// Constructs a `ProjectRelPath` from a path that may be absolute if it resides within `root`.
    ///
    /// # Errors
    /// Returns `PathGuardError::PathEscape` if the path falls outside `root` or escapes via `..`.
    pub fn from_project_root(
        root: impl AsRef<Path>,
        path: impl AsRef<Path>,
    ) -> Result<Self, PathGuardError> {
        let root = root.as_ref();
        let path = path.as_ref();
        let rel = if path.is_absolute() {
            path.strip_prefix(root)
                .map_err(|_| PathGuardError::PathEscape(path.display().to_string()))?
        } else {
            path
        };
        Self::new(rel)
    }

    /// Returns the underlying normalized `Path`.
    #[must_use]
    pub fn as_path(&self) -> &Path {
        &self.0
    }
}

impl AsRef<Path> for ProjectRelPath {
    fn as_ref(&self) -> &Path {
        &self.0
    }
}

impl fmt::Display for ProjectRelPath {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0.display())
    }
}

/// A validated 64-character lowercase SHA-256 hex string.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Sha256Hex(String);

impl Sha256Hex {
    /// Validates and constructs a `Sha256Hex`.
    ///
    /// # Errors
    /// Returns `PathGuardError::InvalidHash` if not 64 valid hex characters.
    pub fn new(s: &str) -> Result<Self, PathGuardError> {
        let clean = s.trim().to_ascii_lowercase();
        if clean.len() != 64 || !clean.chars().all(|c| c.is_ascii_hexdigit()) {
            return Err(PathGuardError::InvalidHash(s.to_string()));
        }
        Ok(Self(clean))
    }

    /// Computes the SHA-256 hash of bytes and returns a `Sha256Hex`.
    #[must_use]
    pub fn from_bytes(data: &[u8]) -> Self {
        use sha2::{Digest, Sha256};
        let mut hasher = Sha256::new();
        hasher.update(data);
        Self(hex::encode(hasher.finalize()))
    }

    /// Returns the hash string slice.
    #[must_use]
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl AsRef<str> for Sha256Hex {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl fmt::Display for Sha256Hex {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

/// Safely joins a root path with a validated `ProjectRelPath`.
///
/// Ensures lexical normalization, rejects escaping root, and rejects symlinks in any existing path segments.
///
/// # Errors
/// Returns `PathGuardError::SymlinkForbidden` if symlinks are detected, or `PathGuardError::Io` on metadata failure.
pub fn safe_join(root: &Path, rel: &ProjectRelPath) -> Result<PathBuf, PathGuardError> {
    let mut current = root.to_path_buf();

    for component in rel.as_path().components() {
        if let Component::Normal(seg) = component {
            current.push(seg);
            if current.is_symlink() {
                return Err(PathGuardError::SymlinkForbidden(
                    current.display().to_string(),
                ));
            }
        }
    }

    Ok(current)
}

/// Atomically writes content to a destination file.
///
/// Writes through a `NamedTempFile` created in the destination's parent directory,
/// flushes to disk, and atomically persists it to `dest`.
///
/// # Errors
/// Returns `PathGuardError::Io` if temporary file creation, write, flush, or persistence fails.
pub fn atomic_write(dest: &Path, content: impl AsRef<[u8]>) -> Result<(), PathGuardError> {
    let parent = dest.parent().unwrap_or_else(|| Path::new("."));
    if !parent.exists() {
        std::fs::create_dir_all(parent).map_err(|source| PathGuardError::Io {
            path: parent.to_path_buf(),
            source,
        })?;
    }

    let mut temp = NamedTempFile::new_in(parent).map_err(|source| PathGuardError::Io {
        path: parent.to_path_buf(),
        source,
    })?;

    temp.write_all(content.as_ref())
        .map_err(|source| PathGuardError::Io {
            path: temp.path().to_path_buf(),
            source,
        })?;

    temp.flush().map_err(|source| PathGuardError::Io {
        path: temp.path().to_path_buf(),
        source,
    })?;

    temp.persist(dest).map_err(|e| PathGuardError::Io {
        path: dest.to_path_buf(),
        source: e.error,
    })?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_project_rel_path_valid() {
        assert!(ProjectRelPath::new("lib/widgets/button.dart").is_ok());
        assert!(ProjectRelPath::new("foo/./bar/baz.dart").is_ok());
        assert_eq!(
            ProjectRelPath::new("foo/./bar/../baz.dart")
                .unwrap()
                .as_path(),
            Path::new("foo/baz.dart")
        );
    }

    #[test]
    fn test_project_rel_path_rejects_escapes_and_absolute() {
        assert!(ProjectRelPath::new("/etc/passwd").is_err());
        assert!(ProjectRelPath::new("../escaping.dart").is_err());
        assert!(ProjectRelPath::new("foo/../../escaping.dart").is_err());
        assert!(ProjectRelPath::new("").is_err());
    }

    #[test]
    fn test_sha256_hex_valid() {
        let valid = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
        assert!(Sha256Hex::new(valid).is_ok());
        assert_eq!(
            Sha256Hex::from_bytes(b"").as_str(),
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        );
    }

    #[test]
    fn test_sha256_hex_invalid() {
        assert!(Sha256Hex::new("short").is_err());
        assert!(Sha256Hex::new(&"g".repeat(64)).is_err());
    }

    #[test]
    fn test_atomic_write_creates_and_overwrites() {
        let dir = tempdir().unwrap();
        let target = dir.path().join("nested/folder/file.txt");

        assert!(atomic_write(&target, b"hello world").is_ok());
        assert_eq!(std::fs::read_to_string(&target).unwrap(), "hello world");

        assert!(atomic_write(&target, b"new content").is_ok());
        assert_eq!(std::fs::read_to_string(&target).unwrap(), "new content");
    }

    #[test]
    fn test_safe_join_normal() {
        let dir = tempdir().unwrap();
        let rel = ProjectRelPath::new("nested/file.txt").unwrap();
        let joined = safe_join(dir.path(), &rel).unwrap();
        assert_eq!(joined, dir.path().join("nested/file.txt"));
    }
}
