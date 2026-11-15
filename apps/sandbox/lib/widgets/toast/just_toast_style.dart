// justui-meta: registry=54ea4e9a9e0876f6d67fbc793f99082555fce87d3a56a064d75d96ac37a72fca local=449d5d7ce90750fbedb6d49670b8835580981564ff598a3bb62ceff440f597fd
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a toast.
class JustToastStyle {
  /// Custom background color of the toast.
  final Color? backgroundColor;

  /// Custom foreground (text, icon) color of the toast.
  final Color? foregroundColor;

  /// Custom border color of the toast.
  final Color? borderColor;

  /// Custom border width of the toast.
  final double? borderWidth;

  /// Custom border radius of the toast.
  final BorderRadius? borderRadius;

  /// Custom inner padding of the toast.
  final EdgeInsets? padding;

  /// Custom text style overrides.
  final TextStyle? textStyle;

  /// Custom maximum width constraint.
  final double? maxWidth;

  /// Custom minimum width constraint.
  final double? minWidth;

  /// Custom shadows/elevation.
  final List<BoxShadow>? shadows;

  const JustToastStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.maxWidth,
    this.minWidth,
    this.shadows,
  });
}
