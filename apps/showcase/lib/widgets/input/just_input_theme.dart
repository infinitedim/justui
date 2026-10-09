// justui-meta: registry=5a9c5dd087220e465584cbfd251d4836740a37d8738e7ea2afd7ada8326653be local=13f5969401360a0af460d7c5ed370502e1e30216c33705d88bc44f24fd637ee0
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_input_style.dart';

/// Global theme configurations for inputs, extending Flutter's [ThemeExtension].
class JustInputTheme extends ThemeExtension<JustInputTheme> {
  /// Default input styling override.
  final JustInputStyle? inputStyle;

  const JustInputTheme({this.inputStyle});

  /// Default configuration for the theme.
  static const JustInputTheme defaults = JustInputTheme();

  @override
  JustInputTheme copyWith({JustInputStyle? inputStyle}) {
    return JustInputTheme(inputStyle: inputStyle ?? this.inputStyle);
  }

  @override
  JustInputTheme lerp(ThemeExtension<JustInputTheme>? other, double t) {
    if (other is! JustInputTheme) return this;
    return t < 0.5 ? this : other;
  }
}
