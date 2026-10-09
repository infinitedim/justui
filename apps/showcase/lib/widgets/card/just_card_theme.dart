// justui-meta: registry=72713e2987f3b9487c7a994bf5c7f5db58e65f084df5034c155f4f20868e968b local=017bbb53d655d3fd99a9d743a5eccf2ef5d59048b45fb748c83e57bc01d0003f
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
