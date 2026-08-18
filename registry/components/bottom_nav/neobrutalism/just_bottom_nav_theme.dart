import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_bottom_nav_style.dart';
import 'package:just_ui_core/just_ui_core.dart';

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

  
  /// Fallback factory constructor from [JustThemeData].
  factory JustBottomNavTheme.fromTheme(JustThemeData justTheme) => const JustBottomNavTheme();

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

/// Extension method on [BuildContext] to access [JustBottomNavTheme] safely.
extension JustBottomNavThemeContext on BuildContext {
  JustBottomNavTheme get justBottomNavTheme =>
      Theme.of(this).extension<JustBottomNavTheme>() ??
      JustBottomNavTheme.fromTheme(justTheme);
}
