use inquire::{MultiSelect, Select};
use std::io::{self, Write};

fn read_line() -> String {
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap_or(0);
    input.trim().to_string()
}

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

pub fn select_one(message: &str, options: &[&str], default_index: usize) -> usize {
    let result = Select::new(message, options.to_vec())
        .with_starting_cursor(default_index)
        .prompt();

    match result {
        Ok(selected) => options
            .iter()
            .position(|&o| o == selected)
            .unwrap_or(default_index),
        Err(_) => default_index,
    }
}

pub fn select_multiple(message: &str, options: &[&str]) -> Vec<usize> {
    let result = MultiSelect::new(message, options.to_vec()).prompt();

    match result {
        Ok(selected) => selected
            .iter()
            .filter_map(|s| options.iter().position(|o| o == s))
            .collect(),
        Err(_) => Vec::new(),
    }
}

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
