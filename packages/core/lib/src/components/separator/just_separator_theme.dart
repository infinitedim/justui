import 'package:flutter/material.dart' show ThemeExtension;

import 'just_separator_style.dart';

/// Global theme configuration for separators, extending Flutter's [ThemeExtension].
class JustSeparatorTheme extends ThemeExtension<JustSeparatorTheme> {
  /// The global style override for all separators.
  final JustSeparatorStyle? style;

  /// Creates a [JustSeparatorTheme] configuration.
  const JustSeparatorTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustSeparatorTheme();

  @override
  JustSeparatorTheme copyWith({JustSeparatorStyle? style}) {
    return JustSeparatorTheme(style: style ?? this.style);
  }

  @override
  JustSeparatorTheme lerp(ThemeExtension<JustSeparatorTheme>? other, double t) {
    if (other is! JustSeparatorTheme) return this;
    return t < 0.5 ? this : other;
  }
}
