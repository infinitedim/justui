// justui-meta: registry=b25bd07bac76690ab6ad7c9a1f7202d810eab2caba5f543385bc53028a730b18 local=b25bd07bac76690ab6ad7c9a1f7202d810eab2caba5f543385bc53028a730b18
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_switch_style.dart';

/// Alias for [JustSwitchTheme] for convention parity.
typedef JustSwitchThemeData = JustSwitchTheme;

/// Global theme configuration for switch controls, extending Flutter's [ThemeExtension].
class const JustSwitchTheme({
  /// Base style override for switches.
  final JustSwitchStyle? style,

  /// Whether to enable haptic feedback on switch toggles.
  final bool enableHaptic = false,
}) extends ThemeExtension<JustSwitchTheme> {
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
    return JustSwitchTheme(
      style: .lerp(style, other.style, t),
      enableHaptic: t < 0.5 ? enableHaptic : other.enableHaptic,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustSwitchTheme &&
          runtimeType == other.runtimeType &&
          style == other.style &&
          enableHaptic == other.enableHaptic;

  @override
  int get hashCode => Object.hash(style, enableHaptic);
}
