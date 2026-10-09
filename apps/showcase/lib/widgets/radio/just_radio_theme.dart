// justui-meta: registry=142ea9bc77e2bd39236a089a439f51aa22ec9ba962ecf7fbcae6e81b9042d301 local=212b9e3042eabc1aeb63ac59cf8a29f81474b9cd6b8da1f003a92f97755ea66a
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_radio_style.dart';

/// Global theme configuration for radio buttons, extending Flutter's [ThemeExtension].
class JustRadioTheme extends ThemeExtension<JustRadioTheme> {
  /// Base style override for radio buttons.
  final JustRadioStyle? style;

  /// Whether to enable haptic feedback on radio selection changes.
  final bool enableHaptic;

  const JustRadioTheme({this.style, this.enableHaptic = false});

  /// Default configuration for the theme.
  static const JustRadioTheme defaults = JustRadioTheme();

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
