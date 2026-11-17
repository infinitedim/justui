// justui-meta: registry=afc3d5339575ada7503f446652184a5bfb9396fa88f177ec1781ed455001afce local=ffe17debd1966004efc93b6ca08a48eb9d6d6665e48c6faf47bd02d929f2a2fd
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
