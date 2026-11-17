// justui-meta: registry=5d994cc9c3b426a7cf2f469794dcef6dc26e48d903b0af8c837f2dde85451eb4 local=5933fcb6e8655a4ce7ce785f95341f22b85403a424d04bdc9fa9b26ef958b888
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_input_style.dart';

/// Global theme configurations for inputs, extending Flutter's [ThemeExtension].
class JustInputTheme extends ThemeExtension<JustInputTheme> {
  /// Default input styling override.
  final JustInputStyle? inputStyle;

  const JustInputTheme({this.inputStyle});

  /// Default configuration for the theme.
  static const JustInputTheme defaults = JustInputTheme();

  @override
  JustInputTheme copyWith({JustInputStyle? inputStyle}) {
    return JustInputTheme(inputStyle: inputStyle ?? this.inputStyle);
  }

  @override
  JustInputTheme lerp(ThemeExtension<JustInputTheme>? other, double t) {
    if (other is! JustInputTheme) return this;
    return t < 0.5 ? this : other;
  }
}
