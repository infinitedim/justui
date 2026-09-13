// justui-meta: registry=0f744f75a31ec7a971c8f66c4fd72d1ac26670638b8fdcf76d1017f44f3eb8cf local=0f744f75a31ec7a971c8f66c4fd72d1ac26670638b8fdcf76d1017f44f3eb8cf
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_breadcrumb_style.dart';

/// Global theme configuration for breadcrumbs, extending Flutter's [ThemeExtension].
class const JustBreadcrumbTheme({
  /// Default style override for breadcrumbs.
  final JustBreadcrumbStyle? style,
}) extends ThemeExtension<JustBreadcrumbTheme> {
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
