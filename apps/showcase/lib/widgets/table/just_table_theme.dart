// justui-meta: registry=0bfb5051be3f7f12a2f16148f4ebde71929a19b9376c94a5f5d7a89d81229284 local=91cfe941a17248556f7132e4a393408f8cd16bac6036159165198fc7d9b6d358
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_table_style.dart';

/// Global theme configuration for tables, extending Flutter's [ThemeExtension].
class JustTableTheme extends ThemeExtension<JustTableTheme> {
  /// Base style override for table components.
  final JustTableStyle? style;

  const JustTableTheme({this.style});

  /// Default configuration for the theme.
  static const JustTableTheme defaults = JustTableTheme();

  @override
  JustTableTheme copyWith({JustTableStyle? style}) {
    return JustTableTheme(style: style ?? this.style);
  }

  @override
  JustTableTheme lerp(ThemeExtension<JustTableTheme>? other, double t) {
    if (other is! JustTableTheme) return this;
    return t < 0.5 ? this : other;
  }
}
