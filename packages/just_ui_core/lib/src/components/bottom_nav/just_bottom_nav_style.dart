import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustBottomNav].
class JustBottomNavStyle {
  /// Custom height of the navigation bar.
  final double? height;

  /// Custom padding around the bar content.
  final EdgeInsets? padding;

  /// Custom background color of the bar.
  final Color? backgroundColor;

  /// Custom border radius of the bar (especially useful for the floating variant).
  final BorderRadius? borderRadius;

  /// Custom color of the active item (icon and text).
  final Color? activeColor;

  /// Custom color of inactive items.
  final Color? inactiveColor;

  /// Custom text style for labels.
  final TextStyle? textStyle;

  /// Custom icon size.
  final double? iconSize;

  /// Creates a [JustBottomNavStyle] override configuration.
  const JustBottomNavStyle({
    this.height,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.activeColor,
    this.inactiveColor,
    this.textStyle,
    this.iconSize,
  });
}
