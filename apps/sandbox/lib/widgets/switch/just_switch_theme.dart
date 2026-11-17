// justui-meta: registry=46a50fb24666b52a9491d83349bb37d9b772a9b121ac2991fa744fc7426f48b7 local=22ba2d4afe25c116ca52698bea34d1c33f1196cbc872ecbc52cfee780f05581c
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
