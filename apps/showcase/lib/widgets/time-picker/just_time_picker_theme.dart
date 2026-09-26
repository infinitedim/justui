// justui-meta: registry=8bce76196570eeff315b98c0ce9c702fc0e4adec7bd471bc6fd4856bb78c52e5 local=8299446bc928737ddd8ec542587346eff50a74e0f029801b73380d1353da54d5
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_time_picker_style.dart';
import 'just_time_picker_variants.dart';

/// Global theme configuration for time pickers, extending Flutter's [ThemeExtension].
class JustTimePickerTheme extends ThemeExtension<JustTimePickerTheme> {
  /// Style overrides applied to inline/dial/spinner variants.
  final JustTimePickerStyle? inlineStyle;

  /// Style overrides applied to modal variant.
  final JustTimePickerStyle? modalStyle;

  /// Style overrides applied to dropdown variant.
  final JustTimePickerStyle? dropdownStyle;

  /// Default interaction mode. If null, defaults to .dial.
  final JustTimePickerMode? defaultMode;

  /// Whether haptic feedback is enabled globally.
  final bool enableHaptic;

  const JustTimePickerTheme({
    this.inlineStyle,
    this.modalStyle,
    this.dropdownStyle,
    this.defaultMode,
    this.enableHaptic = false,
  });

  /// Default configuration for the theme.
  static const JustTimePickerTheme defaults = JustTimePickerTheme();

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
