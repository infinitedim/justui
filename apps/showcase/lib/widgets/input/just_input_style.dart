// justui-meta: registry=20449f9394c6b215b846e0984d6be3529aefe1848595000a8c21ac500a26d3a6 local=b3338549037c359a21d8ff2f7d7b18932871c7538dee1dd7c987947f8afe7dfe
import 'package:flutter/widgets.dart';

/// Customized per-instance styles for [JustInput] to support robust customizability.
class JustInputStyle {
  /// Custom border color in default state.
  final Color? borderColor;

  /// Custom border color when focused.
  final Color? focusedBorderColor;

  /// Custom border color in error state.
  final Color? errorBorderColor;

  /// Custom background color of the input container.
  final Color? backgroundColor;

  /// Custom border radius of the input field.
  final BorderRadius? borderRadius;

  /// Custom padding inside the input container.
  final EdgeInsetsGeometry? contentPadding;

  /// Custom text style for the user input text.
  final TextStyle? textStyle;

  /// Custom text style for the floating/static label.
  final TextStyle? labelStyle;

  /// Custom text style for helper, error, or success texts.
  final TextStyle? helperStyle;

  const JustInputStyle({
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.backgroundColor,
    this.borderRadius,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.helperStyle,
  });
}
