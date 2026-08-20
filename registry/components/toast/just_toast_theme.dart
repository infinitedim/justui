import 'package:flutter/material.dart' show ThemeExtension;

import 'just_toast_style.dart';

/// Global theme configuration for toasts, extending Flutter's [ThemeExtension].
class const JustToastTheme({
  /// Style override for informational toasts.
  final JustToastStyle? infoStyle,

  /// Style override for success toasts.
  final JustToastStyle? successStyle,

  /// Style override for warning toasts.
  final JustToastStyle? warningStyle,

  /// Style override for error toasts.
  final JustToastStyle? errorStyle,

  /// Whether to enable haptic feedback when a toast is shown.
  final bool enableHaptic = false,
}) extends ThemeExtension<JustToastTheme> {
  /// Default configuration for the theme.
  static const defaults = JustToastTheme();

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
