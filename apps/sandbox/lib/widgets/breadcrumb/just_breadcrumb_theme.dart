// justui-meta: registry=82e949293ba5753cc01cde989b943856b1e340666c5bb69a12a1271784655563 local=bd0423fc14366524f581b0f6cede472279beba11f135d02f702210224977ca63
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_breadcrumb_style.dart';

/// Global theme configuration for breadcrumbs, extending Flutter's [ThemeExtension].
class JustBreadcrumbTheme extends ThemeExtension<JustBreadcrumbTheme> {
  /// Default style override for breadcrumbs.
  final JustBreadcrumbStyle? style;

  const JustBreadcrumbTheme({this.style});

  /// Default theme configuration.
  static const JustBreadcrumbTheme defaults = JustBreadcrumbTheme();

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
