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
}) {
  /// Returns a copy with given fields replaced.
  JustCheckboxStyle copyWith({
    Color? activeColor,
    Color? checkColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    return JustCheckboxStyle(
      activeColor: activeColor ?? this.activeColor,
      checkColor: checkColor ?? this.checkColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Linearly interpolates between two [JustCheckboxStyle]s.
  static JustCheckboxStyle? lerp(
    JustCheckboxStyle? a,
    JustCheckboxStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return JustCheckboxStyle(
      activeColor: Color.lerp(a?.activeColor, b?.activeColor, t),
      checkColor: Color.lerp(a?.checkColor, b?.checkColor, t),
      borderColor: Color.lerp(a?.borderColor, b?.borderColor, t),
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustCheckboxStyle &&
          runtimeType == other.runtimeType &&
          activeColor == other.activeColor &&
          checkColor == other.checkColor &&
          borderColor == other.borderColor &&
          borderRadius == other.borderRadius &&
          textStyle == other.textStyle;

  @override
  int get hashCode => Object.hash(
    activeColor,
    checkColor,
    borderColor,
    borderRadius,
    textStyle,
  );
}
