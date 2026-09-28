//! Runs the user's local `dart format` on files this CLI just wrote, so the
//! content on disk matches what a `dart format` run would already produce
//! instead of drifting from it and being reported as "locally modified" by
//! `list`/`diff` the moment the user (or their editor) formats it.

use std::path::Path;
use std::process::Command;
use std::sync::OnceLock;

use crate::utils::import_rewriter;

fn dart_available() -> bool {
    static AVAILABLE: OnceLock<bool> = OnceLock::new();
    *AVAILABLE.get_or_init(|| {
        Command::new("dart")
            .arg("--version")
            .output()
            .map(|out| out.status.success())
            .unwrap_or(false)
    })
}

/// Formats `path` in place with `dart format`, then — if the file carries a
/// `justui-meta` header — recomputes its embedded `local` hash from the
/// post-format content, so status commands (`list`, `diff`) treat the
/// formatted file as the installed baseline rather than a local edit.
///
/// A no-op when the `dart` binary isn't on PATH, or when formatting fails:
/// the file is left exactly as written.
pub fn format_and_refresh_metadata(path: &Path) {
    if !dart_available() {
        return;
    }

    let formatted = Command::new("dart")
        .arg("format")
        .arg("--output=write")
        .arg(path)
        .output();

    if !matches!(formatted, Ok(out) if out.status.success()) {
        return;
    }

    let Ok(raw) = std::fs::read_to_string(path) else {
        return;
    };
    let content = raw.replace("\r\n", "\n");
    let Some(meta) = import_rewriter::parse_metadata(&content) else {
        return;
    };
    let clean = import_rewriter::strip_metadata(&content);
    let new_local_hash = crate::commands::add::sha256_hex(clean.as_bytes());
    if new_local_hash == meta.local_hash {
        return;
    }
    let refreshed = import_rewriter::inject_metadata(&clean, &meta.registry_hash, &new_local_hash);
    let _ = std::fs::write(path, refreshed);
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::commands::add::sha256_hex;

    #[test]
    fn format_and_refresh_metadata_reformats_and_updates_local_hash() {
        let temp_dir = tempfile::tempdir().unwrap();
        let path = temp_dir.path().join("just_example.dart");

        // Deliberately unformatted: extra blank lines, no space after `,`.
        let unformatted_body =
            "class Example {\n  final int a;\n\n\n  Example(this.a,this.a);\n}\n";
        let pre_format_hash = sha256_hex(unformatted_body.as_bytes());
        let registry_hash = "deadbeef".repeat(8);

        // Metadata as `add` would inject it: local_hash matches the
        // *unformatted* body, since that's what was written to disk.
        let on_disk =
            import_rewriter::inject_metadata(unformatted_body, &registry_hash, &pre_format_hash);
        std::fs::write(&path, &on_disk).unwrap();

        format_and_refresh_metadata(&path);

        let result = std::fs::read_to_string(&path).unwrap();
        let meta = import_rewriter::parse_metadata(&result)
            .expect("formatted file must still carry a justui-meta header");
        let clean = import_rewriter::strip_metadata(&result);

        // The registry hash (what upstream shipped) must be untouched.
        assert_eq!(meta.registry_hash, registry_hash);
        // The local hash must match the *formatted* content actually on disk,
        // not the pre-format content that was originally written.
        assert_eq!(meta.local_hash, sha256_hex(clean.as_bytes()));
        assert_ne!(
            meta.local_hash, pre_format_hash,
            "dart format must have changed this deliberately-unformatted input"
        );
    }

    #[test]
    fn format_and_refresh_metadata_is_noop_without_metadata_header() {
        let temp_dir = tempfile::tempdir().unwrap();
        let path = temp_dir.path().join("plain.dart");
        let content = "class Plain {\n  final int a;\n}\n";
        std::fs::write(&path, content).unwrap();

        format_and_refresh_metadata(&path);

        // No justui-meta header was present, so no hash bookkeeping happens;
        // the file may still get reformatted by dart format itself, but
        // there is nothing to assert about metadata that never existed.
        assert!(
            import_rewriter::parse_metadata(&std::fs::read_to_string(&path).unwrap()).is_none()
        );
    }
}
