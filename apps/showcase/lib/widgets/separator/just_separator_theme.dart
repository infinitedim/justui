// justui-meta: registry=9d40ec1154f69dc69eb34dfc0d5b34b95f8bd5c5dcd122c47a236fb718f42b24 local=9d40ec1154f69dc69eb34dfc0d5b34b95f8bd5c5dcd122c47a236fb718f42b24
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_separator_style.dart';

/// Global theme configuration for separators, extending Flutter's [ThemeExtension].
class const JustSeparatorTheme({
  /// The global style override for all separators.
  final JustSeparatorStyle? style,
}) extends ThemeExtension<JustSeparatorTheme> {
  /// Default configuration for the theme.
  static const defaults = JustSeparatorTheme();

  @override
  JustSeparatorTheme copyWith({JustSeparatorStyle? style}) {
    return JustSeparatorTheme(style: style ?? this.style);
  }

  @override
  JustSeparatorTheme lerp(ThemeExtension<JustSeparatorTheme>? other, double t) {
    if (other is! JustSeparatorTheme) return this;
    return t < 0.5 ? this : other;
  }
}
