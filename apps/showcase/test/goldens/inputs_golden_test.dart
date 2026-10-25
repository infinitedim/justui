// ignore_for_file: implementation_imports
@Tags(<String>['golden'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart' show DateTimeRange, TimeOfDay;
import 'package:flutter/services.dart' show FontLoader, LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_range_picker.dart';
import 'package:just_ui_core/src/components/radio/just_radio_group.dart';
import 'package:just_ui_core/src/components/switch/just_switch.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

import '../support/golden_harness.dart';

/// The Inputs scenes, each with a view size that fits it unclipped.
const Map<String, Size> _scenes = <String, Size>{
  'input': Size(320, 160),
  'checkbox': Size(320, 160),
  'radio': Size(320, 160),
  'radio-group': Size(320, 160),
  'switch': Size(320, 160),
  'slider': Size(320, 160),
  'date-picker': Size(372, 400),
  'date-range-picker': Size(372, 400),
  'time-picker': Size(320, 360),
};

/// Core draws chevrons with Material icon glyphs (date pickers). The shared
/// loader only covers the text families, so this file loads the icon font
/// the SDK ships; without it the goldens would show tofu boxes.
Future<void> _loadMaterialIcons() async {
  final String? root = Platform.environment['FLUTTER_ROOT'];
  final File font = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (root == null || !font.existsSync()) {
    throw StateError('MaterialIcons font not found under FLUTTER_ROOT');
  }
  final FontLoader loader = FontLoader('MaterialIcons')
    ..addFont(
      Future<ByteData>.value(ByteData.sublistView(font.readAsBytesSync())),
    );
  await loader.load();
}

Future<void> _pump(WidgetTester tester, String scene) => pumpScene(
  tester,
  scene: scene,
  preset: .default_,
  mode: .light,
  size: _scenes[scene]!,
);

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

FocusNode? get _focus => FocusManager.instance.primaryFocus;

/// The focus node that owns the widget [finder] finds (its nearest [Focus]).
FocusNode _nodeOf(WidgetTester tester, Finder finder) =>
    Focus.of(tester.element(finder));

/// Presses Tab until [target] has focus; fails after [max] presses.
Future<void> _tabTo(
  WidgetTester tester,
  FocusNode target, {
  int max = 60,
}) async {
  for (int i = 0; i < max; i++) {
    await _press(tester, LogicalKeyboardKey.tab);
    if (_focus == target) return;
  }
  fail('Tab did not reach $target in $max presses');
}

/// Tabs from outside the scene through every stop and back to the first.
///
/// In the VM the route scope has no parent scope, so after the last stop
/// Tab wraps to the first one; on the web the same edge leaves the view
/// (`TraversalEdgeBehavior.leaveFlutterView`). Wrapping proves no stop
/// keeps Tab for itself, which is what a keyboard trap would do.
Future<List<FocusNode>> _tabCycle(WidgetTester tester) async {
  expect(
    _focus,
    isA<FocusScopeNode>(),
    reason: 'no control has focus before the first Tab',
  );
  await _press(tester, LogicalKeyboardKey.tab);
  final FocusNode first = _focus!;
  expect(first, isNot(isA<FocusScopeNode>()), reason: 'Tab enters the scene');
  final List<FocusNode> stops = <FocusNode>[first];
  for (int i = 0; i < 80; i++) {
    await _press(tester, LogicalKeyboardKey.tab);
    final FocusNode next = _focus!;
    if (next == first) return stops;
    expect(next, isNot(stops.last), reason: 'Tab moved the focus');
    stops.add(next);
  }
  fail('Tab never came back to the first stop');
}

void _traversalTests() {
  for (final String scene in _scenes.keys) {
    testWidgets('$scene: Tab in, through and out, Shift+Tab back', (
      WidgetTester tester,
    ) async {
      await _pump(tester, scene);
      final List<FocusNode> stops = await _tabCycle(tester);
      if (stops.length > 1) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await _press(tester, LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        expect(_focus, stops.last);
      }
    });
  }
}

// One scene per test: ViewHost reads its config once, in initState.
void _controlTests() {
  testWidgets('checkbox toggles with Space', (WidgetTester tester) async {
    await _pump(tester, 'checkbox');
    await _tabTo(tester, _nodeOf(tester, find.text('Remember this device')));
    await _press(tester, LogicalKeyboardKey.space);
    expect(tester.widget<JustCheckbox>(find.byType(JustCheckbox)).value, false);
  });

  testWidgets('switch toggles with Space', (WidgetTester tester) async {
    await _pump(tester, 'switch');
    await _tabTo(tester, _nodeOf(tester, find.text('Wi-Fi')));
    await _press(tester, LogicalKeyboardKey.space);
    expect(tester.widget<JustSwitch>(find.byType(JustSwitch)).value, false);
  });

  testWidgets('radio selects Monthly with Space', (WidgetTester tester) async {
    await _pump(tester, 'radio-group');
    await _tabTo(tester, _nodeOf(tester, find.text('Monthly')));
    await _press(tester, LogicalKeyboardKey.space);
    final JustRadioGroup<int> group = tester.widget<JustRadioGroup<int>>(
      find.byType(JustRadioGroup<int>),
    );
    expect(group.value, 1);
  });

  testWidgets('slider moves with the arrow keys', (WidgetTester tester) async {
    await _pump(tester, 'slider');
    await _press(tester, LogicalKeyboardKey.tab);
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('65%'), findsOneWidget);
  });

  testWidgets('input shows the rule message for an invalid name', (
    WidgetTester tester,
  ) async {
    await _pump(tester, 'input');
    const String message = 'Use lowercase letters, numbers and underscores.';
    expect(find.text(message), findsNothing);
    await _press(tester, LogicalKeyboardKey.tab);
    await tester.enterText(find.byType(EditableText), 'Just UI');
    await tester.pumpAndSettle();
    expect(find.text(message), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'just_ui_2');
    await tester.pumpAndSettle();
    expect(find.text(message), findsNothing);
  });
}

void _pickerTests() {
  testWidgets('date picker picks a day with Enter', (
    WidgetTester tester,
  ) async {
    await _pump(tester, 'date-picker');
    await _tabTo(tester, _nodeOf(tester, find.text('20')));
    await _press(tester, LogicalKeyboardKey.enter);
    final JustDatePicker picker = tester.widget<JustDatePicker>(
      find.byType(JustDatePicker),
    );
    expect(picker.value?.day, 20);
  });

  testWidgets('date range picker picks two ends with Enter', (
    WidgetTester tester,
  ) async {
    await _pump(tester, 'date-range-picker');
    await _tabTo(tester, _nodeOf(tester, find.text('20')));
    await _press(tester, LogicalKeyboardKey.enter);
    await _tabTo(tester, _nodeOf(tester, find.text('22')));
    await _press(tester, LogicalKeyboardKey.enter);
    final DateTimeRange? range = tester
        .widget<JustDateRangePicker>(find.byType(JustDateRangePicker))
        .value;
    expect(<int?>[range?.start.day, range?.end.day], <int>[20, 22]);
  });

  testWidgets('time picker spinner steps the hour with Arrow Down', (
    WidgetTester tester,
  ) async {
    await _pump(tester, 'time-picker');
    final Focus spinnerFocus = tester.widget<Focus>(
      find
          .descendant(
            of: find.byType(TimePickerSpinner),
            matching: find.byType(Focus),
          )
          .first,
    );
    await _tabTo(tester, spinnerFocus.focusNode!);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    final TimeOfDay? time = tester
        .widget<JustTimePicker>(find.byType(JustTimePicker))
        .value;
    expect(time, const TimeOfDay(hour: 10, minute: 41));
  });
}

void main() {
  setUpAll(_loadMaterialIcons);

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
    _traversalTests();
    _controlTests();
    _pickerTests();
  });
}
