// justui-meta: registry=1628deba06c92b8c7bcf7a73ebc07af56e60ade1f8ebf76e94e4a907d81fa810 local=12ebce38969950548558f2ab5895ff2c6f1997d40436564e7630014c5fdbcf40
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
