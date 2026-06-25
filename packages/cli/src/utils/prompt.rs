use std::io::{self, Write};

/// Reads a trimmed line from stdin. Returns empty string on EOF.
fn read_line() -> String {
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap_or(0);
    input.trim().to_string()
}

/// Prompts for a yes/no confirmation.
/// Matches Dart `JustPrompt.confirm` exactly.
pub fn confirm(message: &str, default: bool) -> bool {
    let suffix = if default { "[Y/n]" } else { "[y/N]" };
    print!("{} {}: ", message, suffix);
    io::stdout().flush().unwrap();
    let input = read_line().to_lowercase();
    if input.is_empty() {
        return default;
    }
    input == "y" || input == "yes"
}

/// Prompts the user to select a single item from a numbered list.
/// Returns the 0-based index. Falls back to `default_index` on empty/invalid input.
/// Matches Dart `JustPrompt.selectOne` exactly.
pub fn select_one(message: &str, options: &[&str], default_index: usize) -> usize {
    for (i, opt) in options.iter().enumerate() {
        let marker = if i == default_index { '*' } else { ' ' };
        println!("  [{}{}] {}", marker, i + 1, opt);
    }
    print!("{} (default: {}): ", message, default_index + 1);
    io::stdout().flush().unwrap();
    let input = read_line();
    if input.is_empty() {
        return default_index;
    }
    if let Ok(parsed) = input.parse::<usize>() {
        if parsed >= 1 && parsed <= options.len() {
            return parsed - 1;
        }
    }
    default_index
}

/// Prompts the user to select multiple items from a numbered list.
/// Returns a Vec of 0-based selected indices.
/// Matches Dart `JustPrompt.selectMultiple` exactly.
pub fn select_multiple(message: &str, options: &[&str]) -> Vec<usize> {
    for (i, opt) in options.iter().enumerate() {
        println!("  [{}] {}", i + 1, opt);
    }
    print!("{} (e.g. 1, 3 or \"all\"): ", message);
    io::stdout().flush().unwrap();
    let input = read_line().to_lowercase();

    if input == "all" {
        return (0..options.len()).collect();
    }

    let mut selected = Vec::new();
    for part in input.split(',') {
        let trimmed = part.trim();
        if let Ok(parsed) = trimmed.parse::<usize>() {
            if parsed >= 1 && parsed <= options.len() {
                selected.push(parsed - 1);
            }
        }
    }
    selected
}

/// Prompts for a string input.
/// Matches Dart `JustPrompt.ask` exactly.
pub fn ask(message: &str, default_value: &str) -> String {
    print!("{} [{}]: ", message, default_value);
    io::stdout().flush().unwrap();
    let input = read_line();
    if input.is_empty() {
        default_value.to_string()
    } else {
        input
    }
}
