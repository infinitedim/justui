import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../registry/registry_client.dart';
import '../utils/logger.dart';
import '../utils/prompt.dart';
import '../utils/pubspec_editor.dart';
import '../utils/import_rewriter.dart';
import '../utils/diff_formatter.dart';

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
      final sharedComponents = index.computeSharedComponents();
      for (final compName in componentsToAdd) {
        await addComponent(
          compName,
          index,
          client,
          config.componentsDir,
          config.tokensDir,
          config.sharedDir,
          sharedComponents,
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
    String sharedDir,
    Set<String> sharedComponents,
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
      await addComponent(
        dep,
        index,
        client,
        componentsDir,
        tokensDir,
        sharedDir,
        sharedComponents,
        visited,
      );
    }

    JustLogger.info('Adding component "$name" (v${component.version})...');

    // 2. Map target directory based on category and shared status
    final String targetDir =
        component.category == 'tokens' || component.category == 'core'
        ? tokensDir
        : sharedComponents.contains(component.name)
        ? sharedDir
        : fileSystem.path.join(componentsDir, component.name);

    // 3. Download, validate, rewrite, and write each file
    for (final file in component.files) {
      final content = await client.fetchFileContent(file.path);

      // Verify SHA-256 checksum integrity of downloaded content
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

      // Apply dynamic relative import rewriting
      final rewrittenContent = ImportRewriter.rewrite(
        content: content,
        sourceRegistryPath: file.path,
        currentComponentName: component.name,
        registryIndex: index,
        componentsDir: componentsDir,
        tokensDir: tokensDir,
        sharedDir: sharedDir,
        sharedComponents: sharedComponents,
        fileSystem: fileSystem,
      );

      final localRewrittenHash = sha256
          .convert(utf8.encode(rewrittenContent))
          .toString();
      final finalContentToWrite = ImportRewriter.injectMetadata(
        rewrittenContent,
        expectedHash,
        localRewrittenHash,
      );

      final localFileName = sharedComponents.contains(component.name)
          ? ImportRewriter.normalizeSharedFileName(file.name)
          : file.name;
      final targetPath = fileSystem.path.join(targetDir, localFileName);
      final targetFile = fileSystem.file(targetPath);

      bool shouldWrite = true;
      if (targetFile.existsSync()) {
        final rawLocalContent = targetFile.readAsStringSync();
        final localContent = rawLocalContent.replaceAll('\r\n', '\n');

        final meta = ImportRewriter.parseMetadata(localContent);
        if (meta != null) {
          final localCleanContent = ImportRewriter.stripMetadata(localContent);
          final currentLocalHash = sha256
              .convert(utf8.encode(localCleanContent))
              .toString();

          if (currentLocalHash == meta.localHash) {
            // Unmodified locally by the user
            if (meta.registryHash == expectedHash) {
              JustLogger.stdout('  - $localFileName is already up-to-date.');
              shouldWrite = false;
            } else {
              JustLogger.info(
                '  - Updating $localFileName to latest registry version.',
              );
              shouldWrite = true;
            }
          } else {
            // Locally modified by the user
            if (meta.registryHash == expectedHash) {
              // Remote is same, but local is modified -> keep local
              JustLogger.stdout(
                '  - $localFileName has been customized locally. Skipping.',
              );
              shouldWrite = false;
            } else {
              // True conflict: remote changed and local changed
              JustLogger.warning(
                'Conflict: Local file "$localFileName" has been modified, and a registry update is available.',
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
                  // Show diff of clean local content vs remote rewritten content
                  DiffFormatter.printUnifiedDiff(
                    localFileName,
                    localCleanContent,
                    rewrittenContent,
                  );
                } else {
                  JustLogger.error('Invalid option. Choose o, s, or d.');
                }
              }
            }
          }
        } else {
          // No metadata header: fall back to raw hash comparison of the entire file
          final localBytes = utf8.encode(localContent);
          final localHash = sha256.convert(localBytes).toString();

          if (localHash == expectedHash) {
            JustLogger.stdout(
              '  - $localFileName is already up-to-date (no metadata).',
            );
            shouldWrite = false;
          } else {
            JustLogger.warning(
              'Conflict: Local file "$localFileName" exists and differs (no metadata).',
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
                DiffFormatter.printUnifiedDiff(
                  localFileName,
                  localContent,
                  rewrittenContent,
                );
              } else {
                JustLogger.error('Invalid option. Choose o, s, or d.');
              }
            }
          }
        }
      }

      if (shouldWrite) {
        // Create parents dynamically
        targetFile.parent.createSync(recursive: true);
        targetFile.writeAsStringSync(finalContentToWrite);
        JustLogger.stdout('  - Copied $localFileName to $targetDir/');
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
}
