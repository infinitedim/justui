import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_select_style.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for select dropdowns, extending Flutter's [ThemeExtension].
class JustSelectTheme extends ThemeExtension<JustSelectTheme> {
  /// Base style override for select components.
  final JustSelectStyle? style;

  /// Creates a [JustSelectTheme] configuration.
  const JustSelectTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustSelectTheme();

  
  /// Fallback factory constructor from [JustThemeData].
  factory JustSelectTheme.fromTheme(JustThemeData justTheme) => const JustSelectTheme();

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

/// Extension method on [BuildContext] to access [JustSelectTheme] safely.
extension JustSelectThemeContext on BuildContext {
  JustSelectTheme get justSelectTheme =>
      Theme.of(this).extension<JustSelectTheme>() ??
      JustSelectTheme.fromTheme(justTheme);
}
