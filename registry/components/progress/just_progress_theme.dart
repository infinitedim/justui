import 'package:flutter/material.dart' show ThemeExtension;

import 'just_progress_style.dart';

/// Global theme configuration for progress indicators, extending Flutter's [ThemeExtension].
class const JustProgressTheme({
  /// Base style override for progress components.
  final JustProgressStyle? style,
}) extends ThemeExtension<JustProgressTheme> {
  /// Default configuration for the theme.
  static const defaults = JustProgressTheme();

  @override
  JustProgressTheme copyWith({JustProgressStyle? style}) {
    return JustProgressTheme(style: style ?? this.style);
  }

  @override
  JustProgressTheme lerp(ThemeExtension<JustProgressTheme>? other, double t) {
    if (other is! JustProgressTheme) return this;
    return t < 0.5 ? this : other;
  }
}
