import 'package:flutter/material.dart' show ThemeExtension;

import 'just_time_picker_style.dart';
import 'just_time_picker_variants.dart';

/// Global theme configuration for time pickers, extending Flutter's [ThemeExtension].
class const JustTimePickerTheme({
  /// Style overrides applied to inline/dial/spinner variants.
  final JustTimePickerStyle? inlineStyle,

  /// Style overrides applied to modal variant.
  final JustTimePickerStyle? modalStyle,

  /// Style overrides applied to dropdown variant.
  final JustTimePickerStyle? dropdownStyle,

  /// Default interaction mode. If null, defaults to .dial.
  final JustTimePickerMode? defaultMode,

  /// Whether haptic feedback is enabled globally.
  final bool enableHaptic = false,
}) extends ThemeExtension<JustTimePickerTheme> {
  /// Default configuration for the theme.
  static const defaults = JustTimePickerTheme();

  @override
  JustTimePickerTheme copyWith({
    JustTimePickerStyle? inlineStyle,
    JustTimePickerStyle? modalStyle,
    JustTimePickerStyle? dropdownStyle,
    JustTimePickerMode? defaultMode,
    bool? enableHaptic,
  }) {
    return JustTimePickerTheme(
      inlineStyle: inlineStyle ?? this.inlineStyle,
      modalStyle: modalStyle ?? this.modalStyle,
      dropdownStyle: dropdownStyle ?? this.dropdownStyle,
      defaultMode: defaultMode ?? this.defaultMode,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustTimePickerTheme lerp(
    ThemeExtension<JustTimePickerTheme>? other,
    double t,
  ) {
    if (other is! JustTimePickerTheme) return this;
    return t < 0.5 ? this : other;
  }
}
