// justui-meta: registry=482fb7cbcf56fc24263d536f4bcfad97f6e2072577a368fe590332eb646cea6c local=c531d6a0d6a3a66ee349675dad379712641841f73d5227b96fb3092238a518d6
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_separator_style.dart';

/// Global theme configuration for separators, extending Flutter's [ThemeExtension].
class JustSeparatorTheme extends ThemeExtension<JustSeparatorTheme> {
  /// The global style override for all separators.
  final JustSeparatorStyle? style;

  const JustSeparatorTheme({this.style});

  /// Default configuration for the theme.
  static const JustSeparatorTheme defaults = JustSeparatorTheme();

  @override
  JustSeparatorTheme copyWith({JustSeparatorStyle? style}) {
    return JustSeparatorTheme(style: style ?? this.style);
  }

  @override
  JustSeparatorTheme lerp(ThemeExtension<JustSeparatorTheme>? other, double t) {
    if (other is! JustSeparatorTheme) return this;
    return t < 0.5 ? this : other;
  }
}
