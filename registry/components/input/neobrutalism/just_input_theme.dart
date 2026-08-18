import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_input_style.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configurations for inputs, extending Flutter's [ThemeExtension].
class JustInputTheme extends ThemeExtension<JustInputTheme> {
  /// Default input styling override.
  final JustInputStyle? inputStyle;

  /// Creates a [JustInputTheme] configuration.
  const JustInputTheme({this.inputStyle});

  /// Default configuration for the theme.
  static const defaults = JustInputTheme();

  /// Fallback factory constructor from [JustThemeData].
  factory JustInputTheme.fromTheme(JustThemeData justTheme) =>
      const JustInputTheme();

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

/// Extension method on [BuildContext] to access [JustInputTheme] safely.
extension JustInputThemeContext on BuildContext {
  JustInputTheme get justInputTheme =>
      Theme.of(this).extension<JustInputTheme>() ??
      JustInputTheme.fromTheme(justTheme);
}
