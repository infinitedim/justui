// justui-meta: registry=7104f09c1aad84d6c14db02f020c6fae84131fe39f16df6e57816440b94860a6 local=2bc4848113ef3b93a90165348c40be27b0975bc04c2e2cdd268740251618f3da
import 'package:flutter/material.dart' show DateTimeRange;

/// Display variant for [JustDatePicker].
enum JustDatePickerVariant {
  /// Calendar renders directly in the widget tree (no overlay).
  inline,

  /// Calendar is shown in a modal dialog via [showJustDatePicker].
  modal,

  /// Calendar is attached as a dropdown popup beneath a trigger field.
  dropdown,

  /// Adaptive variant: floating popover on desktop/tablet (≥ 640px),
  /// draggable bottom sheet on mobile (< 640px).
  responsive,
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
class JustDatePickerLocale {
  /// Full month names starting from January (index 0).
  final List<String> monthNames;

  /// Short month names starting from Jan (index 0).
  final List<String> shortMonthNames;

  /// Weekday abbreviation headers starting from Monday (index 0).
  final List<String> weekdayHeaders;

  /// What screen readers say for a day cell. `{day}`, `{month}` (from
  /// [monthNames]) and `{year}` are filled in, so the order can follow the
  /// language (for example '{day} {month} {year}').
  final String dayLabel;

  const JustDatePickerLocale({
    this.monthNames = const <String>[
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
    this.shortMonthNames = const <String>[
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
    this.weekdayHeaders = const <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ],
    this.dayLabel = 'Day {day}, {month} {year}',
  });

  /// [dayLabel] filled in for [date].
  String dayLabelFor(DateTime date) => dayLabel
      .replaceAll('{day}', '${date.day}')
      .replaceAll('{month}', monthNames[date.month - 1])
      .replaceAll('{year}', '${date.year}');
}

/// Quick-select date range preset definition for [JustDateRangePicker].
class JustDateRangePreset {
  /// Display label shown on the preset button (e.g. 'Last 7 Days').
  final String label;

  /// Callback returning the corresponding [DateTimeRange].
  final DateTimeRange Function() resolve;

  const JustDateRangePreset({required this.label, required this.resolve});
}
