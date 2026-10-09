// justui-meta: registry=794bf56a7cd3f52f9ad250843c36d88248474b5a24a54260a4b1e1f613bc94ea local=1baf83fed9df2bac8af20d3c4eb70bc37f58a0d2038e77a06b7293fda510be62
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_separator_style.dart';

/// Global theme configuration for separators, extending Flutter's [ThemeExtension].
class JustSeparatorTheme extends ThemeExtension<JustSeparatorTheme> {
  /// The global style override for all separators.
  final JustSeparatorStyle? style;

  const JustSeparatorTheme({this.style});

  /// Default configuration for the theme.
  static const JustSeparatorTheme defaults = JustSeparatorTheme();

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
