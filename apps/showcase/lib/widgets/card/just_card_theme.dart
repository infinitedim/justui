// justui-meta: registry=e635d9c8dc3d5b3254b268e6372363f09e22656eca300b6aa3f845eb1e6cdee7 local=e635d9c8dc3d5b3254b268e6372363f09e22656eca300b6aa3f845eb1e6cdee7
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_card_style.dart';

/// Global theme configuration for cards, extending Flutter's [ThemeExtension].
class const JustCardTheme({
  /// The global base style override for all card variants.
  final JustCardStyle? style,
}) extends ThemeExtension<JustCardTheme> {
  /// Default configuration for the theme.
  static const defaults = JustCardTheme();

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
