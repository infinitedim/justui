import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a tooltip.
class const JustTooltipStyle({
  /// Custom background color of the tooltip bubble.
  final Color? backgroundColor,

  /// Custom text or foreground color of the tooltip.
  final Color? foregroundColor,

  /// Custom border color of the tooltip bubble.
  final Color? borderColor,

  /// Custom border width of the tooltip bubble. Set `0.0` to hide the border.
  final double? borderWidth,

  /// Custom border radius of the tooltip bubble.
  final BorderRadius? borderRadius,

  /// Custom inner padding of the tooltip bubble.
  final EdgeInsets? padding,

  /// Custom text style for the tooltip message.
  final TextStyle? textStyle,

  /// Custom shadow list for the tooltip bubble. Pass an empty list to omit shadows.
  final List<BoxShadow>? shadows,

  /// Custom maximum width constraint.
  final double? maxWidth,
});
