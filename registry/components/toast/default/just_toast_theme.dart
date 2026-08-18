import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_toast_style.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for toasts, extending Flutter's [ThemeExtension].
class JustToastTheme extends ThemeExtension<JustToastTheme> {
  /// Style override for informational toasts.
  final JustToastStyle? infoStyle;

  /// Style override for success toasts.
  final JustToastStyle? successStyle;

  /// Style override for warning toasts.
  final JustToastStyle? warningStyle;

  /// Style override for error toasts.
  final JustToastStyle? errorStyle;

  /// Whether to enable haptic feedback when a toast is shown.
  final bool enableHaptic;

  /// Creates a [JustToastTheme] configuration.
  const JustToastTheme({
    this.infoStyle,
    this.successStyle,
    this.warningStyle,
    this.errorStyle,
    this.enableHaptic = false,
  });

  /// Default configuration for the theme.
  static const defaults = JustToastTheme();

  /// Fallback factory constructor from [JustThemeData].
  factory JustToastTheme.fromTheme(JustThemeData justTheme) =>
      const JustToastTheme();

  @override
  JustToastTheme copyWith({
    JustToastStyle? infoStyle,
    JustToastStyle? successStyle,
    JustToastStyle? warningStyle,
    JustToastStyle? errorStyle,
    bool? enableHaptic,
  }) {
    return JustToastTheme(
      infoStyle: infoStyle ?? this.infoStyle,
      successStyle: successStyle ?? this.successStyle,
      warningStyle: warningStyle ?? this.warningStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustToastTheme lerp(ThemeExtension<JustToastTheme>? other, double t) {
    if (other is! JustToastTheme) return this;
    return t < 0.5 ? this : other;
  }
}

/// Extension method on [BuildContext] to access [JustToastTheme] safely.
extension JustToastThemeContext on BuildContext {
  JustToastTheme get justToastTheme =>
      Theme.of(this).extension<JustToastTheme>() ??
      JustToastTheme.fromTheme(justTheme);
}
