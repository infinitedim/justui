import 'dart:convert';
import 'dart:io';

/// Checks every git-tracked file for bidirectional override and zero-width control characters.
///
/// Disallowed:
/// - Bidi controls: U+202A..U+202E (LRE, RLE, PDF, LRO, RLO)
/// - Bidi isolate controls: U+2066..U+2069 (LRI, RLI, FSI, PDI)
/// - Zero-width spaces & joiners: U+200B..U+200D (ZWSP, ZWNJ, ZWJ)
/// - Byte Order Mark: U+FEFF outside of file offset 0
void main(List<String> args) {
  final gitResult = Process.runSync('git', ['ls-files', '-z']);
  if (gitResult.exitCode != 0) {
    stderr.writeln('Failed to get tracked files from git: ${gitResult.stderr}');
    exit(1);
  }

  final files = (gitResult.stdout as String)
      .split('\x00')
      .where((f) => f.trim().isNotEmpty)
      .toList();

  final binaryExtensions = {
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
    '.ico',
    '.webp',
    '.zip',
    '.gz',
    '.tar',
    '.tgz',
    '.wasm',
    '.woff',
    '.woff2',
    '.ttf',
    '.eot',
    '.pdf',
  };

  int violations = 0;

  for (final filePath in files) {
    final lower = filePath.toLowerCase();
    if (binaryExtensions.any((ext) => lower.endsWith(ext))) {
      continue;
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    List<int> bytes;
    try {
      bytes = file.readAsBytesSync();
    } catch (_) {
      continue;
    }

    // Quick null byte check for binary files
    if (bytes.contains(0)) {
      continue;
    }

    String content;
    try {
      content = utf8.decode(bytes);
    } catch (_) {
      // Non-UTF-8 binary or malformed file
      continue;
    }

    final runes = content.runes.toList();
    int lineNumber = 1;

    for (int i = 0; i < runes.length; i++) {
      final r = runes[i];
      if (r == 0x0A) {
        lineNumber++;
      }

      final isBidi =
          (r >= 0x202A && r <= 0x202E) || (r >= 0x2066 && r <= 0x2069);
      final isZeroWidth = (r >= 0x200B && r <= 0x200D);
      final isDisplacedBom = (r == 0xFEFF && i > 0);

      if (isBidi || isZeroWidth || isDisplacedBom) {
        final reason = isBidi
            ? 'Bidi control character'
            : isZeroWidth
            ? 'Zero-width character'
            : 'Displaced BOM';
        stderr.writeln(
          'Security check failed: $reason (U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')}) found in $filePath:$lineNumber',
        );
        violations++;
      }
    }
  }

  if (violations > 0) {
    stderr.writeln('Total hidden Unicode violations found: $violations');
    exit(1);
  }

  stdout.writeln('All tracked files passed hidden Unicode check.');
  exit(0);
}
