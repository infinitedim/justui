// justui-meta: registry=42372ff3a4c94c6d3cd59dd1322126f4e0846f96d80fd3974c1754026d61f90c local=717b4e196c1fbe84c37a4f31166b298de34d391866c2a578ce2282fe820a1218
import 'package:material_ui/material_ui.dart' show ThemeExtension;

import 'just_dialog_style.dart';

/// Global theme configuration for dialogs, extending Flutter's [ThemeExtension].
class JustDialogTheme extends ThemeExtension<JustDialogTheme> {
  /// Style override for centered dialogs.
  final JustDialogStyle? centerStyle;

  /// Style override for bottom sheet-like dialogs.
  final JustDialogStyle? bottomStyle;

  /// Style override for top banner-like dialogs.
  final JustDialogStyle? topStyle;

  const JustDialogTheme({this.centerStyle, this.bottomStyle, this.topStyle});

  /// Default configuration for the theme.
  static const JustDialogTheme defaults = JustDialogTheme();

  @override
  JustDialogTheme copyWith({
    JustDialogStyle? centerStyle,
    JustDialogStyle? bottomStyle,
    JustDialogStyle? topStyle,
  }) {
    return JustDialogTheme(
      centerStyle: centerStyle ?? this.centerStyle,
      bottomStyle: bottomStyle ?? this.bottomStyle,
      topStyle: topStyle ?? this.topStyle,
    );
  }

  @override
  JustDialogTheme lerp(ThemeExtension<JustDialogTheme>? other, double t) {
    if (other is! JustDialogTheme) return this;
    return t < 0.5 ? this : other;
  }
}
