import 'package:flutter/material.dart' show ThemeExtension;

import 'just_accordion_style.dart';

/// Global theme configuration for accordions, extending Flutter's [ThemeExtension].
class JustAccordionTheme extends ThemeExtension<JustAccordionTheme> {
  /// Base style override for accordion components.
  final JustAccordionStyle? style;

  /// Creates a [JustAccordionTheme] configuration.
  const JustAccordionTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustAccordionTheme();

  @override
  JustAccordionTheme copyWith({JustAccordionStyle? style}) {
    return JustAccordionTheme(style: style ?? this.style);
  }

  @override
  JustAccordionTheme lerp(ThemeExtension<JustAccordionTheme>? other, double t) {
    if (other is! JustAccordionTheme) return this;
    return t < 0.5 ? this : other;
  }
}
