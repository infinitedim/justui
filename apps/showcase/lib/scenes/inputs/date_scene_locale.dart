// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker_style.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker_variants.dart';

import '../scene.dart';

/// Year of the demo month.
///
/// The React demos show October without a year. Core marks today with a
/// ring from `DateTime.now()` and has no way to pass a fixed "today", so a
/// demo month that contains the current day would change the goldens every
/// day. A past October keeps them stable.
const int _demoYear = 2025;

/// Day [day] of the demo month (October).
DateTime demoDay(int day) => DateTime(_demoYear, 10, day);

/// Calendar copy from the page: October, the weekday row and the day cell
/// label. Only October is ever shown ([demoHeader] has no month arrows), so
/// the other month names never reach the screen or a screen reader.
JustDatePickerLocale demoLocale(SceneContext scene) {
  const JustDatePickerLocale en = JustDatePickerLocale();
  final List<String> months = List<String>.of(en.monthNames);
  months[9] = scene.strings.text('month');
  final List<String> weekdays = scene.strings.list('weekdays');
  return JustDatePickerLocale(
    monthNames: months,
    shortMonthNames: en.shortMonthNames,
    weekdayHeaders: weekdays.length == 7 ? weekdays : en.weekdayHeaders,
    dayLabel: scene.strings.text('dayLabel'),
  );
}

/// The month name alone, like the React demo's label: no arrows and no
/// month or year view, so the calendar stays on the demo month.
Widget Function(
  BuildContext context,
  DateTime activeDate,
  JustCalendarView view,
  VoidCallback toggleView,
  VoidCallback onPrev,
  VoidCallback onNext,
)
demoHeader(SceneContext scene) {
  return (
    BuildContext context,
    DateTime activeDate,
    JustCalendarView view,
    VoidCallback toggleView,
    VoidCallback onPrev,
    VoidCallback onNext,
  ) => Padding(
    padding: .symmetric(vertical: context.justSpacing.xs),
    child: Text(
      scene.strings.text('month'),
      style: context.justTypo.headingSm.copyWith(
        color: context.justColors.textPrimary,
      ),
    ),
  );
}

/// Sundays in ink: Ink and Paper keeps status colors for validation and
/// destructive actions, and core paints Sundays in the error role.
JustDatePickerStyle demoStyle(BuildContext context) =>
    JustDatePickerStyle(sundayTextColor: context.justColors.textPrimary);
