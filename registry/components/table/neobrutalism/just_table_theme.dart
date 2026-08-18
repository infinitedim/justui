import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_table_style.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for tables, extending Flutter's [ThemeExtension].
class JustTableTheme extends ThemeExtension<JustTableTheme> {
  /// Base style override for table components.
  final JustTableStyle? style;

  /// Creates a [JustTableTheme] configuration.
  const JustTableTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustTableTheme();

  /// Fallback factory constructor from [JustThemeData].
  factory JustTableTheme.fromTheme(JustThemeData justTheme) =>
      const JustTableTheme();

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

/// Extension method on [BuildContext] to access [JustTableTheme] safely.
extension JustTableThemeContext on BuildContext {
  JustTableTheme get justTableTheme =>
      Theme.of(this).extension<JustTableTheme>() ??
      JustTableTheme.fromTheme(justTheme);
}
