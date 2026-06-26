use anyhow::Result;
use regex::Regex;

use crate::config::JustUIConfig;
use crate::utils::{logger, prompt};

/// Runs the `justui create [component_name]` command.
pub fn run(component_name_arg: Option<String>, auto_yes: bool) -> Result<()> {
    // 1. Verify initialization config exists
    let config_path = std::path::Path::new(JustUIConfig::CONFIG_FILE_NAME);
    if !config_path.exists() {
        logger::error(
            "Project not initialized. Please run \"justui init\" in the root directory first.",
        );
        return Ok(());
    }

    // 2. Parse configuration
    let config = match std::fs::read_to_string(config_path) {
        Ok(content) => JustUIConfig::from_yaml(&content),
        Err(e) => {
            logger::error(&format!(
                "Failed to parse {}: {}",
                JustUIConfig::CONFIG_FILE_NAME,
                e
            ));
            return Ok(());
        }
    };

    // 3. Resolve component name
    let component_name = match component_name_arg {
        Some(n) => n,
        None => {
            let n = prompt::ask("Enter custom component name", "");
            if n.trim().is_empty() {
                logger::error("Component name cannot be empty.");
                return Ok(());
            }
            n
        }
    };

    let name_regex = Regex::new(r"^[a-zA-Z_][a-zA-Z0-9_]*$").unwrap();
    let snake_name = to_snake_case(&component_name);
    if !name_regex.is_match(&snake_name) {
        logger::error(&format!(
            "Invalid component name \"{}\". \
             It must contain only letters, numbers, or underscores.",
            component_name
        ));
        return Ok(());
    }

    let class_name = to_pascal_case(&component_name);
    let target_dir = format!("{}/{}", config.components_dir, snake_name);

    logger::info(&format!(
        "Scaffolding custom component \"{}\" in {}...",
        class_name, target_dir
    ));

    // 4. Generate the 4-file templates
    let files_to_write = vec![
        (
            format!("{}_style.dart", snake_name),
            generate_style_template(&class_name),
        ),
        (
            format!("{}_variants.dart", snake_name),
            generate_variants_template(&class_name),
        ),
        (
            format!("{}_theme.dart", snake_name),
            generate_theme_template(&class_name, &snake_name),
        ),
        (
            format!("{}.dart", snake_name),
            generate_widget_template(&class_name, &snake_name),
        ),
    ];

    std::fs::create_dir_all(&target_dir)
        .map_err(|e| anyhow::anyhow!("Failed to scaffold custom component: {}", e))?;

    for (file_name, content) in &files_to_write {
        let file_path = format!("{}/{}", target_dir, file_name);
        let path = std::path::Path::new(&file_path);

        let should_write = if path.exists() {
            if auto_yes {
                logger::stdout(&format!("[auto] Lewati {} (sudah ada)", file_name));
                false
            } else {
                prompt::confirm(
                    &format!("File \"{}\" already exists. Overwrite?", file_name),
                    false,
                )
            }
        } else {
            true
        };

        if should_write {
            std::fs::write(path, content)
                .map_err(|e| anyhow::anyhow!("Failed to scaffold custom component: {}", e))?;
            logger::stdout(&format!("  - Generated {}", file_name));
        } else if !auto_yes {
            logger::stdout(&format!("  - Skipped {}", file_name));
        }
    }

    logger::success(&format!(
        "Scaffolded custom component \"{}\" successfully.",
        class_name
    ));
    Ok(())
}

/// Converts input to snake_case.
/// Matches Dart `_toSnakeCase` exactly.
fn to_snake_case(input: &str) -> String {
    let re = Regex::new(r"([a-z])([A-Z])").unwrap();
    re.replace_all(input, "${1}_${2}")
        .replace('-', "_")
        .to_lowercase()
}

/// Converts input to PascalCase.
/// Matches Dart `_toPascalCase` exactly.
fn to_pascal_case(input: &str) -> String {
    let re = Regex::new(r"([a-z])([A-Z])").unwrap();
    let snake = re.replace_all(input, "${1}_${2}").replace('-', "_");
    snake
        .split('_')
        .map(|w| {
            if w.is_empty() {
                String::new()
            } else {
                let mut chars = w.chars();
                match chars.next() {
                    None => String::new(),
                    Some(c) => c.to_uppercase().to_string() + &chars.as_str().to_lowercase(),
                }
            }
        })
        .collect()
}

// ─── Template generators (verbatim from Dart create_command.dart) ─────────────

fn generate_style_template(class_name: &str) -> String {
    format!(
        "import 'package:flutter/widgets.dart';\n\
         \n\
         /// Customized per-instance visual styles for [{class_name}].\n\
         class {class_name}Style {{\n\
           /// Custom background color.\n\
           final Color? backgroundColor;\n\
         \n\
           /// Custom padding inside the container.\n\
           final EdgeInsetsGeometry? padding;\n\
         \n\
           /// Custom border radius.\n\
           final BorderRadius? borderRadius;\n\
         \n\
           /// Creates a [{class_name}Style] override.\n\
           const {class_name}Style({{\n\
             this.backgroundColor,\n\
             this.padding,\n\
             this.borderRadius,\n\
           }});\n\
         }}\n",
        class_name = class_name
    )
}

fn generate_variants_template(class_name: &str) -> String {
    format!(
        "/// The visual style variants for [{class_name}].\n\
         enum {class_name}Variant {{\n\
           /// Default variant.\n\
           default_,\n\
         \n\
           /// Outline variant.\n\
           outline,\n\
         }}\n\
         \n\
         /// Sizing classifications for [{class_name}].\n\
         enum {class_name}Size {{\n\
           /// Small size.\n\
           sm,\n\
         \n\
           /// Medium size.\n\
           md,\n\
         \n\
           /// Large size.\n\
           lg,\n\
         }}\n",
        class_name = class_name
    )
}

