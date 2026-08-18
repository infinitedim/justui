import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_slider_style.dart';

import 'package:just_ui_core/just_ui_core.dart';

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

  /// Fallback factory constructor from [JustThemeData].
  factory JustSliderTheme.fromTheme(JustThemeData justTheme) =>
      const JustSliderTheme();

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

/// Extension method on [BuildContext] to access [JustSliderTheme] safely.
extension JustSliderThemeContext on BuildContext {
  JustSliderTheme get justSliderTheme =>
      Theme.of(this).extension<JustSliderTheme>() ??
      JustSliderTheme.fromTheme(justTheme);
}
