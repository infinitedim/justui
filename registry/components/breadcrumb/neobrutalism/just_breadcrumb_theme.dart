import 'package:flutter/material.dart' show ThemeExtension;

import 'just_breadcrumb_style.dart';

/// Global theme configuration for breadcrumbs, extending Flutter's [ThemeExtension].
class JustBreadcrumbTheme extends ThemeExtension<JustBreadcrumbTheme> {
  /// Default style override for breadcrumbs.
  final JustBreadcrumbStyle? style;

  /// Creates a [JustBreadcrumbTheme] theme extension.
  const JustBreadcrumbTheme({this.style});

  /// Default theme configuration.
  static const defaults = JustBreadcrumbTheme();

  @override
  JustBreadcrumbTheme copyWith({JustBreadcrumbStyle? style}) {
    return JustBreadcrumbTheme(style: style ?? this.style);
  }

  @override
  JustBreadcrumbTheme lerp(
    ThemeExtension<JustBreadcrumbTheme>? other,
    double t,
  ) {
    if (other is! JustBreadcrumbTheme) return this;
    return t < 0.5 ? this : other;
  }
}
