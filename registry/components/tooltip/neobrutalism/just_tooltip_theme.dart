import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_tooltip_style.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for tooltips, extending Flutter's [ThemeExtension].
class JustTooltipTheme extends ThemeExtension<JustTooltipTheme> {
  /// Style override for the tooltip.
  final JustTooltipStyle? style;

  /// Creates a [JustTooltipTheme] configuration.
  const JustTooltipTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustTooltipTheme();

  
  /// Fallback factory constructor from [JustThemeData].
  factory JustTooltipTheme.fromTheme(JustThemeData justTheme) => const JustTooltipTheme();

  @override
  JustTooltipTheme copyWith({JustTooltipStyle? style}) {
    return JustTooltipTheme(style: style ?? this.style);
  }

  @override
  JustTooltipTheme lerp(ThemeExtension<JustTooltipTheme>? other, double t) {
    if (other is! JustTooltipTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Extension method on [BuildContext] to access [JustTooltipTheme] safely.
extension JustTooltipThemeContext on BuildContext {
  JustTooltipTheme get justTooltipTheme =>
      Theme.of(this).extension<JustTooltipTheme>() ??
      JustTooltipTheme.fromTheme(justTheme);
}
