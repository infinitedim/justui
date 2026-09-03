import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustButton] and [JustIconButton].
class const JustButtonStyle({
  /// Custom background color of the button.
  final Color? backgroundColor,

  /// Custom text or icon color of the button.
  final Color? foregroundColor,

  /// Custom border color of the button.
  final Color? borderColor,

  /// Custom border radius of the button.
  final BorderRadius? borderRadius,

  /// Custom inner padding of the button.
  final EdgeInsets? padding,

  /// Custom text style overrides.
  final TextStyle? textStyle,

  /// Custom elevation (shadow).
  final double? elevation,
}) {
  /// Returns a copy with given fields replaced.
  JustButtonStyle copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    double? elevation,
  }) {
    return JustButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      elevation: elevation ?? this.elevation,
    );
  }

  /// Linearly interpolates between two [JustButtonStyle]s.
  static JustButtonStyle? lerp(
    JustButtonStyle? a,
    JustButtonStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    final double? lerpedElevation;
    if (a?.elevation != null && b?.elevation != null) {
      lerpedElevation = a!.elevation! + (b!.elevation! - a.elevation!) * t;
    } else {
      lerpedElevation = t < 0.5 ? a?.elevation : b?.elevation;
    }
    return JustButtonStyle(
      backgroundColor: .lerp(a?.backgroundColor, b?.backgroundColor, t),
      foregroundColor: .lerp(a?.foregroundColor, b?.foregroundColor, t),
      borderColor: .lerp(a?.borderColor, b?.borderColor, t),
      borderRadius: .lerp(a?.borderRadius, b?.borderRadius, t),
      padding: .lerp(a?.padding, b?.padding, t),
      textStyle: .lerp(a?.textStyle, b?.textStyle, t),
      elevation: lerpedElevation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustButtonStyle &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          foregroundColor == other.foregroundColor &&
          borderColor == other.borderColor &&
          borderRadius == other.borderRadius &&
          padding == other.padding &&
          textStyle == other.textStyle &&
          elevation == other.elevation;

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    foregroundColor,
    borderColor,
    borderRadius,
    padding,
    textStyle,
    elevation,
  );
}
