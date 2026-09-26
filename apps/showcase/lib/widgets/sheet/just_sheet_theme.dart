// justui-meta: registry=a325b9404fa49183d8cbc51dde1da6258cda9973d7f04a67dce2684c4dd49651 local=b551a219d51331a835b8f5278f3a42309ce10ff7573d42893297b3d5118a7480
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_sheet_style.dart';

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

  const JustSheetTheme({
    this.bottomStyle,
    this.topStyle,
    this.leftStyle,
    this.rightStyle,
  });

  /// Default configuration for the theme.
  static const JustSheetTheme defaults = JustSheetTheme();

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
