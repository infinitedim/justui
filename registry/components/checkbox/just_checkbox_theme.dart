import 'package:flutter/material.dart' show ThemeExtension;

import 'just_checkbox_style.dart';

/// Alias for [JustCheckboxTheme] for convention parity.
typedef JustCheckboxThemeData = JustCheckboxTheme;

/// Global theme configuration for checkboxes, extending Flutter's [ThemeExtension].
class const JustCheckboxTheme({
  /// Base style override for checkboxes.
  final JustCheckboxStyle? style,

  /// Whether to enable haptic feedback on checkbox state changes.
  final bool enableHaptic = false,
}) extends ThemeExtension<JustCheckboxTheme> {
  /// Default configuration for the theme.
  static const defaults = JustCheckboxTheme();

  @override
  JustCheckboxTheme copyWith({JustCheckboxStyle? style, bool? enableHaptic}) {
    return JustCheckboxTheme(
      style: style ?? this.style,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustCheckboxTheme lerp(ThemeExtension<JustCheckboxTheme>? other, double t) {
    if (other is! JustCheckboxTheme) return this;
    return JustCheckboxTheme(
      style: .lerp(style, other.style, t),
      enableHaptic: t < 0.5 ? enableHaptic : other.enableHaptic,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustCheckboxTheme &&
          runtimeType == other.runtimeType &&
          style == other.style &&
          enableHaptic == other.enableHaptic;

  @override
  int get hashCode => Object.hash(style, enableHaptic);
}
