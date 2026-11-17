// justui-meta: registry=838fade20e6baecdb5bb7cd2ac75794b0ee38ed0375171a1a63ea48586fd6fe6 local=9e8b066205054ea1c03d2d8956064fde1cf0e3837e9c16b10087842fcdd61f15
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_table_style.dart';

/// Global theme configuration for tables, extending Flutter's [ThemeExtension].
class JustTableTheme extends ThemeExtension<JustTableTheme> {
  /// Base style override for table components.
  final JustTableStyle? style;

  const JustTableTheme({this.style});

  /// Default configuration for the theme.
  static const JustTableTheme defaults = JustTableTheme();

  @override
  JustTableTheme copyWith({JustTableStyle? style}) {
    return JustTableTheme(style: style ?? this.style);
  }

  @override
  JustTableTheme lerp(ThemeExtension<JustTableTheme>? other, double t) {
    if (other is! JustTableTheme) return this;
    return t < 0.5 ? this : other;
  }
}
