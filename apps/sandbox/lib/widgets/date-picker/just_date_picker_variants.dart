// justui-meta: registry=864a7d7eaced87dcc11625d1aaf73aecd0c4a55937977fe12f6eb76aef9b0420 local=f8f27a3205c0685512fa1d235bc1814ede5844e1a5f44363c684fd9ea68ba473
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

/// An immutable date range consisting of [start] and [end] timestamps.
class JustDateTimeRange {
  /// The start of the range.
  final DateTime start;

  /// The end of the range.
  final DateTime end;

  /// Creates a [JustDateTimeRange].
  JustDateTimeRange({required this.start, required this.end})
    : assert(!start.isAfter(end), 'start cannot be after end');

  /// The duration between [start] and [end].
  Duration get duration => end.difference(start);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustDateTimeRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start - $end';
}

/// Quick-select date range preset definition for [JustDateRangePicker].
class JustDateRangePreset {
  /// Display label shown on the preset button (e.g. 'Last 7 Days').
  final String label;

  /// Callback returning the corresponding [JustDateTimeRange].
  final JustDateTimeRange Function() resolve;

  const JustDateRangePreset({required this.label, required this.resolve});
}
