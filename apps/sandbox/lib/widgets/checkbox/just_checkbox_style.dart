// justui-meta: registry=8fe56b6b3caa3f2c39f74758665b6fc3a03bb7ec639b83313ed89ba1f22573c8 local=eac38e643c46747d7b5ed65e2cf1d82d4ac43b0594b999f877667e32e21320be
import 'package:flutter/foundation.dart' show listEquals;
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

  /// Custom box shadow when unchecked. If null, follows preset tokens.
  final List<BoxShadow>? shadows;

  /// Custom box shadow when checked/active. If null, follows [shadows] or preset tokens.
  final List<BoxShadow>? activeShadows;

  const JustCheckboxStyle({
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.borderRadius,
    this.textStyle,
    this.shadows,
    this.activeShadows,
  });

  /// Returns a copy with given fields replaced.
  JustCheckboxStyle copyWith({
    Color? activeColor,
    Color? checkColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    List<BoxShadow>? shadows,
    List<BoxShadow>? activeShadows,
  }) {
    return JustCheckboxStyle(
      activeColor: activeColor ?? this.activeColor,
      checkColor: checkColor ?? this.checkColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      textStyle: textStyle ?? this.textStyle,
      shadows: shadows ?? this.shadows,
      activeShadows: activeShadows ?? this.activeShadows,
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
      activeColor: .lerp(a?.activeColor, b?.activeColor, t),
      checkColor: .lerp(a?.checkColor, b?.checkColor, t),
      borderColor: .lerp(a?.borderColor, b?.borderColor, t),
      borderRadius: .lerp(a?.borderRadius, b?.borderRadius, t),
      textStyle: .lerp(a?.textStyle, b?.textStyle, t),
      shadows: t < 0.5 ? a?.shadows : b?.shadows,
      activeShadows: t < 0.5 ? a?.activeShadows : b?.activeShadows,
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
          textStyle == other.textStyle &&
          listEquals(shadows, other.shadows) &&
          listEquals(activeShadows, other.activeShadows);

  @override
  int get hashCode => Object.hash(
    activeColor,
    checkColor,
    borderColor,
    borderRadius,
    textStyle,
    shadows == null ? null : Object.hashAll(shadows!),
    activeShadows == null ? null : Object.hashAll(activeShadows!),
  );
}
