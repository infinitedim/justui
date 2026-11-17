// justui-meta: registry=610ad7d178d4e7008d2a95057690f9ed4627edfdd6ae56fd1f8b6f611f0c937a local=328b6775dfca84b2d4ab626febb563a0266c4f6589b4dfda61ba11a99cbe26aa
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_scroll_area_style.dart';

/// Global theme configuration for scroll areas, extending Flutter's [ThemeExtension].
class JustScrollAreaTheme extends ThemeExtension<JustScrollAreaTheme> {
  /// The global style override for all scroll areas.
  final JustScrollAreaStyle? style;

  const JustScrollAreaTheme({this.style});

  /// Default configuration for the theme.
  static const JustScrollAreaTheme defaults = JustScrollAreaTheme();

  @override
  JustScrollAreaTheme copyWith({JustScrollAreaStyle? style}) {
    return JustScrollAreaTheme(style: style ?? this.style);
  }

  @override
  JustScrollAreaTheme lerp(
    ThemeExtension<JustScrollAreaTheme>? other,
    double t,
  ) {
    if (other is! JustScrollAreaTheme) return this;
    return t < 0.5 ? this : other;
  }
}
