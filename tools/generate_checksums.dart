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
  final bool isDryRun = args.contains('--dry-run');

  final String scriptPath = File(Platform.script.toFilePath()).absolute
      .resolveSymbolicLinksSync();
  final String projectRoot = p.dirname(p.dirname(scriptPath));

  final File indexFile = File(p.join(projectRoot, 'registry', 'index.json'));
  if (!indexFile.existsSync()) {
    print('Error: registry/index.json not found at ${indexFile.path}');
    exit(1);
  }

  final String content = await indexFile.readAsString();
  final Map<String, dynamic> indexJson =
      jsonDecode(content) as Map<String, dynamic>;
  final List<dynamic> components = indexJson['components'] as List<dynamic>;

  final File corePubspecFile = File(
    p.join(projectRoot, 'packages', 'core', 'pubspec.yaml'),
  );
  String? coreVersion;
  if (corePubspecFile.existsSync()) {
    final String pubspecContent = corePubspecFile.readAsStringSync();
    final RegExpMatch? versionMatch = RegExp(
      r'^version:\s*([^\s]+)',
      multiLine: true,
    ).firstMatch(pubspecContent);
    if (versionMatch != null) {
      coreVersion = versionMatch.group(1);
    }
  }

  if (coreVersion != null) {
    indexJson['version'] = coreVersion;
    print(
      'Target registry version: $coreVersion (from packages/core/pubspec.yaml)',
    );
  }

  if (isDryRun) {
    print('Running in DRY-RUN mode. No files will be copied or written.\n');
  } else {
    print('Syncing files and calculating SHA-256 checksums...\n');
  }

  bool hasErrors = false;
  final List<String> driftedFiles = <String>[];

  // Build a set of all file names already registered across all components in index.json
  final Set<String> registeredFileNames = <String>{};
  for (final dynamic comp in components) {
    final Map<String, dynamic> compMap = comp as Map<String, dynamic>;
    final Map<String, dynamic> filesMap =
        compMap['files'] as Map<String, dynamic>? ?? <String, dynamic>{};
    for (final String preset in filesMap.keys) {
      final List<dynamic> fileList =
          filesMap[preset] as List<dynamic>? ?? <dynamic>[];
      for (final dynamic f in fileList) {
        final Map<String, dynamic> fMap = f as Map<String, dynamic>;
        registeredFileNames.add(fMap['name'] as String);
      }
    }
  }

  for (final dynamic component in components) {
    final Map<String, dynamic> compMap = component as Map<String, dynamic>;
    if (coreVersion != null) {
      compMap['version'] = coreVersion;
    }
    final Map<String, dynamic> filesMap =
        compMap['files'] as Map<String, dynamic>;
    final String name = compMap['name'] as String;
    final bool isInternal = compMap['internal'] == true;
    print('-----------------------------------------');
    print('Component: $name${isInternal ? ' [internal]' : ''}');

    // Determine component folder in packages/core/lib/src/components/
    String? compFolder;
    for (final String preset in filesMap.keys) {
      final List<dynamic> fileList =
          filesMap[preset] as List<dynamic>? ?? <dynamic>[];
      for (final dynamic f in fileList) {
        final String? path = (f as Map<String, dynamic>)['path'] as String?;
        if (path != null && path.startsWith('components/')) {
          final List<String> parts = path.split('/');
          if (parts.length > 1) {
            compFolder = parts[1];
            break;
          }
        }
      }
      if (compFolder != null) break;
    }
    compFolder ??= name.replaceAll('-', '_');

    // Auto-Discovery: scan packages/core/lib/src/components/<compFolder>
    final Directory coreCompDir = Directory(
      p.join(
        projectRoot,
        'packages',
        'core',
        'lib',
        'src',
        'components',
        compFolder,
      ),
    );

    final Set<String> existingComponentFileNames = <String>{};
    for (final String preset in filesMap.keys) {
      final List<dynamic> fileList =
          filesMap[preset] as List<dynamic>? ?? <dynamic>[];
      for (final dynamic f in fileList) {
        existingComponentFileNames.add(
          (f as Map<String, dynamic>)['name'] as String,
        );
      }
    }

    if (coreCompDir.existsSync()) {
      final Iterable<File> coreFiles = coreCompDir
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'));

      final String nameSnake = name.replaceAll('-', '_');

      for (final File fileEntity in coreFiles) {
        final String fileName = p.basename(fileEntity.path);
        if (existingComponentFileNames.contains(fileName)) continue;

        // Check if this auto-discovered file belongs to this component
        final bool isCommonFile =
            fileName.endsWith('_style.dart') ||
            fileName.endsWith('_theme.dart') ||
            fileName.endsWith('_variants.dart');

        bool belongsToThisComp = false;

        if (isCommonFile) {
          if (fileName.startsWith('just_${nameSnake}_') ||
              fileName.startsWith('_${nameSnake}_') ||
              fileName.contains(nameSnake)) {
            belongsToThisComp = true;
          } else if (!registeredFileNames.contains(fileName)) {
            belongsToThisComp = true;
          }
        } else if (fileName.contains(nameSnake) ||
            fileName.startsWith('just_$nameSnake')) {
          belongsToThisComp = true;
        }

        if (belongsToThisComp) {
          print('  Auto-discovered file: $fileName');
          existingComponentFileNames.add(fileName);
          registeredFileNames.add(fileName);

          final Map<String, dynamic> newEntry = <String, dynamic>{
            'name': fileName,
            'path': isCommonFile
                ? 'components/$compFolder/$fileName'
                : 'components/$compFolder/default/$fileName',
          };

          if (isCommonFile) {
            final List<dynamic> commonList =
                (filesMap['common'] as List<dynamic>?) ?? <dynamic>[];
            commonList.add(newEntry);
            filesMap['common'] = commonList;
          } else {
            final List<dynamic> defaultList =
                (filesMap['default'] as List<dynamic>?) ?? <dynamic>[];
            defaultList.add(newEntry);
            filesMap['default'] = defaultList;
          }
        }
      }
    }

    // Restructure filesMap to extract common files (_style, _theme, _variants)
    final Map<String, dynamic> newFilesMap = <String, dynamic>{};
    final List<Map<String, dynamic>> commonFiles = <Map<String, dynamic>>[];
    final Set<String> commonFileNames = <String>{};

    if (filesMap.containsKey('common')) {
      final List<dynamic> files = filesMap['common'] as List<dynamic>;
      for (final dynamic f in files) {
        final Map<String, dynamic> fileMap = Map<String, dynamic>.from(
          f as Map<String, dynamic>,
        );
        final String fileName = fileMap['name'] as String;
        if (!commonFileNames.contains(fileName)) {
          commonFileNames.add(fileName);
          commonFiles.add(fileMap);
        }
      }
    }

    for (final String preset in filesMap.keys.toList()) {
      if (preset == 'common') continue;
      final List<dynamic> files = filesMap[preset] as List<dynamic>;
      final List<Map<String, dynamic>> remainingPresetFiles =
          <Map<String, dynamic>>[];

      for (final dynamic f in files) {
        final Map<String, dynamic> fileMap = Map<String, dynamic>.from(
          f as Map<String, dynamic>,
        );
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

    final Map<String, dynamic> orderedFilesMap = <String, dynamic>{};
    if (commonFiles.isNotEmpty) {
      orderedFilesMap['common'] = commonFiles;
    }
    for (final String key in newFilesMap.keys) {
      if (newFilesMap[key] != null &&
          (newFilesMap[key] as List<dynamic>).isNotEmpty) {
        orderedFilesMap[key] = newFilesMap[key];
      }
    }

    compMap['files'] = orderedFilesMap;

    for (final String preset in orderedFilesMap.keys) {
      final List<dynamic> files = orderedFilesMap[preset] as List<dynamic>;
      print('  Section: $preset');

      final List<_FileResult> results = await Future.wait(
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

      for (final _FileResult result in results) {
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

  final List<String> dependencyErrors = _validateRegistryDependencies(
    components: components,
    projectRoot: projectRoot,
  );
  if (dependencyErrors.isNotEmpty) {
    print('registryDependencies do not match actual imports:');
    for (final String error in dependencyErrors) {
      print('  - $error');
    }
    hasErrors = true;
  }

  if (hasErrors) {
    print('Completed with errors. Fix the problems listed above and re-run.');
    exit(1);
  }

  if (driftedFiles.isNotEmpty) {
    print('\nDrift summary (${driftedFiles.length} file(s)):');
    for (final String path in driftedFiles) {
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
    final Set<String> validAbsolutePaths = <String>{};
    for (final dynamic comp in components) {
      final Map<String, dynamic> compMap = comp as Map<String, dynamic>;
      final Map<String, dynamic> filesMap =
          compMap['files'] as Map<String, dynamic>;
      for (final String preset in filesMap.keys) {
        final List<dynamic> fileList = filesMap[preset] as List<dynamic>;
        for (final dynamic f in fileList) {
          final Map<String, dynamic> fileMap = f as Map<String, dynamic>;
          final String relPath = fileMap['path'] as String;
          validAbsolutePaths.add(
            p.normalize(p.join(projectRoot, 'registry', relPath)),
          );
        }
      }
    }

    // Clean up redundant/obsolete files in registry/components
    final Directory registryComponentsDir = Directory(
      p.join(projectRoot, 'registry', 'components'),
    );
    if (registryComponentsDir.existsSync()) {
      final List<FileSystemEntity> allEntities = registryComponentsDir.listSync(
        recursive: true,
      );
      for (final FileSystemEntity entity in allEntities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final String normalizedPath = p.normalize(entity.path);
          if (!validAbsolutePaths.contains(normalizedPath)) {
            print(
              '  Removing obsolete file: ${p.relative(normalizedPath, from: projectRoot)}',
            );
            entity.deleteSync();
          }
        }
      }
    }

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
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
  final ResolvedPaths resolved = _resolvePaths(
    relPath: relPath,
    preset: preset,
    isInternal: isInternal,
    projectRoot: projectRoot,
  );
  final (:File srcFile, :File destFile, :FileOrigin origin) = resolved;

  if (!srcFile.existsSync()) {
    return (
      error: 'Source file not found: ${srcFile.path}',
      drifted: false,
      relPath: relPath,
      logLine: '',
    );
  }

  // Detect manual edits made in registry/ that would be overwritten by the
  // core mirror. Hashes are streamed so large files are never fully buffered.
  bool drifted = false;
  if (origin == .coreMirrored && destFile.existsSync()) {
    final Digest srcHash = await _hashFile(srcFile);
    final Digest destHash = await _hashFile(destFile);
    if (srcHash != destHash) {
      drifted = true;
    }
  }

  if (isDryRun) {
    final Digest digest = await _hashFile(srcFile);
    return (
      error: null,
      drifted: drifted,
      relPath: relPath,
      logLine: '[DRY-RUN] $relPath → sha256:$digest',
    );
  }

  await destFile.parent.create(recursive: true);

  // Only core-mirrored files are copied; registry-native files are already
  // the source of truth and are just re-hashed.
  if (origin == .coreMirrored) {
    await srcFile.copy(destFile.path);
  }
  final String logLine = switch (origin) {
    .coreMirrored => 'Synced: $relPath',
    .registryNative => 'Registry-native: $relPath',
  };

  final Digest digest = await _hashFile(destFile);

  _applyChecksum(fileMap, digest);

  return (error: null, drifted: drifted, relPath: relPath, logLine: logLine);
}

/// Maps a registry-relative path to its source and destination files.
///
/// Preset folders (`default/`, `neobrutalism/`) are stripped to find the
/// matching file in `packages/core/lib/src`; when no core file exists the
/// registry copy itself is the source.
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
  final File coreFile = File(
    p.join(projectRoot, 'packages', 'core', 'lib', 'src', srcRelPath),
  );
  final bool sourcedFromCore = coreFile.existsSync();
  final FileOrigin origin = sourcedFromCore ? .coreMirrored : .registryNative;

  final File srcFile = sourcedFromCore
      ? coreFile
      : File(p.join(projectRoot, 'registry', relPath));

  final File destFile = File(p.join(projectRoot, 'registry', relPath));

  return (srcFile: srcFile, destFile: destFile, origin: origin);
}

/// Cross-checks every component's declared `registryDependencies` against the
/// relative imports its files actually contain. Theme and overlay imports are
/// satisfied by the core kernel and are ignored.
List<String> _validateRegistryDependencies({
  required List<dynamic> components,
  required String projectRoot,
}) {
  final RegExp presetSegment = RegExp(r'/(default|neobrutalism)/');
  final RegExp relativeImport = RegExp(
    r"^(?:import|export)\s+'([^']+)'",
    multiLine: true,
  );

  final Map<String, String> ownerByCanonicalPath = <String, String>{};
  for (final dynamic comp in components) {
    final Map<String, dynamic> compMap = comp as Map<String, dynamic>;
    final Map<String, dynamic> filesMap =
        compMap['files'] as Map<String, dynamic>;
    for (final dynamic fileList in filesMap.values) {
      for (final dynamic f in fileList as List<dynamic>) {
        final String path = (f as Map<String, dynamic>)['path'] as String;
        ownerByCanonicalPath.putIfAbsent(
          p.posix.normalize(path.replaceFirst(presetSegment, '/')),
          () => compMap['name'] as String,
        );
      }
    }
  }

  final List<String> errors = <String>[];
  for (final dynamic comp in components) {
    final Map<String, dynamic> compMap = comp as Map<String, dynamic>;
    final String name = compMap['name'] as String;
    final bool isInternal = compMap['internal'] == true;
    final Map<String, dynamic> filesMap =
        compMap['files'] as Map<String, dynamic>;

    final Set<String> needed = <String>{};
    for (final MapEntry<String, dynamic> section in filesMap.entries) {
      for (final dynamic f in section.value as List<dynamic>) {
        final String relPath = (f as Map<String, dynamic>)['path'] as String;
        final File srcFile = _resolvePaths(
          relPath: relPath,
          preset: section.key,
          isInternal: isInternal,
          projectRoot: projectRoot,
        ).srcFile;
        if (!srcFile.existsSync()) continue;

        final String canonicalDir = p.posix.dirname(
          relPath.replaceFirst(presetSegment, '/'),
        );
        for (final RegExpMatch match in relativeImport.allMatches(
          srcFile.readAsStringSync(),
        )) {
          final String target = match.group(1)!;
          if (target.startsWith('package:') || target.startsWith('dart:')) {
            continue;
          }
          final String resolved = p.posix.normalize(
            p.posix.join(canonicalDir, target),
          );
          if (resolved.startsWith('theme/') ||
              resolved.startsWith('overlay/') ||
              resolved.startsWith('..')) {
            continue;
          }
          final String? owner = ownerByCanonicalPath[resolved];
          if (owner == null) {
            errors.add('$name: $relPath imports unregistered file $resolved');
          } else if (owner != name) {
            needed.add(owner);
          }
        }
      }
    }

    final Set<String> declared =
        ((compMap['registryDependencies'] as List<dynamic>?) ?? <dynamic>[])
            .cast<String>()
            .toSet();
    final Set<String> missing = needed.difference(declared);
    final Set<String> unused = declared.difference(needed);
    if (missing.isNotEmpty) {
      errors.add('$name: missing ${missing.toList()..sort()}');
    }
    if (unused.isNotEmpty) {
      errors.add('$name: unused ${unused.toList()..sort()}');
    }
  }
  return errors;
}

/// Computes the SHA-256 of [file] by streaming it, without buffering the
/// whole file in memory.
Future<Digest> _hashFile(File file) async {
  return sha256.bind(file.openRead()).first;
}

/// Stores the `sha256:<hex>` checksum on a registry file entry. This is the
/// only place where file entries in `index.json` are mutated.
void _applyChecksum(Map<String, dynamic> fileMap, Digest digest) {
  fileMap['checksum'] = 'sha256:$digest';
}
