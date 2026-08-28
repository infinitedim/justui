// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart'
    show DayPeriod, Icons, MaterialApp, Scaffold, ThemeData, TimeOfDay;
import 'package:flutter/rendering.dart' show SemanticsFlag;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog.dart';
import 'package:just_ui_core/src/components/input/just_input.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(
    Widget child, {
    JustThemeData? theme,
    JustDialogController? dialogController,
  }) {
    final activeTheme = theme ?? JustThemeData.light;
    final effectiveDialogController =
        dialogController ?? JustDialogController();
    return JustThemeProvider(
      lightTheme: activeTheme,
      child: MaterialApp(
        builder: (context, materialChild) {
          return JustThemeProvider(
            lightTheme: activeTheme,
            child: materialChild!,
          );
        },
        home: JustDialogScope(
          controller: effectiveDialogController,
          child: Scaffold(
            body: SingleChildScrollView(child: Center(child: child)),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. Dial Engine Boundaries & Interaction
  // ===========================================================================
  group('1. Dial Engine Boundaries', () {
    testWidgets('Renders TimePickerDial and updates time via tap', (
      tester,
    ) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          JustTimePicker(
            value: initialTime,
            mode: .dial,
            timeFormat: .twelveHour,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      expect(find.byType(TimePickerDial), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('00'), findsOneWidget);

      // Dial center calculation
      final dialFinder = find.byType(TimePickerDial);
      final dialCenter = tester.getCenter(dialFinder);

      // Tap on 3 o'clock position (right side of the dial: dx + 80, dy)
      await tester.tapAt(dialCenter + const Offset(80.0, 0.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
      expect(
        selectedTime!.hourOfPeriod == 0 ? 12 : selectedTime!.hourOfPeriod,
        equals(3),
      );
    });

    testWidgets('Restricts time selection with firstTime and lastTime bounds', (
      tester,
    ) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 12, minute: 0);
      const firstTime = TimeOfDay(hour: 10, minute: 0);
      const lastTime = TimeOfDay(hour: 16, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerDial(
            selectedTime: initialTime,
            firstTime: firstTime,
            lastTime: lastTime,
            timeFormat: .twelveHour,
            activeSegment: .hour,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      final dialCenter = tester.getCenter(find.byType(TimePickerDial));

      // Tap 8 o'clock (outside allowed range [10..16] PM -> 20:00) -> should be rejected
      await tester.tapAt(dialCenter + const Offset(-70.0, 40.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNull);

      // Tap 2 o'clock (within allowed range 14:00 <= 16:00: dx=70, dy=-40) -> should succeed
      await tester.tapAt(dialCenter + const Offset(70.0, -40.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
      expect(
        selectedTime!.hourOfPeriod == 0 ? 12 : selectedTime!.hourOfPeriod,
        equals(2),
      );
    });

    testWidgets('Respects selectableTimePredicate', (tester) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerDial(
            selectedTime: initialTime,
            selectableTimePredicate: (time) => time.hour % 2 == 0,
            timeFormat: .twentyFourHour,
            activeSegment: .hour,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      final dialCenter = tester.getCenter(find.byType(TimePickerDial));

      // Tap 3 o'clock inner ring (15:00, odd) -> rejected by predicate
      await tester.tapAt(dialCenter + const Offset(65.0, 0.0));
      await tester.pumpAndSettle();
      expect(selectedTime, isNull);

      // Tap 6 o'clock inner ring (18:00, even) -> allowed by predicate
      await tester.tapAt(dialCenter + const Offset(0.0, 65.0));
      await tester.pumpAndSettle();
      expect(selectedTime, isNotNull);
      expect(selectedTime!.hour, equals(18));
    });

    testWidgets('Snaps minutes to minuteInterval on dial', (tester) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerDial(
            selectedTime: initialTime,
            minuteInterval: 15,
            activeSegment: .minute,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      final dialCenter = tester.getCenter(find.byType(TimePickerDial));

      // Tap near 3 o'clock (minute 15)
      await tester.tapAt(dialCenter + const Offset(80.0, 0.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
      expect(selectedTime!.minute, equals(15));
    });

    testWidgets('Auto-advances from hour to minute on hour tap', (
      tester,
    ) async {
      JustTimePickerSegment? activeSegment;
      const initialTime = TimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerDial(
            selectedTime: initialTime,
            activeSegment: .hour,
            autoAdvance: true,
            onSegmentChanged: (seg) => activeSegment = seg,
          ),
        ),
      );

      final dialCenter = tester.getCenter(find.byType(TimePickerDial));
      await tester.tapAt(dialCenter + const Offset(80.0, 0.0));
      await tester.pump();

      // Advance timer duration (250ms)
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(activeSegment, equals(JustTimePickerSegment.minute));
    });
  });

  // ===========================================================================
  // 2. Spinner Engine Looping & Scrolling
  // ===========================================================================
  group('2. Spinner Engine Looping/Scrolling', () {
    testWidgets('Renders TimePickerSpinner with 3 columns in 12h mode', (
      tester,
    ) async {
      const initialTime = TimeOfDay(hour: 9, minute: 30);

      await tester.pumpWidget(
        buildTestApp(
          const TimePickerSpinner(value: initialTime, timeFormat: .twelveHour),
        ),
      );

      expect(find.byType(TimePickerSpinner), findsOneWidget);
      expect(find.byType(ListWheelScrollView), findsNWidgets(3));
      expect(find.text('09'), findsWidgets);
      expect(find.text('30'), findsWidgets);
      expect(find.text('AM'), findsWidgets);
    });

    testWidgets('Renders TimePickerSpinner with 2 columns in 24h mode', (
      tester,
    ) async {
      const initialTime = TimeOfDay(hour: 14, minute: 45);

      await tester.pumpWidget(
        buildTestApp(
          const TimePickerSpinner(
            value: initialTime,
            timeFormat: .twentyFourHour,
          ),
        ),
      );

      expect(find.byType(TimePickerSpinner), findsOneWidget);
      expect(find.byType(ListWheelScrollView), findsNWidgets(2));
      expect(find.text('14'), findsWidgets);
      expect(find.text('45'), findsWidgets);
    });

    testWidgets('Scrolls hour wheel and updates time', (tester) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerSpinner(
            value: initialTime,
            timeFormat: .twelveHour,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      // Drag the first wheel (hour) downward
      final hourWheel = find.byType(ListWheelScrollView).first;
      await tester.drag(hourWheel, const Offset(0.0, -88.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
    });

    testWidgets('Scrolls minute wheel and updates time', (tester) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 10, minute: 15);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerSpinner(
            value: initialTime,
            minuteInterval: 5,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      final minuteWheel = find.byType(ListWheelScrollView).at(1);
      await tester.drag(minuteWheel, const Offset(0.0, -88.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
    });

    testWidgets('Clamps and snaps time to bounds in spinner', (tester) async {
      const initialTime = TimeOfDay(hour: 8, minute: 0);
      const firstTime = TimeOfDay(hour: 9, minute: 0);
      const lastTime = TimeOfDay(hour: 17, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          const TimePickerSpinner(
            value: initialTime,
            firstTime: firstTime,
            lastTime: lastTime,
            minuteInterval: 15,
          ),
        ),
      );

      // Clamped to firstTime 09:00
      expect(find.text('09'), findsWidgets);
      expect(find.text('00'), findsWidgets);
    });
  });

  // ===========================================================================
  // 3. Input Engine Validation
  // ===========================================================================
  group('3. Input Engine Validation', () {
    testWidgets('Renders TimePickerInput and enters valid numeric text', (
      tester,
    ) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 10, minute: 20);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerInput(
            selectedTime: initialTime,
            timeFormat: .twelveHour,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      expect(find.byType(TimePickerInput), findsOneWidget);
      expect(find.byType(JustInput), findsNWidgets(2));

      // Enter new hour '08' in first input field
      final hourInput = find.byType(EditableText).first;
      await tester.enterText(hourInput, '08');
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
      expect(
        selectedTime!.hourOfPeriod == 0 ? 12 : selectedTime!.hourOfPeriod,
        equals(8),
      );
    });

    testWidgets('Clamps out-of-range hours on submit', (tester) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerInput(
            selectedTime: initialTime,
            timeFormat: .twentyFourHour,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      final hourInput = find.byType(EditableText).first;
      await tester.enterText(hourInput, '99');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      // In 24h mode, max hour is 23
      expect(selectedTime?.hour, equals(23));
    });

    testWidgets('Clamps out-of-range minutes on submit', (tester) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerInput(
            selectedTime: initialTime,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      final minuteInput = find.byType(EditableText).last;
      await tester.enterText(minuteInput, '85');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Max minute is 59
      expect(selectedTime?.minute, equals(59));
    });

    testWidgets('Sanitizes non-numeric characters in input fields', (
      tester,
    ) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerInput(
            selectedTime: initialTime,
            timeFormat: .twelveHour,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      final hourInput = find.byType(EditableText).first;
      await tester.enterText(hourInput, 'ab05cd');
      await tester.pumpAndSettle();

      expect(
        selectedTime?.hourOfPeriod == 0 ? 12 : selectedTime?.hourOfPeriod,
        equals(5),
      );
    });

    testWidgets('Auto-advances focus to minute input after typing 2 digits', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const TimePickerInput(
            selectedTime: TimeOfDay(hour: 1, minute: 0),
            timeFormat: .twelveHour,
            autofocus: true,
          ),
        ),
      );

      final hourInput = find.byType(EditableText).first;
      await tester.enterText(hourInput, '11');
      await tester.pumpAndSettle();

      // Focus should have advanced to minute field
      final minuteInput = find.byType(EditableText).last;
      final minuteEditable = tester.widget<EditableText>(minuteInput);
      expect(minuteEditable.focusNode.hasFocus, isTrue);
    });
  });

  // ===========================================================================
  // 4. 12h/24h Toggle Formatting & Header Readout
  // ===========================================================================
  group('4. 12h/24h Toggle Formatting', () {
    testWidgets('Displays 12-hour format with AM/PM toggle', (tester) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 9, minute: 15);

      await tester.pumpWidget(
        buildTestApp(
          JustTimePicker(
            value: initialTime,
            timeFormat: .twelveHour,
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      expect(find.text('09'), findsWidgets);
      expect(find.text('15'), findsWidgets);
      expect(find.text('AM'), findsWidgets);
      expect(find.text('PM'), findsWidgets);

      // Tap PM button in header
      await tester.tap(find.text('PM').first);
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
      expect(selectedTime!.hour, equals(21)); // 9 AM -> 9 PM = 21:15
      expect(selectedTime!.period, equals(DayPeriod.pm));
    });

    testWidgets('Displays 24-hour format without AM/PM toggle', (tester) async {
      const initialTime = TimeOfDay(hour: 21, minute: 45);

      await tester.pumpWidget(
        buildTestApp(
          const JustTimePicker(value: initialTime, timeFormat: .twentyFourHour),
        ),
      );

      expect(find.text('21'), findsWidgets);
      expect(find.text('45'), findsWidgets);
      expect(find.text('AM'), findsNothing);
      expect(find.text('PM'), findsNothing);
    });

    testWidgets('Switches active segment between hour and minute in header', (
      tester,
    ) async {
      const initialTime = TimeOfDay(hour: 10, minute: 25);

      await tester.pumpWidget(
        buildTestApp(
          const JustTimePicker(value: initialTime, initialSegment: .hour),
        ),
      );

      // Tap minute header button ('25')
      await tester.tap(find.text('25').first);
      await tester.pumpAndSettle();

      // Active segment switches to minute
      final dial = tester.widget<TimePickerDial>(find.byType(TimePickerDial));
      expect(dial.activeSegment, equals(JustTimePickerSegment.minute));
    });

    testWidgets('Cycles picker interaction modes via header switch button', (
      tester,
    ) async {
      const initialTime = TimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          const JustTimePicker(
            value: initialTime,
            mode: .dial,
            allowModeSwitch: true,
          ),
        ),
      );

      expect(find.byType(TimePickerDial), findsOneWidget);

      // Tap mode switch button -> switch to Spinner
      await tester.tap(find.byIcon(Icons.view_agenda_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerSpinner), findsOneWidget);

      // Tap mode switch button -> switch to Input
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerInput), findsOneWidget);

      // Tap mode switch button -> switch back to Dial
      await tester.tap(find.byIcon(Icons.access_time_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDial), findsOneWidget);
    });
  });

  // ===========================================================================
  // 5. Preset Integration & Styling
  // ===========================================================================
  group('5. Preset Integration', () {
    testWidgets('Renders JustTimePicker under Neobrutalism preset', (
      tester,
    ) async {
      const initialTime = TimeOfDay(hour: 14, minute: 30);

      await tester.pumpWidget(
        buildTestApp(
          const JustTimePicker(value: initialTime, timeFormat: .twentyFourHour),
          theme: JustThemeData.neobrutalismLight,
        ),
      );

      expect(find.byType(JustTimePicker), findsOneWidget);
      expect(find.byType(TimePickerDial), findsOneWidget);
      expect(find.text('14'), findsWidgets);
      expect(find.text('30'), findsWidgets);
    });

    testWidgets('Applies custom JustTimePickerStyle overrides', (tester) async {
      const initialTime = TimeOfDay(hour: 8, minute: 0);
      const customStyle = JustTimePickerStyle(
        backgroundColor: Color(0xFF1E1E2E),
        dialFaceColor: Color(0xFF2E2E3E),
        handColor: Color(0xFFFF5555),
        dialTextColor: Color(0xFFFFFFFF),
        selectedTextColor: Color(0xFF000000),
        borderRadius: .all(Radius.circular(20.0)),
        dialSize: 220.0,
      );

      await tester.pumpWidget(
        buildTestApp(
          const JustTimePicker(value: initialTime, style: customStyle),
        ),
      );

      final dial = tester.widget<TimePickerDial>(find.byType(TimePickerDial));
      expect(dial.style?.dialFaceColor, equals(const Color(0xFF2E2E3E)));
      expect(dial.style?.handColor, equals(const Color(0xFFFF5555)));
      expect(dial.style?.dialSize, equals(220.0));
    });

    testWidgets('Applies JustTimePickerTheme extension defaults', (
      tester,
    ) async {
      const initialTime = TimeOfDay(hour: 11, minute: 45);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              JustTimePickerTheme(enableHaptic: true, defaultMode: .spinner),
            ],
          ),
          home: JustThemeProvider(
            lightTheme: JustThemeData.light,
            child: const Scaffold(
              body: Center(child: JustTimePicker(value: initialTime)),
            ),
          ),
        ),
      );

      expect(find.byType(JustTimePicker), findsOneWidget);
    });
  });

  // ===========================================================================
  // 6. Overlay Modal & Dropdown Behavior
  // ===========================================================================
  group('6. Overlay Modal Behavior', () {
    testWidgets('Renders dropdown variant and toggles popover overlay', (
      tester,
    ) async {
      TimeOfDay? selectedTime;
      const initialTime = TimeOfDay(hour: 10, minute: 30);

      await tester.pumpWidget(
        buildTestApp(
          JustTimePicker.dropdown(
            value: initialTime,
            placeholder: 'Select time',
            onChanged: (time) => selectedTime = time,
          ),
        ),
      );

      // Initially trigger button is shown, overlay is closed
      expect(find.text('10:30 AM'), findsOneWidget);
      expect(find.byType(TimePickerDial), findsNothing);

      // Tap trigger to open dropdown
      await tester.tap(find.text('10:30 AM'));
      await tester.pumpAndSettle();

      // Overlay popover opens
      expect(find.byType(TimePickerDial), findsOneWidget);

      // Tap dial to select time
      final dialCenter = tester.getCenter(find.byType(TimePickerDial));
      await tester.tapAt(dialCenter + const Offset(80.0, 0.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
    });

    testWidgets('Renders modal trigger button and opens dialog', (
      tester,
    ) async {
      const initialTime = TimeOfDay(hour: 15, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          const JustTimePicker.modal(
            value: initialTime,
            placeholder: 'Open Picker',
            timeFormat: .twentyFourHour,
          ),
        ),
      );

      expect(find.text('15:00'), findsOneWidget);
      expect(find.byType(TimePickerDial), findsNothing);

      // Tap modal trigger
      await tester.tap(find.text('15:00'));
      await tester.pumpAndSettle();

      // Dialog opens with dial and action buttons
      expect(find.byType(TimePickerDial), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('showJustTimePicker returns selected time on confirm', (
      tester,
    ) async {
      TimeOfDay? resultTime;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) {
              return JustButton(
                label: 'Show Picker',
                onPressed: () async {
                  resultTime = await showJustTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 10, minute: 0),
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Picker'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);

      // Tap OK button to confirm
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(resultTime, isNotNull);
      expect(resultTime!.hour, equals(10));
      expect(resultTime!.minute, equals(0));
    });
  });

  // ===========================================================================
  // 7. A11y Semantics Limits & Keyboard Navigation
  // ===========================================================================
  group('7. A11y Semantics Limits', () {
    testWidgets(
      'TimePickerDial exposes container semantics and increase/decrease actions',
      (tester) async {
        final handle = tester.ensureSemantics();
        const initialTime = TimeOfDay(hour: 10, minute: 0);

        await tester.pumpWidget(
          buildTestApp(
            const TimePickerDial(
              selectedTime: initialTime,
              activeSegment: .hour,
            ),
          ),
        );

        final semanticsFinder = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Hour',
        );
        expect(semanticsFinder, findsOneWidget);

        final dialSemantics = tester.getSemantics(semanticsFinder);
        expect(dialSemantics.value, equals('10'));
        expect(dialSemantics.increasedValue, equals('Next value'));
        expect(dialSemantics.decreasedValue, equals('Previous value'));

        handle.dispose();
      },
    );

    testWidgets(
      'TimePickerSpinner wheels expose semantics with label and value',
      (tester) async {
        final handle = tester.ensureSemantics();
        const initialTime = TimeOfDay(hour: 8, minute: 30);

        await tester.pumpWidget(
          buildTestApp(
            const TimePickerSpinner(
              value: initialTime,
              timeFormat: .twelveHour,
            ),
          ),
        );

        expect(
          tester.getSemantics(find.byType(ListWheelScrollView).first),
          matchesSemantics(
            label: 'Hour',
            value: '08',
            increasedValue: '09',
            decreasedValue: '07',
            hasIncreaseAction: true,
            hasDecreaseAction: true,
          ),
        );

        handle.dispose();
      },
    );

    testWidgets('TimePickerDial navigates with keyboard arrow keys', (
      tester,
    ) async {
      TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return TimePickerDial(
                selectedTime: selectedTime,
                activeSegment: .hour,
                onChanged: (time) {
                  setState(() {
                    selectedTime = time;
                  });
                },
              );
            },
          ),
        ),
      );

      // Focus the dial focus node directly
      final focusNode = tester
          .widget<Focus>(
            find.descendant(
              of: find.byType(TimePickerDial),
              matching: find.byType(Focus),
            ),
          )
          .focusNode!;
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      // Send Arrow Up key event -> increments hour from 10 to 11
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(selectedTime.hour, equals(11));

      // Send Arrow Down key event -> decrements hour from 11 back to 10
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(selectedTime.hour, equals(10));
    });

    testWidgets(
      'AM/PM toggle buttons expose button semantics and selected state',
      (tester) async {
        final handle = tester.ensureSemantics();
        const initialTime = TimeOfDay(hour: 9, minute: 0);

        await tester.pumpWidget(
          buildTestApp(
            const JustTimePicker(value: initialTime, timeFormat: .twelveHour),
          ),
        );

        // Verify AM semantics node has isButton, isSelected: true
        final amSemantics = tester.getSemantics(find.text('AM').first);
        expect(amSemantics.label.contains('AM'), isTrue);
        expect(amSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(amSemantics.hasFlag(SemanticsFlag.isSelected), isTrue);

        // Verify PM semantics node has isButton, isSelected: false
        final pmSemantics = tester.getSemantics(find.text('PM').first);
        expect(pmSemantics.label.contains('PM'), isTrue);
        expect(pmSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(pmSemantics.hasFlag(SemanticsFlag.isSelected), isFalse);

        handle.dispose();
      },
    );
  });
}
