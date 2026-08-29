use regex::Regex;
use std::collections::HashMap;

/// Transpiles Dart code using standard constructor syntax into primary constructor syntax.
/// If the code does not match the expected pattern or has syntax that cannot be safely converted,
/// it returns the original code unchanged (fail-safe).
pub fn transpile_to_primary_constructor(code: &str) -> String {
    let class_regex = match Regex::new(
        r"class\s+([A-Z][a-zA-Z0-9_]*)\s*(?:(extends|with|implements)\s+([^{]+))?\s*\{",
    ) {
        Ok(r) => r,
        Err(_) => return code.to_string(),
    };

    let field_regex = match Regex::new(r"final\s+([A-Za-z0-9_<>?, ]+)\s+([a-zA-Z0-9_]+)\s*;") {
        Ok(r) => r,
        Err(_) => return code.to_string(),
    };

    let constructor_regex =
        match Regex::new(r"const\s+([A-Z][a-zA-Z0-9_]*)\s*\(\s*\{([\s\S]*?)\}\s*\)\s*;") {
            Ok(r) => r,
            Err(_) => return code.to_string(),
        };

    let mut result = code.to_string();

    for class_cap in class_regex.captures_iter(code) {
        let class_name = match class_cap.get(1) {
            Some(m) => m.as_str(),
            None => continue,
        };

        // Find matching constructor for this class
        let ctor_cap = match constructor_regex
            .captures_iter(code)
            .find(|c| c.get(1).map_or(false, |m| m.as_str() == class_name))
        {
            Some(c) => c,
            None => continue,
        };

        let ctor_params_raw = match ctor_cap.get(2) {
            Some(m) => m.as_str(),
            None => continue,
        };

        // Collect fields declared in this class
        let mut fields: HashMap<String, String> = HashMap::new();
        for field_cap in field_regex.captures_iter(code) {
            if let (Some(type_match), Some(name_match)) = (field_cap.get(1), field_cap.get(2)) {
                fields.insert(
                    name_match.as_str().to_string(),
                    type_match.as_str().to_string(),
                );
            }
        }

        if fields.is_empty() {
            continue;
        }

        // Transpile params
        let mut new_params: Vec<String> = Vec::new();
        let mut converted_field_names: Vec<String> = Vec::new();

        for line in ctor_params_raw.lines() {
            let trimmed = line.trim().trim_end_matches(',');
            if trimmed.is_empty() {
                continue;
            }

            if trimmed == "super.key" {
                new_params.push("    super.key,".to_string());
            } else if trimmed.starts_with("required this.") {
                let param_name = trimmed.trim_start_matches("required this.").trim();
                if let Some(type_name) = fields.get(param_name) {
                    new_params.push(format!("    required final {} {},", type_name, param_name));
                    converted_field_names.push(param_name.to_string());
                } else {
                    new_params.push(format!("    {},", trimmed));
                }
            } else if trimmed.starts_with("this.") {
                let rest = trimmed.trim_start_matches("this.").trim();
                if let Some((param_name, default_val)) = rest.split_once('=') {
                    let p_name = param_name.trim();
                    let d_val = default_val.trim();
                    if let Some(type_name) = fields.get(p_name) {
                        new_params.push(format!("    final {} {} = {},", type_name, p_name, d_val));
                        converted_field_names.push(p_name.to_string());
                    } else {
                        new_params.push(format!("    {},", trimmed));
                    }
                } else {
                    let p_name = rest.trim();
                    if let Some(type_name) = fields.get(p_name) {
                        new_params.push(format!("    final {} {},", type_name, p_name));
                        converted_field_names.push(p_name.to_string());
                    } else {
                        new_params.push(format!("    {},", trimmed));
                    }
                }
            } else {
                new_params.push(format!("    {},", trimmed));
            }
        }

        if converted_field_names.is_empty() {
            continue;
        }

        let full_class_match = class_cap.get(0).unwrap().as_str();
        let primary_header = if let (Some(kw), Some(parent)) = (class_cap.get(2), class_cap.get(3))
        {
            format!(
                "class {}({{\n{}\n}}) {} {} {{",
                class_name,
                new_params.join("\n"),
                kw.as_str(),
                parent.as_str().trim()
            )
        } else {
            format!("class {}({{\n{}\n}}) {{", class_name, new_params.join("\n"))
        };

        result = result.replace(full_class_match, &primary_header);

        // Remove constructor block
        let ctor_full = ctor_cap.get(0).unwrap().as_str();
        result = result.replace(ctor_full, "");

        // Remove field declarations that were converted
        for field_name in converted_field_names {
            if let Some(type_name) = fields.get(&field_name) {
                let field_decl = format!("final {} {};", type_name, field_name);
                result = result.replace(&field_decl, "");
            }
        }
    }

    // Clean up empty lines created by removals
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

    cleaned_lines.join("\n")
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

        assert!(output.contains("class JustBadge({"));
        assert!(output.contains("super.key,"));
        assert!(output.contains("required final String label,"));
        assert!(output.contains("final JustBadgeVariant variant = JustBadgeVariant.solid,"));
        assert!(output.contains("}) extends StatelessWidget {"));
        assert!(!output.contains("const JustBadge({"));
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

        assert!(output.contains("class JustBreadcrumbItem({"));
        assert!(output.contains("required final String label,"));
        assert!(output.contains("final VoidCallback? onTap,"));
        assert!(!output.contains("const JustBreadcrumbItem({"));
    }

    #[test]
    fn test_transpile_fail_safe_unmatched_code() {
        let input = "class CustomWidget {}";
        let output = transpile_to_primary_constructor(input);
        assert_eq!(input, output);
    }
}
