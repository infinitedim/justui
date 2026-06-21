import 'package:file/file.dart';
import '../registry/registry_client.dart';

/// Represents the parsed metadata header from a file copied by JustUI.
class JustUIMetadata {
  /// The SHA-256 hash of the original file in the remote registry.
  final String registryHash;

  /// The SHA-256 hash of the file after import rewriting has been applied locally.
  final String localHash;

  /// Creates a metadata definition.
  JustUIMetadata({required this.registryHash, required this.localHash});
}

/// A helper class to rewrite relative import paths and manage metadata headers.
class ImportRewriter {
  static final RegExp _importRegExp =
      RegExp(r'''import\s+['"]([^'"]+)['"]\s*;''');
  
  static final RegExp _metaRegExp = RegExp(
    r"^// justui-meta: registry=([a-zA-Z0-9]+) local=([a-zA-Z0-9]+)\r?\n",
  );

  /// Parses the [JustUIMetadata] from the top of the file content, if present.
  static JustUIMetadata? parseMetadata(String content) {
    final match = _metaRegExp.firstMatch(content);
    if (match != null) {
      return JustUIMetadata(
        registryHash: match.group(1)!,
        localHash: match.group(2)!,
      );
    }
    return null;
  }

  /// Strips the `// justui-meta` header line from the file content if it exists.
  static String stripMetadata(String content) {
    if (_metaRegExp.hasMatch(content)) {
      return content.replaceFirst(_metaRegExp, '');
    }
    return content;
  }

  /// Prepends the metadata header line containing registry and local hashes to the content.
  static String injectMetadata(
    String content,
    String registryHash,
    String localHash,
  ) {
    final cleanContent = stripMetadata(content);
    return '// justui-meta: registry=$registryHash local=$localHash\n$cleanContent';
  }

  /// Rewrites relative imports inside [content] to align with the local directory setup.
  static String rewrite({
    required String content,
    required String sourceRegistryPath,
    required String currentComponentName,
    required RegistryIndex registryIndex,
    required String componentsDir,
    required String tokensDir,
    required FileSystem fileSystem,
  }) {
    final cleanContent = stripMetadata(content);
    final pathContext = fileSystem.path;

    // Determine the current file's local target directory
    final currentComponent = registryIndex.components.firstWhere(
      (c) => c.name == currentComponentName,
      orElse: () => throw Exception(
        'Current component "$currentComponentName" not found in registry',
      ),
    );

    final String currentDir =
        currentComponent.category == 'tokens' ||
                currentComponent.category == 'core'
            ? tokensDir
            : pathContext.join(componentsDir, currentComponentName);

    final filename = pathContext.basename(sourceRegistryPath);
    final String currentFilePath = pathContext.join(currentDir, filename);

    return cleanContent.replaceAllMapped(_importRegExp, (match) {
      final importPath = match.group(1)!;

      // Skip absolute imports (dart: and package:), unless they match local package:just_ui_core/just_ui_core.dart
      if (importPath.startsWith('package:') || importPath.startsWith('dart:')) {
        return match.group(0)!;
      }

      // Special Case: theme relative imports pointing to core theming engine
      if (importPath.contains('theme/theme_provider.dart') ||
          importPath.contains('theme/theme_data.dart') ||
          importPath.contains('theme/theme_aspects.dart') ||
          importPath.contains('theme/theme_data_material.dart')) {
        return "import 'package:just_ui_core/just_ui_core.dart';";
      }

      // Resolve the relative path in the registry context (Unix-style normalizations)
      final sourceRegDir = pathContext.dirname(sourceRegistryPath);
      final resolvedRegPath = pathContext
          .normalize(pathContext.join(sourceRegDir, importPath))
          .replaceAll('\\', '/');

      // Find which component owns this registry file
      RegistryComponent? targetComponent;
      RegistryFile? targetFile;

      for (final comp in registryIndex.components) {
        for (final file in comp.files) {
          if (file.path == resolvedRegPath) {
            targetComponent = comp;
            targetFile = file;
            break;
          }
        }
        if (targetComponent != null) break;
      }

      if (targetComponent != null && targetFile != null) {
        // Calculate the target path in the user's project
        final String targetDir = targetComponent.category == 'tokens' ||
                targetComponent.category == 'core'
            ? tokensDir
            : pathContext.join(componentsDir, targetComponent.name);

        final String targetFilePath =
            pathContext.join(targetDir, targetFile.name);

        // Compute the relative path from the current file's local directory to the target file
        final relativeImport = pathContext
            .relative(targetFilePath, from: pathContext.dirname(currentFilePath))
            .replaceAll('\\', '/');

        return "import '$relativeImport';";
      }

      // Fallback: If not found in registry index, return unchanged
      return match.group(0)!;
    });
  }
}
