import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustToggle] and [JustToggleGroup].
class JustToggleStyle {
  /// Custom background color of the toggle when selected.
  final Color? selectedBackgroundColor;

  /// Custom background color of the toggle when unselected.
  final Color? unselectedBackgroundColor;

  /// Custom border color of the toggle when selected.
  final Color? selectedBorderColor;

  /// Custom border color of the toggle when unselected.
  final Color? unselectedBorderColor;

  /// Custom text or icon color of the toggle when selected.
  final Color? selectedTextColor;

  /// Custom text or icon color of the toggle when unselected.
  final Color? unselectedTextColor;

  /// Custom border radius.
  final BorderRadius? borderRadius;

  /// Creates a [JustToggleStyle] override.
  const JustToggleStyle({
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.borderRadius,
  });
}