fn generate_theme_template(class_name: &str, snake_name: &str) -> String {
    format!(
        "import 'package:flutter/material.dart';\n\
         import '{snake_name}_style.dart';\n\
         \n\
         /// Global theme configuration for [{class_name}], extending Flutter's [ThemeExtension].\n\
         class {class_name}Theme extends ThemeExtension<{class_name}Theme> {{\n\
           /// Style override for the default variant.\n\
           final {class_name}Style? defaultStyle;\n\
         \n\
           /// Style override for the outline variant.\n\
           final {class_name}Style? outlineStyle;\n\
         \n\
           /// Creates a [{class_name}Theme] configuration.\n\
           const {class_name}Theme({{\n\
             this.defaultStyle,\n\
             this.outlineStyle,\n\
           }});\n\
         \n\
           /// Default configuration for the theme.\n\
           static const defaults = {class_name}Theme();\n\
         \n\
           @override\n\
           {class_name}Theme copyWith({{\n\
             {class_name}Style? defaultStyle,\n\
             {class_name}Style? outlineStyle,\n\
           }}) {{\n\
             return {class_name}Theme(\n\
               defaultStyle: defaultStyle ?? this.defaultStyle,\n\
               outlineStyle: outlineStyle ?? this.outlineStyle,\n\
             );\n\
           }}\n\
         \n\
           @override\n\
           {class_name}Theme lerp(ThemeExtension<{class_name}Theme>? other, double t) {{\n\
             if (other is! {class_name}Theme) return this;\n\
             return t < 0.5 ? this : other;\n\
           }}\n\
         }}\n",
        class_name = class_name,
        snake_name = snake_name
    )
}

fn generate_widget_template(class_name: &str, snake_name: &str) -> String {
    format!(
        "import 'package:flutter/widgets.dart';\n\
         import 'package:just_ui_core/just_ui_core.dart';\n\
         import '{snake_name}_style.dart';\n\
         import '{snake_name}_variants.dart';\n\
         import '{snake_name}_theme.dart';\n\
         \n\
         /// A custom widget [{class_name}] created following the aspect-based design conventions.\n\
         class {class_name} extends StatelessWidget {{\n\
           /// The child widget.\n\
           final Widget child;\n\
         \n\
           /// The visual style variant.\n\
           final {class_name}Variant variant;\n\
         \n\
           /// The physical size classification.\n\
           final {class_name}Size size;\n\
         \n\
           /// Per-instance style overrides.\n\
           final {class_name}Style? style;\n\
         \n\
           /// Default constructor for [{class_name}].\n\
           const {class_name}({{\n\
             super.key,\n\
             required this.child,\n\
             this.variant = .default_,\n\
             this.size = .md,\n\
             this.style,\n\
           }});\n\
         \n\
           @override\n\
           Widget build(BuildContext context) {{\n\
             // Aspect-based read of design tokens\n\
             final colors = context.justColors;\n\
             final spacing = context.justSpacing;\n\
             final radius = context.justRadius;\n\
         \n\
             // Resolve theme style\n\
             // Try to retrieve widget theme extension from Flutter's InheritedTheme if registered\n\
             // e.g. BuildContext has standard extensions access if passed to ThemeData.extensions.\n\
             final theme = context.justTheme;\n\
             final widgetTheme = Theme.of(context).extension<{class_name}Theme>() ?? {class_name}Theme.defaults;\n\
         \n\
             // Resolve base styles by variant\n\
             final baseStyle = variant == .outline ? widgetTheme.outlineStyle : widgetTheme.defaultStyle;\n\
         \n\
             // Resolve sizes\n\
             double paddingH;\n\
             double paddingV;\n\
             BorderRadius defaultRadius;\n\
         \n\
             switch (size) {{\n\
               case .sm:\n\
                 paddingH = spacing.sm;\n\
                 paddingV = spacing.xs;\n\
                 defaultRadius = .all(radius.sm);\n\
                 break;\n\
               case .md:\n\
                 paddingH = spacing.md;\n\
                 paddingV = spacing.sm;\n\
                 defaultRadius = .all(radius.md);\n\
                 break;\n\
               case .lg:\n\
                 paddingH = spacing.lg;\n\
                 paddingV = spacing.md;\n\
                 defaultRadius = .all(radius.lg);\n\
                 break;\n\
             }}\n\
         \n\
             // Colors mapping\n\
             final Color bg = variant == .outline ? const Color(0x00000000) : colors.background;\n\
             final Color border = variant == .outline ? colors.borderDefault : const Color(0x00000000);\n\
         \n\
             // Combine overrides\n\
             final finalBg = style?.backgroundColor ?? baseStyle?.backgroundColor ?? bg;\n\
             final finalPadding = style?.padding ?? baseStyle?.padding ?? .symmetric(horizontal: paddingH, vertical: paddingV);\n\
             final finalRadius = style?.borderRadius ?? baseStyle?.borderRadius ?? defaultRadius;\n\
         \n\
             return Container(\n\
               padding: finalPadding,\n\
               decoration: BoxDecoration(\n\
                 color: finalBg,\n\
                 borderRadius: finalRadius,\n\
                 border: border != const Color(0x00000000) ? .all(color: border, width: 1.0) : null,\n\
               ),\n\
               child: child,\n\
             );\n\
           }}\n\
         }}\n",
        class_name = class_name,
        snake_name = snake_name
    )
}
