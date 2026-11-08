import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/date_picker/_date_picker_calendar.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker_variants.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_range_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(Widget child, {JustThemeData? theme}) {
    return MaterialApp(
      home: JustThemeProvider(
        lightTheme: theme ?? JustThemeData.light,
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('JustDatePicker Widget Tests', () {
    testWidgets('Renders inline date picker and selects a date', (
      WidgetTester tester,
    ) async {
      DateTime? selectedDate;
      final DateTime initialDate = DateTime(2026, 8, 15);

      await tester.pumpWidget(
        buildTestApp(
          JustDatePicker.inline(
            value: initialDate,
            onChanged: (DateTime date) => selectedDate = date,
          ),
        ),
      );

      expect(find.byType(DatePickerCalendar), findsOneWidget);
      expect(find.text('August 2026'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);

      // Tap day 20
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      expect(selectedDate, equals(DateTime(2026, 8, 20)));
    });

    testWidgets('Restricts date selection with firstDate and lastDate', (
      WidgetTester tester,
    ) async {
      DateTime? selectedDate;
      final DateTime initialDate = DateTime(2026, 8, 15);
      final DateTime firstDate = DateTime(2026, 8, 10);
      final DateTime lastDate = DateTime(2026, 8, 25);

      await tester.pumpWidget(
        buildTestApp(
          JustDatePicker.inline(
            value: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            onChanged: (DateTime date) => selectedDate = date,
          ),
        ),
      );

      // Tap day 5 (before firstDate -> disabled)
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      expect(selectedDate, isNull);

      // Tap day 20 (within range -> selected)
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(selectedDate, equals(DateTime(2026, 8, 20)));
    });

    testWidgets('Navigates months using chevron arrows', (
      WidgetTester tester,
    ) async {
      final DateTime initialDate = DateTime(2026, 8, 15);

      await tester.pumpWidget(
        buildTestApp(JustDatePicker.inline(value: initialDate)),
      );

      expect(find.text('August 2026'), findsOneWidget);

      // Tap next month (chevron right icon)
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(find.text('September 2026'), findsOneWidget);

      // Tap prev month (chevron left icon)
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('August 2026'), findsOneWidget);
    });

    testWidgets('Supports custom headerBuilder', (WidgetTester tester) async {
      final DateTime initialDate = DateTime(2026, 8, 15);

      await tester.pumpWidget(
        buildTestApp(
          JustDatePicker.inline(
            value: initialDate,
            headerBuilder:
                (
                  BuildContext context,
                  DateTime activeDate,
                  JustCalendarView view,
                  VoidCallback toggleView,
                  void Function() onPrev,
                  void Function() onNext,
                ) {
                  return Text(
                    'Custom Header ${activeDate.month}/${activeDate.year}',
                  );
                },
          ),
        ),
      );

      expect(find.text('Custom Header 8/2026'), findsOneWidget);
    });

    testWidgets('Renders dropdown variant and toggles popup overlay', (
      WidgetTester tester,
    ) async {
      final DateTime initialDate = DateTime(2026, 8, 15);

      await tester.pumpWidget(
        buildTestApp(
          JustDatePicker.dropdown(
            value: initialDate,
            placeholder: 'Select date',
            onChanged: (DateTime date) {},
          ),
        ),
      );

      expect(find.text('15 Aug 2026'), findsOneWidget);
      expect(find.byType(DatePickerCalendar), findsNothing);

      // Tap trigger to open dropdown
      await tester.tap(find.text('15 Aug 2026'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerCalendar), findsOneWidget);
    });
  });

  group('JustDateRangePicker Widget Tests', () {
    testWidgets('Selects date range via two taps', (WidgetTester tester) async {
      JustDateTimeRange? selectedRange;

      await tester.pumpWidget(
        buildTestApp(
          JustDateRangePicker(
            value: JustDateTimeRange(
              start: DateTime(2026, 8, 1),
              end: DateTime(2026, 8, 1),
            ),
            onChanged: (JustDateTimeRange range) => selectedRange = range,
          ),
        ),
      );

      // First tap sets range start (day 10)
      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();

      // Second tap sets range end (day 20)
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      expect(selectedRange, isNotNull);
      expect(selectedRange!.start, equals(DateTime(2026, 8, 10)));
      expect(selectedRange!.end, equals(DateTime(2026, 8, 20)));
    });

    testWidgets('Triggers range preset button selection', (
      WidgetTester tester,
    ) async {
      JustDateTimeRange? selectedRange;

      await tester.pumpWidget(
        buildTestApp(
          JustDateRangePicker(
            presets: JustDateRangePicker.defaultPresets(),
            onChanged: (JustDateTimeRange range) => selectedRange = range,
          ),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);

      await tester.tap(find.text('Last 7 Days'));
      await tester.pumpAndSettle();

      expect(selectedRange, isNotNull);
    });
  });

  group('JustDateTimeRange Unit Tests', () {
    test('Calculates duration accurately and formats toString', () {
      final DateTime start = DateTime(2026, 8, 1, 10, 0);
      final DateTime end = DateTime(2026, 8, 5, 12, 30);
      final JustDateTimeRange range = JustDateTimeRange(start: start, end: end);

      expect(range.start, equals(start));
      expect(range.end, equals(end));
      expect(range.duration, equals(const Duration(days: 4, hours: 2, minutes: 30)));
      expect(range.toString(), equals('$start - $end'));
    });

    test('Throws AssertionError when start is after end', () {
      expect(
        () => JustDateTimeRange(
          start: DateTime(2026, 8, 10),
          end: DateTime(2026, 8, 5),
        ),
        throwsAssertionError,
      );
    });

    test('Value equality and hashCode', () {
      final JustDateTimeRange range1 = JustDateTimeRange(
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 10),
      );
      final JustDateTimeRange range2 = JustDateTimeRange(
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 10),
      );
      final JustDateTimeRange range3 = JustDateTimeRange(
        start: DateTime(2026, 8, 2),
        end: DateTime(2026, 8, 10),
      );

      expect(range1, equals(range2));
      expect(range1.hashCode, equals(range2.hashCode));
      expect(range1, isNot(equals(range3)));
    });

    test('Calendar leap year and month days calculation', () {
      // Leap year 2024
      expect(DateTime(2024, 3, 0).day, equals(29));
      // Non-leap year 2026
      expect(DateTime(2026, 3, 0).day, equals(28));
      // 30-day month
      expect(DateTime(2026, 5, 0).day, equals(30));
      // 31-day month
      expect(DateTime(2026, 9, 0).day, equals(31));
    });
  });

  group('Neobrutalism Theme Preset Integration', () {
    testWidgets('Renders DatePicker under Neobrutalism preset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          JustDatePicker.inline(value: DateTime(2026, 8, 15)),
          theme: JustThemeData.neobrutalismLight,
        ),
      );

      expect(find.byType(DatePickerCalendar), findsOneWidget);
      expect(find.text('August 2026'), findsOneWidget);
    });
  });
}
