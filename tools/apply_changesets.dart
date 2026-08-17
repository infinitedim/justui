// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as p;

/// Mapping: changeset package name → path ke pubspec.yaml
const Map<String, String> dartPackages = {
  'just_ui_tokens': 'packages/tokens/pubspec.yaml',
  'just_ui_core': 'packages/core/pubspec.yaml',
};

void main(List<String> args) async {
  final isDryRun = args.contains('--dry-run');
  final scriptPath = File(Platform.script.toFilePath()).absolute.path;
  final projectRoot = p.dirname(p.dirname(scriptPath));

  final changesetDir = Directory(p.join(projectRoot, '.changeset'));
  if (!changesetDir.existsSync()) {
    print('No .changeset directory found. Nothing to do.');
    return;
  }

  // Kumpulkan semua changeset files (kecuali config.json)
  final changesetFiles = changesetDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md') && !f.path.endsWith('README.md'))
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
      {}; // package → bump type (patch/minor/major)

  for (final file in changesetFiles) {
    final content = await file.readAsString();
    final lines = content.split('\n');
    bool inFrontmatter = false;
    int dashCount = 0;

    for (final line in lines) {
      if (line.trim() == '---') {
        dashCount++;
        inFrontmatter = dashCount == 1;
        if (dashCount == 2) break;
        continue;
      }
      if (!inFrontmatter) continue;

      // Parse: "package_name": bump_type
      final match = RegExp(r'"([^"]+)":\s*(patch|minor|major)')
          .firstMatch(line);
      if (match != null) {
        final pkgName = match.group(1)!;
        final bumpType = match.group(2)!;
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
  for (final entry in bumpMap.entries) {
    print('  ${entry.key}: ${entry.value}');
  }
  print('');

  // Apply bumps ke pubspec.yaml
  for (final entry in bumpMap.entries) {
    final pkgName = entry.key;
    final bumpType = entry.value;

    if (!dartPackages.containsKey(pkgName)) continue;

    final pubspecPath = p.join(projectRoot, dartPackages[pkgName]!);
    final pubspecFile = File(pubspecPath);

    if (!pubspecFile.existsSync()) {
      print('Warning: pubspec.yaml not found at $pubspecPath, skipping.');
      continue;
    }

    final content = await pubspecFile.readAsString();
    final versionMatch = RegExp(
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
    final oldVersion = '$major.$minor.$patch';

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

    final newVersion = '$major.$minor.$patch';
    final newContent = content.replaceFirst(
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

  if (isDryRun) {
    print('\nDry-run complete. No files were modified.');
  } else {
    print('\nAll Dart package versions updated successfully.');
  }
}

String _highestBump(String? existing, String incoming) {
  const order = ['patch', 'minor', 'major'];
  if (existing == null) return incoming;
  return order.indexOf(incoming) > order.indexOf(existing)
      ? incoming
      : existing;
}
