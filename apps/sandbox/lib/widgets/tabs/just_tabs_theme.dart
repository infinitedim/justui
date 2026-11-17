// justui-meta: registry=b7eefc7796dce173acc0ec14c8b0d3995064f304629a2beac171d2a998641edb local=28d532ac3dbcc1bb9280eeca77a49c832b102b8b329d22bda09b8a613d3c51c0
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_tabs_style.dart';

/// Global theme configuration for tabs, extending Flutter's [ThemeExtension].
class JustTabsTheme extends ThemeExtension<JustTabsTheme> {
  /// Default style override for [JustTabVariant.line].
  final JustTabsStyle? lineStyle;

  /// Default style override for [JustTabVariant.enclosed].
  final JustTabsStyle? enclosedStyle;

  /// Default style override for [JustTabVariant.pill].
  final JustTabsStyle? pillStyle;

  /// Default style override for [JustTabVariant.vertical].
  final JustTabsStyle? verticalStyle;

  const JustTabsTheme({
    this.lineStyle,
    this.enclosedStyle,
    this.pillStyle,
    this.verticalStyle,
  });

  /// Default theme configuration.
  static const JustTabsTheme defaults = JustTabsTheme();

  @override
  JustTabsTheme copyWith({
    JustTabsStyle? lineStyle,
    JustTabsStyle? enclosedStyle,
    JustTabsStyle? pillStyle,
    JustTabsStyle? verticalStyle,
  }) {
    return JustTabsTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      enclosedStyle: enclosedStyle ?? this.enclosedStyle,
      pillStyle: pillStyle ?? this.pillStyle,
      verticalStyle: verticalStyle ?? this.verticalStyle,
    );
  }

  @override
  JustTabsTheme lerp(ThemeExtension<JustTabsTheme>? other, double t) {
    if (other is! JustTabsTheme) return this;
    return t < 0.5 ? this : other;
  }
}
