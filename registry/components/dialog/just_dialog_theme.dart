import 'package:flutter/material.dart' show ThemeExtension;

import 'just_dialog_style.dart';

/// Global theme configuration for dialogs, extending Flutter's [ThemeExtension].
class const JustDialogTheme({
  /// Style override for centered dialogs.
  final JustDialogStyle? centerStyle,

  /// Style override for bottom sheet-like dialogs.
  final JustDialogStyle? bottomStyle,

  /// Style override for top banner-like dialogs.
  final JustDialogStyle? topStyle,
}) extends ThemeExtension<JustDialogTheme> {
  /// Default configuration for the theme.
  static const defaults = JustDialogTheme();

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
