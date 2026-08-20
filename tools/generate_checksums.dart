// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Where a registry file's bytes originate from.
///
/// - [coreMirrored]: non-internal component preset (default, neobrutalism).
///   Source of truth lives in packages/core/lib/src/, registry copy is
///   mirrored from it on every run.
/// - [registryNative]: internal component. The registry file itself is the
///   source of truth — nothing to mirror.
enum FileOrigin { coreMirrored, registryNative }

/// Resolved src/dest pair + origin classification for a single file entry.
typedef ResolvedPaths = ({File srcFile, File destFile, FileOrigin origin});

void main(List<String> args) async {
  final isDryRun = args.contains('--dry-run');

  final scriptPath = File(Platform.script.toFilePath()).canonicalPath();
  final projectRoot = p.dirname(p.dirname(scriptPath));

  final indexFile = File(p.join(projectRoot, 'registry', 'index.json'));
  if (!indexFile.existsSync()) {
    print('Error: registry/index.json not found at ${indexFile.path}');
    exit(1);
  }

  final String content = await indexFile.readAsString();
  final Map<String, dynamic> indexJson =
      jsonDecode(content) as Map<String, dynamic>;
  final List<dynamic> components = indexJson['components'] as List<dynamic>;

  if (isDryRun) {
    print('Running in DRY-RUN mode. No files will be copied or written.\n');
  } else {
    print('Syncing files and calculating SHA-256 checksums...\n');
  }

  bool hasErrors = false;
  final List<String> driftedFiles = [];

  for (final dynamic component in components) {
    final compMap = component as Map<String, dynamic>;
    final Map<String, dynamic> filesMap =
        compMap['files'] as Map<String, dynamic>;
    final name = compMap['name'] as String;
    final bool isInternal = compMap['internal'] == true;
    print('-----------------------------------------');
    print('Component: $name${isInternal ? ' [internal]' : ''}');

    // Restructure filesMap to extract common files (_style, _theme, _variants)
    final Map<String, dynamic> newFilesMap = {};
    final List<Map<String, dynamic>> commonFiles = [];
    final Set<String> commonFileNames = {};

    for (final String preset in filesMap.keys.toList()) {
      if (preset == 'common') continue;
      final List<dynamic> files = filesMap[preset] as List<dynamic>;
      final List<Map<String, dynamic>> remainingPresetFiles = [];

      for (final dynamic f in files) {
        final fileMap = Map<String, dynamic>.from(f as Map<String, dynamic>);
        final String fileName = fileMap['name'] as String;

        final bool isCommon =
            fileName.endsWith('_style.dart') ||
            fileName.endsWith('_theme.dart') ||
            fileName.endsWith('_variants.dart');

        final String origPath = fileMap['path'] as String;

        if (isCommon) {
          if (!commonFileNames.contains(fileName)) {
            commonFileNames.add(fileName);
            fileMap['path'] = origPath.replaceFirst(
              RegExp(r'/(default|neobrutalism)/'),
              '/',
            );
            commonFiles.add(fileMap);
          }
        } else {
          fileMap['path'] = origPath;
          remainingPresetFiles.add(fileMap);
        }
      }

      newFilesMap[preset] = remainingPresetFiles;
    }

    final Map<String, dynamic> orderedFilesMap = {};
    if (commonFiles.isNotEmpty) {
      orderedFilesMap['common'] = commonFiles;
    }
    for (final key in newFilesMap.keys) {
      if (newFilesMap[key] != null && (newFilesMap[key] as List).isNotEmpty) {
        orderedFilesMap[key] = newFilesMap[key];
      }
    }

    compMap['files'] = orderedFilesMap;

    for (final String preset in orderedFilesMap.keys) {
      final List<dynamic> files = orderedFilesMap[preset] as List<dynamic>;
      print('  Section: $preset');

      final results = await Future.wait(
        files.map(
          (dynamic file) => _processFile(
            fileMap: file as Map<String, dynamic>,
            preset: preset,
            isInternal: isInternal,
            projectRoot: projectRoot,
            isDryRun: isDryRun,
          ),
        ),
      );

      for (final result in results) {
        if (result.error != null) {
          print('    Error: ${result.error}');
          hasErrors = true;
          continue;
        }
        if (result.drifted) {
          driftedFiles.add(result.relPath!);
          print('    [WARNING] ${result.relPath} differs from core source.');
          print(
            '              Registry will be overwritten from packages/core.',
          );
          print(
            '              Manual edits in registry/ not yet moved to core will be LOST.',
          );
        }
        print('    ${result.logLine}');
      }
    }
  }

  print('-----------------------------------------');

  if (hasErrors) {
    print('Completed with errors. Fix missing source files above and re-run.');
    exit(1);
  }

  if (driftedFiles.isNotEmpty) {
    print('\nDrift summary (${driftedFiles.length} file(s)):');
    for (final path in driftedFiles) {
      print('  - $path');
    }
  }

  if (isDryRun) {
    print('\nDry-run completed.');
    print(
      driftedFiles.isEmpty
          ? 'Status: All files in sync.'
          : 'Status: Differences detected between registry and core source.',
    );
  } else {
    // Collect all valid registry file paths from updated indexJson
    final Set<String> validAbsolutePaths = {};
    for (final dynamic comp in components) {
      final compMap = comp as Map<String, dynamic>;
      final filesMap = compMap['files'] as Map<String, dynamic>;
      for (final preset in filesMap.keys) {
        final List<dynamic> fileList = filesMap[preset] as List<dynamic>;
        for (final dynamic f in fileList) {
          final fileMap = f as Map<String, dynamic>;
          final relPath = fileMap['path'] as String;
          validAbsolutePaths.add(
            p.normalize(p.join(projectRoot, 'registry', relPath)),
          );
        }
      }
    }

    // Clean up redundant/obsolete files in registry/components
    final registryComponentsDir = Directory(
      p.join(projectRoot, 'registry', 'components'),
    );
    if (registryComponentsDir.existsSync()) {
      final List<FileSystemEntity> allEntities = registryComponentsDir.listSync(
        recursive: true,
      );
      for (final entity in allEntities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final normalizedPath = p.normalize(entity.path);
          if (!validAbsolutePaths.contains(normalizedPath)) {
            print(
              '  Removing obsolete file: ${p.relative(normalizedPath, from: projectRoot)}',
            );
            entity.deleteSync();
          }
        }
      }
    }

    const encoder = JsonEncoder.withIndent('  ');
    await indexFile.writeAsString('${encoder.convert(indexJson)}\n');
    print('\nSuccess: Updated registry/index.json and synced all files.');
    if (driftedFiles.isNotEmpty) {
      print('Warning: Some registry files were overwritten from core source.');
    }
  }
}

