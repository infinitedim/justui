import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_scroll_area_style.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for scroll areas, extending Flutter's [ThemeExtension].
class JustScrollAreaTheme extends ThemeExtension<JustScrollAreaTheme> {
  /// The global style override for all scroll areas.
  final JustScrollAreaStyle? style;

  /// Creates a [JustScrollAreaTheme] configuration.
  const JustScrollAreaTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustScrollAreaTheme();

  /// Fallback factory constructor from [JustThemeData].
  factory JustScrollAreaTheme.fromTheme(JustThemeData justTheme) =>
      const JustScrollAreaTheme();

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

/// Extension method on [BuildContext] to access [JustScrollAreaTheme] safely.
extension JustScrollAreaThemeContext on BuildContext {
  JustScrollAreaTheme get justScrollAreaTheme =>
      Theme.of(this).extension<JustScrollAreaTheme>() ??
      JustScrollAreaTheme.fromTheme(justTheme);
}
