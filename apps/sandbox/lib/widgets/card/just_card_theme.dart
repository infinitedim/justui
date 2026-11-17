// justui-meta: registry=e47ddda445a9a258408944c9a02f5f31f5325cac7f2e2a3e6cb5fbe94b20cb58 local=0a77dbe2705ed4f8821200f9185da1277a115c9e5b0b1b556d7c870412d5c5dd
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_card_style.dart';

/// Global theme configuration for cards, extending Flutter's [ThemeExtension].
class JustCardTheme extends ThemeExtension<JustCardTheme> {
  /// The global base style override for all card variants.
  final JustCardStyle? style;

  const JustCardTheme({this.style});

  /// Default configuration for the theme.
  static const JustCardTheme defaults = JustCardTheme();

  @override
  JustCardTheme copyWith({JustCardStyle? style}) {
    return JustCardTheme(style: style ?? this.style);
  }

  @override
  JustCardTheme lerp(ThemeExtension<JustCardTheme>? other, double t) {
    if (other is! JustCardTheme) return this;
    return t < 0.5 ? this : other;
  }
}