/// Result of processing a single file entry. Plain record — no DTO/copyWith
/// needed for a throwaway CLI script; this just keeps concurrent results
/// out of shared mutable state until the main loop prints them in order.
typedef _FileResult = ({
  String? error,
  bool drifted,
  String? relPath,
  String logLine,
});

Future<_FileResult> _processFile({
  required Map<String, dynamic> fileMap,
  required String preset,
  required bool isInternal,
  required String projectRoot,
  required bool isDryRun,
}) async {
  final String relPath = fileMap['path'] as String;
  final resolved = _resolvePaths(
    relPath: relPath,
    preset: preset,
    isInternal: isInternal,
    projectRoot: projectRoot,
  );
  final (:srcFile, :destFile, :origin) = resolved;

  if (!srcFile.existsSync()) {
    return (
      error: 'Source file not found: ${srcFile.path}',
      drifted: false,
      relPath: relPath,
      logLine: '',
    );
  }

  // Poin 1 + 4: hash-based drift check using streamed hashing instead of
  // loading both files fully into memory and comparing bytes.
  bool drifted = false;
  if (origin == FileOrigin.coreMirrored && destFile.existsSync()) {
    final srcHash = await _hashFile(srcFile);
    final destHash = await _hashFile(destFile);
    if (srcHash != destHash) {
      drifted = true;
    }
  }

  if (isDryRun) {
    final digest = await _hashFile(srcFile);
    return (
      error: null,
      drifted: drifted,
      relPath: relPath,
      logLine: '[DRY-RUN] $relPath → sha256:$digest',
    );
  }

  await destFile.parent.create(recursive: true);

  // Poin 2: pattern matching over the FileOrigin enum decides the action
  // and resulting log line, instead of an inline boolean branch.
  if (origin == FileOrigin.coreMirrored) {
    await srcFile.copy(destFile.path);
  }
  final String logLine = switch (origin) {
    FileOrigin.coreMirrored => 'Synced: $relPath',
    FileOrigin.registryNative => 'Registry-native: $relPath',
  };

  final digest = await _hashFile(destFile);

  // Poin 5: mutation is isolated to this single call site rather than
  // scattered inline in the main loop.
  _applyChecksum(fileMap, digest);

  return (error: null, drifted: drifted, relPath: relPath, logLine: logLine);
}

/// Poin 3: path resolution extracted into a pure function — no I/O side
/// effects, easy to unit test independent of the filesystem.
ResolvedPaths _resolvePaths({
  required String relPath,
  required String preset,
  required bool isInternal,
  required String projectRoot,
}) {
  final String srcRelPath = relPath.replaceFirst(
    RegExp(r'/(default|neobrutalism)/'),
    '/',
  );
  final coreFile = File(
    p.join(projectRoot, 'packages', 'core', 'lib', 'src', srcRelPath),
  );
  final bool sourcedFromCore = coreFile.existsSync();
  final origin = sourcedFromCore
      ? FileOrigin.coreMirrored
      : FileOrigin.registryNative;

  final File srcFile = sourcedFromCore
      ? coreFile
      : File(p.join(projectRoot, 'registry', relPath));

  final destFile = File(p.join(projectRoot, 'registry', relPath));

  return (srcFile: srcFile, destFile: destFile, origin: origin);
}

/// Poin 4: streamed SHA-256 instead of reading the whole file into memory
/// first via readAsBytes().
Future<Digest> _hashFile(File file) async {
  return sha256.bind(file.openRead()).first;
}

/// Poin 5: the one place fileMap gets mutated with its checksum. Keeping
/// this isolated (rather than inlined in the main loop) makes the mutation
/// explicit and easy to swap for an immutable DTO later if the script ever
/// grows beyond a single-run CLI.
void _applyChecksum(Map<String, dynamic> fileMap, Digest digest) {
  fileMap['checksum'] = 'sha256:$digest';
}

extension on File {
  String canonicalPath() {
    return File(p.normalize(path)).absolute.path;
  }
}
