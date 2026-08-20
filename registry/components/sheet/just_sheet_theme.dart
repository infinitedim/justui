import 'package:flutter/material.dart' show ThemeExtension;

import 'just_sheet_style.dart';

/// Global theme configuration for sheets, extending Flutter's [ThemeExtension].
class const JustSheetTheme({
  /// Style override for sheets sliding from the bottom.
  final JustSheetStyle? bottomStyle,

  /// Style override for sheets sliding from the top.
  final JustSheetStyle? topStyle,

  /// Style override for sheets sliding from the left.
  final JustSheetStyle? leftStyle,

  /// Style override for sheets sliding from the right.
  final JustSheetStyle? rightStyle,
}) extends ThemeExtension<JustSheetTheme> {
  /// Default configuration for the theme.
  static const defaults = JustSheetTheme();

  @override
  JustSheetTheme copyWith({
    JustSheetStyle? bottomStyle,
    JustSheetStyle? topStyle,
    JustSheetStyle? leftStyle,
    JustSheetStyle? rightStyle,
  }) {
    return JustSheetTheme(
      bottomStyle: bottomStyle ?? this.bottomStyle,
      topStyle: topStyle ?? this.topStyle,
      leftStyle: leftStyle ?? this.leftStyle,
      rightStyle: rightStyle ?? this.rightStyle,
    );
  }

  @override
  JustSheetTheme lerp(ThemeExtension<JustSheetTheme>? other, double t) {
    if (other is! JustSheetTheme) return this;
    return t < 0.5 ? this : other;
  }
}
