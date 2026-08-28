import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustSelect].
class const JustSelectStyle({
  /// Custom background color of the select trigger.
  final Color? triggerBackgroundColor,

  /// Custom border color of the select trigger.
  final Color? triggerBorderColor,

  /// Custom background color of the dropdown overlay.
  final Color? dropdownBackgroundColor,

  /// Custom background color of options on hover.
  final Color? optionHoverColor,

  /// Custom background color of the selected option.
  final Color? selectedOptionColor,

  /// Custom text color of the select content.
  final Color? textColor,

  /// Custom text color of the placeholder.
  final Color? placeholderColor,

  /// Custom border radius of both trigger and dropdown.
  final BorderRadius? borderRadius,

  /// Custom elevation (shadow) for the dropdown.
  final double? dropdownElevation,
});
