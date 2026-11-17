// justui-meta: registry=dea907a8a3fbb176f382d17e6134cf15afc1ab98275d34e2231874df7cb29ca2 local=f76a9ad168748bda2eece2482df32df48878fb97bf9a918a095a163a00e66023
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
