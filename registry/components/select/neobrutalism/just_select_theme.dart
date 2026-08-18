import 'package:flutter/material.dart' show ThemeExtension;

import 'just_select_style.dart';

/// Global theme configuration for select dropdowns, extending Flutter's [ThemeExtension].
class JustSelectTheme extends ThemeExtension<JustSelectTheme> {
  /// Base style override for select components.
  final JustSelectStyle? style;

  /// Creates a [JustSelectTheme] configuration.
  const JustSelectTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustSelectTheme();

  @override
  JustSelectTheme copyWith({JustSelectStyle? style}) {
    return JustSelectTheme(style: style ?? this.style);
  }

  @override
  JustSelectTheme lerp(ThemeExtension<JustSelectTheme>? other, double t) {
    if (other is! JustSelectTheme) return this;
    return t < 0.5 ? this : other;
  }
}
