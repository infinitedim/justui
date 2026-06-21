import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../registry/registry_client.dart';
import '../utils/logger.dart';
import '../utils/prompt.dart';
import '../utils/import_rewriter.dart';
import '../utils/diff_formatter.dart';

/// The status type of a local file compared to the registry version.
enum DiffStatusType {
  /// File is identical to the registry version.
  upToDate,

  /// File has been modified locally by the user.
  locallyModified,

  /// Registry has a new version, and the local file is unmodified.
  updateAvailable,

  /// Registry has a new version, and the local file was also modified.
  conflict,

  /// File does not exist locally.
  missing,
}

/// Stores diff status results for an individual file.
class DiffFileStatus {
  /// File definition from the registry index.
  final RegistryFile file;

  /// Absolute local file path.
  final String targetPath;

  /// Resolved status.
  final DiffStatusType statusType;

  /// Local content with metadata stripped.
  final String localContent;

  /// Expected registry hash.
  final String expectedHash;

  /// Creates a diff file status definition.
  DiffFileStatus({
    required this.file,
    required this.targetPath,
    required this.statusType,
    required this.localContent,
    required this.expectedHash,
  });
}

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

      final List<DiffFileStatus> filesStatus = [];

      for (final file in component.files) {
        final targetPath = fileSystem.path.join(targetDir, file.name);
        final localFile = fileSystem.file(targetPath);

        final expectedHash = file.checksum.replaceAll('sha256:', '').trim();

        if (!localFile.existsSync()) {
          filesStatus.add(DiffFileStatus(
            file: file,
            targetPath: targetPath,
            statusType: DiffStatusType.missing,
            localContent: '',
            expectedHash: expectedHash,
          ));
          continue;
        }

        final rawLocalContent = localFile.readAsStringSync();
        final localContent = rawLocalContent.replaceAll('\r\n', '\n');

        final meta = ImportRewriter.parseMetadata(localContent);
        if (meta != null) {
          final localCleanContent = ImportRewriter.stripMetadata(localContent);
          final currentLocalHash =
              sha256.convert(utf8.encode(localCleanContent)).toString();

          if (currentLocalHash == meta.localHash) {
            if (meta.registryHash == expectedHash) {
              filesStatus.add(DiffFileStatus(
                file: file,
                targetPath: targetPath,
                statusType: DiffStatusType.upToDate,
                localContent: localCleanContent,
                expectedHash: expectedHash,
              ));
            } else {
              filesStatus.add(DiffFileStatus(
                file: file,
                targetPath: targetPath,
                statusType: DiffStatusType.updateAvailable,
                localContent: localCleanContent,
                expectedHash: expectedHash,
              ));
            }
          } else {
            if (meta.registryHash == expectedHash) {
              filesStatus.add(DiffFileStatus(
                file: file,
                targetPath: targetPath,
                statusType: DiffStatusType.locallyModified,
                localContent: localCleanContent,
                expectedHash: expectedHash,
              ));
            } else {
              filesStatus.add(DiffFileStatus(
                file: file,
                targetPath: targetPath,
                statusType: DiffStatusType.conflict,
                localContent: localCleanContent,
                expectedHash: expectedHash,
              ));
            }
          }
        } else {
          // No metadata header: fall back to comparing raw content hash against expected
          final localBytes = utf8.encode(localContent);
          final localHash = sha256.convert(localBytes).toString();

          if (localHash == expectedHash) {
            filesStatus.add(DiffFileStatus(
              file: file,
              targetPath: targetPath,
              statusType: DiffStatusType.upToDate,
              localContent: localContent,
              expectedHash: expectedHash,
            ));
          } else {
            filesStatus.add(DiffFileStatus(
              file: file,
              targetPath: targetPath,
              statusType: DiffStatusType.locallyModified,
              localContent: localContent,
              expectedHash: expectedHash,
            ));
          }
        }
      }

      // Print status overview
      for (final fs in filesStatus) {
        switch (fs.statusType) {
          case DiffStatusType.upToDate:
            JustLogger.success('${fs.file.name}: Up to date.');
            break;
          case DiffStatusType.locallyModified:
            JustLogger.warning('${fs.file.name}: Modified locally.');
            break;
          case DiffStatusType.updateAvailable:
            JustLogger.info('${fs.file.name}: Update available.');
            break;
          case DiffStatusType.conflict:
            JustLogger.warning('${fs.file.name}: Conflict (both modified).');
            break;
          case DiffStatusType.missing:
            JustLogger.warning(
              'File ${fs.file.name} is missing locally (needs to be added).',
            );
            break;
        }
      }

      // Check if there are any differences
      final changedFiles = filesStatus
          .where((fs) => fs.statusType != DiffStatusType.upToDate)
          .toList();

      if (changedFiles.isEmpty) {
        return;
      }

      if (isVerbose) {
        for (final fs in changedFiles) {
          if (fs.statusType == DiffStatusType.missing) continue;
          final remoteRaw = await client.fetchFileContent(fs.file.path);
          final remoteRewritten = ImportRewriter.rewrite(
            content: remoteRaw,
            sourceRegistryPath: fs.file.path,
            currentComponentName: componentName,
            registryIndex: index,
            componentsDir: config.componentsDir,
            tokensDir: config.tokensDir,
            fileSystem: fileSystem,
          );
          _printLineDiff(fs.file.name, fs.localContent, remoteRewritten);
        }
        return;
      }

      // Helper to print all diffs with a specific context count
      Future<void> showAllDiffs(int context) async {
        for (final fs in changedFiles) {
          if (fs.statusType == DiffStatusType.missing) {
            JustLogger.info('\n[File "${fs.file.name}" is missing locally]');
            continue;
          }
          final remoteRaw = await client.fetchFileContent(fs.file.path);
          final remoteRewritten = ImportRewriter.rewrite(
            content: remoteRaw,
            sourceRegistryPath: fs.file.path,
            currentComponentName: componentName,
            registryIndex: index,
            componentsDir: config.componentsDir,
            tokensDir: config.tokensDir,
            fileSystem: fileSystem,
          );
          DiffFormatter.printUnifiedDiff(
            fs.file.name,
            fs.localContent,
            remoteRewritten,
            contextCount: context,
          );
        }
      }

      // Show initial diffs
      await showAllDiffs(3);

      // Prompt loop
      while (true) {
        JustLogger.stdout('\nOptions:');
        JustLogger.stdout('  [a] Apply all changes');
        JustLogger.stdout('  [s] Select changes to apply');
        JustLogger.stdout('  [v] View full diff');
        JustLogger.stdout('  [q] Quit');

        final choice =
            JustPrompt.ask('Choose option', defaultValue: 'q').toLowerCase();

        if (choice == 'q') {
          break;
        } else if (choice == 'v') {
          await showAllDiffs(99999);
        } else if (choice == 'a') {
          for (final fs in changedFiles) {
            await _applyFileChange(fs, componentName, index, client, config);
          }
          JustLogger.success('All changes applied successfully.');
          break;
        } else if (choice == 's') {
          for (final fs in changedFiles) {
            final confirm = JustPrompt.confirm(
              'Apply changes to "${fs.file.name}"?',
              defaultValue: false,
            );
            if (confirm) {
              await _applyFileChange(fs, componentName, index, client, config);
            }
          }
          JustLogger.success('Selected changes applied successfully.');
          break;
        } else {
          JustLogger.error('Invalid option.');
        }
      }
    } catch (e) {
      JustLogger.error('Failed to run diff for "$componentName": $e');
    }
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

  Future<void> _applyFileChange(
    DiffFileStatus fs,
    String componentName,
    RegistryIndex index,
    RegistryClient client,
    JustUIConfig config,
  ) async {
    final remoteRaw = await client.fetchFileContent(fs.file.path);
    final remoteRewritten = ImportRewriter.rewrite(
      content: remoteRaw,
      sourceRegistryPath: fs.file.path,
      currentComponentName: componentName,
      registryIndex: index,
      componentsDir: config.componentsDir,
      tokensDir: config.tokensDir,
      fileSystem: fileSystem,
    );

    final localHash = sha256.convert(utf8.encode(remoteRewritten)).toString();
    final finalToWrite = ImportRewriter.injectMetadata(
      remoteRewritten,
      fs.expectedHash,
      localHash,
    );

    final file = fileSystem.file(fs.targetPath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(finalToWrite);
    JustLogger.stdout('  - Updated ${fs.file.name}');
  }
}
