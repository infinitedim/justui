// justui-meta: registry=5d50b41362cab850217519a259713fb6e9925c4faf5aef1dc286542e2f3bce3e local=e01604579e5e909f7cf09001b46c63d9b3bbcdaf5a02f6eb55c92e72972c7fb9
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustSeparator].
class JustSeparatorStyle {
  /// The color of the separator line.
  final Color? color;

  /// The thickness of the separator line.
  final double? thickness;

  /// The leading indentation distance.
  final double? indent;

  /// The trailing indentation distance.
  final double? endIndent;

  /// Text style of the label text (if provided).
  final TextStyle? labelStyle;

  /// Padding around the label text.
  final EdgeInsets? labelPadding;

  const JustSeparatorStyle({
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
    this.labelStyle,
    this.labelPadding,
  });
}
