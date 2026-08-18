import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_sheet_style.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for sheets, extending Flutter's [ThemeExtension].
class JustSheetTheme extends ThemeExtension<JustSheetTheme> {
  /// Style override for sheets sliding from the bottom.
  final JustSheetStyle? bottomStyle;

  /// Style override for sheets sliding from the top.
  final JustSheetStyle? topStyle;

  /// Style override for sheets sliding from the left.
  final JustSheetStyle? leftStyle;

  /// Style override for sheets sliding from the right.
  final JustSheetStyle? rightStyle;

  /// Creates a [JustSheetTheme] configuration.
  const JustSheetTheme({
    this.bottomStyle,
    this.topStyle,
    this.leftStyle,
    this.rightStyle,
  });

  /// Default configuration for the theme.
  static const defaults = JustSheetTheme();

  
  /// Fallback factory constructor from [JustThemeData].
  factory JustSheetTheme.fromTheme(JustThemeData justTheme) => const JustSheetTheme();

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

/// Extension method on [BuildContext] to access [JustSheetTheme] safely.
extension JustSheetThemeContext on BuildContext {
  JustSheetTheme get justSheetTheme =>
      Theme.of(this).extension<JustSheetTheme>() ??
      JustSheetTheme.fromTheme(justTheme);
}
