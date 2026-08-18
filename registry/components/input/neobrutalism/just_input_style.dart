import 'package:flutter/widgets.dart';

/// Customized per-instance styles for [JustInput] to support robust customizability.
class const JustInputStyle({
  /// Custom border color in default state.
  final Color? borderColor,

  /// Custom border color when focused.
  final Color? focusedBorderColor,

  /// Custom border color in error state.
  final Color? errorBorderColor,

  /// Custom background color of the input container.
  final Color? backgroundColor,

  /// Custom border radius of the input field.
  final BorderRadius? borderRadius,

  /// Custom padding inside the input container.
  final EdgeInsetsGeometry? contentPadding,

  /// Custom text style for the user input text.
  final TextStyle? textStyle,

  /// Custom text style for the floating/static label.
  final TextStyle? labelStyle,

  /// Custom text style for helper, error, or success texts.
  final TextStyle? helperStyle,
});
