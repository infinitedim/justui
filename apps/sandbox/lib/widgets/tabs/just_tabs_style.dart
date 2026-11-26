// justui-meta: registry=c46adbf1a8e044e411e1cf4cc69cd127250f7eda149972a070a974ad98c6eef2 local=632cd4868bd48de795ad068aef2316068234c5977c011c5519c8c3b8d45141d2
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

  /// Custom bottom hairline color for the tab bar container (e.g. [JustTabVariant.line]).
  final Color? borderBottomColor;

  /// Custom bottom hairline width for the tab bar container.
  final double? borderBottomWidth;

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
    this.borderBottomColor,
    this.borderBottomWidth,
  });
}
