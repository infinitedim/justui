// justui-meta: registry=6c20b28590d5a532d92194b95e2965ef6c8ea4f29483c62581901693e4568d30 local=649462dd24d9c3f2608a18fcb9473ad9812d46df21c865d31225835db6994006
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_progress_style.dart';

/// Global theme configuration for progress indicators, extending Flutter's [ThemeExtension].
class JustProgressTheme extends ThemeExtension<JustProgressTheme> {
  /// Base style override for progress components.
  final JustProgressStyle? style;

  const JustProgressTheme({this.style});

  /// Default configuration for the theme.
  static const JustProgressTheme defaults = JustProgressTheme();

  @override
  JustProgressTheme copyWith({JustProgressStyle? style}) {
    return JustProgressTheme(style: style ?? this.style);
  }

  @override
  JustProgressTheme lerp(ThemeExtension<JustProgressTheme>? other, double t) {
    if (other is! JustProgressTheme) return this;
    return t < 0.5 ? this : other;
  }
}
