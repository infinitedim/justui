import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustSidebar].
class const JustSidebarStyle({
  /// Custom background color of the sidebar panel.
  final Color? backgroundColor,

  /// Custom border color of the sidebar panel.
  final Color? borderColor,

  /// Custom border radius of the sidebar panel.
  final BorderRadius? borderRadius,

  /// Custom color of the active item (text, icon, and highlights).
  final Color? activeColor,

  /// Custom background color of the selected sidebar item.
  final Color? selectedBackgroundColor,

  /// Custom foreground color (icon and text) of the selected sidebar item.
  final Color? selectedForegroundColor,

  /// Custom color of inactive items.
  final Color? inactiveColor,

  /// Custom border radius for individual menu items.
  final BorderRadius? itemBorderRadius,

  /// Custom padding around the entire sidebar.
  final EdgeInsets? padding,

  /// Custom padding inside each menu item.
  final EdgeInsets? itemPadding,

  /// Custom vertical spacing between sidebar items.
  final double? itemSpacing,

  /// Custom text style for menu labels.
  final TextStyle? textStyle,

  /// Custom text style for the active menu label.
  final TextStyle? activeTextStyle,
});
