// justui-meta: registry=c591b12ef63f9b8713748acc1097ef2ab10a75f41e8f3306d74ab885b28c4f4e local=cd6614694988d99253777cee43831d08fe53531e3e2bae5a8fc7d1ea65a7ef72
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_select_style.dart';

/// Global theme configuration for select dropdowns, extending Flutter's [ThemeExtension].
class JustSelectTheme extends ThemeExtension<JustSelectTheme> {
  /// Base style override for select components.
  final JustSelectStyle? style;

  const JustSelectTheme({this.style});

  /// Default configuration for the theme.
  static const JustSelectTheme defaults = JustSelectTheme();

  @override
  JustSelectTheme copyWith({JustSelectStyle? style}) {
    return JustSelectTheme(style: style ?? this.style);
  }

  @override
  JustSelectTheme lerp(ThemeExtension<JustSelectTheme>? other, double t) {
    if (other is! JustSelectTheme) return this;
    return t < 0.5 ? this : other;
  }
}
