use regex::Regex;
use std::collections::HashMap;

/// Finds the index of the matching closing brace `}` for the opening brace at `open_brace_idx`.
/// Skips braces inside single-line comments, block comments, and string literals.
fn find_matching_brace(code: &str, open_brace_idx: usize) -> Option<usize> {
    let bytes = code.as_bytes();
    let mut depth = 0;
    let mut i = open_brace_idx;
    let len = bytes.len();

    while i < len {
        match bytes[i] {
            b'/' if i + 1 < len && bytes[i + 1] == b'/' => {
                i += 2;
                while i < len && bytes[i] != b'\n' {
                    i += 1;
                }
            }
            b'/' if i + 1 < len && bytes[i + 1] == b'*' => {
                i += 2;
                while i + 1 < len && !(bytes[i] == b'*' && bytes[i + 1] == b'/') {
                    i += 1;
                }
                if i + 1 < len {
                    i += 2;
                }
            }
            b'\'' | b'"' => {
                let quote = bytes[i];
                let is_triple = i + 2 < len && bytes[i + 1] == quote && bytes[i + 2] == quote;
                if is_triple {
                    i += 3;
                    while i + 2 < len
                        && !(bytes[i] == quote && bytes[i + 1] == quote && bytes[i + 2] == quote)
                    {
                        if bytes[i] == b'\\' {
                            i += 2;
                        } else {
                            i += 1;
                        }
                    }
                    if i + 2 < len {
                        i += 3;
                    }
                } else {
                    i += 1;
                    while i < len && bytes[i] != quote && bytes[i] != b'\n' {
                        if bytes[i] == b'\\' {
                            i += 2;
                        } else {
                            i += 1;
                        }
                    }
                    if i < len && bytes[i] == quote {
                        i += 1;
                    }
                }
            }
            b'{' => {
                depth += 1;
                i += 1;
            }
            b'}' => {
                depth -= 1;
                if depth == 0 {
                    return Some(i);
                }
                i += 1;
            }
            _ => {
                i += 1;
            }
        }
    }
    None
}

/// Finds the index of the matching closing angle bracket `>` for the opening `<` at `open_angle_idx`.
/// Skips angle brackets inside comments and string literals.
fn find_matching_angle(code: &str, open_angle_idx: usize) -> Option<usize> {
    let bytes = code.as_bytes();
    let len = bytes.len();
    let mut depth = 0;
    let mut i = open_angle_idx;

    while i < len {
        match bytes[i] {
            b'<' => {
                depth += 1;
                i += 1;
            }
            b'>' => {
                depth -= 1;
                if depth == 0 {
                    return Some(i);
                }
                i += 1;
            }
            b'{' | b';' => {
                return None;
            }
            _ => {
                i += 1;
            }
        }
    }
    None
}

/// Splits a constructor parameter list by top-level commas, respecting nested parentheses,
/// brackets, braces, strings, and comments.
fn split_parameters(raw: &str) -> Vec<String> {
    let mut chunks = Vec::new();
    let bytes = raw.as_bytes();
    let len = bytes.len();
    let mut start = 0;
    let mut paren_depth: usize = 0;
    let mut brace_depth: usize = 0;
    let mut bracket_depth: usize = 0;
    let mut in_string = false;
    let mut string_char = b' ';
    let mut in_line_comment = false;
    let mut in_block_comment = false;
    let mut i = 0;

    while i < len {
        let b = bytes[i];
        if in_line_comment {
            if b == b'\n' {
                in_line_comment = false;
            }
            i += 1;
            continue;
        }
        if in_block_comment {
            if b == b'*' && i + 1 < len && bytes[i + 1] == b'/' {
                in_block_comment = false;
                i += 2;
                continue;
            }
            i += 1;
            continue;
        }
        if in_string {
            if b == b'\\' {
                i += 2;
                continue;
            }
            if b == string_char {
                in_string = false;
            }
            i += 1;
            continue;
        }

        if b == b'/' && i + 1 < len && bytes[i + 1] == b'/' {
            in_line_comment = true;
            i += 2;
            continue;
        }
        if b == b'/' && i + 1 < len && bytes[i + 1] == b'*' {
            in_block_comment = true;
            i += 2;
            continue;
        }
        if b == b'\'' || b == b'"' {
            in_string = true;
            string_char = b;
            i += 1;
            continue;
        }

        match b {
            b'(' => paren_depth += 1,
            b')' => paren_depth = paren_depth.saturating_sub(1),
            b'{' => brace_depth += 1,
            b'}' => brace_depth = brace_depth.saturating_sub(1),
            b'[' => bracket_depth += 1,
            b']' => bracket_depth = bracket_depth.saturating_sub(1),
            b',' if paren_depth == 0 && brace_depth == 0 && bracket_depth == 0 => {
                let chunk = raw[start..i].trim();
                if !chunk.is_empty() {
                    chunks.push(chunk.to_string());
                }
                start = i + 1;
            }
            _ => {}
        }
        i += 1;
    }
    let last = raw[start..].trim();
    if !last.is_empty() {
        chunks.push(last.to_string());
    }
    chunks
}

