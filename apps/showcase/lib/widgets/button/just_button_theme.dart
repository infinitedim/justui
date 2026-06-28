// justui-meta: registry=f4d0f2c52f56f910dbe00f92a4e1549994c3ced627b383987d2a620c109dc7bc local=f4d0f2c52f56f910dbe00f92a4e1549994c3ced627b383987d2a620c109dc7bc
import 'package:flutter/material.dart' show ThemeExtension;
import 'just_button_style.dart';

/// Global theme configuration for buttons, extending Flutter's [ThemeExtension].
class JustButtonTheme extends ThemeExtension<JustButtonTheme> {
  /// Style override for the primary button.
  final JustButtonStyle? primaryStyle;

  /// Style override for the secondary button.
  final JustButtonStyle? secondaryStyle;

  /// Style override for the ghost button.
  final JustButtonStyle? ghostStyle;

  /// Style override for the destructive button.
  final JustButtonStyle? destructiveStyle;

  /// Style override for the link button.
  final JustButtonStyle? linkStyle;

  /// Whether to enable haptic feedback on button presses by default.
  final bool enableHaptic;

  /// Creates a [JustButtonTheme] configuration.
  const JustButtonTheme({
    this.primaryStyle,
    this.secondaryStyle,
    this.ghostStyle,
    this.destructiveStyle,
    this.linkStyle,
    this.enableHaptic = false,
  });

  /// Default configuration for the theme.
  static const defaults = JustButtonTheme();

  @override
  JustButtonTheme copyWith({
    JustButtonStyle? primaryStyle,
    JustButtonStyle? secondaryStyle,
    JustButtonStyle? ghostStyle,
    JustButtonStyle? destructiveStyle,
    JustButtonStyle? linkStyle,
    bool? enableHaptic,
  }) {
    return JustButtonTheme(
      primaryStyle: primaryStyle ?? this.primaryStyle,
      secondaryStyle: secondaryStyle ?? this.secondaryStyle,
      ghostStyle: ghostStyle ?? this.ghostStyle,
      destructiveStyle: destructiveStyle ?? this.destructiveStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustButtonTheme lerp(ThemeExtension<JustButtonTheme>? other, double t) {
    if (other is! JustButtonTheme) return this;
    return t < 0.5 ? this : other;
  }
}
