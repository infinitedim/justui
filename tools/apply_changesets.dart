// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Mapping: changeset package name → path ke pubspec.yaml
const Map<String, String> dartPackages = <String, String>{
  'just_ui_tokens': 'packages/tokens/pubspec.yaml',
  'just_ui_core': 'packages/core/pubspec.yaml',
};

void main(List<String> args) async {
  final bool isDryRun = args.contains('--dry-run');
  final String scriptPath = File(Platform.script.toFilePath()).absolute.path;
  final String projectRoot = p.dirname(p.dirname(scriptPath));

  final Directory changesetDir = Directory(p.join(projectRoot, '.changeset'));
  if (!changesetDir.existsSync()) {
    print('No .changeset directory found. Nothing to do.');
    return;
  }

  // Kumpulkan semua changeset files (kecuali config.json)
  final List<File> changesetFiles = changesetDir
      .listSync()
      .whereType<File>()
      .where(
        (File f) => f.path.endsWith('.md') && !f.path.endsWith('README.md'),
      )
      .toList();

  if (changesetFiles.isEmpty) {
    print('No pending changesets found. Nothing to do.');
    return;
  }

  // Parse semua changeset files
  // Format changeset .md:
  // ---
  // "just_ui_tokens": patch
  // "just_ui_core": minor
  // ---
  // Description of the change
  final Map<String, String> bumpMap =
      <String, String>{}; // package → bump type (patch/minor/major)

  for (final File file in changesetFiles) {
    final String content = await file.readAsString();
    final List<String> lines = content.split('\n');
    bool inFrontmatter = false;
    int dashCount = 0;

    for (final String line in lines) {
      if (line.trim() == '---') {
        dashCount++;
        inFrontmatter = dashCount == 1;
        if (dashCount == 2) break;
        continue;
      }
      if (!inFrontmatter) continue;

      // Parse: "package_name": bump_type
      final RegExpMatch? match = RegExp(r'"([^"]+)":\s*(patch|minor|major)')
          .firstMatch(line);
      if (match != null) {
        final String pkgName = match.group(1)!;
        final String bumpType = match.group(2)!;
        // Ambil bump tertinggi jika package muncul di multiple changesets
        bumpMap[pkgName] = _highestBump(bumpMap[pkgName], bumpType);
      }
    }
  }

  if (bumpMap.isEmpty) {
    print('No package bumps found in changesets. Nothing to do.');
    return;
  }

  print('Changesets parsed. Bumps to apply:');
  for (final MapEntry<String, String> entry in bumpMap.entries) {
    print('  ${entry.key}: ${entry.value}');
  }
  print('');

  // Apply bumps ke pubspec.yaml
  for (final MapEntry<String, String> entry in bumpMap.entries) {
    final String pkgName = entry.key;
    final String bumpType = entry.value;

    if (!dartPackages.containsKey(pkgName)) continue;

    final String pubspecPath = p.join(projectRoot, dartPackages[pkgName]!);
    final File pubspecFile = File(pubspecPath);

    if (!pubspecFile.existsSync()) {
      print('Warning: pubspec.yaml not found at $pubspecPath, skipping.');
      continue;
    }

    final String content = await pubspecFile.readAsString();
    final RegExpMatch? versionMatch = RegExp(
      r'^version:\s*(\d+)\.(\d+)\.(\d+)',
      multiLine: true,
    ).firstMatch(content);

    if (versionMatch == null) {
      print('Warning: No version field found in $pubspecPath, skipping.');
      continue;
    }

    int major = int.parse(versionMatch.group(1)!);
    int minor = int.parse(versionMatch.group(2)!);
    int patch = int.parse(versionMatch.group(3)!);
    final String oldVersion = '$major.$minor.$patch';

    switch (bumpType) {
      case 'major':
        major++;
        minor = 0;
        patch = 0;
      case 'minor':
        minor++;
        patch = 0;
      case 'patch':
        patch++;
    }

    final String newVersion = '$major.$minor.$patch';
    final String newContent = content.replaceFirst(
      RegExp(r'^version:\s*\d+\.\d+\.\d+', multiLine: true),
      'version: $newVersion',
    );

    print('$pkgName: $oldVersion → $newVersion ($bumpType)');

    if (!isDryRun) {
      await pubspecFile.writeAsString(newContent);
      print('  ✔ Updated $pubspecPath');
    } else {
      print('  [dry-run] Would update $pubspecPath');
    }
  }

  if (bumpMap.containsKey('just_ui_core')) {
    final File indexFile = File(p.join(projectRoot, 'registry', 'index.json'));
    if (indexFile.existsSync()) {
      final String indexContent = await indexFile.readAsString();
      final Map<String, dynamic> indexJson =
          jsonDecode(indexContent) as Map<String, dynamic>;
      final File corePubspec = File(
        p.join(projectRoot, dartPackages['just_ui_core']!),
      );
      final String coreContent = await corePubspec.readAsString();
      final RegExpMatch? coreMatch = RegExp(
        r'^version:\s*([^\s]+)',
        multiLine: true,
      ).firstMatch(coreContent);
      if (coreMatch != null) {
        final String coreVer = coreMatch.group(1)!;
        indexJson['version'] = coreVer;
        final List<dynamic> compList =
            indexJson['components'] as List<dynamic>? ?? <dynamic>[];
        for (final dynamic comp in compList) {
          if (comp is Map<String, dynamic>) {
            comp['version'] = coreVer;
          }
        }
        if (!isDryRun) {
          const JsonEncoder encoder = JsonEncoder.withIndent('  ');
          await indexFile.writeAsString('${encoder.convert(indexJson)}\n');
          print('  ✔ Updated registry/index.json to $coreVer');
        } else {
          print('  [dry-run] Would update registry/index.json to $coreVer');
        }
      }
    }
  }

  if (isDryRun) {
    print('\nDry-run complete. No files were modified.');
  } else {
    print('\nAll Dart package versions updated successfully.');
  }
}

String _highestBump(String? existing, String incoming) {
  const List<String> order = <String>['patch', 'minor', 'major'];
  if (existing == null) return incoming;
  return order.indexOf(incoming) > order.indexOf(existing)
      ? incoming
      : existing;
}
