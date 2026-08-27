import 'package:flutter/material.dart' show DateTimeRange;

/// Display variant for [JustDatePicker].
enum JustDatePickerVariant {
  /// Calendar renders directly in the widget tree (no overlay).
  inline,

  /// Calendar is shown in a modal dialog via [showJustDatePicker].
  modal,

  /// Calendar is attached as a dropdown popup beneath a trigger field.
  dropdown,
}

/// The currently active calendar view mode.
enum JustCalendarView {
  /// Shows individual days in a 7-column grid.
  day,

  /// Shows months in a 4x3 grid for the active year.
  month,

  /// Shows years in a 4x3 grid around the active year.
  year,
}

/// Custom locale names provider for date pickers without external dependencies.
class const JustDatePickerLocale({
  /// Full month names starting from January (index 0).
  final List<String> monthNames = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ],

  /// Short month names starting from Jan (index 0).
  final List<String> shortMonthNames = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ],

  /// Weekday abbreviation headers starting from Monday (index 0).
  final List<String> weekdayHeaders = const [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ],
});

/// Quick-select date range preset definition for [JustDateRangePicker].
class const JustDateRangePreset({
  /// Display label shown on the preset button (e.g. 'Last 7 Days').
  required final String label,

  /// Callback returning the corresponding [DateTimeRange].
  required final DateTimeRange Function() resolve,
});
