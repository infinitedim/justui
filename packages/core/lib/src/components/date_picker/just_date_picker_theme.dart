import 'package:flutter/material.dart' show ThemeExtension;

import 'just_date_picker_style.dart';

/// Global theme configuration for date pickers, extending Flutter's [ThemeExtension].
class const JustDatePickerTheme({
  /// Style override for inline date pickers.
  final JustDatePickerStyle? inlineStyle,

  /// Style override for modal date pickers.
  final JustDatePickerStyle? modalStyle,

  /// Style override for dropdown date pickers.
  final JustDatePickerStyle? dropdownStyle,

  /// Whether to enable haptic feedback on date selection by default.
  final bool enableHaptic = false,
}) extends ThemeExtension<JustDatePickerTheme> {
  /// Default configuration for the theme.
  static const defaults = JustDatePickerTheme();

  @override
  JustDatePickerTheme copyWith({
    JustDatePickerStyle? inlineStyle,
    JustDatePickerStyle? modalStyle,
    JustDatePickerStyle? dropdownStyle,
    bool? enableHaptic,
  }) {
    return JustDatePickerTheme(
      inlineStyle: inlineStyle ?? this.inlineStyle,
      modalStyle: modalStyle ?? this.modalStyle,
      dropdownStyle: dropdownStyle ?? this.dropdownStyle,
      enableHaptic: enableHaptic ?? this.enableHaptic,
    );
  }

  @override
  JustDatePickerTheme lerp(ThemeExtension<JustDatePickerTheme>? other, double t) {
    if (other is! JustDatePickerTheme) return this;
    return t < 0.5 ? this : other;
  }
}
