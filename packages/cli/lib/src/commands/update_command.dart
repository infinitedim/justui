import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../registry/registry_client.dart';
import '../utils/logger.dart';
import '../utils/prompt.dart';
import '../utils/import_rewriter.dart';
import 'add_command.dart';

/// The CLI command to check and pull component updates.
class UpdateCommand extends Command<void> {
  @override
  final String name = 'update';

  @override
  final String description =
      'Update installed components to the latest registry version.';

  /// Mockable file system instance.
  final FileSystem fileSystem;

  /// Creates an [UpdateCommand].
  UpdateCommand(this.fileSystem);

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

    JustLogger.info('Checking for updates...');

    try {
      final client = RegistryClient(config.registryUrl, fileSystem);
      final index = await client.fetchIndex();

      // Scan local components directory
      final componentsDir = fileSystem.directory(config.componentsDir);
      if (!componentsDir.existsSync()) {
        JustLogger.warning(
          'Components directory "${config.componentsDir}" does not exist. No components installed yet.',
        );
        return;
      }

      final List<String> localComponentNames = [];
      final entities = componentsDir.listSync();
      for (final entity in entities) {
        if (entity is Directory) {
          final name = fileSystem.path.basename(entity.path);
          localComponentNames.add(name);
        }
      }

      if (localComponentNames.isEmpty) {
        JustLogger.warning('No installed components found.');
        return;
      }

      // Filter local components that differ from the registry version
      final List<String> outdatedComponents = [];
      final sharedComponents = index.computeSharedComponents();

      for (final localName in localComponentNames) {
        final matchingComponents = index.components
            .where((c) => c.name == localName)
            .toList();
        if (matchingComponents.isEmpty) continue;
        final component = matchingComponents.first;

        bool needsUpdate = false;
        final String targetDir =
            component.category == 'tokens' || component.category == 'core'
            ? config.tokensDir
            : sharedComponents.contains(component.name)
            ? config.sharedDir
            : fileSystem.path.join(config.componentsDir, component.name);

        for (final file in component.files) {
          final localFileName = sharedComponents.contains(component.name)
              ? ImportRewriter.normalizeSharedFileName(file.name)
              : file.name;
          final targetPath = fileSystem.path.join(targetDir, localFileName);
          final localFile = fileSystem.file(targetPath);
          if (!localFile.existsSync()) {
            needsUpdate = true;
            break;
          }

          final rawLocalContent = localFile.readAsStringSync();
          final localContent = rawLocalContent.replaceAll('\r\n', '\n');
          final expectedHash = file.checksum.replaceAll('sha256:', '').trim();

          final meta = ImportRewriter.parseMetadata(localContent);
          if (meta != null) {
            // Check if the registry version has changed
            if (meta.registryHash != expectedHash) {
              needsUpdate = true;
              break;
            }
          } else {
            // Fall back to direct hash check of entire file
            final localBytes = utf8.encode(localContent);
            final localHash = sha256.convert(localBytes).toString();
            if (localHash != expectedHash) {
              needsUpdate = true;
              break;
            }
          }
        }

        if (needsUpdate) {
          outdatedComponents.add(component.name);
        }
      }

      if (outdatedComponents.isEmpty) {
        JustLogger.success('All components are up-to-date!');
        return;
      }

      JustLogger.stdout('Outdated components found:');
      final selectedIndices = JustPrompt.selectMultiple(
        'Select components to update',
        outdatedComponents,
      );

      if (selectedIndices.isEmpty) {
        JustLogger.warning('No updates performed.');
        return;
      }

      // Reuse AddCommand's addComponent logic
      final addCommand = AddCommand(fileSystem);
      final visited = <String>{};
      for (final idx in selectedIndices) {
        final compName = outdatedComponents[idx];
        await addCommand.addComponent(
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
      JustLogger.error('Failed to perform update: $e');
    }
  }
}
