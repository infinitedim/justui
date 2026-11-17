// justui-meta: registry=f6c1254534c903be9d3ebd80358b4f7a63b2b2f09519ed89592335c45fe117c9 local=c5db384d0b6b8f858298d2c6aed977cfdfc1531afd88841c7586e05a240fb96c
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
