use similar::{ChangeTag, TextDiff};
use std::cmp::max;

use crate::utils::logger;

/// Kind of a diff line.
#[allow(dead_code)]
pub enum DiffKind {
    Unchanged,
    Added,
    Removed,
}

/// A single line in a calculated diff.
#[allow(dead_code)]
pub struct DiffLine {
    pub kind: DiffKind,
    pub text: String,
    /// 1-indexed line number in the local file, 0 if not present in local.
    pub local_line_num: usize,
    /// 1-indexed line number in the remote file, 0 if not present in remote.
    pub remote_line_num: usize,
}

/// Computes the diff between `local` and `remote` using the `similar` crate (LCS algorithm).
#[allow(dead_code)]
pub fn calculate_diff(local: &str, remote: &str) -> Vec<DiffLine> {
    let local_norm = local.replace("\r\n", "\n");
    let remote_norm = remote.replace("\r\n", "\n");

    let diff = TextDiff::from_lines(&local_norm, &remote_norm);
    let mut result = Vec::new();

    for change in diff.iter_all_changes() {
        let (kind, local_num, remote_num) = match change.tag() {
            ChangeTag::Equal => (
                DiffKind::Unchanged,
                change.old_index().map(|i| i + 1).unwrap_or(0),
                change.new_index().map(|i| i + 1).unwrap_or(0),
            ),
            ChangeTag::Delete => (
                DiffKind::Removed,
                change.old_index().map(|i| i + 1).unwrap_or(0),
                0,
            ),
            ChangeTag::Insert => (
                DiffKind::Added,
                0,
                change.new_index().map(|i| i + 1).unwrap_or(0),
            ),
        };
        result.push(DiffLine {
            kind,
            text: change.value().trim_end_matches('\n').to_string(),
            local_line_num: local_num,
            remote_line_num: remote_num,
        });
    }
    result
}

/// Formats and prints a unified diff inside a bordered panel.
/// Output format matches the Dart `DiffFormatter.printUnifiedDiff` exactly.
pub fn print_unified_diff(file_name: &str, local: &str, remote: &str, context_count: usize) {
    let local_norm = local.replace("\r\n", "\n");
    let remote_norm = remote.replace("\r\n", "\n");

    let diff = TextDiff::from_lines(&local_norm, &remote_norm);

    // Check for any changes
    let has_changes = diff.iter_all_changes().any(|c| c.tag() != ChangeTag::Equal);
    if !has_changes {
        logger::success(&format!("  {}: No changes detected.", file_name));
        return;
    }

    // Print header border: "┌─ {filename} ──────..."
    // border_length = max(40, filename_char_count + 8)
    let fn_chars = file_name.chars().count();
    let border_length = max(40, fn_chars + 8);
    let dash_count = border_length.saturating_sub(fn_chars + 4);
    let header_dashes = "─".repeat(dash_count);
    logger::stdout(&format!("┌─ {} {}", file_name, header_dashes));

    for group in diff.grouped_ops(context_count) {
        // Compute hunk header values: localStart, localCount, remoteStart, remoteCount
        let mut local_start = 0usize;
        let mut local_count = 0usize;
        let mut remote_start = 0usize;
        let mut remote_count = 0usize;

        for op in &group {
            for change in diff.iter_changes(op) {
                match change.tag() {
                    ChangeTag::Equal => {
                        let old = change.old_index().unwrap() + 1;
                        let new = change.new_index().unwrap() + 1;
                        if local_start == 0 {
                            local_start = old;
                        }
                        local_count += 1;
                        if remote_start == 0 {
                            remote_start = new;
                        }
                        remote_count += 1;
                    }
                    ChangeTag::Delete => {
                        let old = change.old_index().unwrap() + 1;
                        if local_start == 0 {
                            local_start = old;
                        }
                        local_count += 1;
                    }
                    ChangeTag::Insert => {
                        let new = change.new_index().unwrap() + 1;
                        if remote_start == 0 {
                            remote_start = new;
                        }
                        remote_count += 1;
                    }
                }
            }
        }

        // Hunk header — cyan
        let hunk_header = format!(
            "│ @@ -{},{} +{},{} @@",
            local_start, local_count, remote_start, remote_count
        );
        logger::stdout(&format!("\x1B[36m{}\x1B[0m", hunk_header));

        // Hunk lines
        for op in &group {
            for change in diff.iter_changes(op) {
                let text = change.value().trim_end_matches('\n');
                match change.tag() {
                    ChangeTag::Insert => logger::stdout(&format!("\x1B[32m│ +  {}\x1B[0m", text)),
                    ChangeTag::Delete => logger::stdout(&format!("\x1B[31m│ -  {}\x1B[0m", text)),
                    ChangeTag::Equal => logger::stdout(&format!("│    {}", text)),
                }
            }
        }
    }

    // Footer border: "└────────..."
    let footer = format!("└{}", "─".repeat(border_length));
    logger::stdout(&footer);
}
