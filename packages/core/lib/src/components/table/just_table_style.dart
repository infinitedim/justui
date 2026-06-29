import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustTable].
class JustTableStyle {
  /// Custom background color of the table header row.
  final Color? headerBackgroundColor;

  /// Custom text color of the table header cells.
  final Color? headerTextColor;

  /// Custom background color of the table body rows.
  final Color? rowBackgroundColor;

  /// Custom background color for alternating rows (only applicable to [JustTableVariant.striped]).
  final Color? alternateRowBackgroundColor;

  /// Custom border color of cells and table container.
  final Color? borderColor;

  /// Custom background color when hovering over a row.
  final Color? hoverColor;

  /// Custom background color when a row is selected.
  final Color? selectedRowColor;

  /// Custom horizontal padding inside cells.
  final double? horizontalPadding;

  /// Custom text style for header cells.
  final TextStyle? headerTextStyle;

  /// Custom text style for body cells.
  final TextStyle? cellTextStyle;

  /// Creates a [JustTableStyle] override.
  const JustTableStyle({
    this.headerBackgroundColor,
    this.headerTextColor,
    this.rowBackgroundColor,
    this.alternateRowBackgroundColor,
    this.borderColor,
    this.hoverColor,
    this.selectedRowColor,
    this.horizontalPadding,
    this.headerTextStyle,
    this.cellTextStyle,
  });
}
