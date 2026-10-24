// justui-meta: registry=5568fd1fc2838818e22aab45f517c81d4e10c8792bd9557b49aa4d0da7c304bb local=4f428dc22d97392ce83ae6ed0f4a9f5d4729e2980f3eb0d2003fb24d2bc21e21
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for date picker components.
class JustDatePickerStyle {
  /// Custom background color of the calendar container.
  final Color? backgroundColor;

  /// Custom text color for unselected day cells.
  final Color? dayTextColor;

  /// Custom text color for Sunday cells and Sunday header.
  final Color? sundayTextColor;

  /// Custom background color for the selected date.
  final Color? selectedDayColor;

  /// Custom text color for the selected date.
  final Color? selectedDayTextColor;

  /// Custom border color for today's date indicator.
  final Color? todayBorderColor;

  /// Custom fill color for days inside a selected range.
  final Color? rangeHighlightColor;

  /// Custom outer border color of the calendar container.
  final Color? borderColor;

  /// Custom border radius of the calendar container.
  final BorderRadius? borderRadius;

  /// Custom inner padding of the calendar container.
  final EdgeInsets? padding;

  /// Custom day cell dimension (width and height). Defaults to preset resolution.
  final double? cellSize;

  /// Custom elevation (shadow).
  final double? elevation;

  const JustDatePickerStyle({
    this.backgroundColor,
    this.dayTextColor,
    this.sundayTextColor,
    this.selectedDayColor,
    this.selectedDayTextColor,
    this.todayBorderColor,
    this.rangeHighlightColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.cellSize,
    this.elevation,
  });
}
