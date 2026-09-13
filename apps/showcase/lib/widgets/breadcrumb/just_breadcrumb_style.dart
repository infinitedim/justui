// justui-meta: registry=ef15b0bab4a590b00d340c52b3f841d67c85a2a5b06ca319b060e763153cef23 local=ef15b0bab4a590b00d340c52b3f841d67c85a2a5b06ca319b060e763153cef23
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustBreadcrumb].
class const JustBreadcrumbStyle({
  /// Custom padding around the entire breadcrumb bar.
  final EdgeInsets? padding,

  /// Custom padding between items.
  final EdgeInsets? itemPadding,

  /// Custom text style override for clickable items.
  final TextStyle? textStyle,

  /// Custom text style override for the active (last) item.
  final TextStyle? activeTextStyle,

  /// Custom color override for item labels and icons.
  final Color? color,

  /// Custom color override for the active (last) item.
  final Color? activeColor,

  /// Custom style for the separator.
  final TextStyle? separatorStyle,
});
