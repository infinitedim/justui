import 'package:flutter/material.dart' show ThemeExtension;
import 'just_radio_style.dart';

/// Global theme configuration for radio buttons, extending Flutter's [ThemeExtension].
class JustRadioTheme extends ThemeExtension<JustRadioTheme> {
  /// Base style override for radio buttons.
  final JustRadioStyle? style;

  /// Whether to enable haptic feedback on radio selection changes.
  final bool enableHaptic;

  /// Creates a [JustRadioTheme] configuration.
  const JustRadioTheme({this.style, this.enableHaptic = false});

  /// Default configuration for the theme.
  static const defaults = JustRadioTheme();

  @override
  JustRadioTheme copyWith({JustRadioStyle? style, bool? enableHaptic}) {
    return JustRadioTheme(
      style: style ?? this.style,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustRadioTheme lerp(ThemeExtension<JustRadioTheme>? other, double t) {
    if (other is! JustRadioTheme) return this;
    return t < 0.5 ? this : other;
  }
}
