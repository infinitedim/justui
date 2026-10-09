// justui-meta: registry=a5867baaa5fde9fb8d9fc58246b3e724fd399fe3938c98b490b309ce9c1702ce local=94669b75bdbd3446fdbf952827247a2ae06af60dca525df50bc7a7d4fdc2137e
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_slider_style.dart';

/// Global theme configuration for sliders, extending Flutter's [ThemeExtension].
class JustSliderTheme extends ThemeExtension<JustSliderTheme> {
  /// Base style override for sliders.
  final JustSliderStyle? style;

  /// Whether to enable haptic feedback on slider interactions.
  final bool enableHaptic;

  const JustSliderTheme({this.style, this.enableHaptic = true});

  /// Default configuration for the theme.
  static const JustSliderTheme defaults = JustSliderTheme();

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
