// justui-meta: registry=44149c0775ae6e612591b3cc83524753e5b0ebaa88c7fb794950e903477f4109 local=fff35486196c63432b4cddaa033bfa8b4f7ba2cecc70e26f5c28caf689af2bb4
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
