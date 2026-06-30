// justui-meta: registry=4cc522d8baf358ff9124eaf8fc75016ccc674c41c00daf37d5ae6952cc8c0251 local=4cc522d8baf358ff9124eaf8fc75016ccc674c41c00daf37d5ae6952cc8c0251
import 'package:flutter/widgets.dart';

/// Visual variants for [JustCard].
enum JustCardVariant {
  /// Elevated card with shadow.
  elevated,

  /// Outlined card with a border and no shadow.
  outlined,

  /// Filled card with a solid background and no border/shadow.
  filled,
}

/// Customized per-instance visual styles for [JustCard].
class JustCardStyle {
  /// The background color of the card.
  final Color? backgroundColor;

  /// The border color of the card.
  final Color? borderColor;

  /// The thickness of the card's border.
  final double? borderWidth;

  /// The corner radius of the card.
  final BorderRadius? borderRadius;

  /// The list of shadows applied to the card.
  final List<BoxShadow>? shadows;

  /// Inner padding of the card content.
  final EdgeInsets? padding;

  /// Outer margin around the card.
  final EdgeInsets? margin;

  /// Inner padding of the card header.
  final EdgeInsets? headerPadding;

  /// Inner padding of the card footer.
  final EdgeInsets? footerPadding;

  /// Color of the divider line below the header.
  final Color? headerDividerColor;

  /// Color of the divider line above the footer.
  final Color? footerDividerColor;

  /// The scale factor when the card is pressed. Defaults to 0.99 for interactive cards.
  final double? scaleOnPress;

  /// Creates a [JustCardStyle] configuration.
  const JustCardStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.shadows,
    this.padding,
    this.margin,
    this.headerPadding,
    this.footerPadding,
    this.headerDividerColor,
    this.footerDividerColor,
    this.scaleOnPress,
  });
}
