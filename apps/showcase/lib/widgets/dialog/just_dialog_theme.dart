// justui-meta: registry=fcd48ec1e9657846a661521136884c5500c73b85822f8604f6d976738d97ccea local=096cc8b3099ed8773232540745628b5c36dd6e153d4a2ed0bc1186779ba9bdc4
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
