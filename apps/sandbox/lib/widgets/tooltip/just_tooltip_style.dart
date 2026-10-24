// justui-meta: registry=e362dcdd6851d2803972dedff509760a74823d49b0aa5464e4c307d72d4e428c local=9cf7bebb2382fd20e77761d3b8ab7950195e33c68ff6d3c6ea438d15743f69ea
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a tooltip.
class JustTooltipStyle {
  /// Custom background color of the tooltip bubble.
  final Color? backgroundColor;

  /// Custom text or foreground color of the tooltip.
  final Color? foregroundColor;

  /// Custom border radius of the tooltip bubble.
  final BorderRadius? borderRadius;

  /// Custom inner padding of the tooltip bubble.
  final EdgeInsets? padding;

  /// Custom maximum width constraint.
  final double? maxWidth;

  const JustTooltipStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.maxWidth,
  });
}
