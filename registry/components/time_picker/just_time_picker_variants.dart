import 'package:flutter/material.dart' show DayPeriod, TimeOfDay;

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

/// Boundary and formatting helper extensions on [TimeOfDay].
extension TimeOfDayBoundary on TimeOfDay {
  /// Total minutes since midnight for comparison and arithmetic.
  int get totalMinutes => hour * 60 + minute;

  /// Whether this time falls within inclusive [min] and [max] bounds.
  bool isWithin(TimeOfDay? min, TimeOfDay? max) {
    if (min != null && totalMinutes < min.totalMinutes) return false;
    if (max != null && totalMinutes > max.totalMinutes) return false;
    return true;
  }

  /// Clamps this time to the nearest valid value within [min] and [max] bounds.
  TimeOfDay clampTo(TimeOfDay? min, TimeOfDay? max) {
    if (min != null && totalMinutes < min.totalMinutes) return min;
    if (max != null && totalMinutes > max.totalMinutes) return max;
    return this;
  }

  /// Snaps minute to the nearest valid interval step.
  TimeOfDay snapMinute(int interval) {
    assert(60 % interval == 0, 'Interval must evenly divide 60');
    final snapped = ((minute / interval).round() * interval) % 60;
    return replacing(minute: snapped);
  }

  /// Returns a copy with the period toggled (AM↔PM).
  TimeOfDay togglePeriod() {
    final newHour = hour < 12 ? hour + 12 : hour - 12;
    return replacing(hour: newHour);
  }

  /// Returns a copy with a specific 12-hour value (1..12) and period.
  TimeOfDay withHour12(int hour12, DayPeriod period) {
    assert(hour12 >= 1 && hour12 <= 12, 'Hour in 12-hour format must be 1..12');
    final new24 = period == DayPeriod.am
        ? (hour12 == 12 ? 0 : hour12)
        : (hour12 == 12 ? 12 : hour12 + 12);
    return replacing(hour: new24);
  }
}
