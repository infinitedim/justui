// justui-meta: registry=227c384e0b4fb2c34183df1fbc34b6bac081d3ae253270d8aaeb809e3cc2c3ec local=227c384e0b4fb2c34183df1fbc34b6bac081d3ae253270d8aaeb809e3cc2c3ec
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
