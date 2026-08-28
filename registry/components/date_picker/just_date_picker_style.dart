import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for date picker components.
class const JustDatePickerStyle({
  /// Custom background color of the calendar container.
  final Color? backgroundColor,

  /// Custom text color for unselected day cells.
  final Color? dayTextColor,

  /// Custom text color for Sunday cells and Sunday header.
  final Color? sundayTextColor,

  /// Custom background color for the selected date.
  final Color? selectedDayColor,

  /// Custom text color for the selected date.
  final Color? selectedDayTextColor,

  /// Custom border color for today's date indicator.
  final Color? todayBorderColor,

  /// Custom fill color for days inside a selected range.
  final Color? rangeHighlightColor,

  /// Custom outer border color of the calendar container.
  final Color? borderColor,

  /// Custom border radius of the calendar container.
  final BorderRadius? borderRadius,

  /// Custom inner padding of the calendar container.
  final EdgeInsets? padding,

  /// Custom day cell dimension (width and height). Defaults to preset resolution.
  final double? cellSize,

  /// Custom elevation (shadow).
  final double? elevation,
});
