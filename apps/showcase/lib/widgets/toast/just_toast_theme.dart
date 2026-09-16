// justui-meta: registry=790636410ca043e519c1df34bea547490c447ff7a12659c1cf2b018e96d3bea7 local=790636410ca043e519c1df34bea547490c447ff7a12659c1cf2b018e96d3bea7
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
