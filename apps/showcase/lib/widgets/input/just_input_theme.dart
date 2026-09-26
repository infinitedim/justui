// justui-meta: registry=5a9c5dd087220e465584cbfd251d4836740a37d8738e7ea2afd7ada8326653be local=9e41600a75fafba17ce5a1719e9967cd2914638f8730fd1dcde381259ee183ca
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
