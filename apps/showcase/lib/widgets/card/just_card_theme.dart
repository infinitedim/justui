// justui-meta: registry=72713e2987f3b9487c7a994bf5c7f5db58e65f084df5034c155f4f20868e968b local=600ef5e830e9e4928c6f6d1582c156501726c8f28a0d9a10eda91d327fc6877d
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_card_style.dart';

/// Global theme configuration for cards, extending Flutter's [ThemeExtension].
class JustCardTheme extends ThemeExtension<JustCardTheme> {
  /// The global base style override for all card variants.
  final JustCardStyle? style;

  const JustCardTheme({this.style});

  /// Default configuration for the theme.
  static const JustCardTheme defaults = JustCardTheme();

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
