import 'dart:convert';
import 'dart:io';
import 'package:file/file.dart';

/// Represents a file within a registry component.
class RegistryFile {
  /// File basename (e.g., 'just_button.dart').
  final String name;

  /// Relative path within the registry (e.g., 'components/button/just_button.dart').
  final String path;

  /// Expected SHA-256 checksum prefixed with 'sha256:'.
  final String checksum;

  /// Creates a registry file definition.
  RegistryFile({
    required this.name,
    required this.path,
    required this.checksum,
  });

  /// Parses from JSON map.
  factory RegistryFile.fromJson(Map<String, dynamic> json) {
    return RegistryFile(
      name: json['name'] as String,
      path: json['path'] as String,
      checksum: json['checksum'] as String,
    );
  }
}

/// Represents a component defined in the registry.
class RegistryComponent {
  /// Unique component name identifier (e.g., 'button').
  final String name;

  /// Semantic version.
  final String version;

  /// Brief description.
  final String description;

  /// Classification category (e.g. 'primitives', 'layout').
  final String category;

  /// Names of other registry components this component depends on.
  final List<String> registryDependencies;

  /// External packages from pub.dev required by this component.
  final Map<String, String> pubDependencies;

  /// List of files that comprise this component.
  final List<RegistryFile> files;

  /// Creates a registry component.
  RegistryComponent({
    required this.name,
    required this.version,
    required this.description,
    required this.category,
    required this.registryDependencies,
    required this.pubDependencies,
    required this.files,
  });

  /// Parses from JSON map.
  factory RegistryComponent.fromJson(Map<String, dynamic> json) {
    final filesJson = json['files'] as List<dynamic>? ?? [];
    final regDepsJson = json['registryDependencies'] as List<dynamic>? ?? [];
    final pubDepsJson = json['pubDependencies'] as Map<String, dynamic>? ?? {};

    return RegistryComponent(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      registryDependencies: regDepsJson.map((e) => e.toString()).toList(),
      pubDependencies: pubDepsJson.map(
        (key, val) => MapEntry(key, val.toString()),
      ),
      files: filesJson
          .map((e) => RegistryFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents the top-level index file of the registry.
class RegistryIndex {
  /// Index schema version.
  final String version;

  /// Registered components list.
  final List<RegistryComponent> components;

  /// Creates a registry index.
  RegistryIndex({required this.version, required this.components});

  /// Parses from JSON map.
  factory RegistryIndex.fromJson(Map<String, dynamic> json) {
    final compsJson = json['components'] as List<dynamic>? ?? [];
    return RegistryIndex(
      version: json['version'] as String? ?? '1',
      components: compsJson
          .map((e) => RegistryComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns the set of component names that are considered "shared" —
  /// i.e., components that appear as a `registryDependency` of 2 or more
  /// other components.
  ///
  /// These components will be placed flat inside the `sharedDir` rather than
  /// in their own sub-folder under `componentsDir`.
  Set<String> computeSharedComponents() {
    final dependentCount = <String, int>{};
    for (final comp in components) {
      for (final dep in comp.registryDependencies) {
        dependentCount[dep] = (dependentCount[dep] ?? 0) + 1;
      }
    }
    return dependentCount.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toSet();
  }
}

/// Client class to handle fetching the registry index and files from local or remote sources.
class RegistryClient {
  /// Base URL (e.g. 'https://raw.githubusercontent.com/...') or directory path.
  final String baseUrl;

  /// File system wrapper for local lookups and mocking.
  final FileSystem fileSystem;

  /// Custom network client for testing.
  final HttpClient? httpClient;

  /// Creates a [RegistryClient].
  RegistryClient(this.baseUrl, this.fileSystem, {this.httpClient});

  bool get _isRemote =>
      baseUrl.startsWith('http://') || baseUrl.startsWith('https://');

  /// Fetches and parses the registry index.
  Future<RegistryIndex> fetchIndex() async {
    final content = await _readContent('index.json');
    final Map<String, dynamic> json =
        jsonDecode(content) as Map<String, dynamic>;
    return RegistryIndex.fromJson(json);
  }

  /// Fetches content of a component file by its relative path.
  Future<String> fetchFileContent(String relativePath) async {
    return _readContent(relativePath);
  }

  Future<String> _readContent(String relativePath) async {
    if (_isRemote) {
      final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      final url = '$cleanBaseUrl$relativePath';
      final client = httpClient ?? HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          throw Exception(
            'Failed to fetch from registry ($url): HTTP ${response.statusCode}',
          );
        }
        return await response.transform(utf8.decoder).join();
      } finally {
        if (httpClient == null) {
          client.close();
        }
      }
    } else {
      final path = fileSystem.path.join(baseUrl, relativePath);
      final file = fileSystem.file(path);
      if (!file.existsSync()) {
        throw Exception('Registry file not found at: $path');
      }
      return file.readAsStringSync();
    }
  }
}
