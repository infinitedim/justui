import 'package:flutter/material.dart' show ThemeExtension;

import 'just_table_style.dart';

/// Global theme configuration for tables, extending Flutter's [ThemeExtension].
class const JustTableTheme({
  /// Base style override for table components.
  final JustTableStyle? style,
}) extends ThemeExtension<JustTableTheme> {
  /// Default configuration for the theme.
  static const defaults = JustTableTheme();

  @override
  JustTableTheme copyWith({JustTableStyle? style}) {
    return JustTableTheme(style: style ?? this.style);
  }

  @override
  JustTableTheme lerp(ThemeExtension<JustTableTheme>? other, double t) {
    if (other is! JustTableTheme) return this;
    return t < 0.5 ? this : other;
  }
}
