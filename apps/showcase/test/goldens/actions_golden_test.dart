@Tags(<String>['golden'])
library;

import 'package:flutter/services.dart'
    show FontLoader, LogicalKeyboardKey, rootBundle;

import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart' show SemanticsData;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

import '../support/golden_harness.dart';

/// Every Actions scene with the view size it is locked at.
const Map<String, Size> _scenes = <String, Size>{
  'button': Size(320, 160),
  'icon-button': Size(160, 96),
  'toggle': Size(160, 96),
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

  group('keyboard', () {
    testWidgets('icon-button: one stop, Enter activates', (
      WidgetTester tester,
    ) async {
      await _pump(tester, 'icon-button');
      final List<FocusNode> stops = await _tabStops(tester);
      expect(stops, hasLength(1));
      expect(await _activate(tester, stops.single), isTrue);
      expect(find.bySemanticsLabel('Add'), findsOneWidget);
    });

    testWidgets('toggle: one stop, Space flips the pressed state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await _pump(tester, 'toggle');
      final List<FocusNode> stops = await _tabStops(tester);
      expect(stops, hasLength(1));
      expect(_bold(tester).flagsCollection.isToggled, Tristate.isTrue);
      await _activate(tester, stops.single, LogicalKeyboardKey.space);
      expect(_bold(tester).flagsCollection.isToggled, Tristate.isFalse);
      semantics.dispose();
    });
  });
}

Future<void> _pump(WidgetTester tester, String scene) => pumpScene(
  tester,
  scene: scene,
  preset: .default_,
  mode: .light,
  size: _scenes[scene]!,
);

SemanticsData _bold(WidgetTester tester) =>
    tester.getSemantics(find.bySemanticsLabel('Bold')).getSemanticsData();

/// Presses Tab until focus wraps back to the first stop and returns the
/// stops in order. Ending on a wrap proves Tab leaves the last stop (no
/// trap); on the web the same edge moves focus out of the view.
Future<List<FocusNode>> _tabStops(WidgetTester tester) async {
  final List<FocusNode> stops = <FocusNode>[];
  for (int i = 0; i < 8; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final FocusNode node = FocusManager.instance.primaryFocus!;
    if (stops.isNotEmpty && node == stops.first) return stops;
    stops.add(node);
  }
  fail('Tab did not wrap after ${stops.length} stops');
}

/// Focuses [stop], presses [key] and settles; returns whether it was handled.
Future<bool> _activate(
  WidgetTester tester,
  FocusNode stop, [
  LogicalKeyboardKey key = LogicalKeyboardKey.enter,
]) async {
  stop.requestFocus();
  await tester.pump();
  final bool handled = await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
  return handled;
}
