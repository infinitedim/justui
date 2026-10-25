@Tags(<String>['golden'])
library;

// ignore_for_file: implementation_imports

import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/carousel/just_carousel.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

import '../support/golden_harness.dart';

/// Display scenes and the view size each one is locked in.
const Map<String, Size> _scenes = <String, Size>{
  'avatar': Size(240, 96),
  'avatar-group': Size(200, 96),
  'badge': Size(200, 80),
  'card': Size(320, 160),
  'carousel': Size(280, 168),
  'progress': Size(280, 96),
  'skeleton': Size(260, 96),
  'table': Size(320, 160),
};

void main() {
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

  group('keyboard', () {
    Future<void> pumpDefault(WidgetTester tester, String scene) => pumpScene(
      tester,
      scene: scene,
      preset: .default_,
      mode: .light,
      size: _scenes[scene]!,
    );

    testWidgets('carousel: Tab reaches it and the arrow keys change slides', (
      WidgetTester tester,
    ) async {
      await pumpDefault(tester, 'carousel');
      expect(find.text('Slide 1 of 3'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final BuildContext? focused = FocusManager.instance.primaryFocus?.context;
      expect(focused?.findAncestorWidgetOfExactType<JustCarousel>(), isNotNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Slide 2 of 3'), findsOneWidget);
      expect(find.text('Slide 1 of 3'), findsNothing);
    });

    for (final String scene in <String>[
      'avatar',
      'avatar-group',
      'badge',
      'card',
      'progress',
      'skeleton',
      'table',
    ]) {
      testWidgets('$scene has no tab stops', (WidgetTester tester) async {
        await pumpDefault(tester, scene);
        final FocusNode? before = FocusManager.instance.primaryFocus;
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(FocusManager.instance.primaryFocus, before);
      });
    }
  });
}
