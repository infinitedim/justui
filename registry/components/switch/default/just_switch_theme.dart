import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_switch_style.dart';
import 'package:just_ui_core/just_ui_core.dart';

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

  
  /// Fallback factory constructor from [JustThemeData].
  factory JustSwitchTheme.fromTheme(JustThemeData justTheme) => const JustSwitchTheme();

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

/// Extension method on [BuildContext] to access [JustSwitchTheme] safely.
extension JustSwitchThemeContext on BuildContext {
  JustSwitchTheme get justSwitchTheme =>
      Theme.of(this).extension<JustSwitchTheme>() ??
      JustSwitchTheme.fromTheme(justTheme);
}
