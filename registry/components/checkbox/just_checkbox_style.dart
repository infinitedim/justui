import 'package:flutter/widgets.dart';

/// The physical size classification for [JustCheckbox].
enum JustCheckboxSize {
  /// Small size (16x16 visual area)
  sm,

  /// Medium size (20x20 visual area)
  md,

  /// Large size (24x24 visual area)
  lg,
}

/// Customized per-instance visual styles for [JustCheckbox].
class const JustCheckboxStyle({
  /// Background color of the checkbox when checked.
  final Color? activeColor,

  /// Color of the checkmark/indeterminate dash.
  final Color? checkColor,

  /// Border color of the checkbox when unchecked.
  final Color? borderColor,

  /// Border radius of the checkbox square.
  final BorderRadius? borderRadius,

  /// Text style of the checkbox label.
  final TextStyle? textStyle,
});
