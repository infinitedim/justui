// justui-meta: registry=033f977fbeb91050e785b6c4d4b429d8e03b6b650f797a955422dbd618121f5f local=867132c41ac5e1e6c4647a00e8e6217d2a11f1556f6aec909137511a37c59a9b
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
  });
}

/// Quick-select date range preset definition for [JustDateRangePicker].
class JustDateRangePreset {
  /// Display label shown on the preset button (e.g. 'Last 7 Days').
  final String label;

  /// Callback returning the corresponding [DateTimeRange].
  final DateTimeRange Function() resolve;

  const JustDateRangePreset({required this.label, required this.resolve});
}
