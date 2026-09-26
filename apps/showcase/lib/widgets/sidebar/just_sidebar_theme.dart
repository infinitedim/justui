// justui-meta: registry=ddea63de6efd336c12972cf2f69d06a11eef3c39a6133293d3e26fdcc0ab1eed local=d4f20cd20a2b0f764323310e60ac5c2284fc557c7992835e81d47c2396c7b3c1
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_sidebar_style.dart';

/// Global theme configuration for sidebars, extending Flutter's [ThemeExtension].
class JustSidebarTheme extends ThemeExtension<JustSidebarTheme> {
  /// Default style override for [JustSidebarVariant.default_].
  final JustSidebarStyle? defaultStyle;

  /// Default style override for [JustSidebarVariant.floating].
  final JustSidebarStyle? floatingStyle;

  /// Default style override for [JustSidebarVariant.inset].
  final JustSidebarStyle? insetStyle;

  const JustSidebarTheme({
    this.defaultStyle,
    this.floatingStyle,
    this.insetStyle,
  });

  /// Default theme configuration.
  static const JustSidebarTheme defaults = JustSidebarTheme();

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
