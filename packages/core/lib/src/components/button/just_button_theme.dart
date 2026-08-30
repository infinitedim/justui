import 'package:flutter/material.dart' show ThemeExtension;

import 'just_button_style.dart';

/// Alias for [JustButtonTheme] for convention parity.
typedef JustButtonThemeData = JustButtonTheme;

/// Global theme configuration for buttons, extending Flutter's [ThemeExtension].
class const JustButtonTheme({
  /// Style override for the primary button.
  final JustButtonStyle? primaryStyle,

  /// Style override for the secondary button.
  final JustButtonStyle? secondaryStyle,

  /// Style override for the ghost button.
  final JustButtonStyle? ghostStyle,

  /// Style override for the destructive button.
  final JustButtonStyle? destructiveStyle,

  /// Style override for the link button.
  final JustButtonStyle? linkStyle,

  /// Whether to enable haptic feedback on button presses by default.
  final bool enableHaptic = false,
}) extends ThemeExtension<JustButtonTheme> {
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
    return JustButtonTheme(
      primaryStyle: JustButtonStyle.lerp(primaryStyle, other.primaryStyle, t),
      secondaryStyle: JustButtonStyle.lerp(
        secondaryStyle,
        other.secondaryStyle,
        t,
      ),
      ghostStyle: JustButtonStyle.lerp(ghostStyle, other.ghostStyle, t),
      destructiveStyle: JustButtonStyle.lerp(
        destructiveStyle,
        other.destructiveStyle,
        t,
      ),
      linkStyle: JustButtonStyle.lerp(linkStyle, other.linkStyle, t),
      enableHaptic: t < 0.5 ? enableHaptic : other.enableHaptic,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustButtonTheme &&
          runtimeType == other.runtimeType &&
          primaryStyle == other.primaryStyle &&
          secondaryStyle == other.secondaryStyle &&
          ghostStyle == other.ghostStyle &&
          destructiveStyle == other.destructiveStyle &&
          linkStyle == other.linkStyle &&
          enableHaptic == other.enableHaptic;

  @override
  int get hashCode => Object.hash(
    primaryStyle,
    secondaryStyle,
    ghostStyle,
    destructiveStyle,
    linkStyle,
    enableHaptic,
  );
}
