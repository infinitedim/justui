import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../utils/logger.dart';
import '../utils/prompt.dart';

/// The CLI command to scaffold a custom component.
class CreateCommand extends Command<void> {
  @override
  final String name = 'create';

  @override
  final String description =
      'Scaffold a standard 4-file bundle for a custom component.';

  /// Mockable file system instance.
  final FileSystem fileSystem;

  /// Creates a [CreateCommand].
  CreateCommand(this.fileSystem);

  @override
  void run() async {
    // 1. Verify initialization config exists
    final configFile = fileSystem.file(JustUIConfig.configFileName);
    if (!configFile.existsSync()) {
      JustLogger.error(
        'Project not initialized. Please run "justui init" in the root directory first.',
      );
      return;
    }

    // 2. Parse configuration
    JustUIConfig config;
    try {
      config = JustUIConfig.fromYaml(configFile.readAsStringSync());
    } catch (e) {
      JustLogger.error('Failed to parse ${JustUIConfig.configFileName}: $e');
      return;
    }

    // 3. Resolve component name
    String componentName = '';
    final args = argResults?.rest ?? [];
    if (args.isEmpty) {
      componentName = JustPrompt.ask(
        'Enter custom component name',
        defaultValue: '',
      );
      if (componentName.trim().isEmpty) {
        JustLogger.error('Component name cannot be empty.');
        return;
      }
    } else {
      componentName = args.first;
    }

    final nameRegex = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
    final snakeName = _toSnakeCase(componentName);
    if (!nameRegex.hasMatch(snakeName)) {
      JustLogger.error(
        'Invalid component name "$componentName". '
        'It must contain only letters, numbers, or underscores.',
      );
      return;
    }

    final className = _toPascalCase(componentName);
    final targetDir = fileSystem.path.join(config.componentsDir, snakeName);

    JustLogger.info(
      'Scaffolding custom component "$className" in $targetDir...',
    );

    // 4. Generate the 4-file templates
    final filesToWrite = {
      '${snakeName}_style.dart': _generateStyleTemplate(className),
      '${snakeName}_variants.dart': _generateVariantsTemplate(className),
      '${snakeName}_theme.dart': _generateThemeTemplate(className, snakeName),
      '$snakeName.dart': _generateWidgetTemplate(className, snakeName),
    };

    try {
      fileSystem.directory(targetDir).createSync(recursive: true);

      for (final entry in filesToWrite.entries) {
        final filePath = fileSystem.path.join(targetDir, entry.key);
        final file = fileSystem.file(filePath);

        bool shouldWrite = true;
        if (file.existsSync()) {
          shouldWrite = JustPrompt.confirm(
            'File "${entry.key}" already exists. Overwrite?',
            defaultValue: false,
          );
        }

        if (shouldWrite) {
          file.writeAsStringSync(entry.value);
          JustLogger.stdout('  - Generated ${entry.key}');
        } else {
          JustLogger.stdout('  - Skipped ${entry.key}');
        }
      }

      JustLogger.success(
        'Scaffolded custom component "$className" successfully.',
      );
    } catch (e) {
      JustLogger.error('Failed to scaffold custom component: $e');
    }
  }

