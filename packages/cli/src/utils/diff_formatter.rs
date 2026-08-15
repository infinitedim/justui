use similar::{ChangeTag, TextDiff};
use std::cmp::max;

use crate::utils::logger;

#[allow(dead_code)]
pub enum DiffKind {
    Unchanged,
    Added,
    Removed,
}

#[allow(dead_code)]
pub struct DiffLine {
    pub kind: DiffKind,
    pub text: String,

    pub local_line_num: usize,

    pub remote_line_num: usize,
}

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

pub fn print_unified_diff(file_name: &str, local: &str, remote: &str, context_count: usize) {
    let local_norm = local.replace("\r\n", "\n");
    let remote_norm = remote.replace("\r\n", "\n");

    let diff = TextDiff::from_lines(&local_norm, &remote_norm);

    let has_changes = diff.iter_all_changes().any(|c| c.tag() != ChangeTag::Equal);
    if !has_changes {
        logger::success(&format!("  {}: No changes detected.", file_name));
        return;
    }

    let local_highlighted = super::syntax_highlighter::highlight_code(&local_norm, "dart");
    let remote_highlighted = super::syntax_highlighter::highlight_code(&remote_norm, "dart");

    let fn_chars = file_name.chars().count();
    let border_length = max(40, fn_chars + 8);
    let dash_count = border_length.saturating_sub(fn_chars + 4);
    let header_dashes = "─".repeat(dash_count);
    logger::stdout(&format!("┌─ {} {}", file_name, header_dashes));

    for group in diff.grouped_ops(context_count) {
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

        let hunk_header = format!(
            "│ @@ -{},{} +{},{} @@",
            local_start, local_count, remote_start, remote_count
        );
        logger::stdout(&format!("\x1B[36m{}\x1B[0m", hunk_header));

        for op in &group {
            for change in diff.iter_changes(op) {
                let text = change.value().trim_end_matches('\n');
                match change.tag() {
                    ChangeTag::Insert => {
                        let idx = change.new_index().unwrap();
                        let highlighted = remote_highlighted
                            .get(idx)
                            .map(|s| s.as_str())
                            .unwrap_or(text);
                        logger::stdout(&format!("\x1B[32m│ +  {}\x1B[0m", highlighted));
                    }
                    ChangeTag::Delete => {
                        let idx = change.old_index().unwrap();
                        let highlighted = local_highlighted
                            .get(idx)
                            .map(|s| s.as_str())
                            .unwrap_or(text);
                        logger::stdout(&format!("\x1B[31m│ -  {}\x1B[0m", highlighted));
                    }
                    ChangeTag::Equal => {
                        let idx = change.new_index().unwrap();
                        let highlighted = remote_highlighted
                            .get(idx)
                            .map(|s| s.as_str())
                            .unwrap_or(text);
                        logger::stdout(&format!("│    {}", highlighted));
                    }
                }
            }
        }
    }

    let footer = format!("└{}", "─".repeat(border_length));
    logger::stdout(&footer);
}
