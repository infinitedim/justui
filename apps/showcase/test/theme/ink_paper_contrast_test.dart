import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import 'package:showcase/theme/ink_paper_theme.dart';
import 'package:showcase/theme/ink_paper_tokens.dart';

/// A foreground on a background with the WCAG 2.2 AA minimum it must meet.
class const _Pair(
  final String name,
  final Color fg,
  final Color bg,
  final double min,
);

/// Text needs 4.5:1, control boundaries 3:1 (WCAG 1.4.3 and 1.4.11). axe
/// cannot measure pixels on a canvas, so the bridge checks its roles here.
List<_Pair> _pairs(InkPaperRoles r) => <_Pair>[
  _Pair('text on canvas', r.textPrimary, r.canvas, 4.5),
  _Pair('text on surface', r.textPrimary, r.surface, 4.5),
  _Pair('text on raised', r.textPrimary, r.raised, 4.5),
  _Pair('text on sunken', r.textPrimary, r.sunken, 4.5),
  _Pair('secondary text on canvas', r.textSecondary, r.canvas, 4.5),
  _Pair('secondary text on surface', r.textSecondary, r.surface, 4.5),
  _Pair('tertiary text on canvas', r.textTertiary, r.canvas, 4.5),
  _Pair('label on ink fill', r.onInverse, r.inverse, 4.5),
  _Pair('label on hovered ink', r.onInverse, r.inverseHover, 4.5),
  _Pair('label on pressed ink', r.onInverse, r.inversePressed, 4.5),
  _Pair('error on canvas', r.error, r.canvas, 4.5),
  _Pair('error on its tint', r.error, r.errorTint, 4.5),
  _Pair('success on its tint', r.success, r.successTint, 4.5),
  _Pair('warning on its tint', r.warning, r.warningTint, 4.5),
  _Pair('control border on canvas', r.borderControl, r.canvas, 3),
  _Pair('control border on surface', r.borderControl, r.surface, 3),
];

void main() {
  for (final InkPaperMode mode in InkPaperMode.values) {
    group('$mode', () {
      for (final _Pair pair in _pairs(InkPaperTheme.roles(mode))) {
        test('${pair.name} >= ${pair.min}:1', () {
          final double ratio = pair.fg.contrastRatioWith(pair.bg);
          expect(
            ratio,
            greaterThanOrEqualTo(pair.min),
            reason: '${pair.name}: ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    });
  }
}
