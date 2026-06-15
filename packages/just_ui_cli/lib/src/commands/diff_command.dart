import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../registry/registry_client.dart';
import '../utils/logger.dart';

/// The CLI command to inspect local component differences against the registry version.
class DiffCommand extends Command<void> {
  @override
  final String name = 'diff';

  @override
  final String description =
      'Show differences between local components and registry files.';

  /// Mockable file system instance.
  final FileSystem fileSystem;

  /// Creates a [DiffCommand].
  DiffCommand(this.fileSystem) {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Show line-by-line diff details of modifications.',
      negatable: false,
    );
  }

  @override
  void run() async {
    final args = argResults?.rest ?? [];
    if (args.isEmpty) {
      JustLogger.error(
        'Please specify a component name (e.g., "justui diff button").',
      );
      return;
    }
    final componentName = args.first;
    final isVerbose = argResults?['verbose'] as bool? ?? false;

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

    JustLogger.info('Comparing component "$componentName" with registry...');

    try {
      final client = RegistryClient(config.registryUrl, fileSystem);
      final index = await client.fetchIndex();

      final component = index.components.firstWhere(
        (c) => c.name == componentName,
        orElse: () =>
            throw Exception('Component "$componentName" not found in registry'),
      );

      final String targetDir =
          component.category == 'tokens' || component.category == 'core'
          ? config.tokensDir
          : fileSystem.path.join(config.componentsDir, component.name);

      for (final file in component.files) {
        final targetPath = fileSystem.path.join(targetDir, file.name);
        final localFile = fileSystem.file(targetPath);

        if (!localFile.existsSync()) {
          JustLogger.warning(
            'File ${file.name} is missing locally (needs to be added).',
          );
          continue;
        }

        // Calculate local SHA-256 hash
        final localContent = localFile.readAsStringSync();
        final bytes = utf8.encode(localContent);
        final localHash = sha256.convert(bytes).toString();

        // Extract registry hash (format: "sha256:abc123abc...")
        final expectedHash = file.checksum.replaceAll('sha256:', '').trim();

        if (localHash == expectedHash) {
          JustLogger.success('${file.name}: Up to date.');
        } else {
          JustLogger.warning('${file.name}: Modified locally.');
          if (isVerbose) {
            final remoteContent = await client.fetchFileContent(file.path);
            _printLineDiff(file.name, localContent, remoteContent);
          }
        }
      }
    } catch (e) {
      JustLogger.error('Failed to check diff for "$componentName": $e');
    }
  }

  void _printLineDiff(String fileName, String local, String remote) {
    JustLogger.stdout('\n--- Line-by-line diff for $fileName ---');
    final localLines = local.split('\n');
    final remoteLines = remote.split('\n');
    final maxLines = localLines.length > remoteLines.length
        ? localLines.length
        : remoteLines.length;

    for (int i = 0; i < maxLines; i++) {
      final localLine = i < localLines.length ? localLines[i] : null;
      final remoteLine = i < remoteLines.length ? remoteLines[i] : null;

      if (localLine != remoteLine) {
        if (remoteLine != null && localLine == null) {
          // Added in registry
          JustLogger.stdout('\x1B[32m+ [Line ${i + 1}] $remoteLine\x1B[0m');
        } else if (localLine != null && remoteLine == null) {
          // Custom local additions
          JustLogger.stdout('\x1B[31m- [Line ${i + 1}] $localLine\x1B[0m');
        } else {
          // Modified line
          JustLogger.stdout(
            '\x1B[31m- [Line ${i + 1}] Local:    $localLine\x1B[0m',
          );
          JustLogger.stdout(
            '\x1B[32m+ [Line ${i + 1}] Registry: $remoteLine\x1B[0m',
          );
        }
      }
    }
    JustLogger.stdout('-----------------------------------------\n');
  }
}
