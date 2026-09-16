// justui-meta: registry=e362dcdd6851d2803972dedff509760a74823d49b0aa5464e4c307d72d4e428c local=e362dcdd6851d2803972dedff509760a74823d49b0aa5464e4c307d72d4e428c
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a tooltip.
class const JustTooltipStyle({
  /// Custom background color of the tooltip bubble.
  final Color? backgroundColor,

  /// Custom text or foreground color of the tooltip.
  final Color? foregroundColor,

  /// Custom border radius of the tooltip bubble.
  final BorderRadius? borderRadius,

  /// Custom inner padding of the tooltip bubble.
  final EdgeInsets? padding,

  /// Custom maximum width constraint.
  final double? maxWidth,
});
