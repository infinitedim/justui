// justui-meta: registry=20b5d947aec7b64037bbc3b43ead5efbf4cd08c66454a445ba36890c7bbae848 local=4c19438e26deffdf07f05fb7c7678c7c362fa4c0994af96dd5c9e70bf6e5b451
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
