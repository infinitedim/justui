import 'package:flutter/widgets.dart';
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
class JustBreadcrumb extends StatelessWidget {
  /// The list of items in the breadcrumb trail.
  final List<JustBreadcrumbItem> items;

  /// Custom separator widget displayed between items. Defaults to a standard text "/".
  final Widget? separator;

  /// Maximum number of items to display. If exceeded, middle items collapse into a single indicator.
  final int? maxItems;

  /// Custom collapsed indicator widget (defaults to standard "...").
  final Widget? collapsed;

  /// Custom style overrides.
  final JustBreadcrumbStyle? style;

  /// Creates a [JustBreadcrumb] widget.
  const JustBreadcrumb({
    super.key,
    required this.items,
    this.separator,
    this.maxItems,
    this.collapsed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;

    final isNeobrutalism =
        true;

    // Resolve separator widget
    final resolvedSeparator =
        separator ??
        Text(
          '/',
          style:
              style?.separatorStyle ??
              typography.bodyMd.copyWith(
                color: isNeobrutalism
                    ? colors.borderDefault
                    : colors.textSecondary,
              ),
        );

    // Resolve collapsed widget
    final resolvedCollapsed =
        collapsed ?? const Text('...', style: TextStyle(fontWeight: .w600));

    final finalPadding = style?.padding ?? .symmetric(vertical: spacing.sm);

    // Generate list of items to render
    final List<Widget> children = [];
    final hasCollapse =
        maxItems != null && items.length > maxItems! && maxItems! >= 2;

    if (!hasCollapse) {
      for (int i = 0; i < items.length; i++) {
        final isLast = i == items.length - 1;
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
      final collapsedItems = items.sublist(1, items.length - 1);
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
    final customTheme = JustThemeProvider.of(context).theme;
    final colors = customTheme.colors;
    final typography = customTheme.typography;
    final spacing = customTheme.spacing;

    final isClickable = item.onTap != null;

    final normalColor =
        style?.color ?? (isLast ? colors.textPrimary : colors.textSecondary);
    final activeColor = style?.activeColor ?? colors.borderFocus;
    final baseTextStyle = isLast
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
            children: [
              if (item.icon != null) ...[
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
      builder: (context, isHovered, isPressed, isFocused, focusNode) {
        final itemColor = isPressed
            ? activeColor.withValues(alpha: 0.8)
            : (isHovered ? activeColor : normalColor);

        final Widget itemWidget = Semantics(
          label: item.label,
          link: true,
          child: Padding(
            padding: style?.itemPadding ?? .symmetric(horizontal: spacing.xs),
            child: Row(
              mainAxisSize: .min,
              children: [
                if (item.icon != null) ...[
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

class _JustBreadcrumbCollapsed extends StatefulWidget {
  final List<JustBreadcrumbItem> collapsedItems;
  final Widget collapsedIndicator;
  final JustBreadcrumbStyle? style;

  const _JustBreadcrumbCollapsed({
    required this.collapsedItems,
    required this.collapsedIndicator,
    this.style,
  });

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
    final customTheme = JustThemeProvider.of(context).theme;
    final colors = customTheme.colors;
    final typography = customTheme.typography;
    final spacing = customTheme.spacing;
    final radius = customTheme.radius;
    final isNeobrutalism = true;

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _controller,
      overlayChildBuilder: (BuildContext context, info) {
        // targetOffset represents the top-left coordinate of the child widget
        final targetOffset = MatrixUtils.transformPoint(
          info.childPaintTransform,
          .zero,
        );

        return Stack(
          children: [
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
                      color: isNeobrutalism
                          ? colors.textPrimary
                          : colors.borderDefault,
                      width: isNeobrutalism ? 2.5 : 1.0,
                    ),
                    boxShadow: customTheme.shadows.md,
                  ),
                  padding: .symmetric(vertical: spacing.xs),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .stretch,
                      children: widget.collapsedItems.map((item) {
                        return JustPressable(
                          onTap: () {
                            _controller.hide();
                            item.onTap?.call();
                          },
                          builder:
                              (
                                context,
                                isHovered,
                                isPressed,
                                isFocused,
                                focusNode,
                              ) {
                                final itemBg = isPressed
                                    ? colors.borderFocus.withValues(alpha: 0.15)
                                    : (isHovered
                                          ? colors.borderFocus.withValues(
                                              alpha: 0.08,
                                            )
                                          : const Color(0x00000000));
                                final itemFg = item.onTap != null
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
                                    children: [
                                      if (item.icon != null) ...[
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
        builder: (context, isHovered, isPressed, isFocused, focusNode) {
          final customTheme = JustThemeProvider.of(context).theme;
          final isNeobrutalism = true;
          final Widget collapsedIndicatorWidget = Container(
            padding:
                widget.style?.itemPadding ?? .symmetric(horizontal: spacing.xs),
            child: DefaultTextStyle(
              style: (widget.style?.textStyle ?? typography.bodyMd).copyWith(
                color: isHovered || isPressed
                    ? (isNeobrutalism ? colors.textPrimary : colors.borderFocus)
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
