import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustBreadcrumb].
class JustBreadcrumbStyle {
  /// Custom padding around the entire breadcrumb bar.
  final EdgeInsets? padding;

  /// Custom padding between items.
  final EdgeInsets? itemPadding;

  /// Custom text style override for clickable items.
  final TextStyle? textStyle;

  /// Custom text style override for the active (last) item.
  final TextStyle? activeTextStyle;

  /// Custom color override for item labels and icons.
  final Color? color;

  /// Custom color override for the active (last) item.
  final Color? activeColor;

  /// Custom style for the separator.
  final TextStyle? separatorStyle;

  /// Creates a [JustBreadcrumbStyle] configuration.
  const JustBreadcrumbStyle({
    this.padding,
    this.itemPadding,
    this.textStyle,
    this.activeTextStyle,
    this.color,
    this.activeColor,
    this.separatorStyle,
  });
}
