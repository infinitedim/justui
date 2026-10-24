// justui-meta: registry=c0df579127a6c1ceb4245e89db4c09078c58fc5a783c21371b32b8876d39c311 local=b87bb83b2102e920104a7efbf09d061dd7e3f702a3dea6df42b464ad110f1f22
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_accordion_style.dart';

/// Global theme configuration for accordions, extending Flutter's [ThemeExtension].
class JustAccordionTheme extends ThemeExtension<JustAccordionTheme> {
  /// Base style override for accordion components.
  final JustAccordionStyle? style;

  const JustAccordionTheme({this.style});

  /// Default configuration for the theme.
  static const JustAccordionTheme defaults = JustAccordionTheme();

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
