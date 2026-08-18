import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_accordion_style.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for accordions, extending Flutter's [ThemeExtension].
class JustAccordionTheme extends ThemeExtension<JustAccordionTheme> {
  /// Base style override for accordion components.
  final JustAccordionStyle? style;

  /// Creates a [JustAccordionTheme] configuration.
  const JustAccordionTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustAccordionTheme();

  /// Fallback factory constructor from [JustThemeData].
  factory JustAccordionTheme.fromTheme(JustThemeData justTheme) =>
      const JustAccordionTheme();

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

/// Extension method on [BuildContext] to access [JustAccordionTheme] safely.
extension JustAccordionThemeContext on BuildContext {
  JustAccordionTheme get justAccordionTheme =>
      Theme.of(this).extension<JustAccordionTheme>() ??
      JustAccordionTheme.fromTheme(justTheme);
}
