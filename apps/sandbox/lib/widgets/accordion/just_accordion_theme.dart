// justui-meta: registry=0007f3a698699799ab63849d04de1fa4191e99ccbcf7bacc74629aa0a11fe903 local=23b79702a8e8131ea51efea754d6fd6c8cba5e50bd9a7d96219658f82e387431
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
