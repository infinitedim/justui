// justui-meta: registry=b605291f0db7999ae15a9fc4a46bce506326b2dc10c36ed8828c25bdd83e75d0 local=4b0b99f6c35df5adba2a3a06608297beaf1886dc3aaa1022bc36cfd2f61389ad
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_tooltip_style.dart';

/// Global theme configuration for tooltips, extending Flutter's [ThemeExtension].
class JustTooltipTheme extends ThemeExtension<JustTooltipTheme> {
  /// Style override for the tooltip.
  final JustTooltipStyle? style;

  const JustTooltipTheme({this.style});

  /// Default configuration for the theme.
  static const JustTooltipTheme defaults = JustTooltipTheme();

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
