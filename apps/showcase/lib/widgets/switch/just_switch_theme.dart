// justui-meta: registry=fe8e5270f6f1999ece4c111923f2a998dc9fbeb99cb432b14c55ea9fc88e0354 local=dccef3e592445c8ee15954ac768d5fec70c0079b9bed7e60f09c4535039e0a05
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_switch_style.dart';

/// Alias for [JustSwitchTheme] for convention parity.
typedef JustSwitchThemeData = JustSwitchTheme;

/// Global theme configuration for switch controls, extending Flutter's [ThemeExtension].
class JustSwitchTheme extends ThemeExtension<JustSwitchTheme> {
  /// Base style override for switches.
  final JustSwitchStyle? style;

  /// Whether to enable haptic feedback on switch toggles.
  final bool enableHaptic;

  const JustSwitchTheme({this.style, this.enableHaptic = false});

  /// Default configuration for the theme.
  static const JustSwitchTheme defaults = JustSwitchTheme();

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
