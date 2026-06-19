import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../registry/registry_client.dart';
import '../utils/logger.dart';
import '../utils/prompt.dart';
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

      final List<String> componentsToAdd = [];
      final args = argResults?.rest ?? [];

      if (args.isEmpty) {
        // Render interactive selection
        final componentNames = index.components
            .map((c) => '${c.name} (${c.description})')
            .toList();
        if (componentNames.isEmpty) {
          JustLogger.error('No components found in the registry.');
          return;
        }
        JustLogger.stdout('Select components to add:');
        final selectedIndices = JustPrompt.selectMultiple(
          'Choose components',
          componentNames,
        );
        if (selectedIndices.isEmpty) {
          JustLogger.warning('No components selected.');
          return;
        }
        for (final idx in selectedIndices) {
          componentsToAdd.add(index.components[idx].name);
        }
      } else {
        componentsToAdd.addAll(args);
      }

      final visited = <String>{};
      for (final compName in componentsToAdd) {
        await addComponent(
          compName,
          index,
          client,
          config.componentsDir,
          config.tokensDir,
          visited,
        );
      }
    } catch (e) {
      JustLogger.error('Failed to add components: $e');
    }
  }

  Future<void> addComponent(
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
      await addComponent(dep, index, client, componentsDir, tokensDir, visited);
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

      bool shouldWrite = true;
      if (targetFile.existsSync()) {
        final rawLocalContent = targetFile.readAsStringSync();
        final localContent = rawLocalContent.replaceAll('\r\n', '\n');
        final localBytes = utf8.encode(localContent);
        final localHash = sha256.convert(localBytes).toString();

        if (localHash == expectedHash) {
          JustLogger.stdout('  - ${file.name} is already up-to-date.');
          shouldWrite = false;
        } else {
          JustLogger.warning(
            'Conflict: Local file "${file.name}" has been modified.',
          );
          while (true) {
            final action = JustPrompt.ask(
              '  Choose action: [o] Overwrite, [s] Skip, [d] Show Diff',
              defaultValue: 's',
            ).toLowerCase();

            if (action == 'o') {
              shouldWrite = true;
              break;
            } else if (action == 's') {
              shouldWrite = false;
              break;
            } else if (action == 'd') {
              _printLineDiff(file.name, localContent, content);
            } else {
              JustLogger.error('Invalid option. Choose o, s, or d.');
            }
          }
        }
      }

      if (shouldWrite) {
        // Create parents dynamically
        targetFile.parent.createSync(recursive: true);
        targetFile.writeAsStringSync(content);
        JustLogger.stdout('  - Copied ${file.name} to $targetDir/');
      }
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

  void _printLineDiff(String fileName, String local, String remote) {
    JustLogger.stdout('\n--- Line-by-line diff for $fileName ---');
    final localNormalized = local.replaceAll('\r\n', '\n');
    final remoteNormalized = remote.replaceAll('\r\n', '\n');
    final localLines = localNormalized.split('\n');
    final remoteLines = remoteNormalized.split('\n');
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
