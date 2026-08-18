import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import '../../theme/theme_provider.dart';
import '../shared/_shared_pressable.dart';
import '../shared/_shared_focus_indicator.dart';
import 'just_card_style.dart';
import 'just_card_theme.dart';

/// A highly customizable, beautiful Card component adhering to JustUI design system.
///
/// Supports elevated, outlined, and filled visual variants, custom header/footer
/// sections with dividers, and interactive pressed (scale-down) and hover/focus states.
///
/// Can be composed semantically using [JustCardHeader], [JustCardTitle], [JustCardDescription],
/// [JustCardContent], and [JustCardFooter] for advanced card designs.
/// A highly customizable, beautiful Card component adhering to JustUI design system.
///
/// Supports elevated, outlined, and filled visual variants, custom header/footer
/// sections with dividers, and interactive pressed (scale-down) and hover/focus states.
///
/// Can be composed semantically using [JustCardHeader], [JustCardTitle], [JustCardDescription],
/// [JustCardContent], and [JustCardFooter] for advanced card designs.
class const JustCard({
  super.key,

  /// The main body content of the card.
  required final Widget child,

  /// The visual variant style. Defaults to [.elevated].
  final JustCardVariant variant = .elevated,

  /// Optional widget displayed at the top of the card.
  final Widget? header,

  /// Optional widget displayed at the bottom of the card.
  final Widget? footer,

  /// Inner padding of the card body. Defaults to [JustSpacing.lg].
  final EdgeInsets? padding,

  /// Outer margin around the card.
  final EdgeInsets? margin,

  /// Fixed width of the card.
  final double? width,

  /// Fixed height of the card.
  final double? height,

  /// Callback executed when the card is tapped. If provided, the card becomes interactive.
  final VoidCallback? onTap,

  /// Per-instance style overrides.
  final JustCardStyle? style,
}) extends StatelessWidget {
  /// Named constructor for elevated shadow-based cards.
  const new elevated({
    Key? key,
    required Widget child,
    Widget? header,
    Widget? footer,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
    JustCardStyle? style,
  }) : this(
         key: key,
         child: child,
         variant: .elevated,
         header: header,
         footer: footer,
         padding: padding,
         margin: margin,
         width: width,
         height: height,
         onTap: onTap,
         style: style,
       );

  /// Named constructor for border-outlined cards.
  const new outlined({
    Key? key,
    required Widget child,
    Widget? header,
    Widget? footer,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
    JustCardStyle? style,
  }) : this(
         key: key,
         child: child,
         variant: .outlined,
         header: header,
         footer: footer,
         padding: padding,
         margin: margin,
         width: width,
         height: height,
         onTap: onTap,
         style: style,
       );

  /// Named constructor for filled solid background cards.
  const new filled({
    Key? key,
    required Widget child,
    Widget? header,
    Widget? footer,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
    VoidCallback? onTap,
    JustCardStyle? style,
  }) : this(
         key: key,
         child: child,
         variant: .filled,
         header: header,
         footer: footer,
         padding: padding,
         margin: margin,
         width: width,
         height: height,
         onTap: onTap,
         style: style,
       );

  @override
  Widget build(BuildContext context) {
    // Resolve theme extension values
    final globalCardTheme = Theme.of(context).extension<JustCardTheme>();
    final themeStyle = globalCardTheme?.style;

    // Aspect-based subscriptions for optimal rebuild performance
    final theme = JustThemeProvider.of(context).theme;
    final colors = theme.colors;
    final spacing = theme.spacing;
    final radius = theme.radius;
    final shadows = theme.shadows;
    final presetTokens = theme.presetTokens;

    final isInteractive = onTap != null;

    // Resolve base colors and shadows depending on the card variant
    Color defaultBg;
    Color defaultBorderColor;
    double defaultBorderWidth;
    List<BoxShadow> defaultShadows;

    switch (variant) {
      case .elevated:
        defaultBg = colors.card;
        defaultBorderColor = presetTokens.showsDefaultBorder
            ? colors.borderDefault
            : const Color(0x00000000);
        defaultBorderWidth = presetTokens.showsDefaultBorder
            ? presetTokens.borderWidth
            : 0.0;
        defaultShadows = shadows.sm;
        break;
      case .outlined:
        defaultBg = colors.card;
        defaultBorderColor = colors.borderDefault;
        defaultBorderWidth = presetTokens.borderWidth;
        defaultShadows = const [];
        break;
      case .filled:
        defaultBg = colors.muted;
        defaultBorderColor = presetTokens.showsDefaultBorder
            ? colors.borderDefault
            : const Color(0x00000000);
        defaultBorderWidth = presetTokens.showsDefaultBorder
            ? presetTokens.borderWidth
            : 0.0;
        defaultShadows = const [];
        break;
    }

    // Resolve structural values with preference order: widget parameter -> theme extension -> default
    final resolvedBgColor =
        style?.backgroundColor ?? themeStyle?.backgroundColor ?? defaultBg;
    final resolvedBorderColor =
        style?.borderColor ?? themeStyle?.borderColor ?? defaultBorderColor;
    final resolvedBorderWidth =
        style?.borderWidth ?? themeStyle?.borderWidth ?? defaultBorderWidth;
    final resolvedBorderRadius =
        style?.borderRadius ??
        themeStyle?.borderRadius ??
        presetTokens.resolveBorderRadius(radius);
    final resolvedPadding =
        style?.padding ?? themeStyle?.padding ?? .all(spacing.lg);
    final resolvedMargin = style?.margin ?? themeStyle?.margin ?? .zero;

    final resolvedHeaderPadding =
        style?.headerPadding ??
        themeStyle?.headerPadding ??
        .symmetric(horizontal: spacing.lg, vertical: spacing.md);
    final resolvedFooterPadding =
        style?.footerPadding ??
        themeStyle?.footerPadding ??
        .symmetric(horizontal: spacing.lg, vertical: spacing.md);
    final resolvedHeaderDividerColor =
        style?.headerDividerColor ??
        themeStyle?.headerDividerColor ??
        colors.borderDefault;
    final resolvedFooterDividerColor =
        style?.footerDividerColor ??
        themeStyle?.footerDividerColor ??
        colors.borderDefault;

    Widget buildCardContent(bool isHovered, bool isPressed, bool isFocused) {
      final typography = JustThemeProvider.of(
        context,
        aspect: .typography,
      ).theme.typography;
      // Interactive overrides
      List<BoxShadow> currentShadows =
          style?.shadows ?? themeStyle?.shadows ?? defaultShadows;
      Color currentBorderColor = resolvedBorderColor;
      double currentBorderWidth = resolvedBorderWidth;

      if (isInteractive) {
        if (isHovered || isFocused) {
          if (variant == .elevated) {
            currentShadows = shadows.md;
          }
          currentBorderColor = colors.borderFocus;
          if (currentBorderWidth == 0.0) {
            currentBorderWidth = 1.0;
          }
        }
      }

      // Resolve shadows for press state
      List<BoxShadow> resolvedShadows;
      if (style?.shadows != null || themeStyle?.shadows != null) {
        if (isPressed) {
          if (presetTokens.showsDefaultBorder) {
            resolvedShadows = const [];
          } else {
            resolvedShadows = currentShadows
                .map(
                  (s) => s.copyWith(
                    blurRadius: s.blurRadius * 0.6,
                    offset: s.offset * 0.5,
                  ),
                )
                .toList();
          }
        } else {
          resolvedShadows = currentShadows;
        }
      } else {
        if (variant == .elevated || presetTokens.showsDefaultBorder) {
          resolvedShadows = presetTokens.resolveShadow(
            shadows,
            (isHovered || isFocused) ? .lg : .md,
            isPressed: isPressed,
          );
        } else {
          resolvedShadows = const [];
        }
      }

      final BorderSide borderSide = currentBorderWidth > 0.0
          ? BorderSide(color: currentBorderColor, width: currentBorderWidth)
          : .none;

      final dividerHeight = presetTokens.borderWidth > 0.0
          ? presetTokens.borderWidth
          : 1.0;

      final cardLayout = Container(
        width: width,
        height: height,
        margin: resolvedMargin,
        decoration: BoxDecoration(
          color: resolvedBgColor,
          borderRadius: resolvedBorderRadius,
          border: .fromBorderSide(borderSide),
          boxShadow: resolvedShadows,
        ),
        child: DefaultTextStyle(
          style: typography.bodyMd.copyWith(color: colors.textPrimary),
          child: IconTheme.merge(
            data: IconThemeData(color: colors.textPrimary),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                if (header != null) ...[
                  JustCardHeader(
                    padding: resolvedHeaderPadding,
                    child: header!,
                  ),
                  Container(
                    height: dividerHeight,
                    color: resolvedHeaderDividerColor,
                  ),
                ],
                Padding(padding: resolvedPadding, child: child),
                if (footer != null) ...[
                  Container(
                    height: dividerHeight,
                    color: resolvedFooterDividerColor,
                  ),
                  JustCardFooter(
                    padding: resolvedFooterPadding,
                    child: footer!,
                  ),
                ],
              ],
            ),
          ),
        ),
      );

      if (isInteractive) {
        final scaleFactor =
            style?.scaleOnPress ?? themeStyle?.scaleOnPress ?? 0.99;
        return presetTokens.buildPressEffect(
          child: cardLayout,
          isPressed: isPressed,
          animations: theme.animations,
          customScale: scaleFactor,
        );
      }

      return cardLayout;
    }

    if (isInteractive) {
      return Semantics(
        button: true,
        enabled: true,
        child: JustPressable(
          enabled: true,
          onTap: onTap,
          builder: (BuildContext context, JustInteractionState state) {
            return FocusIndicator(
              isFocused: state.isFocusVisible,
              borderRadius: resolvedBorderRadius,
              child: buildCardContent(
                state.isHovered,
                state.isPressed,
                state.isFocused,
              ),
            );
          },
        ),
      );
    }

    return buildCardContent(false, false, false);
  }
}

