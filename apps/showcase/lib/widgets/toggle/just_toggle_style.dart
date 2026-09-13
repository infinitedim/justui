// justui-meta: registry=05e1b3f3e243d604e506e000ea7af1117ca8c827229748a77a84319b7850b028 local=05e1b3f3e243d604e506e000ea7af1117ca8c827229748a77a84319b7850b028
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustToggle] and [JustToggleGroup].
class const JustToggleStyle({
  /// Custom background color of the toggle when selected.
  final Color? selectedBackgroundColor,

  /// Custom background color of the toggle when unselected.
  final Color? unselectedBackgroundColor,

  /// Custom border color of the toggle when selected.
  final Color? selectedBorderColor,

  /// Custom border color of the toggle when unselected.
  final Color? unselectedBorderColor,

  /// Custom text or icon color of the toggle when selected.
  final Color? selectedTextColor,

  /// Custom text or icon color of the toggle when unselected.
  final Color? unselectedTextColor,

  /// Custom border radius.
  final BorderRadius? borderRadius,
});
