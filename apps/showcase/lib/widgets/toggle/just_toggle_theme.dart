// justui-meta: registry=e15e4eec2e0737a8ca4f8cd9df8010c277860eb3b560fec3e073459ba08b1b7c local=2dfb6054b6a6acccbd99a011885822f37b5ccf0a9cdb48622a9e8414bfa93461
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_toggle_style.dart';

/// Global theme configuration for toggle buttons, extending Flutter's [ThemeExtension].
class JustToggleTheme extends ThemeExtension<JustToggleTheme> {
  /// Base style override for toggle components.
  final JustToggleStyle? style;

  const JustToggleTheme({this.style});

  /// Default configuration for the theme.
  static const JustToggleTheme defaults = JustToggleTheme();

  @override
  JustToggleTheme copyWith({JustToggleStyle? style}) {
    return JustToggleTheme(style: style ?? this.style);
  }

  @override
  JustToggleTheme lerp(ThemeExtension<JustToggleTheme>? other, double t) {
    if (other is! JustToggleTheme) return this;
    return t < 0.5 ? this : other;
  }
}
