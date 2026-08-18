import 'package:flutter/material.dart' show ThemeExtension;

import 'just_tooltip_style.dart';

/// Global theme configuration for tooltips, extending Flutter's [ThemeExtension].
class const JustTooltipTheme({
  /// Style override for the tooltip.
  final JustTooltipStyle? style,
}) extends ThemeExtension<JustTooltipTheme> {
  /// Default configuration for the theme.
  static const defaults = JustTooltipTheme();

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
