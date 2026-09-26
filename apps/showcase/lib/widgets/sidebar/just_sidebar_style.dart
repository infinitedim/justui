// justui-meta: registry=7cbfc66312bf9a57a8827b7be209177862cf2babb933ab1930263adcc923f09b local=8a8885f7f7c7ea2d33a44d6e6c21f929d572a6919cec03d192d045f850b86424
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustSidebar].
class JustSidebarStyle {
  /// Custom background color of the sidebar panel.
  final Color? backgroundColor;

  /// Custom color of the active item (text, icon, and highlights).
  final Color? activeColor;

  /// Custom color of inactive items.
  final Color? inactiveColor;

  /// Custom border radius for individual menu items.
  final BorderRadius? itemBorderRadius;

  /// Custom padding around the entire sidebar.
  final EdgeInsets? padding;

  /// Custom padding inside each menu item.
  final EdgeInsets? itemPadding;

  /// Custom text style for menu labels.
  final TextStyle? textStyle;

  /// Custom text style for the active menu label.
  final TextStyle? activeTextStyle;

  const JustSidebarStyle({
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.itemBorderRadius,
    this.padding,
    this.itemPadding,
    this.textStyle,
    this.activeTextStyle,
  });
}
