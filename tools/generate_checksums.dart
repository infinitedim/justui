// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  final isDryRun = args.contains('--dry-run');

  // Find the project root relative to this script's location
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

  for (final dynamic component in components) {
    final compMap = component as Map<String, dynamic>;
    final Map<String, dynamic> filesMap =
        compMap['files'] as Map<String, dynamic>;
    final name = compMap['name'] as String;
    print('-----------------------------------------');
    print('Component: $name');

    for (final String preset in filesMap.keys) {
      final List<dynamic> files = filesMap[preset] as List<dynamic>;
      print('  Preset: $preset');
      for (final dynamic file in files) {
        final fileMap = file as Map<String, dynamic>;
        final String relPath = fileMap['path'] as String;
        // Strip '/default/' from relPath to locate the flat source file in core
        final String srcRelPath = relPath.replaceFirst('/default/', '/');
        final srcFile = File(
          p.join(projectRoot, 'packages', 'core', 'lib', 'src', srcRelPath),
        );
        final destFile = File(p.join(projectRoot, 'registry', relPath));

        if (!srcFile.existsSync()) {
          print('Error: Source file not found: ${srcFile.path}');
          exit(1);
        }

        // Check for drift (difference between existing registry file and source)
        if (destFile.existsSync()) {
          final existingBytes = await destFile.readAsBytes();
          final srcBytes = await srcFile.readAsBytes();
          if (!_bytesEqual(existingBytes, srcBytes)) {
            hasDrifts = true;
            print('    [WARNING] $relPath di registry/ berbeda dari source.');
            print(
              '              Registry akan di-overwrite dari source packages/core.',
            );
            print(
              '              Jika ada edit manual di registry yang belum dipindah ke source,',
            );
            print('              edit itu akan HILANG.');
          }
        }

        final Digest digest;
        if (isDryRun) {
          // Compute checksum from source
          final bytes = await srcFile.readAsBytes();
          digest = sha256.convert(bytes);
          print('    [DRY-RUN] Checksum for $relPath: sha256:$digest');
        } else {
          // Ensure destination folder exists
          await destFile.parent.create(recursive: true);

          // Copy source file to destination registry directory
          await srcFile.copy(destFile.path);
          print('    Synced: $relPath');

          // Calculate SHA-256 checksum
          final bytes = await destFile.readAsBytes();
          digest = sha256.convert(bytes);
          fileMap['checksum'] = 'sha256:$digest';
        }
      }
    }
  }

  print('-----------------------------------------');

  if (isDryRun) {
    print('Dry-run completed. Checksums calculated from source files.');
    if (hasDrifts) {
      print('Status: Differences detected between registry and source files.');
    } else {
      print('Status: Registry and source files are in sync.');
    }
  } else {
    // Write updated index.json back with formatting
    const encoder = JsonEncoder.withIndent('  ');
    await indexFile.writeAsString('${encoder.convert(indexJson)}\n');
    print('Success: Updated registry/index.json and synced all files.');
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
