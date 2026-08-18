import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_checkbox_style.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for checkboxes, extending Flutter's [ThemeExtension].
class JustCheckboxTheme extends ThemeExtension<JustCheckboxTheme> {
  /// Base style override for checkboxes.
  final JustCheckboxStyle? style;

  /// Whether to enable haptic feedback on checkbox state changes.
  final bool enableHaptic;

  /// Creates a [JustCheckboxTheme] configuration.
  const JustCheckboxTheme({this.style, this.enableHaptic = false});

  /// Default configuration for the theme.
  static const defaults = JustCheckboxTheme();

  /// Fallback factory constructor from [JustThemeData].
  factory JustCheckboxTheme.fromTheme(JustThemeData justTheme) =>
      const JustCheckboxTheme();

  @override
  JustCheckboxTheme copyWith({JustCheckboxStyle? style, bool? enableHaptic}) {
    return JustCheckboxTheme(
      style: style ?? this.style,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustCheckboxTheme lerp(ThemeExtension<JustCheckboxTheme>? other, double t) {
    if (other is! JustCheckboxTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Extension method on [BuildContext] to access [JustCheckboxTheme] safely.
extension JustCheckboxThemeContext on BuildContext {
  JustCheckboxTheme get justCheckboxTheme =>
      Theme.of(this).extension<JustCheckboxTheme>() ??
      JustCheckboxTheme.fromTheme(justTheme);
}
