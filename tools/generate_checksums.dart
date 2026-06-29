// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

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

  bool hasDrifts = false;
  bool hasErrors = false;

  for (final dynamic component in components) {
    final compMap = component as Map<String, dynamic>;
    final Map<String, dynamic> filesMap =
        compMap['files'] as Map<String, dynamic>;
    final name = compMap['name'] as String;
    final bool isInternal = compMap['internal'] == true;
    print('-----------------------------------------');
    print('Component: $name${isInternal ? ' [internal]' : ''}');

    for (final String preset in filesMap.keys) {
      final List<dynamic> files = filesMap[preset] as List<dynamic>;
      print('  Preset: $preset');

      for (final dynamic file in files) {
        final fileMap = file as Map<String, dynamic>;
        final String relPath = fileMap['path'] as String;

        // --- Path resolution ---
        //
        // default preset + non-internal → source lives in packages/core/lib/src/
        //   (strip '/default/' segment so 'components/button/default/x.dart'
        //    becomes 'components/button/x.dart' under core/lib/src/)
        //
        // neobrutalism preset OR internal component → source lives directly
        //   in registry/ (no mirroring from core)
        //
        final bool sourcedFromCore = preset == 'default' && !isInternal;

        final File srcFile;
        if (sourcedFromCore) {
          final String srcRelPath = relPath.replaceFirst('/default/', '/');
          srcFile = File(
            p.join(projectRoot, 'packages', 'core', 'lib', 'src', srcRelPath),
          );
        } else {
          srcFile = File(p.join(projectRoot, 'registry', relPath));
        }

        final destFile = File(p.join(projectRoot, 'registry', relPath));

        if (!srcFile.existsSync()) {
          print('    Error: Source file not found: ${srcFile.path}');
          hasErrors = true;
          continue;
        }

        // Drift check only applies when source != dest (i.e. sourced from core)
        if (sourcedFromCore && destFile.existsSync()) {
          final existingBytes = await destFile.readAsBytes();
          final srcBytes = await srcFile.readAsBytes();
          if (!_bytesEqual(existingBytes, srcBytes)) {
            hasDrifts = true;
            print('    [WARNING] $relPath differs from core source.');
            print(
              '              Registry will be overwritten from packages/core.',
            );
            print(
              '              Manual edits in registry/ not yet moved to core will be LOST.',
            );
          }
        }

        final Digest digest;
        if (isDryRun) {
          final bytes = await srcFile.readAsBytes();
          digest = sha256.convert(bytes);
          print('    [DRY-RUN] $relPath → sha256:$digest');
        } else {
          await destFile.parent.create(recursive: true);

          // Only copy if sourced from core; registry-native files are already in place
          if (sourcedFromCore) {
            await srcFile.copy(destFile.path);
            print('    Synced: $relPath');
          } else {
            print('    Registry-native: $relPath');
          }

          final bytes = await destFile.readAsBytes();
          digest = sha256.convert(bytes);
          fileMap['checksum'] = 'sha256:$digest';
        }
      }
    }
  }

  print('-----------------------------------------');

  if (hasErrors) {
    print('Completed with errors. Fix missing source files above and re-run.');
    exit(1);
  }

  if (isDryRun) {
    print('Dry-run completed.');
    if (hasDrifts) {
      print('Status: Differences detected between registry and core source.');
    } else {
      print('Status: All files in sync.');
    }
  } else {
    const encoder = JsonEncoder.withIndent('  ');
    await indexFile.writeAsString('${encoder.convert(indexJson)}\n');
    print('Success: Updated registry/index.json and synced all files.');
    if (hasDrifts) {
      print('Warning: Some registry files were overwritten from core source.');
    }
  }
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

extension on File {
  String canonicalPath() {
    return File(p.normalize(path)).absolute.path;
  }
}
