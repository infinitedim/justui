import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_toggle_style.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for toggle buttons, extending Flutter's [ThemeExtension].
class JustToggleTheme extends ThemeExtension<JustToggleTheme> {
  /// Base style override for toggle components.
  final JustToggleStyle? style;

  /// Creates a [JustToggleTheme] configuration.
  const JustToggleTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustToggleTheme();

  
  /// Fallback factory constructor from [JustThemeData].
  factory JustToggleTheme.fromTheme(JustThemeData justTheme) => const JustToggleTheme();

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

/// Extension method on [BuildContext] to access [JustToggleTheme] safely.
extension JustToggleThemeContext on BuildContext {
  JustToggleTheme get justToggleTheme =>
      Theme.of(this).extension<JustToggleTheme>() ??
      JustToggleTheme.fromTheme(justTheme);
}
