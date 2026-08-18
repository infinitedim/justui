import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustSidebar].
class const JustSidebarStyle({
  /// Custom background color of the sidebar panel.
  final Color? backgroundColor,

  /// Custom color of the active item (text, icon, and highlights).
  final Color? activeColor,

  /// Custom color of inactive items.
  final Color? inactiveColor,

  /// Custom border radius for individual menu items.
  final BorderRadius? itemBorderRadius,

  /// Custom padding around the entire sidebar.
  final EdgeInsets? padding,

  /// Custom padding inside each menu item.
  final EdgeInsets? itemPadding,

  /// Custom text style for menu labels.
  final TextStyle? textStyle,

  /// Custom text style for the active menu label.
  final TextStyle? activeTextStyle,
});
