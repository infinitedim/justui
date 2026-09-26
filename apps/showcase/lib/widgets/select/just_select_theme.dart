// justui-meta: registry=262e2b9eb3361467268330565dfa7ec4dfc6ee1fc999afe867261a79663710d7 local=22ee6cc18580bedde01c5c00c3adb34cfada5e17dd72ed96f840eb6f0f731ce5
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
