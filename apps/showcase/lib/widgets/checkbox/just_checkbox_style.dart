// justui-meta: registry=b551eaaf05face31a54bc719bdfa7d9e14be6b0df961ee7931b109491f4f1ab6 local=b551eaaf05face31a54bc719bdfa7d9e14be6b0df961ee7931b109491f4f1ab6
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
class JustCheckboxStyle {
  /// Background color of the checkbox when checked.
  final Color? activeColor;

  /// Color of the checkmark/indeterminate dash.
  final Color? checkColor;

  /// Border color of the checkbox when unchecked.
  final Color? borderColor;

  /// Border radius of the checkbox square.
  final BorderRadius? borderRadius;

  /// Text style of the checkbox label.
  final TextStyle? textStyle;

  /// Creates a [JustCheckboxStyle] override.
  const JustCheckboxStyle({
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.borderRadius,
    this.textStyle,
  });
}
