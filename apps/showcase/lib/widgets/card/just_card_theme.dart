// justui-meta: registry=afecb0ad46b9fd3c0bfecbbb04978d58d899621018a09d7ef7c6497a9681bf64 local=afecb0ad46b9fd3c0bfecbbb04978d58d899621018a09d7ef7c6497a9681bf64
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_card_style.dart';

/// Global theme configuration for cards, extending Flutter's [ThemeExtension].
class JustCardTheme extends ThemeExtension<JustCardTheme> {
  /// The global base style override for all card variants.
  final JustCardStyle? style;

  /// Creates a [JustCardTheme] configuration.
  const JustCardTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustCardTheme();

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
