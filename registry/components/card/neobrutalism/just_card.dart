import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import '../../../shared/default/_shared_tokens.dart';
import '../../theme/default/_shared_theme_provider.dart';
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
class JustCard extends StatelessWidget {
  /// The main body content of the card.
  final Widget child;

  /// The visual variant style. Defaults to [.elevated].
  final JustCardVariant variant;

  /// Optional widget displayed at the top of the card.
  final Widget? header;

  /// Optional widget displayed at the bottom of the card.
  final Widget? footer;

  /// Inner padding of the card body. Defaults to [JustSpacing.lg].
  final EdgeInsets? padding;

  /// Outer margin around the card.
  final EdgeInsets? margin;

  /// Fixed width of the card.
  final double? width;

  /// Fixed height of the card.
  final double? height;

  /// Callback executed when the card is tapped. If provided, the card becomes interactive.
  final VoidCallback? onTap;

  /// Per-instance style overrides.
  final JustCardStyle? style;

  /// Creates a [JustCard] container.
  const JustCard({
    super.key,
    required this.child,
    this.variant = .elevated,
    this.header,
    this.footer,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.style,
  });

  /// Named constructor for elevated shadow-based cards.
  const JustCard.elevated({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.style,
  }) : variant = .elevated;

  /// Named constructor for border-outlined cards.
  const JustCard.outlined({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.style,
  }) : variant = .outlined;

  /// Named constructor for filled solid background cards.
  const JustCard.filled({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.style,
  }) : variant = .filled;

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

    final isInteractive = onTap != null;
    final isNeobrutalism = true;

    // Resolve base colors and shadows depending on the card variant
    Color defaultBg;
    Color defaultBorderColor;
    double defaultBorderWidth;
    List<BoxShadow> defaultShadows;

    final isDark = colors.background.computeLuminance() < 0.5;

    switch (variant) {
      case .elevated:
        defaultBg = colors.card;
        defaultBorderColor = isNeobrutalism
            ? colors.borderDefault
            : const Color(0x00000000);
        defaultBorderWidth = isNeobrutalism ? 2.5 : 0.0;
        defaultShadows = shadows.sm;
        break;
      case .outlined:
        defaultBg = colors.card;
        defaultBorderColor = colors.borderDefault;
        defaultBorderWidth = isNeobrutalism ? 2.5 : 1.0;
        defaultShadows = const [];
        break;
      case .filled:
        defaultBg = isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF1F5F9); // Slate-800 / Slate-100
        defaultBorderColor = isNeobrutalism
            ? colors.borderDefault
            : const Color(0x00000000);
        defaultBorderWidth = isNeobrutalism ? 2.5 : 0.0;
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
        style?.borderRadius ?? themeStyle?.borderRadius ?? .all(radius.lg);
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

      // Resolve shadows for press state (collapses in neobrutalism)
      currentShadows = theme.resolveShadows(
        currentShadows,
        isPressed: isPressed,
      );

      final BorderSide borderSide = currentBorderWidth > 0.0
          ? BorderSide(color: currentBorderColor, width: currentBorderWidth)
          : .none;

      final cardLayout = Container(
        width: width,
        height: height,
        margin: resolvedMargin,
        decoration: BoxDecoration(
          color: resolvedBgColor,
          borderRadius: resolvedBorderRadius,
          border: .fromBorderSide(borderSide),
          boxShadow: currentShadows,
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            if (header != null) ...[
              JustCardHeader(padding: resolvedHeaderPadding, child: header!),
              Container(height: 1.0, color: resolvedHeaderDividerColor),
            ],
            Padding(padding: resolvedPadding, child: child),
            if (footer != null) ...[
              Container(height: 1.0, color: resolvedFooterDividerColor),
              JustCardFooter(padding: resolvedFooterPadding, child: footer!),
            ],
          ],
        ),
      );

      if (isInteractive) {
        final scaleFactor =
            style?.scaleOnPress ?? themeStyle?.scaleOnPress ?? 0.99;
        return theme.buildPressEffect(
          child: cardLayout,
          isPressed: isPressed,
          scaleFactor: scaleFactor,
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
          builder: (context, isHovered, isPressed, isFocused, focusNode) {
            return FocusIndicator(
              isFocused: isFocused,
              focusColor: colors.borderFocus,
              borderRadius: resolvedBorderRadius,
              child: buildCardContent(isHovered, isPressed, isFocused),
            );
          },
        ),
      );
    }

    return buildCardContent(false, false, false);
  }
}

/// Composable header sub-widget for [JustCard].
class JustCardHeader extends StatelessWidget {
  /// The header content.
  final Widget child;

  /// Custom padding override.
  final EdgeInsets? padding;

  /// Creates a [JustCardHeader].
  const JustCardHeader({super.key, required this.child, this.padding});

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
class JustCardTitle extends StatelessWidget {
  /// The title content.
  final Widget child;

  /// Custom text style override.
  final TextStyle? style;

  /// Creates a [JustCardTitle].
  const JustCardTitle({super.key, required this.child, this.style});

  @override
  Widget build(BuildContext context) {
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final defaultStyle = JustFluidTypo.headingMd(
      context,
    ).copyWith(color: colors.textPrimary, fontWeight: .w600);

    return DefaultTextStyle(style: defaultStyle.merge(style), child: child);
  }
}

/// Composable description sub-widget for [JustCard], usually placed inside [JustCardHeader].
class JustCardDescription extends StatelessWidget {
  /// The description content.
  final Widget child;

  /// Custom text style override.
  final TextStyle? style;

  /// Creates a [JustCardDescription].
  const JustCardDescription({super.key, required this.child, this.style});

  @override
  Widget build(BuildContext context) {
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final defaultStyle = JustFluidTypo.bodySm(
      context,
    ).copyWith(color: colors.textSecondary);

    return DefaultTextStyle(style: defaultStyle.merge(style), child: child);
  }
}

/// Composable main body content sub-widget for [JustCard].
class JustCardContent extends StatelessWidget {
  /// The body content.
  final Widget child;

  /// Custom padding override.
  final EdgeInsets? padding;

  /// Creates a [JustCardContent].
  const JustCardContent({super.key, required this.child, this.padding});

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
class JustCardFooter extends StatelessWidget {
  /// The footer content.
  final Widget child;

  /// Custom padding override.
  final EdgeInsets? padding;

  /// Creates a [JustCardFooter].
  const JustCardFooter({super.key, required this.child, this.padding});

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
