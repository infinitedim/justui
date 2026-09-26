// justui-meta: registry=5a61ec6894613c4a2896d596bd42920b9d2bbf6e7489eecd2ea58d9320962492 local=66c516411365b457db04e8cded33c74e2f5bfc9d669944dfe57cb12c926e32f3
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
