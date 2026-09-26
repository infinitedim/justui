// justui-meta: registry=038cab311adc91ac112f4cf650184bfd082c774ee34057f30aa5986ae3b45896 local=8d3d3ad14c99a387d620d1e31907dbb85124a8f34c0ca1049124be5f4dff2143
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustSelect].
class JustSelectStyle {
  /// Custom background color of the select trigger.
  final Color? triggerBackgroundColor;

  /// Custom border color of the select trigger.
  final Color? triggerBorderColor;

  /// Custom background color of the dropdown overlay.
  final Color? dropdownBackgroundColor;

  /// Custom background color of options on hover.
  final Color? optionHoverColor;

  /// Custom background color of the selected option.
  final Color? selectedOptionColor;

  /// Custom text color of the select content.
  final Color? textColor;

  /// Custom text color of the placeholder.
  final Color? placeholderColor;

  /// Custom border radius of both trigger and dropdown.
  final BorderRadius? borderRadius;

  /// Custom elevation (shadow) for the dropdown.
  final double? dropdownElevation;

  const JustSelectStyle({
    this.triggerBackgroundColor,
    this.triggerBorderColor,
    this.dropdownBackgroundColor,
    this.optionHoverColor,
    this.selectedOptionColor,
    this.textColor,
    this.placeholderColor,
    this.borderRadius,
    this.dropdownElevation,
  });
}
