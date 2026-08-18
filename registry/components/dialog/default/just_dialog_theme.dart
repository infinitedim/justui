import 'package:flutter/material.dart' show Theme, ThemeExtension;

import 'just_dialog_style.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// Global theme configuration for dialogs, extending Flutter's [ThemeExtension].
class JustDialogTheme extends ThemeExtension<JustDialogTheme> {
  /// Style override for centered dialogs.
  final JustDialogStyle? centerStyle;

  /// Style override for bottom sheet-like dialogs.
  final JustDialogStyle? bottomStyle;

  /// Style override for top banner-like dialogs.
  final JustDialogStyle? topStyle;

  /// Creates a [JustDialogTheme] configuration.
  const JustDialogTheme({this.centerStyle, this.bottomStyle, this.topStyle});

  /// Default configuration for the theme.
  static const defaults = JustDialogTheme();

  /// Fallback factory constructor from [JustThemeData].
  factory JustDialogTheme.fromTheme(JustThemeData justTheme) =>
      const JustDialogTheme();

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

/// Extension method on [BuildContext] to access [JustDialogTheme] safely.
extension JustDialogThemeContext on BuildContext {
  JustDialogTheme get justDialogTheme =>
      Theme.of(this).extension<JustDialogTheme>() ??
      JustDialogTheme.fromTheme(justTheme);
}
