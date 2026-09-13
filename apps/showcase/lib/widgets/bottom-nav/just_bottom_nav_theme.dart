// justui-meta: registry=bb4d3c347a2ea9e3ec6c84875b9745a51feb20e6e6afe22438ca91650ab1e4a1 local=bb4d3c347a2ea9e3ec6c84875b9745a51feb20e6e6afe22438ca91650ab1e4a1
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_bottom_nav_style.dart';

/// Global theme configuration for bottom navigation bars, extending Flutter's [ThemeExtension].
class const JustBottomNavTheme({
  /// Default style override for [JustBottomNavVariant.fixed].
  final JustBottomNavStyle? fixedStyle,

  /// Default style override for [JustBottomNavVariant.shifting].
  final JustBottomNavStyle? shiftingStyle,

  /// Default style override for [JustBottomNavVariant.floating].
  final JustBottomNavStyle? floatingStyle,
}) extends ThemeExtension<JustBottomNavTheme> {
  /// Default theme configuration.
  static const defaults = JustBottomNavTheme();

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
