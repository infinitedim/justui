@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart' show ColoredBox;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

import '../support/golden_harness.dart';

const List<String> _scenes = <String>['button'];

void main() {
  for (final String scene in _scenes) {
    for (final (JustThemePreset preset, InkPaperMode mode) in goldenCombos) {
      testWidgets('$scene ${comboName(preset, mode)}', (
        WidgetTester tester,
      ) async {
        await pumpScene(tester, scene: scene, preset: preset, mode: mode);
        await expectLater(
          find.byType(ColoredBox).first,
          matchesGoldenFile('goldens/${scene}_${comboName(preset, mode)}.png'),
        );
      });
    }
  }
}
