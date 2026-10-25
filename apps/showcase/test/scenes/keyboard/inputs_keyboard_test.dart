// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show DateTimeRange, TimeOfDay;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_range_picker.dart';
import 'package:just_ui_core/src/components/radio/just_radio_group.dart';
import 'package:just_ui_core/src/components/switch/just_switch.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

const List<String> _scenes = <String>[
  'input',
  'checkbox',
  'radio',
  'radio-group',
  'switch',
  'slider',
  'date-picker',
  'date-range-picker',
  'time-picker',
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
  testWidgets('checkbox toggles with Space', (WidgetTester tester) async {
    await pumpDefault(tester, 'checkbox');
    await tabTo(tester, nodeOf(tester, find.text('Remember this device')));
    await press(tester, LogicalKeyboardKey.space);
    expect(tester.widget<JustCheckbox>(find.byType(JustCheckbox)).value, false);
  });

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

  testWidgets('slider moves with the arrow keys', (WidgetTester tester) async {
    await pumpDefault(tester, 'slider');
    await press(tester, LogicalKeyboardKey.tab);
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('65%'), findsOneWidget);
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

  testWidgets('time picker spinner steps the hour with Arrow Down', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'time-picker');
    final Focus spinnerFocus = tester.widget<Focus>(
      find
          .descendant(
            of: find.byType(TimePickerSpinner),
            matching: find.byType(Focus),
          )
          .first,
    );
    await tabTo(tester, spinnerFocus.focusNode!);
    await press(tester, LogicalKeyboardKey.arrowDown);
    final TimeOfDay? time = tester
        .widget<JustTimePicker>(find.byType(JustTimePicker))
        .value;
    expect(time, const TimeOfDay(hour: 10, minute: 41));
  });
}

/// AC12 for the Inputs scenes: Tab in, through and out, and each control
/// works from the keyboard.
void main() {
  _traversalTests();
  _controlTests();
  _pickerTests();
}