/// Composable header sub-widget for [JustCard].
/// Composable header sub-widget for [JustCard].
class const JustCardHeader({
  super.key,

  /// The header content.
  required final Widget child,

  /// Custom padding override.
  final EdgeInsets? padding,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final globalCardTheme = Theme.of(context).extension<JustCardTheme>();
    final themeStyle = globalCardTheme?.style;

    final resolvedPadding =
        padding ??
        themeStyle?.headerPadding ??
        .symmetric(horizontal: spacing.lg, vertical: spacing.md);

    return Padding(
      padding: resolvedPadding,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [child],
      ),
    );
  }
}

/// Composable title sub-widget for [JustCard], usually placed inside [JustCardHeader].
/// Composable title sub-widget for [JustCard], usually placed inside [JustCardHeader].
class const JustCardTitle({
  super.key,

  /// The title content.
  required final Widget child,

  /// Custom text style override.
  final TextStyle? style,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final defaultStyle = JustFluidTypo.headingMd(context)
        .copyWith(color: colors.textPrimary, fontWeight: .w600);

    return DefaultTextStyle(style: defaultStyle.merge(style), child: child);
  }
}

/// Composable description sub-widget for [JustCard], usually placed inside [JustCardHeader].
/// Composable description sub-widget for [JustCard], usually placed inside [JustCardHeader].
class const JustCardDescription({
  super.key,

  /// The description content.
  required final Widget child,

  /// Custom text style override.
  final TextStyle? style,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final defaultStyle = JustFluidTypo.bodySm(context)
        .copyWith(color: colors.textSecondary);

    return DefaultTextStyle(style: defaultStyle.merge(style), child: child);
  }
}

/// Composable main body content sub-widget for [JustCard].
/// Composable main body content sub-widget for [JustCard].
class const JustCardContent({
  super.key,

  /// The body content.
  required final Widget child,

  /// Custom padding override.
  final EdgeInsets? padding,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final globalCardTheme = Theme.of(context).extension<JustCardTheme>();
    final themeStyle = globalCardTheme?.style;

    final resolvedPadding = padding ?? themeStyle?.padding ?? .all(spacing.lg);

    return Padding(padding: resolvedPadding, child: child);
  }
}

/// Composable footer sub-widget for [JustCard].
/// Composable footer sub-widget for [JustCard].
class const JustCardFooter({
  super.key,

  /// The footer content.
  required final Widget child,

  /// Custom padding override.
  final EdgeInsets? padding,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final globalCardTheme = Theme.of(context).extension<JustCardTheme>();
    final themeStyle = globalCardTheme?.style;

    final resolvedPadding =
        padding ??
        themeStyle?.footerPadding ??
        .symmetric(horizontal: spacing.lg, vertical: spacing.md);

    return Padding(padding: resolvedPadding, child: child);
  }
}
