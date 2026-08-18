import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_card_style.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for cards, extending Flutter's [ThemeExtension].
class JustCardTheme extends ThemeExtension<JustCardTheme> {
  /// The global base style override for all card variants.
  final JustCardStyle? style;

  /// Creates a [JustCardTheme] configuration.
  const JustCardTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustCardTheme();

  
  /// Fallback factory constructor from [JustThemeData].
  factory JustCardTheme.fromTheme(JustThemeData justTheme) => const JustCardTheme();

  @override
  JustCardTheme copyWith({JustCardStyle? style}) {
    return JustCardTheme(style: style ?? this.style);
  }

  @override
  JustCardTheme lerp(ThemeExtension<JustCardTheme>? other, double t) {
    if (other is! JustCardTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Extension method on [BuildContext] to access [JustCardTheme] safely.
extension JustCardThemeContext on BuildContext {
  JustCardTheme get justCardTheme =>
      Theme.of(this).extension<JustCardTheme>() ??
      JustCardTheme.fromTheme(justTheme);
}
