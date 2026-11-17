// justui-meta: registry=d3c1caee74e537b0d8c4f55084c3d4c1ba7a6819014d55b49a1c7047ea19b713 local=8ae649d6b9dab002933da10dc1ca8b4e57ee03165f18373ffa648c56e4d2145d
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
