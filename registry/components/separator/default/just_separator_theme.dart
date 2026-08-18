import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_separator_style.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for separators, extending Flutter's [ThemeExtension].
class JustSeparatorTheme extends ThemeExtension<JustSeparatorTheme> {
  /// The global style override for all separators.
  final JustSeparatorStyle? style;

  /// Creates a [JustSeparatorTheme] configuration.
  const JustSeparatorTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustSeparatorTheme();

  
  /// Fallback factory constructor from [JustThemeData].
  factory JustSeparatorTheme.fromTheme(JustThemeData justTheme) => const JustSeparatorTheme();

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

/// Extension method on [BuildContext] to access [JustSeparatorTheme] safely.
extension JustSeparatorThemeContext on BuildContext {
  JustSeparatorTheme get justSeparatorTheme =>
      Theme.of(this).extension<JustSeparatorTheme>() ??
      JustSeparatorTheme.fromTheme(justTheme);
}
