import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../utils/logger.dart';
import '../utils/prompt.dart';

/// The CLI command to initialize JustUI in a Flutter project.
class InitCommand extends Command<void> {
  @override
  final String name = 'init';

  @override
  final String description =
      'Initialize JustUI configuration and themes in the project root.';

  /// Mockable file system instance.
  final FileSystem fileSystem;

  /// Creates an [InitCommand].
  /// Creates an [InitCommand].
  InitCommand(this.fileSystem) {
    argParser.addOption(
      'preset',
      help: 'Theme preset style to initialize.',
      allowed: ['default', 'neobrutalism'],
      defaultsTo: 'default',
    );
  }

  @override
  void run() {
    // 1. Verify we are in a valid project root containing a pubspec.yaml file
    final pubspec = fileSystem.file('pubspec.yaml');
    if (!pubspec.existsSync()) {
      JustLogger.error(
        'No pubspec.yaml found in the current directory.\n'
        'Please run "justui init" from the root of your Flutter project.',
      );
      return;
    }

    // 2. Check if configuration file already exists
    final configFile = fileSystem.file(JustUIConfig.configFileName);
    if (configFile.existsSync()) {
      JustLogger.warning(
        '${JustUIConfig.configFileName} already exists in this project.',
      );
      return;
    }

    final presetArg = argResults?['preset'] as String? ?? 'default';
    final wasPresetParsed = argResults?.wasParsed('preset') ?? false;

    JustLogger.stdout('=== JustUI Initialization Wizard ===');

    // Prompt for visual style preset
    String preset = presetArg;
    if (!wasPresetParsed) {
      preset = JustPrompt.ask(
        'Select visual style preset (default, neobrutalism)',
        defaultValue: 'default',
      );
      if (preset != 'default' && preset != 'neobrutalism') {
        preset = 'default';
      }
    }

    // 3. Prompt for components directory
    final componentsDir = JustPrompt.ask(
      'Enter the directory for UI components',
      defaultValue: 'lib/ui',
    );

    // 4. Prompt for tokens directory
    final tokensDir = JustPrompt.ask(
      'Enter the directory for design tokens',
      defaultValue: 'lib/tokens',
    );

    // 5. Prompt for brand seed color
    String brandColor = '#3b82f6';
    final hexRegex = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
    while (true) {
      final input = JustPrompt.ask(
        'Enter your brand seed color (HEX)',
        defaultValue: '#3b82f6',
      );
      if (hexRegex.hasMatch(input)) {
        brandColor = input;
        break;
      }
      JustLogger.error(
        'Invalid HEX color format. Please try again (e.g. #3b82f6 or FFF).',
      );
    }

    // Standardize hex representation to 8-digit uppercase (e.g. 0xFF3B82F6)
    String cleanHex = brandColor.replaceAll('#', '').toUpperCase();
    if (cleanHex.length == 3) {
      cleanHex = cleanHex.split('').map((c) => '$c$c').join();
    }
    final hexCode = '0xFF$cleanHex';

    // 6. Write configuration file
    try {
      final config = JustUIConfig(
        componentsDir: componentsDir,
        tokensDir: tokensDir,
        registryUrl: JustUIConfig.default_.registryUrl,
      );
      configFile.writeAsStringSync(config.toYamlString());
      JustLogger.success('JustUI configuration initialized.');
      JustLogger.info(
        'Configuration written to ${JustUIConfig.configFileName}',
      );

      // 7. Scaffold standard theme file bootstrap
      final themeDir = fileSystem.directory('lib/theme');
      themeDir.createSync(recursive: true);
      final themeFile = fileSystem.file('lib/theme/just_theme.dart');

      final presetParam = preset == 'neobrutalism'
          ? '\n  preset: JustThemePreset.neobrutalism,'
          : '';

      themeFile.writeAsStringSync('''
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// Dynamically generated light theme from brand seed color.
final JustThemeData justThemeLight = JustThemeData.fromSeed(
  const Color($hexCode),
  isDark: false,$presetParam
);

/// Dynamically generated dark theme from brand seed color.
final JustThemeData justThemeDark = JustThemeData.fromSeed(
  const Color($hexCode),
  isDark: true,$presetParam
);
''');
      JustLogger.success(
        'Bootstrap theme created at lib/theme/just_theme.dart',
      );
    } catch (e) {
      JustLogger.error('Failed to initialize JustUI: $e');
    }
  }
}
