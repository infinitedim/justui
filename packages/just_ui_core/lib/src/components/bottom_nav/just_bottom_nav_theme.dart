import 'package:flutter/material.dart';
import 'just_bottom_nav_style.dart';

/// Global theme configuration for bottom navigation bars, extending Flutter's [ThemeExtension].
class JustBottomNavTheme extends ThemeExtension<JustBottomNavTheme> {
  /// Default style override for [JustBottomNavVariant.fixed].
  final JustBottomNavStyle? fixedStyle;

  /// Default style override for [JustBottomNavVariant.shifting].
  final JustBottomNavStyle? shiftingStyle;

  /// Default style override for [JustBottomNavVariant.floating].
  final JustBottomNavStyle? floatingStyle;

  /// Creates a [JustBottomNavTheme] theme extension.
  const JustBottomNavTheme({
    this.fixedStyle,
    this.shiftingStyle,
    this.floatingStyle,
  });

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
