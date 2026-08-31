use inquire::{MultiSelect, Select};
use std::io::{self, IsTerminal};

pub fn is_interactive() -> bool {
    if std::env::var("JUSTUI_FORCE_INTERACTIVE").is_ok() {
        return true;
    }
    if cfg!(test) {
        return false;
    }
    io::stdin().is_terminal() && io::stderr().is_terminal()
}

pub fn confirm_with_input<R: io::BufRead, W: io::Write>(
    reader: &mut R,
    writer: &mut W,
    message: &str,
    default: bool,
) -> bool {
    let suffix = if default { "[Y/n]" } else { "[y/N]" };
    let _ = write!(writer, "{} {}: ", message, suffix);
    let _ = writer.flush();
    let mut input = String::new();
    let _ = reader.read_line(&mut input);
    let trimmed = input.trim().to_lowercase();
    if trimmed.is_empty() {
        return default;
    }
    trimmed == "y" || trimmed == "yes"
}

pub fn confirm(message: &str, default: bool) -> bool {
    if !is_interactive() {
        return default;
    }
    let mut stdin = io::BufReader::new(io::stdin());
    let mut stderr = io::stderr();
    confirm_with_input(&mut stdin, &mut stderr, message, default)
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

pub fn ask_with_input<R: io::BufRead, W: io::Write>(
    reader: &mut R,
    writer: &mut W,
    message: &str,
    default_value: &str,
) -> String {
    let _ = write!(writer, "{} [{}]: ", message, default_value);
    let _ = writer.flush();
    let mut input = String::new();
    let _ = reader.read_line(&mut input);
    let trimmed = input.trim().to_string();
    if trimmed.is_empty() {
        default_value.to_string()
    } else {
        trimmed
    }
}

pub fn ask(message: &str, default_value: &str) -> String {
    if !is_interactive() {
        return default_value.to_string();
    }
    let mut stdin = io::BufReader::new(io::stdin());
    let mut stderr = io::stderr();
    ask_with_input(&mut stdin, &mut stderr, message, default_value)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_non_interactive_prompt_fallbacks() {
        assert!(confirm("Proceed?", true));
        assert!(!confirm("Proceed?", false));

        let options = ["option_a", "option_b", "option_c"];
        assert_eq!(select_one("Select option:", &options, 1), 1);
        assert_eq!(select_multiple("Select options:", &options), vec![0, 1, 2]);

        assert_eq!(ask("Enter name:", "default_name"), "default_name");
    }

    #[test]
    fn test_confirm_and_ask_with_input_streams() {
        let mut out = Vec::new();

        // 1. Confirm 'y' input
        let mut input = std::io::Cursor::new(b"y\n");
        assert!(confirm_with_input(&mut input, &mut out, "Continue?", false));

        // 2. Confirm empty input fallback
        let mut input_empty = std::io::Cursor::new(b"\n");
        assert!(confirm_with_input(
            &mut input_empty,
            &mut out,
            "Continue?",
            true
        ));

        // 3. Confirm 'n' input
        let mut input_n = std::io::Cursor::new(b"n\n");
        assert!(!confirm_with_input(
            &mut input_n,
            &mut out,
            "Continue?",
            true
        ));

        // 4. Ask custom input
        let mut input_ask = std::io::Cursor::new(b"my_custom_value\n");
        assert_eq!(
            ask_with_input(&mut input_ask, &mut out, "Enter value:", "default"),
            "my_custom_value"
        );

        // 5. Ask empty input fallback
        let mut input_ask_empty = std::io::Cursor::new(b"\n");
        assert_eq!(
            ask_with_input(&mut input_ask_empty, &mut out, "Enter value:", "default"),
            "default"
        );
    }

    #[test]
    fn test_force_interactive_branch() {
        let _lock = crate::utils::lock_test_mutex();
        std::env::set_var("JUSTUI_FORCE_INTERACTIVE", "1");
        assert!(is_interactive());
        std::env::remove_var("JUSTUI_FORCE_INTERACTIVE");
    }
}
