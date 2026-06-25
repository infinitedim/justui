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
