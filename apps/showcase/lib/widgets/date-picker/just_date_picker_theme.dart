// justui-meta: registry=e0f593c07da11119ae79ab275ae42ba06a786e6886895353cb0f649e61271b3d local=43e0013fcf8b9c9dbc8b20073fb9641e292d25b8084931a269fd7d371959c98f
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_date_picker_style.dart';

/// Global theme configuration for date pickers, extending Flutter's [ThemeExtension].
class JustDatePickerTheme extends ThemeExtension<JustDatePickerTheme> {
  /// Style override for inline date pickers.
  final JustDatePickerStyle? inlineStyle;

  /// Style override for modal date pickers.
  final JustDatePickerStyle? modalStyle;

  /// Style override for dropdown date pickers.
  final JustDatePickerStyle? dropdownStyle;

  /// Whether to enable haptic feedback on date selection by default.
  final bool enableHaptic;

  const JustDatePickerTheme({
    this.inlineStyle,
    this.modalStyle,
    this.dropdownStyle,
    this.enableHaptic = false,
  });

  /// Default configuration for the theme.
  static const JustDatePickerTheme defaults = JustDatePickerTheme();

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
  JustDatePickerTheme lerp(
    ThemeExtension<JustDatePickerTheme>? other,
    double t,
  ) {
    if (other is! JustDatePickerTheme) return this;
    return t < 0.5 ? this : other;
  }
}
