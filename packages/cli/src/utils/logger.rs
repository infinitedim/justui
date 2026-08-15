use colored::Colorize;

pub fn success(msg: &str) {
    println!("{}", format!("✓ {}", msg).green());
}

pub fn error(msg: &str) {
    println!("{}", format!("✗ Error: {}", msg).red());
}

pub fn warning(msg: &str) {
    println!("{}", format!("⚠ Warning: {}", msg).yellow());
}

pub fn info(msg: &str) {
    println!("{}", format!("ℹ {}", msg).cyan());
}

pub fn stdout(msg: &str) {
    println!("{}", msg);
}

#[allow(dead_code)]
pub fn panel(msg: &str) {
    let msg_chars = msg.chars().count();
    let inner_width = msg_chars + 4;
    let top = format!("┌{}┐", "─".repeat(inner_width));
    let middle = format!("│  {}  │", msg);
    let bottom = format!("└{}┘", "─".repeat(inner_width));
    println!("{}", top.cyan());
    println!("{}", middle.cyan());
    println!("{}", bottom.cyan());
}

pub fn summary(title: &str, items: &[SummaryItem]) {
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

    println!("{}", top.green());
    println!("{}", pad(&format!("  ✔  {}", title)).green());
    if !items.is_empty() {
        println!("{}", pad("").green());
        for item in items {
            let line = format!("  →  {:<12} {}", item.label, item.value);
            println!("{}", pad(&line).green());
        }
    }
    println!("{}", bottom.green());
}

pub struct SummaryItem {
    pub label: String,
    pub value: String,
}
