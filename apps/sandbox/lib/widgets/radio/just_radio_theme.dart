// justui-meta: registry=5ebdc4cf1e5378458a3fef497994d1290d157c03704b7fb1a5cbe845432d3efa local=446e1014995c039add14254332f692bef0b2feda46f8d9985ad4172ceda6b2fb
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
