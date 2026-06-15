import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../registry/registry_client.dart';
import '../utils/logger.dart';
import '../utils/pubspec_editor.dart';

/// The CLI command to copy a component and its dependencies into the target project.
class AddCommand extends Command<void> {
  @override
  final String name = 'add';

  @override
  final String description =
      'Add a component and its dependencies to your project.';

  /// Mockable file system instance.
  final FileSystem fileSystem;

  /// Creates an [AddCommand].
  AddCommand(this.fileSystem);

  @override
  void run() async {
    final args = argResults?.rest ?? [];
    if (args.isEmpty) {
      JustLogger.error(
        'Please specify a component name (e.g., "justui add button").',
      );
      return;
    }
    final componentName = args.first;

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

    JustLogger.info('Fetching registry index from: ${config.registryUrl}');

    try {
      final client = RegistryClient(config.registryUrl, fileSystem);
      final index = await client.fetchIndex();

      final visited = <String>{};
      await _addComponent(
        componentName,
        index,
        client,
        config.componentsDir,
        config.tokensDir,
        visited,
      );
    } catch (e) {
      JustLogger.error('Failed to add component "$componentName": $e');
    }
  }

  Future<void> _addComponent(
    String name,
    RegistryIndex index,
    RegistryClient client,
    String componentsDir,
    String tokensDir,
    Set<String> visited,
  ) async {
    // Circular dependency check and double-copy guard
    if (visited.contains(name)) {
      return;
    }
    visited.add(name);

    final component = index.components.firstWhere(
      (c) => c.name == name,
      orElse: () => throw Exception('Component "$name" not found in registry'),
    );

    // 1. Recursively resolve and download registry dependencies first
    for (final dep in component.registryDependencies) {
      await _addComponent(
        dep,
        index,
        client,
        componentsDir,
        tokensDir,
        visited,
      );
    }

    JustLogger.info('Adding component "$name" (v${component.version})...');

    // 2. Map target target directory based on category
    final String targetDir =
        component.category == 'tokens' || component.category == 'core'
        ? tokensDir
        : fileSystem.path.join(componentsDir, component.name);

    // 3. Download, validate, and write each file
    for (final file in component.files) {
      final content = await client.fetchFileContent(file.path);

      // Verify SHA-256 checksum integrity
      final bytes = utf8.encode(content);
      final downloadedHash = sha256.convert(bytes).toString();
      final expectedHash = file.checksum.replaceAll('sha256:', '').trim();

      if (downloadedHash != expectedHash) {
        throw Exception(
          'Security check failed: Checksum mismatch for downloaded file "${file.name}".\n'
          '  Expected: $expectedHash\n'
          '  Got:      $downloadedHash\n'
          'The download might be corrupted or tampered with.',
        );
      }

      final targetPath = fileSystem.path.join(targetDir, file.name);
      final targetFile = fileSystem.file(targetPath);

      // Create parents dynamically
      targetFile.parent.createSync(recursive: true);
      targetFile.writeAsStringSync(content);
      JustLogger.stdout('  - Copied ${file.name} to $targetDir/');
    }

    // 4. Inject third-party pub dependencies into pubspec.yaml if present
    if (component.pubDependencies.isNotEmpty) {
      final pubspecEditor = PubspecEditor(fileSystem);
      component.pubDependencies.forEach((pubDep, version) {
        try {
          pubspecEditor.addDependency(
            dependencyName: pubDep,
            versionConstraint: version,
            pubspecPath: 'pubspec.yaml',
          );
          JustLogger.success(
            'Added dependency "$pubDep: $version" to pubspec.yaml.',
          );
        } catch (e) {
          JustLogger.warning('Could not add dependency "$pubDep": $e');
        }
      });
    }

    JustLogger.success('Component "$name" added successfully.');
  }
}
