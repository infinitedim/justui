// justui-meta: registry=0e95e9ddde2ed83abee07e4212bfcbf76a0069feb54451ab6b84eece481d1209 local=0e95e9ddde2ed83abee07e4212bfcbf76a0069feb54451ab6b84eece481d1209
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_input_style.dart';

/// Global theme configurations for inputs, extending Flutter's [ThemeExtension].
class JustInputTheme extends ThemeExtension<JustInputTheme> {
  /// Default input styling override.
  final JustInputStyle? inputStyle;

  /// Creates a [JustInputTheme] configuration.
  const JustInputTheme({this.inputStyle});

  /// Default configuration for the theme.
  static const defaults = JustInputTheme();

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
