use inquire::{MultiSelect, Select};
use std::io::{self, IsTerminal, Write};

fn is_interactive() -> bool {
    io::stdin().is_terminal() && io::stderr().is_terminal()
}

fn read_line() -> String {
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap_or(0);
    input.trim().to_string()
}

pub fn confirm(message: &str, default: bool) -> bool {
    if !is_interactive() {
        return default;
    }
    let suffix = if default { "[Y/n]" } else { "[y/N]" };
    eprint!("{} {}: ", message, suffix);
    io::stderr().flush().unwrap();
    let input = read_line().to_lowercase();
    if input.is_empty() {
        return default;
    }
    input == "y" || input == "yes"
}

pub fn select_one(message: &str, options: &[&str], default_index: usize) -> usize {
    if !is_interactive() {
        return default_index;
    }
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
    if !is_interactive() {
        return (0..options.len()).collect();
    }
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
    if !is_interactive() {
        return default_value.to_string();
    }
    eprint!("{} [{}]: ", message, default_value);
    io::stderr().flush().unwrap();
    let input = read_line();
    if input.is_empty() {
        default_value.to_string()
    } else {
        input
    }
}
