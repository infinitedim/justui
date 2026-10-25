// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_range_picker.dart';
import 'package:just_ui_core/src/components/radio/just_radio_group.dart';
import 'package:just_ui_core/src/components/switch/just_switch.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

const List<String> _scenes = <String>[
  'input',
  'radio',
  'radio-group',
  'switch',
  'date-picker',
  'date-range-picker',
];

void _traversalTests() {
  for (final String scene in _scenes) {
    testWidgets('$scene: Tab in, through and out, Shift+Tab back', (
      WidgetTester tester,
    ) async {
      await pumpDefault(tester, scene);
      final List<FocusNode> stops = await tabStops(tester);
      expect(stops.first, isNot(isA<FocusScopeNode>()), reason: 'Tab enters');
      if (stops.length > 1) {
        await shiftTab(tester);
        expect(focused, stops.last);
      }
    });
  }
}

// One scene per test: ViewHost reads its config once, in initState.
void _controlTests() {
  testWidgets('switch toggles with Space', (WidgetTester tester) async {
    await pumpDefault(tester, 'switch');
    await tabTo(tester, nodeOf(tester, find.text('Wi-Fi')));
    await press(tester, LogicalKeyboardKey.space);
    expect(tester.widget<JustSwitch>(find.byType(JustSwitch)).value, false);
  });

  testWidgets('radio selects Monthly with Space', (WidgetTester tester) async {
    await pumpDefault(tester, 'radio-group');
    await tabTo(tester, nodeOf(tester, find.text('Monthly')));
    await press(tester, LogicalKeyboardKey.space);
    final JustRadioGroup<int> group = tester.widget<JustRadioGroup<int>>(
      find.byType(JustRadioGroup<int>),
    );
    expect(group.value, 1);
  });

  testWidgets('input shows the rule message for an invalid name', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'input');
    const String message = 'Use lowercase letters, numbers and underscores.';
    expect(find.text(message), findsNothing);
    await press(tester, LogicalKeyboardKey.tab);
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
    await pumpDefault(tester, 'date-picker');
    await tabTo(tester, nodeOf(tester, find.text('20')));
    await press(tester, LogicalKeyboardKey.enter);
    final JustDatePicker picker = tester.widget<JustDatePicker>(
      find.byType(JustDatePicker),
    );
    expect(picker.value?.day, 20);
  });

  testWidgets('date range picker picks two ends with Enter', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'date-range-picker');
    await tabTo(tester, nodeOf(tester, find.text('20')));
    await press(tester, LogicalKeyboardKey.enter);
    await tabTo(tester, nodeOf(tester, find.text('22')));
    await press(tester, LogicalKeyboardKey.enter);
    final DateTimeRange? range = tester
        .widget<JustDateRangePicker>(find.byType(JustDateRangePicker))
        .value;
    expect(<int?>[range?.start.day, range?.end.day], <int>[20, 22]);
  });
}

/// AC12 for the Inputs scenes: Tab in, through and out, and each control
/// works from the keyboard.
void main() {
  _traversalTests();
  _controlTests();
  _pickerTests();
}
