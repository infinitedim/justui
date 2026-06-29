import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustAccordion].
class JustAccordionStyle {
  /// Custom background color of the accordion headers.
  final Color? headerBackgroundColor;

  /// Custom background color of the accordion contents.
  final Color? contentBackgroundColor;

  /// Custom border color of the accordion items.
  final Color? borderColor;

  /// Custom text color for titles.
  final Color? titleColor;

  /// Custom text color for subtitles.
  final Color? subtitleColor;

  /// Custom color for the chevron/icon indicator.
  final Color? iconColor;

  /// Custom padding inside the header.
  final EdgeInsetsGeometry? headerPadding;

  /// Custom padding inside the content panel.
  final EdgeInsetsGeometry? contentPadding;

  /// Custom border radius for accordion items or container.
  final BorderRadius? borderRadius;

  /// Custom gap spacing between items (only applicable to [JustAccordionVariant.default_]).
  final double? gap;

  /// Creates a [JustAccordionStyle] override.
  const JustAccordionStyle({
    this.headerBackgroundColor,
    this.contentBackgroundColor,
    this.borderColor,
    this.titleColor,
    this.subtitleColor,
    this.iconColor,
    this.headerPadding,
    this.contentPadding,
    this.borderRadius,
    this.gap,
  });
}
