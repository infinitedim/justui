// justui-meta: registry=e899c9ab266748e128c91bd087029b0f3d59972f5b465f993e2cbb6847bb8cb3 local=55a50a709da415d400423631216ba66f61b72d3f42ac88306d0c05f21defaed2
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_bottom_nav_style.dart';

/// Global theme configuration for bottom navigation bars, extending Flutter's [ThemeExtension].
class JustBottomNavTheme extends ThemeExtension<JustBottomNavTheme> {
  /// Default style override for [JustBottomNavVariant.fixed].
  final JustBottomNavStyle? fixedStyle;

  /// Default style override for [JustBottomNavVariant.shifting].
  final JustBottomNavStyle? shiftingStyle;

  /// Default style override for [JustBottomNavVariant.floating].
  final JustBottomNavStyle? floatingStyle;

  const JustBottomNavTheme({
    this.fixedStyle,
    this.shiftingStyle,
    this.floatingStyle,
  });

  /// Default theme configuration.
  static const JustBottomNavTheme defaults = JustBottomNavTheme();

  @override
  JustBottomNavTheme copyWith({
    JustBottomNavStyle? fixedStyle,
    JustBottomNavStyle? shiftingStyle,
    JustBottomNavStyle? floatingStyle,
  }) {
    return JustBottomNavTheme(
      fixedStyle: fixedStyle ?? this.fixedStyle,
      shiftingStyle: shiftingStyle ?? this.shiftingStyle,
      floatingStyle: floatingStyle ?? this.floatingStyle,
    );
  }

  @override
  JustBottomNavTheme lerp(ThemeExtension<JustBottomNavTheme>? other, double t) {
    if (other is! JustBottomNavTheme) return this;
    return t < 0.5 ? this : other;
  }
}
