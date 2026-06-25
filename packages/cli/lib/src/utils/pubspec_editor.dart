import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

/// A utility class for safely modifying a project's `pubspec.yaml` file.
class PubspecEditor {
  /// File system wrapper to allow mocking in test suites.
  final FileSystem fileSystem;

  /// Creates a [PubspecEditor].
  PubspecEditor(this.fileSystem);

  /// Safely adds a dependency to the target `pubspec.yaml` if not already present.
  ///
  /// Preserves all user formatting, indentation, anchors, and comments by using
  /// targeted string insertion instead of parsing and re-serializing the entire file.
  void addDependency({
    required String dependencyName,
    required String versionConstraint,
    required String pubspecPath,
  }) {
    final file = fileSystem.file(pubspecPath);
    if (!file.existsSync()) {
      throw Exception('Target project pubspec.yaml not found at: $pubspecPath');
    }

    final content = file.readAsStringSync();

    // 1. Verify if dependency already exists using YAML parser
    try {
      final doc = loadYaml(content);
      if (doc is YamlMap && doc.containsKey('dependencies')) {
        final deps = doc['dependencies'];
        if (deps is YamlMap && deps.containsKey(dependencyName)) {
          // Already present, skip to avoid double addition
          return;
        }
      }
    } catch (_) {
      // If parsing fails for any reason, proceed with string manipulation
    }

    // 2. Create backup of pubspec.yaml before modification
    final backupFile = fileSystem.file('$pubspecPath.bak');
    backupFile.writeAsStringSync(content);

    // 3. Perform targeted line insertion
    final lines = content.split('\n');
    int dependenciesLineIndex = -1;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Search for top-level 'dependencies:' definition
      if (line.trim() == 'dependencies:') {
        final spaces = line.indexOf('dependencies:');
        if (spaces == 0) {
          dependenciesLineIndex = i;
          break;
        }
      }
    }

    if (dependenciesLineIndex == -1) {
      throw Exception('Root "dependencies:" key not found in pubspec.yaml.');
    }

    // Insert dependency with two spaces indentation
    final dependencyLine = '  $dependencyName: "$versionConstraint"';
    lines.insert(dependenciesLineIndex + 1, dependencyLine);

    // Write modified content back
    file.writeAsStringSync(lines.join('\n'));
  }
}
