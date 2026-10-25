@Tags(<String>['golden'])
library;

import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter/widgets.dart' show ColoredBox, Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

import '../support/golden_harness.dart';

/// Scenes of the v3 "Layout" group, each with a view size that fits it.
const Map<String, Size> _scenes = <String, Size>{
  'separator': Size(240, 80),
  'scroll-area': Size(260, 130),
  'resizable': Size(260, 110),
};

void main() {
  // The shared harness loads the text families only; core icons need the
  // Material icon font that `flutter test` bundles from the pubspec.
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  for (final MapEntry<String, Size> scene in _scenes.entries) {
    for (final (JustThemePreset preset, InkPaperMode mode) in goldenCombos) {
      testWidgets('${scene.key} ${comboName(preset, mode)}', (
        WidgetTester tester,
      ) async {
        await pumpScene(
          tester,
          scene: scene.key,
          preset: preset,
          mode: mode,
          size: scene.value,
        );
        await expectLater(
          find.byType(ColoredBox).first,
          matchesGoldenFile(
            'goldens/${scene.key}_${comboName(preset, mode)}.png',
          ),
        );
      });
    }
  }
}
