// justui-meta: registry=556eadaf9c998c2ce508c881841d5be10d971af1e07acd045197a1e9cecb9cb1 local=a7496376fd16e862e70d897699f8de2892e2e9b0ae4c6e7145beebef61b847e7
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a tooltip.
class JustTooltipStyle {
  /// Custom background color of the tooltip bubble.
  final Color? backgroundColor;

  /// Custom text or foreground color of the tooltip.
  final Color? foregroundColor;

  /// Custom border color of the tooltip bubble.
  final Color? borderColor;

  /// Custom border width of the tooltip bubble. Set `0.0` to hide the border.
  final double? borderWidth;

  /// Custom border radius of the tooltip bubble.
  final BorderRadius? borderRadius;

  /// Custom inner padding of the tooltip bubble.
  final EdgeInsets? padding;

  /// Custom text style for the tooltip message.
  final TextStyle? textStyle;

  /// Custom shadow list for the tooltip bubble. Pass an empty list to omit shadows.
  final List<BoxShadow>? shadows;

  /// Custom maximum width constraint.
  final double? maxWidth;

  const JustTooltipStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.shadows,
    this.maxWidth,
  });
}
