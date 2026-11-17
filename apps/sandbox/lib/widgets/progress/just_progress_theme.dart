// justui-meta: registry=90faa183e4ba7c4aac451d74c60e6a2f2081390701f4c8b6c647ccee5e0f9d37 local=69a31e02fcba9abe71fd0482b52c3caa41160a050daa0aef4b5e2bf67c7b6408
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_progress_style.dart';

/// Global theme configuration for progress indicators, extending Flutter's [ThemeExtension].
class JustProgressTheme extends ThemeExtension<JustProgressTheme> {
  /// Base style override for progress components.
  final JustProgressStyle? style;

  const JustProgressTheme({this.style});

  /// Default configuration for the theme.
  static const JustProgressTheme defaults = JustProgressTheme();

  @override
  JustProgressTheme copyWith({JustProgressStyle? style}) {
    return JustProgressTheme(style: style ?? this.style);
  }

  @override
  JustProgressTheme lerp(ThemeExtension<JustProgressTheme>? other, double t) {
    if (other is! JustProgressTheme) return this;
    return t < 0.5 ? this : other;
  }
}
