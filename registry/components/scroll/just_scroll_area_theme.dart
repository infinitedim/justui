import 'package:flutter/material.dart' show ThemeExtension;

import 'just_scroll_area_style.dart';

/// Global theme configuration for scroll areas, extending Flutter's [ThemeExtension].
class const JustScrollAreaTheme({
  /// The global style override for all scroll areas.
  final JustScrollAreaStyle? style,
}) extends ThemeExtension<JustScrollAreaTheme> {
  /// Default configuration for the theme.
  static const defaults = JustScrollAreaTheme();

  @override
  JustScrollAreaTheme copyWith({JustScrollAreaStyle? style}) {
    return JustScrollAreaTheme(style: style ?? this.style);
  }

  @override
  JustScrollAreaTheme lerp(
    ThemeExtension<JustScrollAreaTheme>? other,
    double t,
  ) {
    if (other is! JustScrollAreaTheme) return this;
    return t < 0.5 ? this : other;
  }
}
