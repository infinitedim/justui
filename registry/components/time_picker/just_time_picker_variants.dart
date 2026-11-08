/// Display variant for time pickers (mirrors date picker variants).
enum JustTimePickerVariant {
  /// Renders directly in the widget tree without overlay.
  inline,

  /// Displayed inside a modal dialog (desktop) or bottom sheet (mobile).
  modal,

  /// Attached as a dropdown popup beneath a trigger field via [OverlayPortal].
  dropdown,

  /// Adaptive — floating popover on desktop (≥640px), bottom sheet on mobile (<640px).
  responsive,
}

/// Internal interaction mode controlling the time selection mechanism.
enum JustTimePickerMode {
  /// Interactive clock face with draggable hand (CustomPainter).
  dial,

  /// Three-column vertical scrollable wheels (ListWheelScrollView).
  spinner,

  /// Direct numeric text input with stepper buttons.
  input,
}

/// Active focused segment in the time picker state machine.
enum JustTimePickerSegment {
  /// Hours segment (1-12 or 0-23).
  hour,

  /// Minutes segment (0-59, respecting minuteInterval).
  minute,

  /// AM/PM period segment (only in 12-hour mode).
  period,
}

/// Time format for display and input.
enum JustTimeFormat {
  /// 12-hour format with AM/PM indicator.
  twelveHour,

  /// 24-hour (international) format.
  twentyFourHour,
}

/// Zero-dependency locale strings for time picker labels.
class const JustTimePickerLocale({
  /// Label for the hour segment.
  final String hourLabel = 'Hour',

  /// Label for the minute segment.
  final String minuteLabel = 'Minute',

  /// Label for the period segment.
  final String periodLabel = 'Period',

  /// Label for the AM period.
  final String amLabel = 'AM',

  /// Label for the PM period.
  final String pmLabel = 'PM',

  /// Label for cancel action.
  final String cancelLabel = 'Cancel',

  /// Label for confirmation action.
  final String confirmLabel = 'OK',

  /// Tooltip text for switching to dial mode.
  final String dialModeTooltip = 'Switch to dial mode',

  /// Tooltip text for switching to text input mode.
  final String inputModeTooltip = 'Switch to text input',

  /// Tooltip text for switching to spinner mode.
  final String spinnerModeTooltip = 'Switch to spinner mode',
});

/// Represents whether a 12-hour time is before noon (AM) or after noon (PM).
enum JustDayPeriod {
  /// Ante meridiem (before noon).
  am,

  /// Post meridiem (after noon).
  pm,
}

/// An immutable representation of a time of day with [hour] and [minute].
class JustTimeOfDay implements Comparable<JustTimeOfDay> {
  /// The number of hours in one day (24).
  static const int hoursPerDay = 24;

  /// The number of hours in one day period (12).
  static const int hoursPerPeriod = 12;

  /// The number of minutes in one hour (60).
  static const int minutesPerHour = 60;

  /// The selected hour, in 24-hour time (0..23).
  final int hour;

  /// The selected minute (0..59).
  final int minute;

  /// Creates a [JustTimeOfDay].
  const JustTimeOfDay({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < hoursPerDay, 'hour must be between 0 and 23'),
      assert(
        minute >= 0 && minute < minutesPerHour,
        'minute must be between 0 and 59',
      );

  /// Creates a [JustTimeOfDay] from a [DateTime].
  JustTimeOfDay.fromDateTime(DateTime time)
    : hour = time.hour,
      minute = time.minute;

  /// Creates a [JustTimeOfDay] representing the current time.
  factory JustTimeOfDay.now() => JustTimeOfDay.fromDateTime(DateTime.now());

  /// Whether this time of day is before noon (AM) or after noon (PM).
  JustDayPeriod get period => hour < hoursPerPeriod ? .am : .pm;

  /// Which hour of the current period this time is (1..12).
  ///
  /// For 12AM (midnight) and 12PM (noon) this returns 12.
  int get hourOfPeriod => hour == 0 || hour == 12 ? 12 : hour - periodOffset;

  /// The hour at which the current period starts (0 for AM, 12 for PM).
  int get periodOffset => period == .am ? 0 : hoursPerPeriod;

  /// Returns a new [JustTimeOfDay] with the hour and/or minute replaced.
  JustTimeOfDay replacing({int? hour, int? minute}) {
    assert(hour == null || (hour >= 0 && hour < hoursPerDay));
    assert(minute == null || (minute >= 0 && minute < minutesPerHour));
    return JustTimeOfDay(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  /// Whether this time occurs earlier than [other].
  bool isBefore(JustTimeOfDay other) => compareTo(other) < 0;

  /// Whether this time occurs later than [other].
  bool isAfter(JustTimeOfDay other) => compareTo(other) > 0;

  /// Whether this time occurs at the same time as [other].
  bool isAtSameTimeAs(JustTimeOfDay other) => compareTo(other) == 0;

  @override
  int compareTo(JustTimeOfDay other) {
    final int hourComparison = hour.compareTo(other.hour);
    return hourComparison == 0
        ? minute.compareTo(other.minute)
        : hourComparison;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustTimeOfDay && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() {
    final String hourStr = hour < 10 ? '0$hour' : '$hour';
    final String minuteStr = minute < 10 ? '0$minute' : '$minute';
    return 'JustTimeOfDay($hourStr:$minuteStr)';
  }
}

/// Boundary and formatting helper extensions on [JustTimeOfDay].
extension TimeOfDayBoundary on JustTimeOfDay {
  /// Total minutes since midnight for comparison and arithmetic.
  int get totalMinutes => hour * 60 + minute;

  /// Whether this time falls within inclusive [min] and [max] bounds.
  bool isWithin(JustTimeOfDay? min, JustTimeOfDay? max) {
    if (min != null && totalMinutes < min.totalMinutes) return false;
    if (max != null && totalMinutes > max.totalMinutes) return false;
    return true;
  }

  /// Clamps this time to the nearest valid value within [min] and [max] bounds.
  JustTimeOfDay clampTo(JustTimeOfDay? min, JustTimeOfDay? max) {
    if (min != null && totalMinutes < min.totalMinutes) return min;
    if (max != null && totalMinutes > max.totalMinutes) return max;
    return this;
  }

  /// Snaps minute to the nearest valid interval step.
  JustTimeOfDay snapMinute(int interval) {
    assert(60 % interval == 0, 'Interval must evenly divide 60');
    final int snapped = ((minute / interval).round() * interval) % 60;
    return replacing(minute: snapped);
  }

  /// Returns a copy with the period toggled (AM<->PM).
  JustTimeOfDay togglePeriod() {
    final int newHour = hour < 12 ? hour + 12 : hour - 12;
    return replacing(hour: newHour);
  }

  /// Returns a copy with a specific 12-hour value (1..12) and period.
  JustTimeOfDay withHour12(int hour12, JustDayPeriod period) {
    assert(hour12 >= 1 && hour12 <= 12, 'Hour in 12-hour format must be 1..12');
    final int new24 = period == .am
        ? (hour12 == 12 ? 0 : hour12)
        : (hour12 == 12 ? 12 : hour12 + 12);
    return replacing(hour: new24);
  }
}
