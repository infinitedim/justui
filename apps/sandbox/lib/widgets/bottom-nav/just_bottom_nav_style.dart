// justui-meta: registry=ab8e0e1323f0bc9a32a69689dfcfc033a77c998ac585799ccc3a494f9dddc6de local=063879799de9021cb71fe91dbc143bd0ddab3a208feb15207005cb9e18854d60
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustBottomNav].
class JustBottomNavStyle {
  /// Custom height of the navigation bar.
  final double? height;

  /// Custom padding around the bar content.
  final EdgeInsets? padding;

  /// Custom background color of the bar.
  final Color? backgroundColor;

  /// Custom border color of the navigation bar container.
  final Color? borderColor;

  /// Custom border radius of the bar (especially useful for the floating variant).
  final BorderRadius? borderRadius;

  /// Custom color of the active item (icon and text).
  final Color? activeColor;

  /// Custom color of the active item indicator bar.
  final Color? activeIndicatorColor;

  /// Whether to render a compact active indicator bar beneath the selected item.
  final bool? showActiveIndicator;

  /// Custom color of inactive items.
  final Color? inactiveColor;

  /// Custom text style for labels.
  final TextStyle? textStyle;

  /// Custom icon size.
  final double? iconSize;

  /// Custom animation duration for transitions.
  final Duration? animationDuration;

  /// Custom animation curve for transitions.
  final Curve? animationCurve;

  const JustBottomNavStyle({
    this.height,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.activeColor,
    this.activeIndicatorColor,
    this.showActiveIndicator,
    this.inactiveColor,
    this.textStyle,
    this.iconSize,
    this.animationDuration,
    this.animationCurve,
  });
}
