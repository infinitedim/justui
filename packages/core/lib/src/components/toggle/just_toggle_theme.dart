import 'package:flutter/material.dart' show ThemeExtension;

import 'just_toggle_style.dart';

/// Global theme configuration for toggle buttons, extending Flutter's [ThemeExtension].
class const JustToggleTheme({
  /// Base style override for toggle components.
  final JustToggleStyle? style,
}) extends ThemeExtension<JustToggleTheme> {
  /// Default configuration for the theme.
  static const defaults = JustToggleTheme();

  @override
  JustToggleTheme copyWith({JustToggleStyle? style}) {
    return JustToggleTheme(style: style ?? this.style);
  }

  @override
  JustToggleTheme lerp(ThemeExtension<JustToggleTheme>? other, double t) {
    if (other is! JustToggleTheme) return this;
    return t < 0.5 ? this : other;
  }
}
