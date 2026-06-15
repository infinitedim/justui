import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../utils/logger.dart';

/// The CLI command to initialize JustUI in a Flutter project.
class InitCommand extends Command<void> {
  @override
  final String name = 'init';

  @override
  final String description = 'Initialize JustUI configuration in the project root.';

  /// Mockable file system instance.
  final FileSystem fileSystem;

  /// Creates an [InitCommand].
  InitCommand(this.fileSystem);

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
      JustLogger.warning('${JustUIConfig.configFileName} already exists in this project.');
      return;
    }

    // 3. Write default configuration file
    try {
      final config = JustUIConfig.default_;
      configFile.writeAsStringSync(config.toYamlString());
      JustLogger.success('JustUI initialized successfully.');
      JustLogger.info('Configuration written to ${JustUIConfig.configFileName}');
    } catch (e) {
      JustLogger.error('Failed to create configuration file: $e');
    }
  }
}
