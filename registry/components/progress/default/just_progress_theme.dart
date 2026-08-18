import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_progress_style.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for progress indicators, extending Flutter's [ThemeExtension].
class JustProgressTheme extends ThemeExtension<JustProgressTheme> {
  /// Base style override for progress components.
  final JustProgressStyle? style;

  /// Creates a [JustProgressTheme] configuration.
  const JustProgressTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustProgressTheme();

  
  /// Fallback factory constructor from [JustThemeData].
  factory JustProgressTheme.fromTheme(JustThemeData justTheme) => const JustProgressTheme();

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

/// Extension method on [BuildContext] to access [JustProgressTheme] safely.
extension JustProgressThemeContext on BuildContext {
  JustProgressTheme get justProgressTheme =>
      Theme.of(this).extension<JustProgressTheme>() ??
      JustProgressTheme.fromTheme(justTheme);
}
