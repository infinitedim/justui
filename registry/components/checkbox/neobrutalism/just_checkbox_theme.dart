import 'package:flutter/material.dart' show ThemeExtension;

import 'just_checkbox_style.dart';

/// Global theme configuration for checkboxes, extending Flutter's [ThemeExtension].
class JustCheckboxTheme extends ThemeExtension<JustCheckboxTheme> {
  /// Base style override for checkboxes.
  final JustCheckboxStyle? style;

  /// Whether to enable haptic feedback on checkbox state changes.
  final bool enableHaptic;

  /// Creates a [JustCheckboxTheme] configuration.
  const JustCheckboxTheme({this.style, this.enableHaptic = false});

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
    return t < 0.5 ? this : other;
  }
}
