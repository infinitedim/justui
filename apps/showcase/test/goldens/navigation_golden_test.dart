@Tags(<String>['golden'])
library;

import 'package:flutter/services.dart'
    show FontLoader, LogicalKeyboardKey, rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

import '../support/golden_harness.dart';

/// Every Navigation scene with the view size it is locked at.
const Map<String, Size> _scenes = <String, Size>{
  'breadcrumb': Size(320, 96),
  'bottom-nav': Size(320, 120),
  'sidebar': Size(240, 200),
  'tabs': Size(360, 96),
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

  group('keyboard', _keyboardTests);
}

/// AC12: Tab in, Tab out (no trap) and activation, per scene.
void _keyboardTests() {
  testWidgets('breadcrumb: plain text, no stop', (WidgetTester tester) async {
    await _pump(tester, 'breadcrumb');
    final List<FocusNode> stops = await _tabStops(tester);
    expect(stops.single, isA<FocusScopeNode>());
  });

  testWidgets('tabs: Tab reaches each tab, Enter selects it', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pump(tester, 'tabs');
    final List<FocusNode> stops = await _tabStops(tester);
    // Core's key listener is a stop of its own before the three tabs.
    expect(stops, hasLength(4));
    expect(_selected(tester, 'Account'), isTrue);
    await _activate(tester, stops[2]);
    expect(_selected(tester, 'Billing'), isTrue);
    expect(_selected(tester, 'Account'), isFalse);
    semantics.dispose();
  });

  testWidgets('bottom-nav: one stop per item, Enter moves current', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pump(tester, 'bottom-nav');
    final List<FocusNode> stops = await _tabStops(tester);
    expect(stops, hasLength(3));
    expect(_selected(tester, 'Home'), isTrue);
    await _activate(tester, stops[1]);
    expect(_selected(tester, 'Search'), isTrue);
    expect(_selected(tester, 'Home'), isFalse);
    semantics.dispose();
  });

  testWidgets('sidebar: one stop per item, Enter moves current', (
    WidgetTester tester,
  ) async {
    await _pump(tester, 'sidebar');
    final List<FocusNode> stops = await _tabStops(tester);
    expect(stops, hasLength(3));
    expect(_weight(tester, 'Components'), FontWeight.w600);
    await _activate(tester, stops.first);
    expect(_weight(tester, 'Overview'), FontWeight.w600);
    expect(_weight(tester, 'Components'), isNot(FontWeight.w600));
  });
}

Future<void> _pump(WidgetTester tester, String scene) => pumpScene(
  tester,
  scene: scene,
  preset: .default_,
  mode: .light,
  size: _scenes[scene]!,
);

/// Whether the item labelled [label] reports the selected state.
bool _selected(WidgetTester tester, String label) => tester
    .getSemantics(find.bySemanticsLabel(RegExp('^$label')))
    .getSemanticsData()
    .flagsCollection
    .isSelected
    .toBoolOrNull()!;

/// Core's sidebar has no selected semantics; its current item is bold.
FontWeight? _weight(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style?.fontWeight;

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
