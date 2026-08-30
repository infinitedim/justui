import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/date_picker/_date_picker_calendar.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker.dart';
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
      tester,
    ) async {
      DateTime? selectedDate;
      final initialDate = DateTime(2026, 8, 15);

      await tester.pumpWidget(
        buildTestApp(
          JustDatePicker.inline(
            value: initialDate,
            onChanged: (date) => selectedDate = date,
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
      tester,
    ) async {
      DateTime? selectedDate;
      final initialDate = DateTime(2026, 8, 15);
      final firstDate = DateTime(2026, 8, 10);
      final lastDate = DateTime(2026, 8, 25);

      await tester.pumpWidget(
        buildTestApp(
          JustDatePicker.inline(
            value: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            onChanged: (date) => selectedDate = date,
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

    testWidgets('Navigates months using chevron arrows', (tester) async {
      final initialDate = DateTime(2026, 8, 15);

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

    testWidgets('Supports custom headerBuilder', (tester) async {
      final initialDate = DateTime(2026, 8, 15);

      await tester.pumpWidget(
        buildTestApp(
          JustDatePicker.inline(
            value: initialDate,
            headerBuilder:
                (context, activeDate, view, toggleView, onPrev, onNext) {
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
      tester,
    ) async {
      final initialDate = DateTime(2026, 8, 15);

      await tester.pumpWidget(
        buildTestApp(
          JustDatePicker.dropdown(
            value: initialDate,
            placeholder: 'Select date',
            onChanged: (date) {},
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
    testWidgets('Selects date range via two taps', (tester) async {
      DateTimeRange? selectedRange;

      await tester.pumpWidget(
        buildTestApp(
          JustDateRangePicker(
            value: DateTimeRange(
              start: DateTime(2026, 8, 1),
              end: DateTime(2026, 8, 1),
            ),
            onChanged: (DateTimeRange range) => selectedRange = range,
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

    testWidgets('Triggers range preset button selection', (tester) async {
      DateTimeRange? selectedRange;

      await tester.pumpWidget(
        buildTestApp(
          JustDateRangePicker(
            presets: JustDateRangePicker.defaultPresets(),
            onChanged: (DateTimeRange range) => selectedRange = range,
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

  group('Neobrutalism Theme Preset Integration', () {
    testWidgets('Renders DatePicker under Neobrutalism preset', (tester) async {
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
