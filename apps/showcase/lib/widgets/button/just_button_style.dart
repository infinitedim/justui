// justui-meta: registry=f5c1e9ba55db0ce246422aecad03fb552d73d5ed08cd29213d99bae9320d347c local=f5c1e9ba55db0ce246422aecad03fb552d73d5ed08cd29213d99bae9320d347c
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustButton] and [JustIconButton].
class JustButtonStyle {
  /// Custom background color of the button.
  final Color? backgroundColor;

  /// Custom text or icon color of the button.
  final Color? foregroundColor;

  /// Custom border color of the button.
  final Color? borderColor;

  /// Custom border radius of the button.
  final BorderRadius? borderRadius;

  /// Custom inner padding of the button.
  final EdgeInsets? padding;

  /// Custom text style overrides.
  final TextStyle? textStyle;

  /// Custom elevation (shadow).
  final double? elevation;

  /// Creates a [JustButtonStyle] override.
  const JustButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.elevation,
  });
}
