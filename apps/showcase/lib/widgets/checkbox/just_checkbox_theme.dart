// justui-meta: registry=d420060a7b3b30cc503e2708efa1c7743464ca1b95ab0b02a2e106eebae74088 local=e162ce2c7907971f5da20b3cd19aed114e9266e625283ebf3ca79a2a080b98fe
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_checkbox_style.dart';

/// Alias for [JustCheckboxTheme] for convention parity.
typedef JustCheckboxThemeData = JustCheckboxTheme;

/// Global theme configuration for checkboxes, extending Flutter's [ThemeExtension].
class JustCheckboxTheme extends ThemeExtension<JustCheckboxTheme> {
  /// Base style override for checkboxes.
  final JustCheckboxStyle? style;

  /// Whether to enable haptic feedback on checkbox state changes.
  final bool enableHaptic;

  const JustCheckboxTheme({this.style, this.enableHaptic = false});

  /// Default configuration for the theme.
  static const JustCheckboxTheme defaults = JustCheckboxTheme();

  @override
  JustCheckboxTheme copyWith({JustCheckboxStyle? style, bool? enableHaptic}) {
    return JustCheckboxTheme(
      style: style ?? this.style,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustCheckboxTheme lerp(ThemeExtension<JustCheckboxTheme>? other, double t) {
    if (other is! JustCheckboxTheme) return this;
    return JustCheckboxTheme(
      style: .lerp(style, other.style, t),
      enableHaptic: t < 0.5 ? enableHaptic : other.enableHaptic,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustCheckboxTheme &&
          runtimeType == other.runtimeType &&
          style == other.style &&
          enableHaptic == other.enableHaptic;

  @override
  int get hashCode => Object.hash(style, enableHaptic);
}
