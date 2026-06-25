import 'package:yaml/yaml.dart';

/// Represents the configuration options for JustUI parsed from `justui.config.yaml`.
class JustUIConfig {
  /// Directory where components should be copied (e.g., 'lib/widgets').
  final String componentsDir;

  /// Directory where design system tokens should be copied (e.g., 'lib/tokens').
  final String tokensDir;

  /// Directory where shared (multi-dependent) components are placed (e.g., 'lib/widgets/shared').
  ///
  /// Shared components are those depended upon by 2 or more other components.
  /// All their files are placed flat directly inside this directory.
  final String sharedDir;

  /// Base URL of the remote component registry.
  final String registryUrl;

  /// Creates a configuration.
  JustUIConfig({
    required this.componentsDir,
    required this.tokensDir,
    required this.sharedDir,
    required this.registryUrl,
  });

  /// The name of the configuration file.
  static const String configFileName = 'justui.config.yaml';

  /// Default configuration instance.
  static final JustUIConfig default_ = JustUIConfig(
    componentsDir: 'lib/widgets',
    tokensDir: 'lib/tokens',
    sharedDir: 'lib/widgets/shared',
    registryUrl:
        'https://raw.githubusercontent.com/infinitedim/justui/main/registry',
  );

  /// Parses config from a YAML string.
  factory JustUIConfig.fromYaml(String yamlContent) {
    try {
      final parsed = loadYaml(yamlContent);
      if (parsed is! YamlMap) {
        return JustUIConfig.default_;
      }
      final componentsDir =
          parsed['components_dir']?.toString() ?? 'lib/widgets';
      return JustUIConfig(
        componentsDir: componentsDir,
        tokensDir: parsed['tokens_dir']?.toString() ?? 'lib/tokens',
        sharedDir: parsed['shared_dir']?.toString() ?? '$componentsDir/shared',
        registryUrl:
            parsed['registry_url']?.toString() ??
            'https://raw.githubusercontent.com/infinitedim/justui/main/registry',
      );
    } catch (_) {
      return JustUIConfig.default_;
    }
  }

  /// Converts the configuration back into a formatted YAML string.
  String toYamlString() {
    return '''
# JustUI Scaffolding Configuration
# Version 1

# Target directory where copied components will be placed
components_dir: $componentsDir

# Target directory where copied token primitives will be placed
tokens_dir: $tokensDir

# Target directory for shared components (used by 2+ other components)
# All shared files are placed flat inside this directory
shared_dir: $sharedDir

# Base registry URL/path to download component sources from
registry_url: $registryUrl
''';
  }
}
