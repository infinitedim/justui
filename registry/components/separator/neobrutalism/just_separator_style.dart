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

  /// Creates a [JustSeparatorStyle] configuration.
  const JustSeparatorStyle({
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
    this.labelStyle,
    this.labelPadding,
  });
}
