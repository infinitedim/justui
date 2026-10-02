use std::sync::atomic::{AtomicBool, Ordering};
use colored::Colorize;

static QUIET: AtomicBool = AtomicBool::new(false);

pub fn init(quiet: bool, no_color: bool) {
    QUIET.store(quiet, Ordering::Relaxed);
    if no_color || std::env::var("NO_COLOR").is_ok() {
        colored::control::set_override(false);
    }
}

pub fn is_quiet() -> bool {
    QUIET.load(Ordering::Relaxed)
}

pub fn success(msg: &str) {
    if is_quiet() {
        return;
    }
    eprintln!("{}", format!("✓ {}", msg).green());
}

pub fn error(msg: &str) {
    eprintln!("{}", format!("✗ Error: {}", msg).red());
}

pub fn warning(msg: &str) {
    if is_quiet() {
        return;
    }
    eprintln!("{}", format!("⚠ Warning: {}", msg).yellow());
}

pub fn info(msg: &str) {
    if is_quiet() {
        return;
    }
    eprintln!("{}", format!("ℹ {}", msg).cyan());
}

pub fn stdout(msg: &str) {
    println!("{}", msg);
}

pub fn panel(msg: &str) {
    if is_quiet() {
        return;
    }
    let msg_chars = msg.chars().count();
    let inner_width = msg_chars + 4;
    let top = format!("┌{}┐", "─".repeat(inner_width));
    let middle = format!("│  {}  │", msg);
    let bottom = format!("└{}┘", "─".repeat(inner_width));
    eprintln!("{}", top.cyan());
    eprintln!("{}", middle.cyan());
    eprintln!("{}", bottom.cyan());
}

pub fn summary(title: &str, items: &[SummaryItem]) {
    if is_quiet() {
        return;
    }
    let title_len = title.chars().count() + 5;
    let item_max_len = items
        .iter()
        .map(|i| i.label.chars().count() + i.value.chars().count() + 8)
        .max()
        .unwrap_or(0);
    let inner_width = title_len.max(item_max_len).max(40);

    let pad = |s: &str| {
        let len = s.chars().count();
        let padding = inner_width.saturating_sub(len);
        format!("│ {}{} │", s, " ".repeat(padding))
    };

    let top = format!("╭{}╮", "─".repeat(inner_width + 2));
    let bottom = format!("╰{}╯", "─".repeat(inner_width + 2));

    eprintln!("{}", top.green());
    eprintln!("{}", pad(&format!("  ✔  {}", title)).green());
    if !items.is_empty() {
        eprintln!("{}", pad("").green());
        for item in items {
            let line = format!("  →  {:<12} {}", item.label, item.value);
            eprintln!("{}", pad(&line).green());
        }
    }
    eprintln!("{}", bottom.green());
}

pub struct SummaryItem {
    pub label: String,
    pub value: String,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_logger_panel_and_summary() {
        panel("Test Panel Header");
        summary(
            "Test Summary Header",
            &[SummaryItem {
                label: "Item A".to_string(),
                value: "Value A".to_string(),
            }],
        );
    }

    #[test]
    fn test_logger_init_quiet_and_no_color() {
        init(true, true);
        assert!(is_quiet());
        // Should not panic or print errors
        info("quiet info message");
        warning("quiet warning message");
        success("quiet success message");
        panel("quiet panel message");

        init(false, false);
        assert!(!is_quiet());
    }
}
