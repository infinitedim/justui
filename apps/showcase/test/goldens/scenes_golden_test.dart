@Tags(<String>['golden'])
library;

import 'package:flutter/widgets.dart' show ColoredBox, Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/scenes/scene_registry.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

import '../support/golden_harness.dart';
import '../support/scene_sizes.dart';

/// Every live scene in the four preset and mode combos (AC5).
void main() {
  test('every live scene has a locked size', () {
    expect(sceneSizes.keys.toSet(), sceneRegistry.keys.toSet());
  });

  for (final String scene in sceneRegistry.keys) {
    final Size size = sceneSizes[scene] ?? const Size(320, 160);
    for (final (JustThemePreset preset, InkPaperMode mode) in goldenCombos) {
      final String name = '${scene}_${comboName(preset, mode)}';
      testWidgets(name, (WidgetTester tester) async {
        await pumpScene(
          tester,
          scene: scene,
          preset: preset,
          mode: mode,
          size: size,
        );
        await expectLater(
          find.byType(ColoredBox).first,
          matchesGoldenFile('goldens/$name.png'),
        );
      });
    }
  }
}
