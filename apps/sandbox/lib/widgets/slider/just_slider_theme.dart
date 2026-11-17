// justui-meta: registry=c3438d8950e75ba66cf184c9bd466664d23471a88a3ae95d607262a528bc8374 local=c8bccb066b1f194fc1a0977e5e3288f3f37c42591ad0b3f21d9bfdbaa3fcaadd
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_slider_style.dart';

/// Global theme configuration for sliders, extending Flutter's [ThemeExtension].
class JustSliderTheme extends ThemeExtension<JustSliderTheme> {
  /// Base style override for sliders.
  final JustSliderStyle? style;

  /// Whether to enable haptic feedback on slider interactions.
  final bool enableHaptic;

  const JustSliderTheme({this.style, this.enableHaptic = true});

  /// Default configuration for the theme.
  static const JustSliderTheme defaults = JustSliderTheme();

  @override
  JustSliderTheme copyWith({JustSliderStyle? style, bool? enableHaptic}) {
    return JustSliderTheme(
      style: style ?? this.style,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustSliderTheme lerp(ThemeExtension<JustSliderTheme>? other, double t) {
    if (other is! JustSliderTheme) return this;
    return t < 0.5 ? this : other;
  }
}
