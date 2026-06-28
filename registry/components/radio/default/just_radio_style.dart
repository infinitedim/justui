import 'package:flutter/widgets.dart';

/// The physical size classification for [JustRadio].
enum JustRadioSize {
  /// Small size (16x16 visual area)
  sm,

  /// Medium size (20x20 visual area)
  md,

  /// Large size (24x24 visual area)
  lg,
}

/// Customized per-instance visual styles for [JustRadio].
class JustRadioStyle {
  /// The active color of the radio ring and inner dot when selected.
  final Color? activeColor;

  /// The color of the radio ring when unselected.
  final Color? borderColor;

  /// The color of the inner dot. Defaults to [activeColor].
  final Color? dotColor;

  /// Text style of the radio label.
  final TextStyle? textStyle;

  /// Creates a [JustRadioStyle] override.
  const JustRadioStyle({
    this.activeColor,
    this.borderColor,
    this.dotColor,
    this.textStyle,
  });
}
