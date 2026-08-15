use std::sync::OnceLock;
use syntect::easy::HighlightLines;
use syntect::highlighting::ThemeSet;
use syntect::parsing::SyntaxSet;
use syntect::util::as_24_bit_terminal_escaped;

static SYNTAX_SET: OnceLock<SyntaxSet> = OnceLock::new();
static THEME_SET: OnceLock<ThemeSet> = OnceLock::new();

fn get_syntax_set() -> &'static SyntaxSet {
    SYNTAX_SET.get_or_init(SyntaxSet::load_defaults_newlines)
}

fn get_theme_set() -> &'static ThemeSet {
    THEME_SET.get_or_init(ThemeSet::load_defaults)
}

pub fn highlight_code(code: &str, extension: &str) -> Vec<String> {
    let ps = get_syntax_set();
    let ts = get_theme_set();

    let syntax = ps
        .find_syntax_by_extension(extension)
        .unwrap_or_else(|| ps.find_syntax_plain_text());

    let theme = &ts.themes["base16-ocean.dark"];

    let mut highlighter = HighlightLines::new(syntax, theme);
    let mut highlighted_lines = Vec::new();

    for line in code.lines() {
        let line_with_nl = format!("{}\n", line);
        match highlighter.highlight_line(&line_with_nl, ps) {
            Ok(ranges) => {
                let escaped = as_24_bit_terminal_escaped(&ranges[..], false);
                let cleaned = escaped.trim_end_matches('\n').to_string();
                highlighted_lines.push(cleaned);
            }
            Err(_) => {
                highlighted_lines.push(line.to_string());
            }
        }
    }

    if highlighted_lines.is_empty() && !code.is_empty() {
        highlighted_lines.push(String::new());
    }

    highlighted_lines
}
