import 'package:flutter/material.dart' show ThemeExtension;

import 'just_sidebar_style.dart';

/// Global theme configuration for sidebars, extending Flutter's [ThemeExtension].
class const JustSidebarTheme({
  /// Default style override for [JustSidebarVariant.default_].
  final JustSidebarStyle? defaultStyle,

  /// Default style override for [JustSidebarVariant.floating].
  final JustSidebarStyle? floatingStyle,

  /// Default style override for [JustSidebarVariant.inset].
  final JustSidebarStyle? insetStyle,
}) extends ThemeExtension<JustSidebarTheme> {
  /// Default theme configuration.
  static const defaults = JustSidebarTheme();

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