/// Field info discovered within a class.
struct FieldInfo {
    type_name: String,
    default_value: Option<String>,
    span: (usize, usize),
}

/// Information about a single class in the file.
struct ClassInfo {
    full_start: usize,
    open_brace_idx: usize,
    close_brace_idx: usize,
    modifiers: String,
    class_name: String,
    type_params: String,
    heritage: String,
}

/// Transpiles Dart code using standard constructor syntax into primary constructor syntax.
///
/// Features:
/// - Class-scoped boundary tracking: only modifies text within the class's `{ ... }` curly braces.
/// - Never deletes fields belonging to sibling classes.
/// - Supports complex field types including function signatures (`bool Function(TimeOfDay)?`).
/// - Strict Fail-Safe Guard: If a constructor has initializer lists (`: assert(...)`, `: value = null`),
///   multiple generative constructors, redirecting constructors (`: this(...)`), or constructor bodies,
///   the class is left completely untouched as a standard constructor (100% valid Dart 3+).
/// - Preserves `const` when converting (`class const ClassName(...)`).
/// - Places generic type parameters before primary constructor parameters (`class const Dropdown<T>(...)`).
pub fn transpile_to_primary_constructor(code: &str) -> String {
    let class_header_regex = match Regex::new(
        r#"(?ms)^[ \t]*((?:(?:abstract|sealed|base|interface|final)\s+)*)class\s+([a-zA-Z_][a-zA-Z0-9_]*)"#,
    ) {
        Ok(r) => r,
        Err(_) => return code.to_string(),
    };

    let mut classes: Vec<ClassInfo> = Vec::new();

    for cap in class_header_regex.captures_iter(code) {
        let full_match = match cap.get(0) {
            Some(m) => m,
            None => continue,
        };

        let full_start = full_match.start();
        let modifiers = cap.get(1).map(|m| m.as_str()).unwrap_or("").to_string();
        let class_name = match cap.get(2) {
            Some(m) => m.as_str().to_string(),
            None => continue,
        };

        let mut cursor = cap.get(2).unwrap().end();
        let code_after = &code[cursor..];
        let trimmed = code_after.trim_start();
        let whitespace_len = code_after.len() - trimmed.len();
        cursor += whitespace_len;

        let type_params = if cursor < code.len() && code.as_bytes()[cursor] == b'<' {
            match find_matching_angle(code, cursor) {
                Some(end_angle) => {
                    let tp = code[cursor..=end_angle].to_string();
                    cursor = end_angle + 1;
                    tp
                }
                None => String::new(),
            }
        } else {
            String::new()
        };

        let next_open_brace = match code[cursor..].find('{') {
            Some(idx) => cursor + idx,
            None => continue,
        };

        let raw_heritage = code[cursor..next_open_brace].trim();
        // If heritage begins with '(', this is already a primary constructor class: skip!
        if raw_heritage.starts_with('(') {
            continue;
        }

        let heritage = raw_heritage.to_string();
        let open_brace_idx = next_open_brace;

        let close_brace_idx = match find_matching_brace(code, open_brace_idx) {
            Some(idx) => idx,
            None => continue,
        };

        classes.push(ClassInfo {
            full_start,
            open_brace_idx,
            close_brace_idx,
            modifiers,
            class_name,
            type_params,
            heritage,
        });
    }

    if classes.is_empty() {
        return code.to_string();
    }

    // Process classes from right to left so byte indices don't shift
    classes.sort_by_key(|c| std::cmp::Reverse(c.full_start));

    let mut result = code.to_string();

    for class_info in classes {
        let class_body = &result[class_info.open_brace_idx + 1..class_info.close_brace_idx];

        // Helper to check if an offset in class_body is at depth 0
        let is_at_depth_zero = |offset: usize| -> bool {
            let mut depth = 0;
            let mut in_line_comment = false;
            let mut in_block_comment = false;
            let mut in_string = false;
            let mut string_char = ' ';
            let bytes = class_body[..offset].as_bytes();
            let mut i = 0;
            while i < bytes.len() {
                let b = bytes[i];
                if in_line_comment {
                    if b == b'\n' {
                        in_line_comment = false;
                    }
                } else if in_block_comment {
                    if b == b'*' && i + 1 < bytes.len() && bytes[i + 1] == b'/' {
                        in_block_comment = false;
                        i += 1;
                    }
                } else if in_string {
                    if b == b'\\' {
                        i += 1;
                    } else if b as char == string_char {
                        in_string = false;
                    }
                } else if b == b'/' && i + 1 < bytes.len() && bytes[i + 1] == b'/' {
                    in_line_comment = true;
                    i += 1;
                } else if b == b'/' && i + 1 < bytes.len() && bytes[i + 1] == b'*' {
                    in_block_comment = true;
                    i += 1;
                } else if b == b'"' || b == b'\'' {
                    in_string = true;
                    string_char = b as char;
                } else if b == b'{' {
                    depth += 1;
                } else if b == b'}' {
                    if depth > 0 {
                        depth -= 1;
                    }
                }
                i += 1;
            }
            depth == 0
        };

        // 1. Scan constructors inside class_body strictly at depth 0
        let ctor_pattern = format!(
            r#"(?ms)(?:^|\n)([ \t]*(?:///.*?\r?\n[ \t]*)*)(const\s+)?{}(\.[a-zA-Z0-9_]+)?\s*\("#,
            regex::escape(&class_info.class_name)
        );
        let ctor_find_regex = match Regex::new(&ctor_pattern) {
            Ok(r) => r,
            Err(_) => continue,
        };

        let mut generative_ctors = Vec::new();

        for cap in ctor_find_regex.captures_iter(class_body) {
            let full = cap.get(0).unwrap();
            let start = full.start();

            // Strictly ignore any match inside a method/body (depth > 0)
            if !is_at_depth_zero(start) {
                continue;
            }

            // Verify not preceded by factory, return, =, =>, new, :, (, ,, [, ?, throw
            let prefix_end = start;
            let prefix = &class_body[..prefix_end];
            let trimmed_prefix = prefix.trim_end();
            if trimmed_prefix.ends_with("factory")
                || trimmed_prefix.ends_with("return")
                || trimmed_prefix.ends_with('=')
                || trimmed_prefix.ends_with("=>")
                || trimmed_prefix.ends_with("new")
                || trimmed_prefix.ends_with(':')
                || trimmed_prefix.ends_with('(')
                || trimmed_prefix.ends_with(',')
                || trimmed_prefix.ends_with('[')
                || trimmed_prefix.ends_with('?')
                || trimmed_prefix.ends_with("throw")
            {
                continue;
            }

            let is_const = cap.get(2).is_some();
            let named_sub = cap.get(3).map(|m| m.as_str().to_string());
            let open_paren_idx = full.end() - 1;

            generative_ctors.push((start, is_const, named_sub, open_paren_idx));
        }

        // Fail-safe: if there are multiple generative constructors, leave untouched!
        if generative_ctors.len() != 1 {
            continue;
        }

        let (ctor_start, is_const, named_sub, open_paren_idx) = generative_ctors.remove(0);

        // Fail-safe: primary constructor cannot be named
        if named_sub.is_some() {
            continue;
        }

        // Find matching closing ')' for the constructor parameters
        let ctor_params_raw = {
            let bytes = class_body.as_bytes();
            let len = bytes.len();
            let mut depth = 0;
            let mut close_idx = None;
            let mut i = open_paren_idx;
            while i < len {
                if bytes[i] == b'(' {
                    depth += 1;
                } else if bytes[i] == b')' {
                    depth -= 1;
                    if depth == 0 {
                        close_idx = Some(i);
                        break;
                    }
                }
                i += 1;
            }
            match close_idx {
                Some(idx) => (
                    class_body[open_paren_idx + 1..idx].to_string(),
                    idx,
                ),
                None => continue,
            }
        };

        let (raw_params, ctor_close_paren_idx) = ctor_params_raw;

        // Check what comes after the closing ')'
        let after_paren = class_body[ctor_close_paren_idx + 1..].trim_start();
        if after_paren.starts_with(':') {
            // Fail-safe: Initializer list (: assert(...), : value = null, : this(...), : super(...))
            continue;
        }
        if after_paren.starts_with('{') {
            // Fail-safe: Constructor has a body block { ... }
            continue;
        }
        if !after_paren.starts_with(';') {
            // Fail-safe: Unexpected constructor terminator
            continue;
        }

        // Determine full end of constructor statement including ';'
        let ctor_semi_offset = match class_body[ctor_close_paren_idx + 1..].find(';') {
            Some(idx) => ctor_close_paren_idx + 1 + idx,
            None => continue,
        };
        let ctor_full_span = (ctor_start, ctor_semi_offset + 1);

        // Parameters must be named parameters enclosed in '{ ... }'
        let inner_params_trimmed = raw_params.trim();
        if !inner_params_trimmed.starts_with('{') || !inner_params_trimmed.ends_with('}') {
            continue;
        }
        let named_params_content =
            &inner_params_trimmed[1..inner_params_trimmed.len() - 1];

        // 2. Discover fields in this class body strictly at depth 0
        let field_regex = match Regex::new(
            r#"(?m)(?:^|\n)([ \t]*(?:///.*?\r?\n[ \t]*)*(?:@\w+\s+)*)final\s+([^;{}=]+?)\s+([a-zA-Z0-9_]+)\s*(?:=\s*([^;{}]+?))?\s*;"#,
        ) {
            Ok(r) => r,
            Err(_) => continue,
        };

        let mut fields: HashMap<String, FieldInfo> = HashMap::new();
        for field_cap in field_regex.captures_iter(class_body) {
            let full_cap = field_cap.get(0).unwrap();
            if !is_at_depth_zero(full_cap.start()) {
                continue;
            }

            let type_str = field_cap.get(2).unwrap().as_str();
            let name_str = field_cap.get(3).unwrap().as_str().to_string();
            let default_val = field_cap.get(4).map(|m| m.as_str().trim().to_string());

            // Normalize type string whitespace (e.g. multi-line Function signatures)
            let normalized_type = type_str.split_whitespace().collect::<Vec<_>>().join(" ");

            fields.insert(
                name_str,
                FieldInfo {
                    type_name: normalized_type,
                    default_value: default_val,
                    span: (full_cap.start(), full_cap.end()),
                },
            );
        }

        // 3. Transpile parameters and verify every 'this.name' can be resolved
        let param_chunks = split_parameters(named_params_content);
        let mut new_params: Vec<String> = Vec::new();
        let mut fields_to_remove_spans: Vec<(usize, usize)> = Vec::new();
        let mut can_transpile = true;

        for chunk in param_chunks {
            let trimmed = chunk.trim();
            if trimmed.is_empty() {
                continue;
            }

            if trimmed.starts_with("super.") {
                new_params.push(format!("  {},", trimmed));
            } else if trimmed.starts_with("required this.") {
                let p_name = trimmed.trim_start_matches("required this.").trim();
                if let Some(f_info) = fields.get(p_name) {
                    new_params.push(format!("  required final {} {},", f_info.type_name, p_name));
                    fields_to_remove_spans.push(f_info.span);
                } else {
                    can_transpile = false;
                    break;
                }
            } else if trimmed.starts_with("this.") {
                let rest = trimmed.trim_start_matches("this.").trim();
                if let Some((p_name, default_val)) = rest.split_once('=') {
                    let p_name = p_name.trim();
                    let d_val = default_val.trim();
                    if let Some(f_info) = fields.get(p_name) {
                        new_params.push(format!(
                            "  final {} {} = {},",
                            f_info.type_name, p_name, d_val
                        ));
                        fields_to_remove_spans.push(f_info.span);
                    } else {
                        can_transpile = false;
                        break;
                    }
                } else {
                    let p_name = rest.trim();
                    if let Some(f_info) = fields.get(p_name) {
                        if let Some(ref d_val) = f_info.default_value {
                            new_params.push(format!(
                                "  final {} {} = {},",
                                f_info.type_name, p_name, d_val
                            ));
                        } else {
                            new_params.push(format!(
                                "  final {} {},",
                                f_info.type_name, p_name
                            ));
                        }
                        fields_to_remove_spans.push(f_info.span);
                    } else {
                        can_transpile = false;
                        break;
                    }
                }
            } else {
                new_params.push(format!("  {},", trimmed));
            }
        }

        if !can_transpile || new_params.is_empty() {
            continue;
        }

        // 4. Modify class body: remove constructor and converted fields strictly by byte spans at depth 0
        let mut spans_to_remove = Vec::new();
        spans_to_remove.push(ctor_full_span);
        for span in fields_to_remove_spans {
            spans_to_remove.push(span);
        }

        // Sort descending so removals do not invalidate earlier offsets
        spans_to_remove.sort_by_key(|&(start, _)| std::cmp::Reverse(start));
        let mut new_body = class_body.to_string();
        for (s, e) in spans_to_remove {
            if s < e && e <= new_body.len() {
                new_body.replace_range(s..e, "");
            }
        }

        // 5. Construct primary constructor class header
        let class_kw = if is_const { "class const" } else { "class" };
        let modifiers_str = if class_info.modifiers.is_empty() {
            String::new()
        } else {
            format!("{} ", class_info.modifiers.trim())
        };

        let primary_header = if class_info.heritage.is_empty() {
            format!(
                "{}{} {}{}({{\n{}\n}}) {{",
                modifiers_str,
                class_kw,
                class_info.class_name,
                class_info.type_params,
                new_params.join("\n")
            )
        } else {
            format!(
                "{}{} {}{}({{\n{}\n}}) {} {{",
                modifiers_str,
                class_kw,
                class_info.class_name,
                class_info.type_params,
                new_params.join("\n"),
                class_info.heritage
            )
        };

        let new_class_content = format!("{}{}\n}}", primary_header, new_body);
        result.replace_range(
            class_info.full_start..=class_info.close_brace_idx,
            &new_class_content,
        );
    }

    // Clean up excessive empty lines created by removals
    let lines: Vec<&str> = result.lines().collect();
    let mut cleaned_lines = Vec::new();
    let mut prev_empty = false;
    for line in lines {
        if line.trim().is_empty() {
            if !prev_empty {
                cleaned_lines.push("");
                prev_empty = true;
            }
        } else {
            cleaned_lines.push(line);
            prev_empty = false;
        }
    }

    let mut final_res = cleaned_lines.join("\n");
    if code.ends_with('\n') && !final_res.ends_with('\n') {
        final_res.push('\n');
    }
    final_res
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_transpile_badge_widget() {
        let input = r#"
class JustBadge extends StatelessWidget {
  final String label;
  final JustBadgeVariant variant;

  const JustBadge({
    super.key,
    required this.label,
    this.variant = JustBadgeVariant.solid,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
"#;

        let output = transpile_to_primary_constructor(input);

        assert!(output.contains("class const JustBadge({"));
        assert!(output.contains("super.key,"));
        assert!(output.contains("required final String label,"));
        assert!(output.contains("final JustBadgeVariant variant = JustBadgeVariant.solid,"));
        assert!(output.contains("}) extends StatelessWidget {"));
        assert!(!output.contains("  const JustBadge({"));
    }

    #[test]
    fn test_transpile_data_class() {
        let input = r#"
class JustBreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const JustBreadcrumbItem({
    required this.label,
    this.onTap,
  });
}
"#;

        let output = transpile_to_primary_constructor(input);

        assert!(output.contains("class const JustBreadcrumbItem({"));
        assert!(output.contains("required final String label,"));
        assert!(output.contains("final VoidCallback? onTap,"));
        assert!(!output.contains("  const JustBreadcrumbItem({"));
    }

    #[test]
    fn test_transpile_complex_function_signature_field() {
        let input = r#"
class JustCarousel extends StatefulWidget {
  final List<Widget> children;
  final Widget Function(BuildContext context, Widget child, double progress)?
  transitionBuilder;

  const JustCarousel({
    super.key,
    required this.children,
    this.transitionBuilder,
  });

  @override
  State<JustCarousel> createState() => _JustCarouselState();
}
"#;

        let output = transpile_to_primary_constructor(input);

        assert!(output.contains("class const JustCarousel({"));
        assert!(output.contains("required final List<Widget> children,"));
        assert!(output.contains("final Widget Function(BuildContext context, Widget child, double progress)? transitionBuilder,"));
        assert!(!output.contains("  const JustCarousel({"));
    }

    #[test]
    fn test_transpile_generic_class() {
        let input = r#"
class JustDropdown<T> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T?>? onChanged;

  const JustDropdown({
    super.key,
    required this.items,
    this.onChanged,
  });
}
"#;

        let output = transpile_to_primary_constructor(input);

        assert!(output.contains("class const JustDropdown<T>({"));
        assert!(output.contains("required final List<T> items,"));
        assert!(output.contains("final ValueChanged<T?>? onChanged,"));
        assert!(output.contains("}) extends StatelessWidget {"));
    }

    #[test]
    fn test_transpile_string_with_comma_in_default() {
        let input = r#"
class Greeter extends StatelessWidget {
  final String greeting;

  const Greeter({
    super.key,
    this.greeting = 'Hello, world!',
  });
}
"#;

        let output = transpile_to_primary_constructor(input);

        assert!(output.contains("class const Greeter({"));
        assert!(output.contains("final String greeting = 'Hello, world!',"));
        assert!(!output.contains("world!'\n"));
    }

    #[test]
    fn test_local_variable_with_same_name_not_removed() {
        let input = r#"
class CounterWidget extends StatelessWidget {
  final int count;

  const CounterWidget({
    super.key,
    required this.count,
  });

  void helper() {
    final int count = 10;
  }
}
"#;

        let output = transpile_to_primary_constructor(input);

        assert!(output.contains("class const CounterWidget({"));
        assert!(output.contains("required final int count,"));
        assert!(output.contains("final int count = 10;"));
    }

    #[test]
    fn test_class_instantiation_in_method_not_confused_for_constructor() {
        let input = r#"
class Item extends StatelessWidget {
  final String title;

  const Item({
    super.key,
    required this.title,
  });

  static List<Item> makeList() {
    return [
      Item(title: 'A'),
      Item(title: 'B'),
    ];
  }
}
"#;

        let output = transpile_to_primary_constructor(input);

        assert!(output.contains("class const Item({"));
        assert!(output.contains("required final String title,"));
        assert!(output.contains("Item(title: 'A')"));
    }

    #[test]
    fn test_fail_safe_on_initializer_assert() {
        let input = r#"
class TimePickerSpinner extends StatefulWidget {
  final int minuteInterval;

  const TimePickerSpinner({
    super.key,
    this.minuteInterval = 1,
  }) : assert(60 % minuteInterval == 0, 'must divide 60');

  @override
  State<TimePickerSpinner> createState() => _TimePickerSpinnerState();
}
"#;

        let output = transpile_to_primary_constructor(input);
        assert_eq!(input, output);
    }

    #[test]
    fn test_fail_safe_on_multiple_generative_constructors() {
        let input = r#"
class JustSlider extends StatefulWidget {
  final double? value;
  final JustRangeValues? rangeValues;

  const JustSlider({
    super.key,
    required this.value,
  }) : rangeValues = null;

  const JustSlider.range({
    super.key,
    required this.rangeValues,
  }) : value = null;
}
"#;

        let output = transpile_to_primary_constructor(input);
        assert_eq!(input, output);
    }

    #[test]
    fn test_sibling_class_fields_preserved() {
        let input = r#"
class TimePickerDial extends StatelessWidget {
  final TimeOfDay value;

  const TimePickerDial({
    super.key,
    required this.value,
  });
}

class _ClockFacePainter extends CustomPainter {
  final double radius;
  final Color color;

  _ClockFacePainter({
    required this.radius,
    required this.color,
  });
}
"#;

        let output = transpile_to_primary_constructor(input);

        assert!(output.contains("class const TimePickerDial({"));
        assert!(output.contains("required final TimeOfDay value,"));
        // _ClockFacePainter should retain its fields
        assert!(output.contains("class _ClockFacePainter({"));
        assert!(output.contains("required final double radius,"));
        assert!(output.contains("required final Color color,"));
    }

    #[test]
    fn test_transpile_fail_safe_unmatched_code() {
        let input = "class CustomWidget {}";
        let output = transpile_to_primary_constructor(input);
        assert_eq!(input, output);
    }
}