  String _toPascalCase(String input) {
    final words = input
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)}_${m.group(2)}',
        )
        .replaceAll('-', '_')
        .split('_');
    return words
        .map((w) {
          if (w.isEmpty) return '';
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join('');
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)}_${m.group(2)}',
        )
        .replaceAll('-', '_')
        .toLowerCase();
  }

  String _generateStyleTemplate(String className) {
    return '''import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [$className].
class ${className}Style {
  /// Custom background color.
  final Color? backgroundColor;

  /// Custom padding inside the container.
  final EdgeInsetsGeometry? padding;

  /// Custom border radius.
  final BorderRadius? borderRadius;

  /// Creates a [${className}Style] override.
  const ${className}Style({
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });
}
''';
  }

  String _generateVariantsTemplate(String className) {
    return '''/// The visual style variants for [$className].
enum ${className}Variant {
  /// Default variant.
  default_,

  /// Outline variant.
  outline,
}

/// Sizing classifications for [$className].
enum ${className}Size {
  /// Small size.
  sm,

  /// Medium size.
  md,

  /// Large size.
  lg,
}
''';
  }

  String _generateThemeTemplate(String className, String snakeName) {
    return '''import 'package:flutter/material.dart';
import '${snakeName}_style.dart';

/// Global theme configuration for [$className], extending Flutter's [ThemeExtension].
class ${className}Theme extends ThemeExtension<${className}Theme> {
  /// Style override for the default variant.
  final ${className}Style? defaultStyle;

  /// Style override for the outline variant.
  final ${className}Style? outlineStyle;

  /// Creates a [${className}Theme] configuration.
  const ${className}Theme({
    this.defaultStyle,
    this.outlineStyle,
  });

  /// Default configuration for the theme.
  static const defaults = ${className}Theme();

  @override
  ${className}Theme copyWith({
    ${className}Style? defaultStyle,
    ${className}Style? outlineStyle,
  }) {
    return ${className}Theme(
      defaultStyle: defaultStyle ?? this.defaultStyle,
      outlineStyle: outlineStyle ?? this.outlineStyle,
    );
  }

  @override
  ${className}Theme lerp(ThemeExtension<${className}Theme>? other, double t) {
    if (other is! ${className}Theme) return this;
    return t < 0.5 ? this : other;
  }
}
''';
  }

  String _generateWidgetTemplate(String className, String snakeName) {
    return '''import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import '${snakeName}_style.dart';
import '${snakeName}_variants.dart';
import '${snakeName}_theme.dart';

/// A custom widget [$className] created following the aspect-based design conventions.
class $className extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// The visual style variant.
  final ${className}Variant variant;

  /// The physical size classification.
  final ${className}Size size;

  /// Per-instance style overrides.
  final ${className}Style? style;

  /// Default constructor for [$className].
  const $className({
    super.key,
    required this.child,
    this.variant = .default_,
    this.size = .md,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    // Aspect-based read of design tokens
    final colors = context.justColors;
    final spacing = context.justSpacing;
    final radius = context.justRadius;

    // Resolve theme style
    // Try to retrieve widget theme extension from Flutter's InheritedTheme if registered
    // e.g. BuildContext has standard extensions access if passed to ThemeData.extensions.
    final theme = context.justTheme;
    final widgetTheme = Theme.of(context).extension<${className}Theme>() ?? ${className}Theme.defaults;

    // Resolve base styles by variant
    final baseStyle = variant == .outline ? widgetTheme.outlineStyle : widgetTheme.defaultStyle;

    // Resolve sizes
    double paddingH;
    double paddingV;
    BorderRadius defaultRadius;

    switch (size) {
      case .sm:
        paddingH = spacing.sm;
        paddingV = spacing.xs;
        defaultRadius = .all(radius.sm);
        break;
      case .md:
        paddingH = spacing.md;
        paddingV = spacing.sm;
        defaultRadius = .all(radius.md);
        break;
      case .lg:
        paddingH = spacing.lg;
        paddingV = spacing.md;
        defaultRadius = .all(radius.lg);
        break;
    }

    // Colors mapping
    final Color bg = variant == .outline ? const Color(0x00000000) : colors.background;
    final Color border = variant == .outline ? colors.borderDefault : const Color(0x00000000);

    // Combine overrides
    final finalBg = style?.backgroundColor ?? baseStyle?.backgroundColor ?? bg;
    final finalPadding = style?.padding ?? baseStyle?.padding ?? .symmetric(horizontal: paddingH, vertical: paddingV);
    final finalRadius = style?.borderRadius ?? baseStyle?.borderRadius ?? defaultRadius;

    return Container(
      padding: finalPadding,
      decoration: BoxDecoration(
        color: finalBg,
        borderRadius: finalRadius,
        border: border != const Color(0x00000000) ? .all(color: border, width: 1.0) : null,
      ),
      child: child,
    );
  }
}
''';
  }
}
