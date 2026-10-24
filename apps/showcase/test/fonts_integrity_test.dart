import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/sha256.dart';

/// `<sha256>  <file>` lines of the font README (packages/tokens/assets/fonts).
Map<String, String> readmeHashes() {
  final String readme = File('${fontsDir.path}/README.md').readAsStringSync();
  final RegExp line = RegExp(r'^([0-9a-f]{64})  (\S+)$', multiLine: true);
  return <String, String>{
    for (final RegExpMatch m in line.allMatches(readme))
      m.group(2)!: m.group(1)!,
  };
}

void main() {
  test('sha256 matches a known vector', () {
    expect(
      sha256Hex(Uint8List.fromList('abc'.codeUnits)),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  test('fonts resolve inside the repo through the symlink', () {
    final String target = Directory(fontsDir.path).resolveSymbolicLinksSync();
    final String repoFonts = Directory('../../packages/tokens/assets/fonts')
        .resolveSymbolicLinksSync();
    expect(target, repoFonts);
  });

  test('every font file matches the SHA-256 in the README', () {
    final Map<String, String> hashes = readmeHashes();
    final Set<String> declared = bridgeFontFiles.values
        .expand((List<String> files) => files)
        .toSet();
    expect(hashes.keys.toSet().containsAll(declared), isTrue);
    for (final MapEntry<String, String> entry in hashes.entries) {
      final Uint8List bytes = File('${fontsDir.path}/${entry.key}')
          .readAsBytesSync();
      expect(sha256Hex(bytes), entry.value, reason: entry.key);
    }
  });
}
