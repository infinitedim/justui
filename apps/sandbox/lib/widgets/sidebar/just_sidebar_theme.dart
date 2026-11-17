// justui-meta: registry=b9ed9660714671263c10fe6fb6bced5cf2285f06bce537d99de9d5e758779078 local=cef7f0f6e005362341e253fefc07c5cfa41b07403b6eae4959fccf9a2aeb123d
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
