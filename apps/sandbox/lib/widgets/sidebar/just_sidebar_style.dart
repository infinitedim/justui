// justui-meta: registry=290204745641c182d34ade28446832318c1663291c7b0950490f0c44ce069396 local=40f112ae00144cb4f2c7175a975c7bd4596db65add426dfd4b58d86fce0f5e80
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustSidebar].
class JustSidebarStyle {
  /// Custom background color of the sidebar panel.
  final Color? backgroundColor;

  /// Custom border color of the sidebar panel.
  final Color? borderColor;

  /// Custom border radius of the sidebar panel.
  final BorderRadius? borderRadius;

  /// Custom color of the active item (text, icon, and highlights).
  final Color? activeColor;

  /// Custom background color of the selected sidebar item.
  final Color? selectedBackgroundColor;

  /// Custom foreground color (icon and text) of the selected sidebar item.
  final Color? selectedForegroundColor;

  /// Custom color of inactive items.
  final Color? inactiveColor;

  /// Custom border radius for individual menu items.
  final BorderRadius? itemBorderRadius;

  /// Custom padding around the entire sidebar.
  final EdgeInsets? padding;

  /// Custom padding inside each menu item.
  final EdgeInsets? itemPadding;

  /// Custom vertical spacing between sidebar items.
  final double? itemSpacing;

  /// Custom text style for menu labels.
  final TextStyle? textStyle;

  /// Custom text style for the active menu label.
  final TextStyle? activeTextStyle;

  const JustSidebarStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.activeColor,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
    this.inactiveColor,
    this.itemBorderRadius,
    this.padding,
    this.itemPadding,
    this.itemSpacing,
    this.textStyle,
    this.activeTextStyle,
  });
}
