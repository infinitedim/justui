// justui-meta: registry=a073f6ea0cd1aa1abbc4067a868638a7cd4150c6020df6d07ae5adf5fb7a7351 local=4dfe012cbafb8e918b1f3591ea3d6041c5e3cb4d1e10c35ebd8e7d1262c937df
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustTabs].
class JustTabsStyle {
  /// Custom padding of the outer tab bar container.
  final EdgeInsets? padding;

  /// Custom padding inside each individual tab item.
  final EdgeInsets? tabPadding;

  /// Custom text style for the active tab label.
  final TextStyle? activeTextStyle;

  /// Custom text style for inactive tab labels.
  final TextStyle? inactiveTextStyle;

  /// Custom color of the active tab (text, icon, indicator).
  final Color? activeColor;

  /// Custom color of inactive tabs.
  final Color? inactiveColor;

  /// Custom color for the sliding active indicator.
  final Color? indicatorColor;

  /// Custom border radius for the sliding active indicator.
  final BorderRadius? indicatorRadius;

  /// Custom thickness of the indicator line (only applicable for [JustTabVariant.line]).
  final double? indicatorThickness;

  /// Custom background color of the tab bar container.
  final Color? containerBackgroundColor;

  /// Custom border radius of the tab bar container.
  final BorderRadius? containerRadius;

  const JustTabsStyle({
    this.padding,
    this.tabPadding,
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.activeColor,
    this.inactiveColor,
    this.indicatorColor,
    this.indicatorRadius,
    this.indicatorThickness,
    this.containerBackgroundColor,
    this.containerRadius,
  });
}
