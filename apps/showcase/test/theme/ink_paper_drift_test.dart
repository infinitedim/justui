import 'dart:io';
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:showcase/theme/ink_paper_tokens.dart';

/// The docs file the bridge colors must match.
final File _css = File('../docs/src/app/globals.css');

/// Selector that opens the light and the dark Ink and Paper role block.
const String _lightOpen = '.ink-paper,\nbody:has(.ink-paper),';
const String _darkOpen = '.dark .ink-paper,\n.dark body:has(.ink-paper),';

/// Hex roles the bridge does not paint (page-level only).
const Set<String> _pageOnly = <String>{'--ip-canvas-opposite', '--ip-band'};

/// Every `--ip-*: #rrggbb;` declaration of the block that starts at [open].
Map<String, Color> parseBlock(String css, String open) {
  final int start = css.indexOf(open);
  expect(
    start,
    isNonNegative,
    reason: 'block "$open" not found in globals.css',
  );
  final int end = css.indexOf('}', start);
  final RegExp decl = RegExp(r'(--ip-[a-z-]+):\s*#([0-9a-fA-F]{6});');
  return <String, Color>{
    for (final RegExpMatch m in decl.allMatches(css.substring(start, end)))
      m.group(1)!: Color(int.parse('FF${m.group(2)!}', radix: 16)),
  };
}

void expectSame(Map<String, Color> dart, Map<String, Color> css) {
  for (final MapEntry<String, Color> role in dart.entries) {
    expect(
      css[role.key],
      role.value,
      reason: '${role.key} differs from globals.css',
    );
  }
  final Set<String> missing = css.keys.toSet()
    ..removeAll(dart.keys)
    ..removeAll(_pageOnly);
  expect(missing, isEmpty, reason: 'roles in globals.css with no Dart value');
}

void main() {
  final String css = _css.readAsStringSync();

  test('light roles match the docs Ink and Paper block', () {
    expectSame(InkPaperTokens.light, parseBlock(css, _lightOpen));
  });

  test('dark roles match the docs Ink and Paper block', () {
    expectSame(InkPaperTokens.dark, parseBlock(css, _darkOpen));
  });
}
