import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a toast.
class JustToastStyle {
  /// Custom background color of the toast.
  final Color? backgroundColor;

  /// Custom foreground (text, icon) color of the toast.
  final Color? foregroundColor;

  /// Custom border color of the toast.
  final Color? borderColor;

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

  /// Creates a [JustToastStyle] override.
  const JustToastStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.maxWidth,
    this.minWidth,
    this.shadows,
  });
}
