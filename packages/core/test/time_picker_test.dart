// ignore_for_file: deprecated_member_use
import 'package:material_ui/material_ui.dart'
    show Icons, MaterialApp, Scaffold, ThemeData, ThemeExtension;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/src/semantics/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog.dart';
import 'package:just_ui_core/src/components/input/just_input.dart';
import 'package:just_ui_core/src/components/shared/_shared_focus_indicator.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(
    Widget child, {
    JustThemeData? theme,
    JustDialogController? dialogController,
  }) {
    final JustThemeData activeTheme = theme ?? JustThemeData.light;
    final JustDialogController effectiveDialogController =
        dialogController ?? JustDialogController();
    return JustThemeProvider(
      lightTheme: activeTheme,
      child: MaterialApp(
        builder: (BuildContext context, Widget? materialChild) {
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
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          JustTimePicker(
            value: initialTime,
            mode: .dial,
            timeFormat: .twelveHour,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      expect(find.byType(TimePickerDial), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('00'), findsOneWidget);

      // Dial center calculation
      final Finder dialFinder = find.byType(TimePickerDial);
      final Offset dialCenter = tester.getCenter(dialFinder);

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
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 12, minute: 0);
      const JustTimeOfDay firstTime = JustTimeOfDay(hour: 10, minute: 0);
      const JustTimeOfDay lastTime = JustTimeOfDay(hour: 16, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerDial(
            selectedTime: initialTime,
            firstTime: firstTime,
            lastTime: lastTime,
            timeFormat: .twelveHour,
            activeSegment: .hour,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      final Offset dialCenter = tester.getCenter(find.byType(TimePickerDial));

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

    testWidgets('Respects selectableTimePredicate', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerDial(
            selectedTime: initialTime,
            selectableTimePredicate: (JustTimeOfDay time) => time.hour % 2 == 0,
            timeFormat: .twentyFourHour,
            activeSegment: .hour,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      final Offset dialCenter = tester.getCenter(find.byType(TimePickerDial));

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

    testWidgets('Snaps minutes to minuteInterval on dial', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerDial(
            selectedTime: initialTime,
            minuteInterval: 15,
            activeSegment: .minute,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      final Offset dialCenter = tester.getCenter(find.byType(TimePickerDial));

      // Tap near 3 o'clock (minute 15)
      await tester.tapAt(dialCenter + const Offset(80.0, 0.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
      expect(selectedTime!.minute, equals(15));
    });

    testWidgets('Auto-advances from hour to minute on hour tap', (
      WidgetTester tester,
    ) async {
      JustTimePickerSegment? activeSegment;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerDial(
            selectedTime: initialTime,
            activeSegment: .hour,
            autoAdvance: true,
            onSegmentChanged: (JustTimePickerSegment seg) =>
                activeSegment = seg,
          ),
        ),
      );

      final Offset dialCenter = tester.getCenter(find.byType(TimePickerDial));
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
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 9, minute: 30);

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
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 14, minute: 45);

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

    testWidgets('Scrolls hour wheel and updates time', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerSpinner(
            value: initialTime,
            timeFormat: .twelveHour,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      // Drag the first wheel (hour) downward
      final Finder hourWheel = find.byType(ListWheelScrollView).first;
      await tester.drag(hourWheel, const Offset(0.0, -88.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
    });

    testWidgets('Scrolls minute wheel and updates time', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 10, minute: 15);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerSpinner(
            value: initialTime,
            minuteInterval: 5,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      final Finder minuteWheel = find.byType(ListWheelScrollView).at(1);
      await tester.drag(minuteWheel, const Offset(0.0, -88.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
    });

    testWidgets('Clamps and snaps time to bounds in spinner', (
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 8, minute: 0);
      const JustTimeOfDay firstTime = JustTimeOfDay(hour: 9, minute: 0);
      const JustTimeOfDay lastTime = JustTimeOfDay(hour: 17, minute: 0);

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
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 10, minute: 20);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerInput(
            selectedTime: initialTime,
            timeFormat: .twelveHour,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      expect(find.byType(TimePickerInput), findsOneWidget);
      expect(find.byType(JustInput), findsNWidgets(2));

      // Enter new hour '08' in first input field
      final Finder hourInput = find.byType(EditableText).first;
      await tester.enterText(hourInput, '08');
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
      expect(
        selectedTime!.hourOfPeriod == 0 ? 12 : selectedTime!.hourOfPeriod,
        equals(8),
      );
    });

    testWidgets('Clamps out-of-range hours on submit', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerInput(
            selectedTime: initialTime,
            timeFormat: .twentyFourHour,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      final Finder hourInput = find.byType(EditableText).first;
      await tester.enterText(hourInput, '99');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      // In 24h mode, max hour is 23
      expect(selectedTime?.hour, equals(23));
    });

    testWidgets('Clamps out-of-range minutes on submit', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerInput(
            selectedTime: initialTime,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      final Finder minuteInput = find.byType(EditableText).last;
      await tester.enterText(minuteInput, '85');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Max minute is 59
      expect(selectedTime?.minute, equals(59));
    });

    testWidgets('Sanitizes non-numeric characters in input fields', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          TimePickerInput(
            selectedTime: initialTime,
            timeFormat: .twelveHour,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
          ),
        ),
      );

      final Finder hourInput = find.byType(EditableText).first;
      await tester.enterText(hourInput, 'ab05cd');
      await tester.pumpAndSettle();

      expect(
        selectedTime?.hourOfPeriod == 0 ? 12 : selectedTime?.hourOfPeriod,
        equals(5),
      );
    });

    testWidgets('Auto-advances focus to minute input after typing 2 digits', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const TimePickerInput(
            selectedTime: JustTimeOfDay(hour: 1, minute: 0),
            timeFormat: .twelveHour,
            autofocus: true,
          ),
        ),
      );

      final Finder hourInput = find.byType(EditableText).first;
      await tester.enterText(hourInput, '11');
      await tester.pumpAndSettle();

      // Focus should have advanced to minute field
      final Finder minuteInput = find.byType(EditableText).last;
      final EditableText minuteEditable = tester.widget<EditableText>(
        minuteInput,
      );
      expect(minuteEditable.focusNode.hasFocus, isTrue);
    });
  });

  // ===========================================================================
  // 4. 12h/24h Toggle Formatting & Header Readout
  // ===========================================================================
  group('4. 12h/24h Toggle Formatting', () {
    testWidgets('Displays 12-hour format with AM/PM toggle', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 9, minute: 15);

      await tester.pumpWidget(
        buildTestApp(
          JustTimePicker(
            value: initialTime,
            timeFormat: .twelveHour,
            onChanged: (JustTimeOfDay time) => selectedTime = time,
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
      expect(selectedTime!.period, equals(JustDayPeriod.pm));
    });

    testWidgets('Displays 24-hour format without AM/PM toggle', (
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 21, minute: 45);

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
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 10, minute: 25);

      await tester.pumpWidget(
        buildTestApp(
          const JustTimePicker(value: initialTime, initialSegment: .hour),
        ),
      );

      // Tap minute header button ('25')
      await tester.tap(find.text('25').first);
      await tester.pumpAndSettle();

      // Active segment switches to minute
      final TimePickerDial dial = tester.widget<TimePickerDial>(
        find.byType(TimePickerDial),
      );
      expect(dial.activeSegment, equals(JustTimePickerSegment.minute));
    });

    testWidgets('Cycles picker interaction modes via header switch button', (
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 12, minute: 0);

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
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 14, minute: 30);

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

    testWidgets('Applies custom JustTimePickerStyle overrides', (
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 8, minute: 0);
      const JustTimePickerStyle customStyle = JustTimePickerStyle(
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

      final TimePickerDial dial = tester.widget<TimePickerDial>(
        find.byType(TimePickerDial),
      );
      expect(dial.style?.dialFaceColor, equals(const Color(0xFF2E2E3E)));
      expect(dial.style?.handColor, equals(const Color(0xFFFF5555)));
      expect(dial.style?.dialSize, equals(220.0));
    });

    testWidgets('Applies JustTimePickerTheme extension defaults', (
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 11, minute: 45);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
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
      WidgetTester tester,
    ) async {
      JustTimeOfDay? selectedTime;
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 10, minute: 30);

      await tester.pumpWidget(
        buildTestApp(
          JustTimePicker.dropdown(
            value: initialTime,
            placeholder: 'Select time',
            onChanged: (JustTimeOfDay time) => selectedTime = time,
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
      final Offset dialCenter = tester.getCenter(find.byType(TimePickerDial));
      await tester.tapAt(dialCenter + const Offset(80.0, 0.0));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
    });

    testWidgets('Renders modal trigger button and opens dialog', (
      WidgetTester tester,
    ) async {
      const JustTimeOfDay initialTime = JustTimeOfDay(hour: 15, minute: 0);

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
      WidgetTester tester,
    ) async {
      JustTimeOfDay? resultTime;

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (BuildContext context) {
              return JustButton(
                label: 'Show Picker',
                onPressed: () async {
                  resultTime = await showJustTimePicker(
                    context: context,
                    initialTime: const JustTimeOfDay(hour: 10, minute: 0),
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
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        const JustTimeOfDay initialTime = JustTimeOfDay(hour: 10, minute: 0);

        await tester.pumpWidget(
          buildTestApp(
            const TimePickerDial(
              selectedTime: initialTime,
              activeSegment: .hour,
            ),
          ),
        );

        final Finder semanticsFinder = find.byWidgetPredicate(
          (Widget w) => w is Semantics && w.properties.label == 'Hour',
        );
        expect(semanticsFinder, findsOneWidget);

        final SemanticsNode dialSemantics = tester.getSemantics(
          semanticsFinder,
        );
        expect(dialSemantics.value, equals('10'));
        expect(dialSemantics.increasedValue, equals('Next value'));
        expect(dialSemantics.decreasedValue, equals('Previous value'));

        handle.dispose();
      },
    );

    testWidgets(
      'TimePickerSpinner wheels expose semantics with label and value',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        const JustTimeOfDay initialTime = JustTimeOfDay(hour: 8, minute: 30);

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
            isSlider: true,
            hasIncreaseAction: true,
            hasDecreaseAction: true,
          ),
        );

        handle.dispose();
      },
    );

    testWidgets('TimePickerDial navigates with keyboard arrow keys', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay selectedTime = const JustTimeOfDay(hour: 10, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TimePickerDial(
                selectedTime: selectedTime,
                activeSegment: .hour,
                onChanged: (JustTimeOfDay time) {
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
      final FocusNode focusNode = tester
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
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        const JustTimeOfDay initialTime = JustTimeOfDay(hour: 9, minute: 0);

        await tester.pumpWidget(
          buildTestApp(
            const JustTimePicker(value: initialTime, timeFormat: .twelveHour),
          ),
        );

        // Verify AM semantics node has isButton, isSelected: true
        final SemanticsNode amSemantics = tester.getSemantics(
          find.text('AM').first,
        );
        expect(amSemantics.label.contains('AM'), isTrue);
        expect(amSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(amSemantics.hasFlag(SemanticsFlag.isSelected), isTrue);

        // Verify PM semantics node has isButton, isSelected: false
        final SemanticsNode pmSemantics = tester.getSemantics(
          find.text('PM').first,
        );
        expect(pmSemantics.label.contains('PM'), isTrue);
        expect(pmSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(pmSemantics.hasFlag(SemanticsFlag.isSelected), isFalse);

        handle.dispose();
      },
    );
  });

  group('JustTimeOfDay Unit Tests', () {
    test('Hour, minute, period, and hourOfPeriod calculations', () {
      const JustTimeOfDay midnight = JustTimeOfDay(hour: 0, minute: 0);
      expect(midnight.period, equals(JustDayPeriod.am));
      expect(midnight.hourOfPeriod, equals(12));
      expect(midnight.periodOffset, equals(0));

      const JustTimeOfDay morning = JustTimeOfDay(hour: 9, minute: 30);
      expect(morning.period, equals(JustDayPeriod.am));
      expect(morning.hourOfPeriod, equals(9));

      const JustTimeOfDay noon = JustTimeOfDay(hour: 12, minute: 0);
      expect(noon.period, equals(JustDayPeriod.pm));
      expect(noon.hourOfPeriod, equals(12));
      expect(noon.periodOffset, equals(12));

      const JustTimeOfDay evening = JustTimeOfDay(hour: 21, minute: 45);
      expect(evening.period, equals(JustDayPeriod.pm));
      expect(evening.hourOfPeriod, equals(9));
    });

    test('replacing, fromDateTime, and now', () {
      const JustTimeOfDay time = JustTimeOfDay(hour: 10, minute: 20);
      final JustTimeOfDay replacedHour = time.replacing(hour: 14);
      expect(replacedHour.hour, equals(14));
      expect(replacedHour.minute, equals(20));

      final JustTimeOfDay replacedMin = time.replacing(minute: 45);
      expect(replacedMin.hour, equals(10));
      expect(replacedMin.minute, equals(45));

      final DateTime dt = DateTime(2026, 8, 15, 16, 25);
      final JustTimeOfDay fromDt = JustTimeOfDay.fromDateTime(dt);
      expect(fromDt.hour, equals(16));
      expect(fromDt.minute, equals(25));

      final JustTimeOfDay now = JustTimeOfDay.now();
      expect(now.hour, inInclusiveRange(0, 23));
      expect(now.minute, inInclusiveRange(0, 59));
    });

    test('Comparisons and equality', () {
      const JustTimeOfDay t1 = JustTimeOfDay(hour: 9, minute: 0);
      const JustTimeOfDay t2 = JustTimeOfDay(hour: 9, minute: 30);
      const JustTimeOfDay t3 = JustTimeOfDay(hour: 10, minute: 0);
      const JustTimeOfDay t1Copy = JustTimeOfDay(hour: 9, minute: 0);

      expect(t1.isBefore(t2), isTrue);
      expect(t2.isAfter(t1), isTrue);
      expect(t1.isAtSameTimeAs(t1Copy), isTrue);
      expect(t1, equals(t1Copy));
      expect(t1.hashCode, equals(t1Copy.hashCode));
      expect(t1, isNot(equals(t2)));
      expect(t1.compareTo(t2), isNegative);
      expect(t3.compareTo(t2), isPositive);
    });

    test('toString formatting with zero padding', () {
      const JustTimeOfDay singleDigit = JustTimeOfDay(hour: 4, minute: 7);
      expect(singleDigit.toString(), equals('JustTimeOfDay(04:07)'));

      const JustTimeOfDay doubleDigit = JustTimeOfDay(hour: 15, minute: 42);
      expect(doubleDigit.toString(), equals('JustTimeOfDay(15:42)'));
    });

    test('Assertions on invalid hour and minute', () {
      expect(() => JustTimeOfDay(hour: -1, minute: 0), throwsAssertionError);
      expect(() => JustTimeOfDay(hour: 24, minute: 0), throwsAssertionError);
      expect(() => JustTimeOfDay(hour: 12, minute: -1), throwsAssertionError);
      expect(() => JustTimeOfDay(hour: 12, minute: 60), throwsAssertionError);
    });
  });

  // ===========================================================================
  // 8. Double-Card, Contrast, Semantics, Focus Visibility, Neobrutalism & Motion
  // ===========================================================================
  group('8. A11y, Contrast, Focus Visibility, Neobrutalism & Motion', () {
    testWidgets(
      'JustTimePicker.inline(mode: .spinner) avoids double-card nesting',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            const JustTimePicker.inline(
              value: JustTimeOfDay(hour: 9, minute: 41),
              mode: .spinner,
              timeFormat: .twelveHour,
            ),
          ),
        );

        final Iterable<Container> spinnerShadowedCards = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(TimePickerSpinner),
                matching: find.byType(Container),
              ),
            )
            .where((Container container) {
              final Decoration? dec = container.decoration;
              return dec is BoxDecoration &&
                  dec.boxShadow != null &&
                  dec.boxShadow!.isNotEmpty;
            });

        expect(spinnerShadowedCards, isEmpty);
      },
    );

    testWidgets(
      'TimePickerSpinner off-center opacity meets WCAG 1.4.3 (>= 4.5:1)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            const TimePickerSpinner(
              value: JustTimeOfDay(hour: 9, minute: 41),
              timeFormat: .twelveHour,
            ),
          ),
        );

        final List<ListWheelScrollView> wheels = tester
            .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
            .toList();
        expect(wheels, hasLength(3));

        for (final ListWheelScrollView wheel in wheels) {
          expect(wheel.overAndUnderCenterOpacity, greaterThanOrEqualTo(0.78));

          // Verify Ink & Paper contrast ratio for off-center items (light & dark)
          const Color ipLightSurface = Color(0xFFFFFFFF);
          const Color ipLightTextSecondary = Color(0xFF42413F);
          final Color blendedLight = Color.alphaBlend(
            ipLightTextSecondary.withValues(
              alpha: wheel.overAndUnderCenterOpacity,
            ),
            ipLightSurface,
          );
          expect(
            blendedLight.contrastRatioWith(ipLightSurface),
            greaterThanOrEqualTo(4.5),
          );

          const Color ipDarkSurface = Color(0xFF141413);
          const Color ipDarkTextSecondary = Color(0xFFC4C2C0);
          final Color blendedDark = Color.alphaBlend(
            ipDarkTextSecondary.withValues(
              alpha: wheel.overAndUnderCenterOpacity,
            ),
            ipDarkSurface,
          );
          expect(
            blendedDark.contrastRatioWith(ipDarkSurface),
            greaterThanOrEqualTo(4.5),
          );
        }
      },
    );

    testWidgets('TimePickerSpinner resolves rowHeight from presetTokens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const TimePickerSpinner(
            value: JustTimeOfDay(hour: 9, minute: 41),
            timeFormat: .twelveHour,
          ),
          theme: JustThemeData.neobrutalismLight,
        ),
      );

      final ListWheelScrollView hourWheel = tester.widget<ListWheelScrollView>(
        find.byType(ListWheelScrollView).first,
      );
      expect(
        hourWheel.itemExtent,
        equals(
          JustThemeData.neobrutalismLight.presetTokens
              .resolveTimePickerSpinnerRowHeight(),
        ),
      );
    });

    testWidgets(
      'TimePickerSpinner wheels exclude nested child semantics inside slider node',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          buildTestApp(
            const TimePickerSpinner(
              value: JustTimeOfDay(hour: 8, minute: 30),
              timeFormat: .twelveHour,
            ),
          ),
        );

        final Finder hourSemanticsFinder = find.byWidgetPredicate(
          (Widget w) => w is Semantics && w.properties.label == 'Hour',
        );
        expect(hourSemanticsFinder, findsOneWidget);

        final SemanticsNode hourNode = tester.getSemantics(hourSemanticsFinder);
        expect(hourNode.childrenCount, equals(0));

        handle.dispose();
      },
    );

    testWidgets(
      'TimePickerSpinner and TimePickerDial track isFocusVisible for FocusIndicator',
      (WidgetTester tester) async {
        final FocusHighlightStrategy originalStrategy =
            FocusManager.instance.highlightStrategy;
        addTearDown(() {
          FocusManager.instance.highlightStrategy = originalStrategy;
        });

        FocusManager.instance.highlightStrategy = .alwaysTouch;
        await tester.pumpWidget(
          buildTestApp(
            const Column(
              mainAxisSize: .min,
              children: <Widget>[
                TimePickerSpinner(value: JustTimeOfDay(hour: 9, minute: 30)),
                TimePickerDial(
                  selectedTime: JustTimeOfDay(hour: 9, minute: 30),
                ),
              ],
            ),
          ),
        );

        final FocusNode spinnerFocus = tester
            .widget<Focus>(
              find.descendant(
                of: find.byType(TimePickerSpinner),
                matching: find.byType(Focus),
              ),
            )
            .focusNode!;
        spinnerFocus.requestFocus();
        await tester.pumpAndSettle();

        FocusIndicator spinnerIndicator = tester.widget<FocusIndicator>(
          find.descendant(
            of: find.byType(TimePickerSpinner),
            matching: find.byType(FocusIndicator),
          ),
        );
        expect(spinnerIndicator.isFocused, isFalse);

        FocusManager.instance.highlightStrategy = .alwaysTraditional;
        await tester.pumpAndSettle();

        spinnerIndicator = tester.widget<FocusIndicator>(
          find.descendant(
            of: find.byType(TimePickerSpinner),
            matching: find.byType(FocusIndicator),
          ),
        );
        expect(spinnerIndicator.isFocused, isTrue);

        // Now verify TimePickerDial focus visibility
        FocusManager.instance.highlightStrategy = .alwaysTouch;
        final FocusNode dialFocus = tester
            .widget<Focus>(
              find.descendant(
                of: find.byType(TimePickerDial),
                matching: find.byType(Focus),
              ),
            )
            .focusNode!;
        dialFocus.requestFocus();
        await tester.pumpAndSettle();

        FocusIndicator dialIndicator = tester.widget<FocusIndicator>(
          find.descendant(
            of: find.byType(TimePickerDial),
            matching: find.byType(FocusIndicator),
          ),
        );
        expect(dialIndicator.isFocused, isFalse);

        FocusManager.instance.highlightStrategy = .alwaysTraditional;
        await tester.pumpAndSettle();

        dialIndicator = tester.widget<FocusIndicator>(
          find.descendant(
            of: find.byType(TimePickerDial),
            matching: find.byType(FocusIndicator),
          ),
        );
        expect(dialIndicator.isFocused, isTrue);
      },
    );

    testWidgets(
      'JustTimePicker header buttons include FocusIndicator and exclude duplicate semantics',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          buildTestApp(
            const JustTimePicker.inline(
              value: JustTimeOfDay(hour: 9, minute: 41),
              mode: .spinner,
              timeFormat: .twelveHour,
            ),
          ),
        );

        // 5 header buttons (hour, minute, AM, PM, mode switch) + 1 spinner FocusIndicator
        expect(
          find.descendant(
            of: find.byType(JustTimePicker),
            matching: find.byType(FocusIndicator),
          ),
          findsNWidgets(6),
        );

        final SemanticsNode amNode = tester.getSemantics(
          find.byWidgetPredicate(
            (Widget w) => w is Semantics && w.properties.label == 'AM',
          ),
        );
        expect(amNode.label, equals('AM'));

        handle.dispose();
      },
    );

    testWidgets(
      'Neobrutalism uses textPrimary border on header segments and TimePickerInput toggle',
      (WidgetTester tester) async {
        // Use light colors (distinct textPrimary vs borderDefault) with neobrutalism preset
        final JustThemeData neoTheme = JustThemeData.light.copyWith(
          preset: .neobrutalism,
        );
        final Color neoBorder = neoTheme.colors.textPrimary;
        final Color neoBorderDefault = neoTheme.colors.borderDefault;
        expect(neoBorder, isNot(equals(neoBorderDefault)));

        await tester.pumpWidget(
          buildTestApp(
            const JustTimePicker.inline(
              value: JustTimeOfDay(hour: 9, minute: 41),
              mode: .input,
              timeFormat: .twelveHour,
            ),
            theme: neoTheme,
          ),
        );

        // Verify header hour/minute/AM-PM/mode buttons and TimePickerInput AM/PM toggle
        // do not use colors.borderDefault when presetTokens.showsDefaultBorder is true.
        final Container minuteButtonContainer = tester.widget<Container>(
          find
              .ancestor(of: find.text('41'), matching: find.byType(Container))
              .first,
        );
        final BoxDecoration minuteDec =
            minuteButtonContainer.decoration! as BoxDecoration;
        expect((minuteDec.border! as Border).top.color, equals(neoBorder));

        final Container inputPeriodContainer = tester.widget<Container>(
          find
              .ancestor(
                of: find.descendant(
                  of: find.byType(TimePickerInput),
                  matching: find.text('AM'),
                ),
                matching: find.byWidgetPredicate(
                  (Widget w) =>
                      w is Container &&
                      w.decoration is BoxDecoration &&
                      (w.decoration! as BoxDecoration).border != null,
                ),
              )
              .first,
        );
        final BoxDecoration inputPeriodDec =
            inputPeriodContainer.decoration! as BoxDecoration;
        expect((inputPeriodDec.border! as Border).top.color, equals(neoBorder));

        // Also check header AM/PM container uses textPrimary border
        final Container headerPeriodContainer = tester.widget<Container>(
          find
              .ancestor(
                of: find.text('AM').first,
                matching: find.byWidgetPredicate(
                  (Widget w) =>
                      w is Container &&
                      w.decoration is BoxDecoration &&
                      (w.decoration! as BoxDecoration).border != null,
                ),
              )
              .first,
        );
        final BoxDecoration headerPeriodDec =
            headerPeriodContainer.decoration! as BoxDecoration;
        expect(
          (headerPeriodDec.border! as Border).top.color,
          equals(neoBorder),
        );
      },
    );

    testWidgets('TimePickerDial and TimePickerSpinner handle KeyRepeatEvent', (
      WidgetTester tester,
    ) async {
      JustTimeOfDay dialTime = const JustTimeOfDay(hour: 9, minute: 0);
      JustTimeOfDay spinnerTime = const JustTimeOfDay(hour: 9, minute: 0);

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: .min,
                children: <Widget>[
                  TimePickerDial(
                    selectedTime: dialTime,
                    activeSegment: .hour,
                    onChanged: (JustTimeOfDay t) =>
                        setState(() => dialTime = t),
                  ),
                  TimePickerSpinner(
                    value: spinnerTime,
                    onChanged: (JustTimeOfDay t) =>
                        setState(() => spinnerTime = t),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Dial repeat key (even without pump between down and repeat)
      final FocusNode dialFocus = tester
          .widget<Focus>(
            find.descendant(
              of: find.byType(TimePickerDial),
              matching: find.byType(Focus),
            ),
          )
          .focusNode!;
      dialFocus.requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(dialTime.hour, equals(11));

      // Spinner repeat key
      final FocusNode spinnerFocus = tester
          .widget<Focus>(
            find.descendant(
              of: find.byType(TimePickerSpinner),
              matching: find.byType(Focus),
            ),
          )
          .focusNode!;
      spinnerFocus.requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(spinnerTime.hour, equals(10));

      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(spinnerTime.hour, equals(11));
    });

    testWidgets(
      'Reduced motion disables animations in spinner, dial, and input',
      (WidgetTester tester) async {
        JustTimeOfDay spinnerTime = const JustTimeOfDay(hour: 10, minute: 0);
        JustTimeOfDay dialTime = const JustTimeOfDay(hour: 10, minute: 0);

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: buildTestApp(
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return MediaQuery(
                    data: const MediaQueryData(disableAnimations: true),
                    child: Column(
                      mainAxisSize: .min,
                      children: <Widget>[
                        const TimePickerInput(
                          selectedTime: JustTimeOfDay(hour: 9, minute: 0),
                          timeFormat: .twelveHour,
                        ),
                        TimePickerSpinner(
                          value: spinnerTime,
                          onChanged: (JustTimeOfDay t) =>
                              setState(() => spinnerTime = t),
                        ),
                        TimePickerDial(
                          selectedTime: dialTime,
                          activeSegment: .hour,
                          onChanged: (JustTimeOfDay t) =>
                              setState(() => dialTime = t),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final AnimatedContainer amToggle = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.descendant(
                  of: find.byType(TimePickerInput),
                  matching: find.text('AM'),
                ),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final AnimatedContainer pmToggle = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.descendant(
                  of: find.byType(TimePickerInput),
                  matching: find.text('PM'),
                ),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        expect(amToggle.duration, equals(Duration.zero));
        expect(pmToggle.duration, equals(Duration.zero));

        final AnimatedDefaultTextStyle wheelText = tester
            .widget<AnimatedDefaultTextStyle>(
              find
                  .descendant(
                    of: find.byType(TimePickerSpinner),
                    matching: find.byType(AnimatedDefaultTextStyle),
                  )
                  .first,
            );
        expect(wheelText.duration, equals(Duration.zero));

        // Keyboard step in reduced motion jumps immediately without throwing
        final FocusNode spinnerFocus = tester
            .widget<Focus>(
              find.descendant(
                of: find.byType(TimePickerSpinner),
                matching: find.byType(Focus),
              ),
            )
            .focusNode!;
        spinnerFocus.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(spinnerTime.hour, equals(11));

        // Dial keyboard step in reduced motion settles immediately
        final FocusNode dialFocus = tester
            .widget<Focus>(
              find.descendant(
                of: find.byType(TimePickerDial),
                matching: find.byType(Focus),
              ),
            )
            .focusNode!;
        dialFocus.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expect(dialTime.hour, equals(11));
      },
    );

    testWidgets(
      'TimePickerSpinner showContainer defaults true and omits card when false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            const Column(
              mainAxisSize: .min,
              children: <Widget>[
                TimePickerSpinner(
                  key: Key('with-container'),
                  value: JustTimeOfDay(hour: 9, minute: 30),
                ),
                TimePickerSpinner(
                  key: Key('without-container'),
                  value: JustTimeOfDay(hour: 9, minute: 30),
                  showContainer: false,
                ),
              ],
            ),
          ),
        );

        bool hasShadowedCard(Key key) {
          return tester
              .widgetList<Container>(
                find.descendant(
                  of: find.byKey(key),
                  matching: find.byType(Container),
                ),
              )
              .any((Container c) {
                final Decoration? dec = c.decoration;
                return dec is BoxDecoration &&
                    dec.boxShadow != null &&
                    dec.boxShadow!.isNotEmpty;
              });
        }

        expect(hasShadowedCard(const Key('with-container')), isTrue);
        expect(hasShadowedCard(const Key('without-container')), isFalse);
      },
    );

    testWidgets(
      'JustTimePickerStyle and JustTimePickerTheme override overAndUnderCenterOpacity and spinnerRowHeight',
      (WidgetTester tester) async {
        const Color customSelected = Color(0xFF123456);
        const Color customDialText = Color(0xFF654321);
        const Color customPeriodActive = Color(0xFF224466);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[
                JustTimePickerTheme(
                  inlineStyle: JustTimePickerStyle(
                    overAndUnderCenterOpacity: 0.85,
                    spinnerRowHeight: 50.0,
                    selectedTextColor: customSelected,
                    dialTextColor: customDialText,
                    periodActiveColor: customPeriodActive,
                  ),
                ),
              ],
            ),
            home: JustThemeProvider(
              lightTheme: JustThemeData.light,
              child: const Scaffold(
                body: Center(
                  child: JustTimePicker.inline(
                    value: JustTimeOfDay(hour: 9, minute: 41),
                    mode: .spinner,
                  ),
                ),
              ),
            ),
          ),
        );

        final ListWheelScrollView hourWheel = tester
            .widget<ListWheelScrollView>(
              find.byType(ListWheelScrollView).first,
            );
        expect(hourWheel.overAndUnderCenterOpacity, equals(0.85));
        expect(hourWheel.itemExtent, equals(50.0));

        // Verify header uses inlineStyle periodActiveColor fallback
        final Container hourHeaderContainer = tester.widget<Container>(
          find
              .ancestor(
                of: find.text('09').first,
                matching: find.byType(Container),
              )
              .first,
        );
        final BoxDecoration hourHeaderDec =
            hourHeaderContainer.decoration! as BoxDecoration;
        expect(hourHeaderDec.color, equals(customPeriodActive));

        // Instance style overrides theme extension
        await tester.pumpWidget(
          buildTestApp(
            const TimePickerSpinner(
              value: JustTimeOfDay(hour: 9, minute: 41),
              style: JustTimePickerStyle(
                overAndUnderCenterOpacity: 0.92,
                spinnerRowHeight: 52.0,
              ),
            ),
          ),
        );

        final ListWheelScrollView styledWheel = tester
            .widget<ListWheelScrollView>(
              find.byType(ListWheelScrollView).first,
            );
        expect(styledWheel.overAndUnderCenterOpacity, equals(0.92));
        expect(styledWheel.itemExtent, equals(52.0));
      },
    );

    testWidgets(
      'TimePickerDial uses localized nextValueLabel and previousValueLabel',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          buildTestApp(
            const TimePickerDial(
              selectedTime: JustTimeOfDay(hour: 10, minute: 0),
              activeSegment: .hour,
              locale: JustTimePickerLocale(
                hourLabel: 'Jam',
                nextValueLabel: 'Nilai berikutnya',
                previousValueLabel: 'Nilai sebelumnya',
              ),
            ),
          ),
        );

        final Finder semanticsFinder = find.byWidgetPredicate(
          (Widget w) => w is Semantics && w.properties.label == 'Jam',
        );
        expect(semanticsFinder, findsOneWidget);

        final SemanticsNode dialSemantics = tester.getSemantics(
          semanticsFinder,
        );
        expect(dialSemantics.increasedValue, equals('Nilai berikutnya'));
        expect(dialSemantics.decreasedValue, equals('Nilai sebelumnya'));

        handle.dispose();
      },
    );

    testWidgets(
      'JustTimePicker exposes semanticsLabel and FocusIndicator on dropdown and modal triggers',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          buildTestApp(
            const Column(
              mainAxisSize: .min,
              children: <Widget>[
                JustTimePicker.inline(
                  value: JustTimeOfDay(hour: 9, minute: 41),
                  mode: .spinner,
                  semanticsLabel: 'Pilih waktu',
                ),
                JustTimePicker.dropdown(
                  value: JustTimeOfDay(hour: 9, minute: 41),
                  semanticsLabel: 'Dropdown waktu',
                ),
                JustTimePicker.modal(
                  value: JustTimeOfDay(hour: 9, minute: 41),
                  semanticsLabel: 'Modal waktu',
                ),
                JustTimePicker.responsive(
                  value: JustTimeOfDay(hour: 9, minute: 41),
                  semanticsLabel: 'Responsif waktu',
                ),
              ],
            ),
          ),
        );

        final Finder inlineSemantics = find.byWidgetPredicate(
          (Widget w) =>
              w is Semantics &&
              w.properties.label == 'Pilih waktu' &&
              w.container &&
              w.explicitChildNodes,
        );
        expect(inlineSemantics, findsOneWidget);

        expect(
          find.descendant(
            of: find.byWidgetPredicate(
              (Widget w) => w is JustTimePicker && w.variant == .dropdown,
            ),
            matching: find.byType(FocusIndicator),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: find.byWidgetPredicate(
              (Widget w) => w is JustTimePicker && w.variant == .modal,
            ),
            matching: find.byType(FocusIndicator),
          ),
          findsOneWidget,
        );

        handle.dispose();
      },
    );
  });
}
