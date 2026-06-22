import 'package:flutter/material.dart' show ThemeExtension;
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

  /// Creates a [JustTabsTheme] theme extension.
  const JustTabsTheme({
    this.lineStyle,
    this.enclosedStyle,
    this.pillStyle,
    this.verticalStyle,
  });

  /// Default theme configuration.
  static const defaults = JustTabsTheme();

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
