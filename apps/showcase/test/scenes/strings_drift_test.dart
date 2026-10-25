import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:showcase/scenes/strings.dart';

/// The `en` entry of `kitTranslations`, parsed from the docs source.
///
/// Every entry there is one line, `key: 'text',` or `key: ['a', 'b'],`, so a
/// line match is enough and keeps the test free of a TS parser.
Map<String, Object> docsEnglish() {
  final String source = File('../docs/src/lib/kit-translations.ts')
      .readAsStringSync();
  final String en = source.substring(
    source.indexOf('  en: {'),
    source.indexOf('  id: {'),
  );
  final RegExp entry = RegExp(r"^    (\w+): (\[.*\]|'.*'),$", multiLine: true);
  final RegExp quoted = RegExp(r"'([^']*)'");
  return <String, Object>{
    for (final RegExpMatch m in entry.allMatches(en))
      m.group(1)!: m.group(2)!.startsWith('[')
          ? quoted
                .allMatches(m.group(2)!)
                .map((RegExpMatch q) => q[1]!)
                .toList()
          : m.group(2)!.substring(1, m.group(2)!.length - 1),
  };
}

void main() {
  test('EN defaults equal the docs kitTranslations.en', () {
    final Map<String, Object> docs = docsEnglish();
    expect(docs, hasLength(greaterThan(40)));
    expect(KitStrings.defaults.keys.toSet(), docs.keys.toSet());
    for (final String key in docs.keys) {
      expect(KitStrings.defaults[key], docs[key], reason: key);
    }
  });
}
