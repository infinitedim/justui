// justui-meta: registry=597bef4c8d1faffa38e9b882c1e2079c459d0c33e884c9ab8f816dfa95aa13d5 local=597bef4c8d1faffa38e9b882c1e2079c459d0c33e884c9ab8f816dfa95aa13d5
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_switch_style.dart';

/// Global theme configuration for switch controls, extending Flutter's [ThemeExtension].
class JustSwitchTheme extends ThemeExtension<JustSwitchTheme> {
  /// Base style override for switches.
  final JustSwitchStyle? style;

  /// Whether to enable haptic feedback on switch toggles.
  final bool enableHaptic;

  /// Creates a [JustSwitchTheme] configuration.
  const JustSwitchTheme({this.style, this.enableHaptic = false});

  /// Default configuration for the theme.
  static const defaults = JustSwitchTheme();

  @override
  JustSwitchTheme copyWith({JustSwitchStyle? style, bool? enableHaptic}) {
    return JustSwitchTheme(
      style: style ?? this.style,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustSwitchTheme lerp(ThemeExtension<JustSwitchTheme>? other, double t) {
    if (other is! JustSwitchTheme) return this;
    return t < 0.5 ? this : other;
  }
}
