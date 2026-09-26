// justui-meta: registry=bf927bf92d45f37fb5bb7093ed890698d6ac158d4b1b6a111b59b9d13e2c6c16 local=549af54506265cdcb48cd80a824257d1a02b5d32f0488055a742169ea8ca29ee
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

  const JustRadioStyle({
    this.activeColor,
    this.borderColor,
    this.dotColor,
    this.textStyle,
  });
}
