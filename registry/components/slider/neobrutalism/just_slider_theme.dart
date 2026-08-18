import 'package:flutter/material.dart' show ThemeExtension;

import 'just_slider_style.dart';

/// Global theme configuration for sliders, extending Flutter's [ThemeExtension].
class JustSliderTheme extends ThemeExtension<JustSliderTheme> {
  /// Base style override for sliders.
  final JustSliderStyle? style;

  /// Whether to enable haptic feedback on slider interactions.
  final bool enableHaptic;

  /// Creates a [JustSliderTheme] configuration.
  const JustSliderTheme({this.style, this.enableHaptic = true});

  /// Default configuration for the theme.
  static const defaults = JustSliderTheme();

  @override
  JustSliderTheme copyWith({JustSliderStyle? style, bool? enableHaptic}) {
    return JustSliderTheme(
      style: style ?? this.style,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustSliderTheme lerp(ThemeExtension<JustSliderTheme>? other, double t) {
    if (other is! JustSliderTheme) return this;
    return t < 0.5 ? this : other;
  }
}
