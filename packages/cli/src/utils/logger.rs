#![allow(
    clippy::print_stderr,
    reason = "logger module is the central stderr output sink"
)]

use colored::Colorize;
use std::io::{IsTerminal, Write};
use std::sync::atomic::{AtomicBool, AtomicU8, Ordering};

static QUIET: AtomicBool = AtomicBool::new(false);
static VERBOSITY: AtomicU8 = AtomicU8::new(0);

/// Determines whether terminal colors should be enabled based on
/// flags, environment variables (`NO_COLOR`, `CLICOLOR_FORCE`), and stream TTY status.
pub fn should_color(stream_is_terminal: bool, no_color_flag: bool) -> bool {
    if no_color_flag {
        return false;
    }
    if let Ok(val) = std::env::var("NO_COLOR")
        && !val.is_empty()
    {
        return false;
    }
    if let Ok(val) = std::env::var("CLICOLOR_FORCE")
        && val != "0"
    {
        return true;
    }
    stream_is_terminal
}

pub fn init(quiet: bool, verbose: u8, no_color: bool) {
    QUIET.store(quiet, Ordering::Relaxed);
    VERBOSITY.store(verbose, Ordering::Relaxed);
    let color_enabled = should_color(std::io::stderr().is_terminal(), no_color);
    colored::control::set_override(color_enabled);
}

pub fn is_quiet() -> bool {
    QUIET.load(Ordering::Relaxed)
}

pub fn verbosity() -> u8 {
    VERBOSITY.load(Ordering::Relaxed)
}

pub fn success(msg: &str) {
    if is_quiet() {
        return;
    }
    eprintln!("{}", format!("✓ {msg}").green());
}

pub fn error(msg: &str) {
    eprintln!("{}", format!("✗ Error: {msg}").red());
}

pub fn warning(msg: &str) {
    if is_quiet() {
        return;
    }
    eprintln!("{}", format!("⚠ Warning: {msg}").yellow());
}

pub fn info(msg: &str) {
    if is_quiet() {
        return;
    }
    eprintln!("{}", format!("ℹ {msg}").cyan());
}

pub fn hint(msg: &str) {
    if is_quiet() {
        return;
    }
    eprintln!("{}", format!("hint: {msg}").cyan());
}

pub fn debug(msg: &str) {
    if is_quiet() || verbosity() < 1 {
        return;
    }
    eprintln!("{}", format!("[debug] {msg}").blue());
}

pub fn trace(msg: &str) {
    if is_quiet() || verbosity() < 2 {
        return;
    }
    eprintln!("{}", format!("[trace] {msg}").magenta());
}

pub fn stdout(msg: &str) {
    let mut out = std::io::stdout().lock();
    if let Err(e) = writeln!(out, "{msg}")
        && e.kind() == std::io::ErrorKind::BrokenPipe
    {
        std::process::exit(0);
    }
    if let Err(e) = out.flush()
        && e.kind() == std::io::ErrorKind::BrokenPipe
    {
        std::process::exit(0);
    }
}

pub fn panel(msg: &str) {
    if is_quiet() {
        return;
    }
    let msg_chars = msg.chars().count();
    let inner_width = msg_chars + 4;
    let top = format!("┌{}┐", "─".repeat(inner_width));
    let middle = format!("│  {msg}  │");
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
    eprintln!("{}", pad(&format!("  ✔  {title}")).green());
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
        init(true, 0, true);
        assert!(is_quiet());
        assert_eq!(verbosity(), 0);
        // Should not panic or print errors
        info("quiet info message");
        warning("quiet warning message");
        success("quiet success message");
        panel("quiet panel message");
        debug("quiet debug message");
        trace("quiet trace message");

        init(false, 2, false);
        assert!(!is_quiet());
        assert_eq!(verbosity(), 2);
        debug("active debug message");
        trace("active trace message");

        // Color decisions
        assert!(!should_color(true, true));
        assert!(should_color(true, false));
        assert!(!should_color(false, false));
    }
}
