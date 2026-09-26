// justui-meta: registry=f0d9b6d5f0496f85b7b6d51a3fb5fa90064efd4db232420a472c989a29dbee19 local=81f079dd90994c1560a91bb869cc2f1054bdee33721f6c626923b4385daabe0b
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_toast_style.dart';

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

  const JustToastTheme({
    this.infoStyle,
    this.successStyle,
    this.warningStyle,
    this.errorStyle,
    this.enableHaptic = false,
  });

  /// Default configuration for the theme.
  static const JustToastTheme defaults = JustToastTheme();

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
