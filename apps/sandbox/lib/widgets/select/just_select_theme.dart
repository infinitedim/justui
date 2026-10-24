// justui-meta: registry=262e2b9eb3361467268330565dfa7ec4dfc6ee1fc999afe867261a79663710d7 local=1ae53f1c1e531455b931cdd8a06aefb93c9e531a1460b9a6317c63b5ea5a0320
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_select_style.dart';

/// Global theme configuration for select dropdowns, extending Flutter's [ThemeExtension].
class JustSelectTheme extends ThemeExtension<JustSelectTheme> {
  /// Base style override for select components.
  final JustSelectStyle? style;

  const JustSelectTheme({this.style});

  /// Default configuration for the theme.
  static const JustSelectTheme defaults = JustSelectTheme();

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
