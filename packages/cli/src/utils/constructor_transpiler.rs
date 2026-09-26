use regex::Regex;
use std::collections::HashMap;
use std::sync::OnceLock;

use crate::utils::env_resolver::DartTarget;
use crate::utils::logger;

fn field_regex() -> &'static Regex {
    static RE: OnceLock<Regex> = OnceLock::new();
    RE.get_or_init(|| {
        Regex::new(
            r#"(?m)(?:^|\n)([ \t]*(?:///.*?\r?\n[ \t]*)*(?:@\w+\s+)*)final\s+([^;{}=]+?)\s+([a-zA-Z0-9_]+)\s*(?:=\s*([^;{}]+?))?\s*;"#,
        )
        .unwrap()
    })
}

/// Finds the index of the matching closing brace `}` for the opening brace at `open_brace_idx`.
/// Skips braces inside single-line comments, block comments, and string literals.
fn find_matching_brace(code: &str, open_brace_idx: usize) -> Option<usize> {
    find_matching_delimiter(code, open_brace_idx, b'{', b'}')
}

/// Finds the index of the delimiter closing the one at `open_idx`, skipping
/// comments and string literals.
fn find_matching_delimiter(code: &str, open_idx: usize, open: u8, close: u8) -> Option<usize> {
    let open_brace_idx = open_idx;
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
            b if b == open => {
                depth += 1;
                i += 1;
            }
            b if b == close => {
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
        r#"(?ms)^[ \t]*((?:(?:abstract|sealed|base|interface|final|mixin)\s+)*)class\s+(?:const\s+)?([a-zA-Z_][a-zA-Z0-9_]*)"#,
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
            let bytes = &class_body.as_bytes()[..offset];
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
                } else if b == b'}' && depth > 0 {
                    depth -= 1;
                }
                i += 1;
            }
            depth == 0
        };

        // 1. Scan constructors inside class_body strictly at depth 0
        let ctor_pattern = format!(
            r#"(?m)(?:^|\n)([ \t]*(?:///.*?\r?\n[ \t]*)*)(const\s+)?{}(\.[a-zA-Z0-9_]+)?\s*\("#,
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
                Some(idx) => (class_body[open_paren_idx + 1..idx].to_string(), idx),
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
        let named_params_content = &inner_params_trimmed[1..inner_params_trimmed.len() - 1];

        // 2. Discover fields in this class body strictly at depth 0
        let field_regex = field_regex();

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
                            new_params.push(format!("  final {} {},", f_info.type_name, p_name));
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

        // Fail-safe: ensure no removal spans overlap
        let mut sorted_spans = spans_to_remove.clone();
        sorted_spans.sort_by_key(|&(s, _)| s);
        let mut has_overlap = false;
        for i in 0..sorted_spans.len().saturating_sub(1) {
            if sorted_spans[i].1 > sorted_spans[i + 1].0 {
                has_overlap = true;
                break;
            }
        }
        if has_overlap {
            continue;
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

/// Rewrites code for the project's configured [`DartTarget`].
///
/// Registry sources are authored with primary constructors. `Standard` projects receive
/// conventional constructors; classes that cannot be converted are reported via a warning
/// because they still require the `primary-constructors` experiment.
pub fn apply_dart_target(code: &str, target: DartTarget) -> String {
    match target {
        DartTarget::Primary => transpile_to_primary_constructor(code),
        DartTarget::Standard => {
            let (converted, skipped) = transpile_to_standard_constructor(code);
            for class_name in skipped {
                logger::warning(&format!(
                    "Class \"{}\" could not be converted to a standard constructor and still \
                     uses primary-constructor syntax. Enable the `primary-constructors` \
                     experiment or convert it manually.",
                    class_name
                ));
            }
            converted
        }
    }
}

/// A single primary-constructor parameter.
enum PrimaryParam {
    /// `[required] final Type name [= default]` — becomes a field plus `this.name`.
    Field {
        comments: Vec<String>,
        required: bool,
        type_name: String,
        name: String,
        default_value: Option<String>,
    },
    /// `[required] super.name [= default]` — forwarded unchanged.
    Super { comments: Vec<String>, text: String },
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum ParamGroup {
    Positional,
    Named,
    OptionalPositional,
}

/// Finds the first top-level `=` that introduces a default value (not `==`, `=>`, `<=`, `>=`, `!=`).
fn find_default_separator(decl: &str) -> Option<usize> {
    let bytes = decl.as_bytes();
    let mut depth = 0usize;
    let mut in_string: Option<u8> = None;
    let mut i = 0;
    while i < bytes.len() {
        let b = bytes[i];
        if let Some(q) = in_string {
            if b == b'\\' {
                i += 2;
                continue;
            }
            if b == q {
                in_string = None;
            }
            i += 1;
            continue;
        }
        match b {
            b'\'' | b'"' => in_string = Some(b),
            b'(' | b'[' | b'{' => depth += 1,
            b')' | b']' | b'}' => depth = depth.saturating_sub(1),
            b'=' if depth == 0 => {
                let next = bytes.get(i + 1).copied();
                let prev = if i > 0 { Some(bytes[i - 1]) } else { None };
                let is_operator = matches!(next, Some(b'=') | Some(b'>'))
                    || matches!(prev, Some(b'=') | Some(b'!') | Some(b'<') | Some(b'>'));
                if !is_operator {
                    return Some(i);
                }
            }
            _ => {}
        }
        i += 1;
    }
    None
}

/// Parses one parameter chunk (as produced by [`split_parameters`]). Returns `None` when the
/// chunk only holds comments, and `Err(())` when the parameter shape is not supported.
fn parse_primary_param(chunk: &str) -> Result<Option<PrimaryParam>, ()> {
    let mut comments = Vec::new();
    let mut decl_lines = Vec::new();
    for line in chunk.lines() {
        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }
        if decl_lines.is_empty() && trimmed.starts_with("//") {
            comments.push(trimmed.to_string());
        } else {
            decl_lines.push(trimmed);
        }
    }
    if decl_lines.is_empty() {
        return Ok(None);
    }
    let decl = decl_lines.join(" ");

    let (required, rest) = match decl.strip_prefix("required ") {
        Some(rest) => (true, rest.trim_start()),
        None => (false, decl.as_str()),
    };

    if rest.starts_with("super.") {
        return Ok(Some(PrimaryParam::Super {
            comments,
            text: decl.clone(),
        }));
    }

    let rest = rest.strip_prefix("final ").ok_or(())?.trim_start();
    let (signature, default_value) = match find_default_separator(rest) {
        Some(idx) => (
            rest[..idx].trim_end(),
            Some(rest[idx + 1..].trim().to_string()),
        ),
        None => (rest.trim_end(), None),
    };

    let name_start = signature
        .char_indices()
        .rev()
        .take_while(|(_, c)| c.is_ascii_alphanumeric() || *c == '_')
        .last()
        .map(|(i, _)| i)
        .ok_or(())?;
    let name = signature[name_start..].to_string();
    let type_name = signature[..name_start].trim().to_string();
    if name.is_empty() || name.starts_with(|c: char| c.is_ascii_digit()) {
        return Err(());
    }

    Ok(Some(PrimaryParam::Field {
        comments,
        required,
        type_name,
        name,
        default_value,
    }))
}

/// Splits the raw text between a primary constructor's parentheses into grouped parameters.
fn parse_primary_params(raw: &str) -> Result<Vec<(ParamGroup, PrimaryParam)>, ()> {
    let mut params = Vec::new();
    for chunk in split_parameters(raw) {
        let body = strip_leading_comments(&chunk);
        let (group, inner) = if body.starts_with('{') && body.ends_with('}') {
            (ParamGroup::Named, &body[1..body.len() - 1])
        } else if body.starts_with('[') && body.ends_with(']') {
            (ParamGroup::OptionalPositional, &body[1..body.len() - 1])
        } else {
            if let Some(param) = parse_primary_param(&chunk)? {
                params.push((ParamGroup::Positional, param));
            }
            continue;
        };
        for inner_chunk in split_parameters(inner) {
            if let Some(param) = parse_primary_param(&inner_chunk)? {
                params.push((group, param));
            }
        }
    }
    Ok(params)
}

fn strip_leading_comments(chunk: &str) -> &str {
    let mut rest = chunk.trim_start();
    while rest.starts_with("//") {
        rest = match rest.find('\n') {
            Some(idx) => rest[idx + 1..].trim_start(),
            None => "",
        };
    }
    rest.trim_end()
}

/// Renders the field declarations and the generative constructor for a converted class.
fn render_standard_members(
    indent: &str,
    class_name: &str,
    is_const: bool,
    params: &[(ParamGroup, PrimaryParam)],
) -> String {
    let member_indent = format!("{}  ", indent);
    let param_indent = format!("{}    ", indent);

    let mut fields = Vec::new();
    for (_, param) in params {
        if let PrimaryParam::Field {
            comments,
            type_name,
            name,
            ..
        } = param
        {
            let mut field = String::new();
            for comment in comments {
                field.push_str(&format!("{}{}\n", member_indent, comment));
            }
            if type_name.is_empty() {
                field.push_str(&format!("{}final {};", member_indent, name));
            } else {
                field.push_str(&format!("{}final {} {};", member_indent, type_name, name));
            }
            fields.push(field);
        }
    }

    let render_param = |param: &PrimaryParam| -> String {
        let mut out = String::new();
        match param {
            PrimaryParam::Field {
                required,
                name,
                default_value,
                ..
            } => {
                out.push_str(&param_indent);
                if *required {
                    out.push_str("required ");
                }
                out.push_str("this.");
                out.push_str(name);
                if let Some(default_value) = default_value {
                    out.push_str(" = ");
                    out.push_str(default_value);
                }
            }
            PrimaryParam::Super { comments, text } => {
                for comment in comments {
                    out.push_str(&format!("{}{}\n", param_indent, comment));
                }
                out.push_str(&param_indent);
                out.push_str(text);
            }
        }
        out.push(',');
        out
    };

    let positional: Vec<String> = params
        .iter()
        .filter(|(g, _)| *g == ParamGroup::Positional)
        .map(|(_, p)| render_param(p))
        .collect();
    let optional_group = params
        .iter()
        .find(|(g, _)| *g != ParamGroup::Positional)
        .map(|(g, _)| *g);
    let optional: Vec<String> = params
        .iter()
        .filter(|(g, _)| *g != ParamGroup::Positional)
        .map(|(_, p)| render_param(p))
        .collect();

    let const_kw = if is_const { "const " } else { "" };
    let ctor = if params.is_empty() {
        format!("{}{}{}();", member_indent, const_kw, class_name)
    } else {
        let mut ctor = format!("{}{}{}(\n", member_indent, const_kw, class_name);
        if !positional.is_empty() {
            ctor.push_str(&positional.join("\n"));
            ctor.push('\n');
        }
        if let Some(group) = optional_group {
            let (open, close) = if group == ParamGroup::Named {
                ('{', '}')
            } else {
                ('[', ']')
            };
            if positional.is_empty() {
                ctor = format!("{}{}{}({}\n", member_indent, const_kw, class_name, open);
            } else {
                ctor.pop();
                ctor.push_str(&format!(" {}\n", open));
            }
            ctor.push_str(&optional.join("\n"));
            ctor.push_str(&format!("\n{}{});", member_indent, close));
        } else {
            ctor.push_str(&format!("{});", member_indent));
        }
        ctor
    };

    let documented = params
        .iter()
        .any(|(_, p)| matches!(p, PrimaryParam::Field { comments, .. } if !comments.is_empty()));
    let field_separator = if documented { "\n\n" } else { "\n" };
    if fields.is_empty() {
        ctor
    } else {
        format!("{}\n\n{}", fields.join(field_separator), ctor)
    }
}

/// Returns the `{}` nesting depth at `offset` within `text`, ignoring comments and strings.
fn brace_depth_at(text: &str, offset: usize) -> usize {
    let bytes = &text.as_bytes()[..offset.min(text.len())];
    let mut depth = 0usize;
    let mut in_string: Option<u8> = None;
    let mut i = 0;
    while i < bytes.len() {
        let b = bytes[i];
        if let Some(q) = in_string {
            if b == b'\\' {
                i += 2;
                continue;
            }
            if b == q || b == b'\n' {
                in_string = None;
            }
            i += 1;
            continue;
        }
        match b {
            b'/' if bytes.get(i + 1) == Some(&b'/') => {
                while i < bytes.len() && bytes[i] != b'\n' {
                    i += 1;
                }
                continue;
            }
            b'/' if bytes.get(i + 1) == Some(&b'*') => {
                i += 2;
                while i + 1 < bytes.len() && !(bytes[i] == b'*' && bytes[i + 1] == b'/') {
                    i += 1;
                }
                i += 2;
                continue;
            }
            b'\'' | b'"' => in_string = Some(b),
            b'{' => depth += 1,
            b'}' => depth = depth.saturating_sub(1),
            _ => {}
        }
        i += 1;
    }
    depth
}

/// Rewrites primary-constructor style member declarations `[const] new name(` / `new(`
/// into conventional `[const] ClassName.name(` / `ClassName(`. Only class-member level
/// (depth 0 of `body`) matches are rewritten, so `new` expressions inside methods are kept.
fn rewrite_new_constructors(body: &str, class_name: &str) -> String {
    static NEW_CTOR: OnceLock<Regex> = OnceLock::new();
    let re = NEW_CTOR.get_or_init(|| {
        Regex::new(
            r"(?m)^([ \t]*)((?:(?:const|factory|external)[ \t]+)*)new\b[ \t]*([A-Za-z_][A-Za-z0-9_]*)?[ \t]*\(",
        )
        .unwrap()
    });

    let mut result = String::with_capacity(body.len());
    let mut last = 0;
    for cap in re.captures_iter(body) {
        let Some(full) = cap.get(0) else {
            continue;
        };
        if brace_depth_at(body, full.start()) != 0 {
            continue;
        }
        result.push_str(&body[last..full.start()]);
        result.push_str(cap.get(1).map_or("", |m| m.as_str()));
        result.push_str(cap.get(2).map_or("", |m| m.as_str()));
        result.push_str(class_name);
        if let Some(name) = cap.get(3) {
            result.push('.');
            result.push_str(name.as_str());
        }
        result.push('(');
        last = full.end();
    }
    result.push_str(&body[last..]);
    result
}

/// Transpiles Dart code written with primary constructors back into conventional constructors
/// so it compiles without the `primary-constructors` experiment.
///
/// Supported parameter shapes (the only ones used by the registry sources):
/// `[required] final Type name [= default]` and `[required] super.name`, in positional, named
/// `{}` or optional positional `[]` groups, optionally preceded by `//` or `///` comments.
///
/// Classes with any other shape are left untouched and their names are returned so the caller
/// can warn the user.
pub fn transpile_to_standard_constructor(code: &str) -> (String, Vec<String>) {
    static HEADER: OnceLock<Regex> = OnceLock::new();
    let header = HEADER.get_or_init(|| {
        Regex::new(
            r"(?m)^([ \t]*)((?:(?:abstract|sealed|base|interface|final|mixin)\s+)*)class\s+(const\s+)?([A-Za-z_][A-Za-z0-9_]*)",
        )
        .unwrap()
    });

    struct Conversion {
        start: usize,
        end: usize,
        replacement: String,
    }

    let mut conversions: Vec<Conversion> = Vec::new();
    let mut skipped: Vec<String> = Vec::new();

    for cap in header.captures_iter(code) {
        let (Some(full), Some(name_match)) = (cap.get(0), cap.get(4)) else {
            continue;
        };
        let indent = cap.get(1).map_or("", |m| m.as_str());
        let modifiers = cap.get(2).map_or("", |m| m.as_str());
        let is_const = cap.get(3).is_some();
        let class_name = name_match.as_str();

        let mut cursor = name_match.end();
        let type_params = if code.as_bytes().get(cursor) == Some(&b'<') {
            match find_matching_angle(code, cursor) {
                Some(end) => {
                    let tp = &code[cursor..=end];
                    cursor = end + 1;
                    tp
                }
                None => continue,
            }
        } else {
            ""
        };

        let after_name = &code[cursor..];
        let open_paren = cursor + (after_name.len() - after_name.trim_start().len());
        if code.as_bytes().get(open_paren) != Some(&b'(') {
            // Conventional class declaration: only `new`-style member constructors need work.
            let Some(open_brace) = code[cursor..].find(['{', ';']).map(|i| cursor + i) else {
                continue;
            };
            if code.as_bytes()[open_brace] != b'{' {
                continue;
            }
            let Some(close_brace) = find_matching_brace(code, open_brace) else {
                continue;
            };
            let body = &code[open_brace + 1..close_brace];
            let rewritten = rewrite_new_constructors(body, class_name);
            if rewritten != body {
                conversions.push(Conversion {
                    start: open_brace + 1,
                    end: close_brace,
                    replacement: rewritten,
                });
            }
            continue;
        }

        let Some(close_paren) = find_matching_delimiter(code, open_paren, b'(', b')') else {
            skipped.push(class_name.to_string());
            continue;
        };

        let Ok(params) = parse_primary_params(&code[open_paren + 1..close_paren]) else {
            skipped.push(class_name.to_string());
            continue;
        };

        let tail = &code[close_paren + 1..];
        let Some(terminator_offset) = tail.find(['{', ';']) else {
            skipped.push(class_name.to_string());
            continue;
        };
        let terminator = close_paren + 1 + terminator_offset;
        let heritage = code[close_paren + 1..terminator].trim();

        let (body_rest, end) = if code.as_bytes()[terminator] == b'{' {
            let Some(close_brace) = find_matching_brace(code, terminator) else {
                skipped.push(class_name.to_string());
                continue;
            };
            let rest = code[terminator + 1..=close_brace].trim_start_matches(['\r', '\n']);
            (rewrite_new_constructors(rest, class_name), close_brace + 1)
        } else {
            (format!("{}}}", indent), terminator + 1)
        };

        let members = render_standard_members(indent, class_name, is_const, &params);
        let heritage_part = if heritage.is_empty() {
            String::new()
        } else {
            format!(" {}", heritage)
        };
        let separator = if body_rest.trim_start().starts_with('}') {
            "\n"
        } else {
            "\n\n"
        };
        let replacement = format!(
            "{}{}class {}{}{} {{\n{}{}{}",
            indent,
            modifiers,
            class_name,
            type_params,
            heritage_part,
            members,
            separator,
            body_rest
        );

        conversions.push(Conversion {
            start: full.start(),
            end,
            replacement,
        });
    }

    let mut result = code.to_string();
    for conversion in conversions.into_iter().rev() {
        result.replace_range(conversion.start..conversion.end, &conversion.replacement);
    }
    (result, skipped)
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

    #[test]
    fn test_standard_named_params_with_docs_defaults_and_super() {
        let input = r#"/// Doc for the widget.
class const JustThing({
  super.key,

  /// The label.
  required final String label,
  final bool enabled = true,
  final void Function(int)? onChanged,
  required super.child,
}) extends InheritedWidget {
  @override
  bool updateShouldNotify(JustThing old) => label != old.label;
}
"#;
        let expected = r#"/// Doc for the widget.
class JustThing extends InheritedWidget {
  /// The label.
  final String label;

  final bool enabled;

  final void Function(int)? onChanged;

  const JustThing({
    super.key,
    required this.label,
    this.enabled = true,
    this.onChanged,
    required super.child,
  });

  @override
  bool updateShouldNotify(JustThing old) => label != old.label;
}
"#;
        let (output, skipped) = transpile_to_standard_constructor(input);
        assert!(skipped.is_empty());
        assert_eq!(output, expected);
    }

    #[test]
    fn test_standard_positional_semicolon_body_and_generic() {
        let input = "class const Pair(\n  final int a,\n  final int b,\n);\n\nfinal class const Holder<T extends Object>({required final T value}) {}\n";
        let expected = "class Pair {\n  final int a;\n  final int b;\n\n  const Pair(\n    this.a,\n    this.b,\n  );\n}\n\nfinal class Holder<T extends Object> {\n  final T value;\n\n  const Holder({\n    required this.value,\n  });\n}\n";
        let (output, skipped) = transpile_to_standard_constructor(input);
        assert!(skipped.is_empty());
        assert_eq!(output, expected);
    }

    #[test]
    fn test_standard_rewrites_new_constructors_only_at_member_level() {
        let input = r#"class const Tabs({final int index = 0}) extends StatelessWidget {
  const new pill({int index = 0}) : this(index: index);

  Widget build(BuildContext context) {
    final x =
        new Foo();
    return x;
  }
}

class Plain {
  const Plain();
  factory new empty() => const Plain();
}
"#;
        let (output, skipped) = transpile_to_standard_constructor(input);
        assert!(skipped.is_empty());
        assert!(output.contains("  const Tabs.pill({int index = 0}) : this(index: index);"));
        assert!(output.contains("        new Foo();"));
        assert!(output.contains("  factory Plain.empty() => const Plain();"));
        assert!(!output.contains("class const"));
    }

    #[test]
    fn test_standard_skips_unsupported_params_and_keeps_conventional_classes() {
        let input = "class const Odd(int plain) {}\n\nclass Normal {\n  const Normal();\n}\n";
        let (output, skipped) = transpile_to_standard_constructor(input);
        assert_eq!(skipped, vec!["Odd".to_string()]);
        assert_eq!(output, input);
    }

    #[test]
    fn test_apply_dart_target_round_trip() {
        let primary = "class const Chip({\n  super.key,\n  required final String label,\n}) extends StatelessWidget {}\n";
        let standard = apply_dart_target(primary, DartTarget::Standard);
        assert!(standard.contains("const Chip({"));
        let back = apply_dart_target(&standard, DartTarget::Primary);
        assert!(back.contains("class const Chip({"));
        assert!(back.contains("required final String label,"));
        assert_eq!(apply_dart_target(primary, DartTarget::Primary), primary);
    }
}
