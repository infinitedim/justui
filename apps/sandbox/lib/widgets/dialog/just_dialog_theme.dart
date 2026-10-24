// justui-meta: registry=fcd48ec1e9657846a661521136884c5500c73b85822f8604f6d976738d97ccea local=82074d5f7f5370da2a1c14c67512874c4206ed14d36486a8b0081e2da0bed850
import 'package:flutter/material.dart' show ThemeExtension;

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
