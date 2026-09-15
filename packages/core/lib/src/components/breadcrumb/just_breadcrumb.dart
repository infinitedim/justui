import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/theme/preset_tokens.dart';
import 'package:just_ui_core/src/theme/theme_data.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart' show JustColorScheme;

import '../../theme/theme_provider.dart';
import '../shared/_shared_pressable.dart';
import 'just_breadcrumb_style.dart';

/// Represents an individual navigation link within a [JustBreadcrumb].
class JustBreadcrumbItem {
  /// The label text of the breadcrumb item.
  final String label;

  /// Callback executed when the item is tapped.
  /// If null, the item behaves as a static current-page label.
  final VoidCallback? onTap;

  /// An optional leading icon.
  final Widget? icon;

  /// Creates a [JustBreadcrumbItem] configuration.
  const JustBreadcrumbItem({required this.label, this.onTap, this.icon});
}

/// A breadcrumb trail component that provides clean horizontal hierarchy navigation.
///
/// Under zero-Material dependency constraints, it supports custom separators,
/// auto-collapsing middle items when length exceeds [maxItems], and showing collapsed
/// items inside a custom floating dropdown menu when the collapse indicator is clicked.
/// A breadcrumb trail component that provides clean horizontal hierarchy navigation.
///
/// Under zero-Material dependency constraints, it supports custom separators,
/// auto-collapsing middle items when length exceeds [maxItems], and showing collapsed
/// items inside a custom floating dropdown menu when the collapse indicator is clicked.
class const JustBreadcrumb({
  super.key,

  /// The list of items in the breadcrumb trail.
  required final List<JustBreadcrumbItem> items,

  /// Custom separator widget displayed between items. Defaults to a standard text "/".
  final Widget? separator,

  /// Maximum number of items to display. If exceeded, middle items collapse into a single indicator.
  final int? maxItems,

  /// Custom collapsed indicator widget (defaults to standard "...").
  final Widget? collapsed,

  /// Custom style overrides.
  final JustBreadcrumbStyle? style,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final JustColorScheme colors = JustThemeProvider.of(
      context,
      aspect: .colors,
    ).theme.colors;
    final JustTypographyScheme typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final JustSpacingScheme spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;

    final JustPresetTokens presetTokens = JustThemeProvider.of(context)
        .theme
        .presetTokens;

    // Resolve separator widget
    final Widget resolvedSeparator =
        separator ??
        Text(
          '/',
          style:
              style?.separatorStyle ??
              typography.bodyMd.copyWith(
                color: presetTokens.showsDefaultBorder
                    ? colors.borderDefault
                    : colors.textSecondary,
              ),
        );

    // Resolve collapsed widget
    final Widget resolvedCollapsed =
        collapsed ?? const Text('...', style: TextStyle(fontWeight: .w600));

    final EdgeInsets finalPadding =
        style?.padding ?? .symmetric(vertical: spacing.sm);

    // Generate list of items to render
    final List<Widget> children = <Widget>[];
    final bool hasCollapse =
        maxItems != null && items.length > maxItems! && maxItems! >= 2;

    if (!hasCollapse) {
      for (int i = 0; i < items.length; i++) {
        final bool isLast = i == items.length - 1;
        children.add(_buildItem(context, items[i], isLast));
        if (!isLast) {
          children.add(
            Padding(
              padding: style?.itemPadding ?? .symmetric(horizontal: spacing.sm),
              child: resolvedSeparator,
            ),
          );
        }
      }
    } else {
      // Always keep the first item
      children.add(_buildItem(context, items.first, false));
      children.add(
        Padding(
          padding: style?.itemPadding ?? .symmetric(horizontal: spacing.sm),
          child: resolvedSeparator,
        ),
      );

      // Group middle collapsed items
      final List<JustBreadcrumbItem> collapsedItems = items.sublist(
        1,
        items.length - 1,
      );
      children.add(
        _JustBreadcrumbCollapsed(
          collapsedItems: collapsedItems,
          collapsedIndicator: resolvedCollapsed,
          style: style,
        ),
      );
      children.add(
        Padding(
          padding: style?.itemPadding ?? .symmetric(horizontal: spacing.sm),
          child: resolvedSeparator,
        ),
      );

      // Always keep the last item
      children.add(_buildItem(context, items.last, true));
    }

    return Padding(
      padding: finalPadding,
      child: SingleChildScrollView(
        scrollDirection: .horizontal,
        child: Row(mainAxisSize: .min, children: children),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    JustBreadcrumbItem item,
    bool isLast,
  ) {
    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
    final JustColorScheme colors = customTheme.colors;
    final JustTypographyScheme typography = customTheme.typography;
    final JustSpacingScheme spacing = customTheme.spacing;

    final bool isClickable = item.onTap != null;

    final Color normalColor =
        style?.color ?? (isLast ? colors.textPrimary : colors.textSecondary);
    final Color activeColor = style?.activeColor ?? colors.borderFocus;
    final TextStyle baseTextStyle = isLast
        ? (style?.activeTextStyle ??
              typography.bodyMd.copyWith(fontWeight: .w600))
        : (style?.textStyle ?? typography.bodyMd);

    if (!isClickable) {
      return Semantics(
        label: item.label,
        child: Padding(
          padding: style?.itemPadding ?? .symmetric(horizontal: spacing.xs),
          child: Row(
            mainAxisSize: .min,
            children: <Widget>[
              if (item.icon != null) ...<Widget>[
                IconTheme.merge(
                  data: IconThemeData(size: 16.0, color: normalColor),
                  child: item.icon!,
                ),
                SizedBox(width: spacing.xs),
              ],
              Text(
                item.label,
                style: baseTextStyle.copyWith(color: normalColor),
              ),
            ],
          ),
        ),
      );
    }

    return JustPressable(
      onTap: item.onTap,
      builder: (BuildContext context, JustInteractionState state) {
        final bool isHovered = state.isHovered;
        final bool isPressed = state.isPressed;
        final Color itemColor = isPressed
            ? activeColor.withValues(alpha: 0.8)
            : (isHovered ? activeColor : normalColor);

        final Widget itemWidget = Semantics(
          label: item.label,
          link: true,
          child: Padding(
            padding: style?.itemPadding ?? .symmetric(horizontal: spacing.xs),
            child: Row(
              mainAxisSize: .min,
              children: <Widget>[
                if (item.icon != null) ...<Widget>[
                  IconTheme.merge(
                    data: IconThemeData(size: 16.0, color: itemColor),
                    child: item.icon!,
                  ),
                  SizedBox(width: spacing.xs),
                ],
                Text(
                  item.label,
                  style: baseTextStyle.copyWith(
                    color: itemColor,
                    decoration: isHovered ? .underline : .none,
                  ),
                ),
              ],
            ),
          ),
        );

        return customTheme.buildPressEffect(
          isPressed: isPressed,
          child: itemWidget,
        );
      },
    );
  }
}

class const _JustBreadcrumbCollapsed({
  required final List<JustBreadcrumbItem> collapsedItems,
  required final Widget collapsedIndicator,
  final JustBreadcrumbStyle? style,
}) extends StatefulWidget {
  @override
  State<_JustBreadcrumbCollapsed> createState() =>
      _JustBreadcrumbCollapsedState();
}

class _JustBreadcrumbCollapsedState extends State<_JustBreadcrumbCollapsed> {
  final OverlayPortalController _controller = OverlayPortalController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
    final JustColorScheme colors = customTheme.colors;
    final JustTypographyScheme typography = customTheme.typography;
    final JustSpacingScheme spacing = customTheme.spacing;
    final JustRadiusScheme radius = customTheme.radius;
    final JustPresetTokens presetTokens = customTheme.presetTokens;

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _controller,
      overlayChildBuilder: (BuildContext context, OverlayChildLayoutInfo info) {
        // targetOffset represents the top-left coordinate of the child widget
        final Offset targetOffset = MatrixUtils.transformPoint(
          info.childPaintTransform,
          .zero,
        );

        return Stack(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _controller.hide(),
              child: const SizedBox.expand(),
            ),
            Positioned(
              left: targetOffset.dx,
              top: targetOffset.dy + info.childSize.height + spacing.xs,
              child: TapRegion(
                onTapOutside: (_) => _controller.hide(),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 160,
                    maxWidth: 240,
                  ),
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: .all(radius.md),
                    border: .all(
                      color: presetTokens.showsDefaultBorder
                          ? colors.textPrimary
                          : colors.borderDefault,
                      width: presetTokens.borderWidth,
                    ),
                    boxShadow: customTheme.shadows.md,
                  ),
                  padding: .symmetric(vertical: spacing.xs),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .stretch,
                      children: widget.collapsedItems.map((
                        JustBreadcrumbItem item,
                      ) {
                        return JustPressable(
                          onTap: () {
                            _controller.hide();
                            item.onTap?.call();
                          },
                          builder:
                              (
                                BuildContext context,
                                JustInteractionState state,
                              ) {
                                final bool isHovered = state.isHovered;
                                final bool isPressed = state.isPressed;
                                final Color itemBg = isPressed
                                    ? colors.borderFocus.withValues(alpha: 0.15)
                                    : (isHovered
                                          ? colors.borderFocus.withValues(
                                              alpha: 0.08,
                                            )
                                          : const Color(0x00000000));
                                final Color itemFg = item.onTap != null
                                    ? (isHovered || isPressed
                                          ? colors.borderFocus
                                          : colors.textPrimary)
                                    : colors.textDisabled;

                                return Container(
                                  color: itemBg,
                                  padding: .symmetric(
                                    horizontal: spacing.md,
                                    vertical: spacing.sm,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      if (item.icon != null) ...<Widget>[
                                        IconTheme.merge(
                                          data: IconThemeData(
                                            size: 16.0,
                                            color: itemFg,
                                          ),
                                          child: item.icon!,
                                        ),
                                        SizedBox(width: spacing.sm),
                                      ],
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style:
                                              (widget.style?.textStyle ??
                                                      typography.bodySm)
                                                  .copyWith(
                                                    color: itemFg,
                                                    fontWeight: .w400,
                                                  ),
                                          maxLines: 1,
                                          overflow: .ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: JustPressable(
        focusNode: _focusNode,
        onTap: () => _controller.toggle(),
        builder: (BuildContext context, JustInteractionState state) {
          final bool isHovered = state.isHovered;
          final bool isPressed = state.isPressed;
          final JustThemeData customTheme = JustThemeProvider.of(context).theme;
          final JustPresetTokens presetTokens = customTheme.presetTokens;
          final Widget collapsedIndicatorWidget = Container(
            padding:
                widget.style?.itemPadding ?? .symmetric(horizontal: spacing.xs),
            child: DefaultTextStyle(
              style: (widget.style?.textStyle ?? typography.bodyMd).copyWith(
                color: isHovered || isPressed
                    ? (presetTokens.showsDefaultBorder
                          ? colors.textPrimary
                          : colors.borderFocus)
                    : colors.textSecondary,
              ),
              child: widget.collapsedIndicator,
            ),
          );

          return Semantics(
            label: 'Show collapsed breadcrumbs',
            button: true,
            child: customTheme.buildPressEffect(
              isPressed: isPressed,
              child: collapsedIndicatorWidget,
            ),
          );
        },
      ),
    );
  }
}
