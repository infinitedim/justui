import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_sidebar_style.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for sidebars, extending Flutter's [ThemeExtension].
class JustSidebarTheme extends ThemeExtension<JustSidebarTheme> {
  /// Default style override for [JustSidebarVariant.default_].
  final JustSidebarStyle? defaultStyle;

  /// Default style override for [JustSidebarVariant.floating].
  final JustSidebarStyle? floatingStyle;

  /// Default style override for [JustSidebarVariant.inset].
  final JustSidebarStyle? insetStyle;

  /// Creates a [JustSidebarTheme] theme extension.
  const JustSidebarTheme({
    this.defaultStyle,
    this.floatingStyle,
    this.insetStyle,
  });

  /// Default theme configuration.
  static const defaults = JustSidebarTheme();

  /// Fallback factory constructor from [JustThemeData].
  factory JustSidebarTheme.fromTheme(JustThemeData justTheme) =>
      const JustSidebarTheme();

  @override
  JustSidebarTheme copyWith({
    JustSidebarStyle? defaultStyle,
    JustSidebarStyle? floatingStyle,
    JustSidebarStyle? insetStyle,
  }) {
    return JustSidebarTheme(
      defaultStyle: defaultStyle ?? this.defaultStyle,
      floatingStyle: floatingStyle ?? this.floatingStyle,
      insetStyle: insetStyle ?? this.insetStyle,
    );
  }

  @override
  JustSidebarTheme lerp(ThemeExtension<JustSidebarTheme>? other, double t) {
    if (other is! JustSidebarTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Extension method on [BuildContext] to access [JustSidebarTheme] safely.
extension JustSidebarThemeContext on BuildContext {
  JustSidebarTheme get justSidebarTheme =>
      Theme.of(this).extension<JustSidebarTheme>() ??
      JustSidebarTheme.fromTheme(justTheme);
}
