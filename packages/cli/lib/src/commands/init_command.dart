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
  InitCommand(this.fileSystem) {
    argParser.addOption(
      'preset',
      help:
          'Theme preset style to initialize. Aliases: neo=neobrutalism, d=default.',
      allowed: ['default', 'd', 'neobrutalism', 'neo'],
      defaultsTo: 'default',
    );
  }

  /// Normalizes preset aliases to their canonical names.
  String _normalizePreset(String input) {
    switch (input.toLowerCase()) {
      case 'neo':
        return 'neobrutalism';
      case 'd':
        return 'default';
      default:
        return input;
    }
  }

  /// Converts a subfolder name to a lib-rooted path.
  ///
  /// Strips any accidental leading 'lib/' prefix the user might type
  /// before prepending the canonical 'lib/' root.
  ///
  /// Examples:
  ///   'widgets'     → 'lib/widgets'
  ///   'lib/widgets' → 'lib/widgets'  (not 'lib/lib/widgets')
  String _toLibPath(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('lib/')) {
      return trimmed; // already has correct prefix
    }
    return 'lib/$trimmed';
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

    // --- Preset selection ---
    String preset;

    if (wasPresetParsed) {
      preset = _normalizePreset(presetArg);
    } else {
      JustLogger.stdout('');
      JustLogger.stdout('Select visual style preset:');
      final presetIdx = JustPrompt.selectOne('Choose preset', [
        'default',
        'neobrutalism (alias: neo)',
      ], defaultIndex: 0);
      preset = presetIdx == 1 ? 'neobrutalism' : 'default';
    }

    // --- Components directory selection ---
    JustLogger.stdout('');
    JustLogger.stdout(
      'Select UI components directory (will be created under lib/):',
    );
    final compChoices = ['widgets', 'components', 'Custom...'];
    final compIdx = JustPrompt.selectOne(
      'Choose components dir',
      compChoices,
      defaultIndex: 0,
    );

    String componentsDir;
    if (compIdx == 2) {
      // Custom — ask for subfolder name, auto-prefix lib/
      final customName = JustPrompt.ask(
        'Enter folder name (under lib/)',
        defaultValue: 'ui',
      );
      componentsDir = _toLibPath(customName);
    } else {
      componentsDir = 'lib/${compChoices[compIdx]}';
    }

    // --- Tokens directory ---
    JustLogger.stdout('');
    final tokensInput = JustPrompt.ask(
      'Enter design tokens folder name (under lib/)',
      defaultValue: 'tokens',
    );
    final tokensDir = _toLibPath(tokensInput);

    // --- Shared components directory ---
    // Default is a 'shared/' subfolder inside the components directory
    final sharedDirDefault = '$componentsDir/shared';
    final rawSharedDir = JustPrompt.ask(
      'Enter shared components folder (leave blank for default)',
      defaultValue: sharedDirDefault,
    );
    final sharedDir = rawSharedDir.isEmpty ? sharedDirDefault : rawSharedDir;

    // --- Brand seed color ---
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

    // Write configuration file
    try {
      final config = JustUIConfig(
        componentsDir: componentsDir,
        tokensDir: tokensDir,
        sharedDir: sharedDir,
        registryUrl: JustUIConfig.default_.registryUrl,
      );
      configFile.writeAsStringSync(config.toYamlString());
      JustLogger.success('JustUI configuration initialized.');
      JustLogger.info(
        'Configuration written to ${JustUIConfig.configFileName}',
      );

      // Scaffold standard theme file bootstrap
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
