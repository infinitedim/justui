import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import '../config/justui_config.dart';
import '../registry/registry_client.dart';
import '../utils/logger.dart';

/// The CLI command to list available components from the registry.
class ListCommand extends Command<void> {
  @override
  final String name = 'list';

  @override
  final String description = 'List all available components in the registry.';

  /// Mockable file system instance.
  final FileSystem fileSystem;

  /// Creates a [ListCommand].
  ListCommand(this.fileSystem);

  @override
  void run() async {
    // 1. Resolve registry URL from configuration or use default
    String registryUrl = JustUIConfig.default_.registryUrl;
    final configFile = fileSystem.file(JustUIConfig.configFileName);
    if (configFile.existsSync()) {
      try {
        final config = JustUIConfig.fromYaml(configFile.readAsStringSync());
        registryUrl = config.registryUrl;
      } catch (_) {
        // Fallback to default
      }
    }

    JustLogger.info('Fetching component registry from: $registryUrl');

    try {
      final client = RegistryClient(registryUrl, fileSystem);
      final index = await client.fetchIndex();

      if (index.components.isEmpty) {
        JustLogger.warning('No components found in the registry.');
        return;
      }

      JustLogger.stdout('\nAvailable components:');

      // Group components by category
      final Map<String, List<RegistryComponent>> grouped = {};
      for (final comp in index.components) {
        grouped.putIfAbsent(comp.category, () => []).add(comp);
      }

      for (final entry in grouped.entries) {
        final category = entry.key;
        final comps = entry.value;

        // Print category header capitalized
        final capitalizedCategory = category.isNotEmpty
            ? category[0].toUpperCase() + category.substring(1)
            : 'General';
        JustLogger.stdout('  $capitalizedCategory:');

        for (final comp in comps) {
          final dot = '\x1B[32m●\x1B[0m'; // Green bullet
          final nameStr = comp.name.padRight(16);
          final versionStr = '(${comp.version})'.padRight(10);
          JustLogger.stdout(
            '    $dot $nameStr $versionStr ${comp.description}',
          );
        }
      }
      JustLogger.stdout('');
    } catch (e) {
      JustLogger.error('Failed to list components: $e');
    }
  }
}
