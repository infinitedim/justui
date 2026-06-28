use colored::Colorize;

/// Logs a green success message with a checkmark.
pub fn success(msg: &str) {
    println!("{}", format!("✓ {}", msg).green());
}

/// Logs a red error message with a cross icon.
pub fn error(msg: &str) {
    println!("{}", format!("✗ Error: {}", msg).red());
}

/// Logs a yellow warning message.
pub fn warning(msg: &str) {
    println!("{}", format!("⚠ Warning: {}", msg).yellow());
}

/// Logs a cyan informational message.
pub fn info(msg: &str) {
    println!("{}", format!("ℹ {}", msg).cyan());
}

/// Logs a plain unformatted line to the console.
pub fn stdout(msg: &str) {
    println!("{}", msg);
}

/// Menampilkan pesan di dalam bordered panel.
/// Contoh output:
/// ┌─────────────────────────────┐
/// │  Adding component "button"  │
/// └─────────────────────────────┘
#[allow(dead_code)]
pub fn panel(msg: &str) {
    let msg_chars = msg.chars().count();
    let inner_width = msg_chars + 4; // 2 spasi kiri, 2 spasi kanan
    let top = format!("┌{}┐", "─".repeat(inner_width));
    let middle = format!("│  {}  │", msg);
    let bottom = format!("└{}┘", "─".repeat(inner_width));
    println!("{}", top.cyan());
    println!("{}", middle.cyan());
    println!("{}", bottom.cyan());
}

/// Menampilkan summary box berisi daftar item.
/// Contoh output:
/// ╭─────────────────────────────────────────╮
/// │  ✔  3 komponen berhasil ditambahkan     │
/// │                                         │
/// │  → button    v0.2.0  lib/components/button/   │
/// │  → input     v0.1.0  lib/components/input/    │
/// │  → shared    v0.1.0  lib/components/shared/   │
/// ╰─────────────────────────────────────────╯
pub fn summary(title: &str, items: &[SummaryItem]) {
    // Hitung lebar box berdasarkan konten terpanjang
    let title_len = title.chars().count() + 5; // prefix "  ✔  " = 5 char
    let item_max_len = items
        .iter()
        .map(|i| i.label.chars().count() + i.value.chars().count() + 8) // "  → " + spacing
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

/// Satu baris item di dalam summary box.
pub struct SummaryItem {
    pub label: String,
    pub value: String,
}
