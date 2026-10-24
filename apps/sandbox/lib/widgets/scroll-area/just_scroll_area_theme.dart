// justui-meta: registry=2043b211a79b74045ae3bb2f293424b5039e264e1738366bfee49b359d143a13 local=2233a015be712d86f2773abbea0af51418f217a2239a68c10da787bea7f66eec
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_scroll_area_style.dart';

/// Global theme configuration for scroll areas, extending Flutter's [ThemeExtension].
class JustScrollAreaTheme extends ThemeExtension<JustScrollAreaTheme> {
  /// The global style override for all scroll areas.
  final JustScrollAreaStyle? style;

  const JustScrollAreaTheme({this.style});

  /// Default configuration for the theme.
  static const JustScrollAreaTheme defaults = JustScrollAreaTheme();

  @override
  JustScrollAreaTheme copyWith({JustScrollAreaStyle? style}) {
    return JustScrollAreaTheme(style: style ?? this.style);
  }

  @override
  JustScrollAreaTheme lerp(
    ThemeExtension<JustScrollAreaTheme>? other,
    double t,
  ) {
    if (other is! JustScrollAreaTheme) return this;
    return t < 0.5 ? this : other;
  }
}
