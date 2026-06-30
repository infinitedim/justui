import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Theme;

import '../../../shared/default/_shared_tokens.dart';
import '../../theme/default/_shared_theme_provider.dart';
import '../shared/_shared_tooltip_overlay.dart';
import '../shared/_shared_pressable.dart';
import 'just_sidebar_style.dart';
import 'just_sidebar_theme.dart';
import 'just_sidebar_variants.dart';

/// Represents a single navigation destination item inside [JustSidebar].
class JustSidebarItem {
  /// The label text.
  final String label;

  /// The leading icon.
  final Widget icon;

  /// Callback executed when the item is tapped.
  final VoidCallback? onTap;

  /// An optional notification badge widget (e.g. JustBadge).
  final Widget? badge;

  /// Nested sub-menu items under this item.
  final List<JustSidebarItem>? children;

  /// Whether the item is interactive.
  final bool enabled;

  /// Creates a [JustSidebarItem] destination.
  const JustSidebarItem({
    required this.label,
    required this.icon,
    this.onTap,
    this.badge,
    this.children,
    this.enabled = true,
  });
}

/// A premium, collapsible sidebar navigation panel supporting recursive sub-menus,
/// collapsed hover tooltips, and responsive layout scaling.
class JustSidebar extends StatefulWidget {
  /// The list of sidebar navigation items.
  final List<JustSidebarItem> items;

  /// Logo or brand widget displayed at the top of the sidebar.
  final Widget? header;

  /// User profile or actions widget displayed at the bottom of the sidebar.
  final Widget? footer;

  /// The expanded width of the sidebar (defaults to 260px).
  final double width;

  /// The collapsed width of the sidebar (defaults to 68px).
  final double collapsedWidth;

  /// Whether the sidebar can be collapsed.
  final bool isCollapsible;

  /// Whether the sidebar is currently collapsed.
  final bool isCollapsed;

  /// Callback executed when collapse state changes.
  final ValueChanged<bool>? onCollapsedChanged;

  /// The active item index in the flattened top-level items.
  final int selectedIndex;

  /// Callback executed when a top-level menu item is selected.
  final ValueChanged<int>? onItemSelected;

  /// The layout variant (default_, floating, inset).
  final JustSidebarVariant variant;

  /// Custom style overrides.
  final JustSidebarStyle? style;

  /// Creates a [JustSidebar] panel.
  const JustSidebar({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.width = 260.0,
    this.collapsedWidth = 68.0,
    this.isCollapsible = true,
    this.isCollapsed = false,
    this.onCollapsedChanged,
    this.selectedIndex = 0,
    this.onItemSelected,
    this.variant = .default_,
    this.style,
  });

  @override
  State<JustSidebar> createState() => _JustSidebarState();
}

class _JustSidebarState extends State<JustSidebar>
    with TickerProviderStateMixin {
  late final AnimationController _collapseController;
  late final Animation<double> _collapseAnimation;

  @override
  void initState() {
    super.initState();
    _collapseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isCollapsed ? 0.0 : 1.0,
    );
    _collapseAnimation = CurvedAnimation(
      parent: _collapseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant JustSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      _collapseController.animateTo(widget.isCollapsed ? 0.0 : 1.0);
    }
  }

  @override
  void dispose() {
    _collapseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context).theme;
    final sidebarTheme = Theme.of(context).extension<JustSidebarTheme>();
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final radius = customTheme.radius;
    final shadows = customTheme.shadows;

    // Resolve active styles
    JustSidebarStyle? themeStyle;
    if (sidebarTheme != null) {
      switch (widget.variant) {
        case .default_:
          themeStyle = sidebarTheme.defaultStyle;
          break;
        case .floating:
          themeStyle = sidebarTheme.floatingStyle;
          break;
        case .inset:
          themeStyle = sidebarTheme.insetStyle;
          break;
      }
    }

    final double screenWidth = MediaQuery.sizeOf(context).width;
    // Auto-collapse sidebar on smaller screens (below md breakpoint)
    final bool isAutoCollapsed = screenWidth <= JustBreakpoints.md;
    final bool activeCollapsed = widget.isCollapsed || isAutoCollapsed;

    if (activeCollapsed &&
        _collapseController.value > 0.0 &&
        !isAutoCollapsed) {
      _collapseController.value = 0.0;
    } else if (!activeCollapsed &&
        _collapseController.value < 1.0 &&
        !isAutoCollapsed) {
      _collapseController.value = 1.0;
    }

    final containerBg =
        widget.style?.backgroundColor ??
        themeStyle?.backgroundColor ??
        colors.elevated;
    final activeColor =
        widget.style?.activeColor ??
        themeStyle?.activeColor ??
        colors.borderFocus;
    final inactiveColor =
        widget.style?.inactiveColor ??
        themeStyle?.inactiveColor ??
        colors.textSecondary;

    final EdgeInsetsGeometry defaultPadding = widget.variant == .floating
        ? .all(spacing.md)
        : (widget.variant == .inset
              ? .symmetric(horizontal: spacing.md, vertical: spacing.lg)
              : .symmetric(vertical: spacing.lg));

    final finalPadding =
        widget.style?.padding ?? themeStyle?.padding ?? defaultPadding;

    final BorderRadius borderRadius = widget.variant == .floating
        ? .all(radius.xl)
        : (widget.variant == .inset ? .all(radius.lg) : .zero);

    return AnimatedBuilder(
      animation: _collapseAnimation,
      builder: (context, child) {
        final double currentWidth =
            widget.collapsedWidth +
            (widget.width - widget.collapsedWidth) * _collapseAnimation.value;

        final isNeobrutalism = true;
        final Border borderStyle = isNeobrutalism
            ? (widget.variant == .default_
                  ? Border(
                      right: BorderSide(
                        color: colors.borderDefault,
                        width: 2.5,
                      ),
                    )
                  : .all(color: colors.borderDefault, width: 2.5))
            : (widget.variant == .default_
                  ? Border(
                      right: BorderSide(
                        color: colors.borderDefault,
                        width: 1.0,
                      ),
                    )
                  : .all(color: colors.borderDefault, width: 1.0));

        return Container(
          width: currentWidth,
          height: .infinity,
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: borderRadius,
            border: borderStyle,
            boxShadow: widget.variant != .default_
                ? (isNeobrutalism
                      ? customTheme.resolveShadows(shadows.lg, isPressed: false)
                      : shadows.md)
                : null,
          ),
          padding: finalPadding,
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              // Header logo area
              if (widget.header != null) ...[
                ClipRect(
                  child: Align(
                    alignment: .centerLeft,
                    heightFactor: 1.0,
                    child: SizedBox(height: 48.0, child: widget.header!),
                  ),
                ),
                SizedBox(height: spacing.lg),
              ],

              // Navigation menu items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .stretch,
                    children: [
                      for (int i = 0; i < widget.items.length; i++)
                        _buildSidebarItem(
                          context: context,
                          item: widget.items[i],
                          index: i,
                          depth: 0,
                          isCollapsed: activeCollapsed,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          themeStyle: themeStyle,
                        ),
                    ],
                  ),
                ),
              ),

              // Footer area
              if (widget.footer != null) ...[
                SizedBox(height: spacing.lg),
                ClipRect(
                  child: Align(alignment: .centerLeft, child: widget.footer!),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem({
    required BuildContext context,
    required JustSidebarItem item,
    required int index,
    required int depth,
    required bool isCollapsed,
    required Color activeColor,
    required Color inactiveColor,
    JustSidebarStyle? themeStyle,
  }) {
    final customTheme = JustThemeProvider.of(context).theme;
    final colors = customTheme.colors;
    final spacing = customTheme.spacing;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final radius = JustThemeProvider.of(context).theme.radius;

    final isSelected = widget.selectedIndex == index && depth == 0;
    final hasChildren = item.children != null && item.children!.isNotEmpty;

    // Proportional indentation in LTR/RTL
    final isRtl = Directionality.of(context) == .rtl;
    final double indent = depth * 16.0;

    final EdgeInsetsGeometry defaultItemPadding = widget.variant == .inset
        ? .symmetric(horizontal: spacing.md, vertical: spacing.sm)
        : .symmetric(horizontal: spacing.lg, vertical: spacing.sm);

    final itemPadding =
        widget.style?.itemPadding ??
        themeStyle?.itemPadding ??
        defaultItemPadding;
    final resolvedItemPadding = itemPadding.resolve(Directionality.of(context));
    final itemRadius =
        widget.style?.itemBorderRadius ??
        themeStyle?.itemBorderRadius ??
        .all(radius.md);

    final textStyle =
        widget.style?.textStyle ?? themeStyle?.textStyle ?? typography.bodyMd;
    final activeTextStyle =
        widget.style?.activeTextStyle ??
        themeStyle?.activeTextStyle ??
        typography.bodyMd.copyWith(fontWeight: .w600);

    // Sidebar item inner layout content
    Widget content = JustPressable(
      enabled: item.enabled,
      onTap: () {
        if (hasChildren) {
          // Folder handles expanding locally (handled by stateful folder widget below)
        } else {
          item.onTap?.call();
          widget.onItemSelected?.call(index);
        }
      },
      builder: (context, isHovered, isPressed, isFocused, focusNode) {
        final double itemOpacity = item.enabled ? 1.0 : 0.5;

        final isNeobrutalism = true;

        final Color itemBg = isSelected
            ? (isNeobrutalism
                  ? activeColor.withValues(alpha: 0.35)
                  : (widget.variant == .default_
                        ? colors.card
                        : activeColor.withValues(alpha: 0.08)))
            : (isPressed
                  ? activeColor.withValues(alpha: 0.12)
                  : (isHovered
                        ? activeColor.withValues(alpha: 0.05)
                        : const Color(0x00000000)));

        final Color foregroundColor = isNeobrutalism
            ? colors.textPrimary
            : (isSelected
                  ? activeColor
                  : (isHovered || isPressed ? activeColor : inactiveColor));

        final resolvedTextStyle = isSelected ? activeTextStyle : textStyle;

        final Border? itemBorder = isNeobrutalism
            ? .all(
                color: (isSelected || isHovered)
                    ? colors.textPrimary
                    : const Color(0x00000000),
                width: 1.5,
              )
            : (isSelected && widget.variant == .default_
                  ? Border(
                      left: !isRtl
                          ? BorderSide(color: activeColor, width: 3.0)
                          : .none,
                      right: isRtl
                          ? BorderSide(color: activeColor, width: 3.0)
                          : .none,
                    )
                  : null);

        final Widget itemRow = Opacity(
          opacity: itemOpacity,
          child: Container(
            decoration: BoxDecoration(
              color: itemBg,
              borderRadius: itemRadius,
              border: itemBorder,
            ),
            padding: resolvedItemPadding.copyWith(
              left: !isRtl
                  ? resolvedItemPadding.left + indent
                  : resolvedItemPadding.left,
              right: isRtl
                  ? resolvedItemPadding.right + indent
                  : resolvedItemPadding.right,
            ),
            child: Row(
              children: [
                IconTheme.merge(
                  data: IconThemeData(size: 20.0, color: foregroundColor),
                  child: item.icon,
                ),
                if (!isCollapsed) ...[
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      item.label,
                      style: resolvedTextStyle.copyWith(color: foregroundColor),
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                  ),
                  if (item.badge != null) ...[
                    SizedBox(width: spacing.sm),
                    item.badge!,
                  ],
                ],
              ],
            ),
          ),
        );

        return customTheme.buildPressEffect(
          isPressed: isPressed,
          child: itemRow,
        );
      },
    );

    // Apply collapsed hover tooltip wrapper
    if (isCollapsed && !hasChildren) {
      content = JustTooltipOverlay(message: item.label, child: content);
    }

    if (hasChildren) {
      return _JustSidebarFolder(
        item: item,
        depth: depth,
        isCollapsed: isCollapsed,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        themeStyle: themeStyle,
        itemWidget: content,
      );
    }

    return content;
  }
}

class _JustSidebarFolder extends StatefulWidget {
  final JustSidebarItem item;
  final int depth;
  final bool isCollapsed;
  final Color activeColor;
  final Color inactiveColor;
  final JustSidebarStyle? themeStyle;
  final Widget itemWidget;

  const _JustSidebarFolder({
    required this.item,
    required this.depth,
    required this.isCollapsed,
    required this.activeColor,
    required this.inactiveColor,
    this.themeStyle,
    required this.itemWidget,
  });

  @override
  State<_JustSidebarFolder> createState() => _JustSidebarFolderState();
}

class _JustSidebarFolderState extends State<_JustSidebarFolder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    _isExpanded = !_isExpanded;
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context).theme;
    final colors = customTheme.colors;
    final spacing = customTheme.spacing;
    final radius = customTheme.radius;
    final isRtl = Directionality.of(context) == .rtl;

    final itemPadding =
        widget.themeStyle?.itemPadding ??
        .symmetric(horizontal: spacing.lg, vertical: spacing.sm);
    final itemRadius = widget.themeStyle?.itemBorderRadius ?? .all(radius.md);

    // Chevron pointing side (or left in RTL) when collapsed, down when expanded
    final Widget chevronIcon = RotationTransition(
      turns: _expandAnimation.drive(Tween<double>(begin: 0.0, end: 0.25)),
      child: Icon(
        isRtl
            ? const IconData(0xEA60, fontFamily: 'MaterialIcons')
            : const IconData(0xEA61, fontFamily: 'MaterialIcons'),
        size: 16.0,
        color: widget.inactiveColor,
      ),
    );

    // Wrap the base item row layout to support folder toggling on folder header click
    final Widget folderHeader = AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final isFolderExpanded = _expandController.value > 0.5;

        return Semantics(
          expanded: isFolderExpanded,
          child: JustPressable(
            onTap: _toggleExpand,
            builder: (context, isHovered, isPressed, isFocused, focusNode) {
              final Color itemBg = isPressed
                  ? widget.activeColor.withValues(alpha: 0.12)
                  : (isHovered
                        ? widget.activeColor.withValues(alpha: 0.05)
                        : const Color(0x00000000));

              final isNeobrutalism = true;
              final Color foregroundColor = isNeobrutalism
                  ? colors.textPrimary
                  : (isHovered || isPressed
                        ? widget.activeColor
                        : widget.inactiveColor);

              final Border? itemBorder = isNeobrutalism
                  ? .all(
                      color: isHovered
                          ? colors.textPrimary
                          : const Color(0x00000000),
                      width: 1.5,
                    )
                  : null;

              final Widget folderBox = Container(
                decoration: BoxDecoration(
                  color: itemBg,
                  borderRadius: itemRadius,
                  border: itemBorder,
                ),
                padding: itemPadding.copyWith(
                  left: !isRtl
                      ? itemPadding.left + (widget.depth * 16.0)
                      : itemPadding.left,
                  right: isRtl
                      ? itemPadding.right + (widget.depth * 16.0)
                      : itemPadding.right,
                ),
                child: Row(
                  children: [
                    IconTheme.merge(
                      data: IconThemeData(size: 20.0, color: foregroundColor),
                      child: widget.item.icon,
                    ),
                    if (!widget.isCollapsed) ...[
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: Text(
                          widget.item.label,
                          style: TextStyle(
                            color: foregroundColor,
                            fontSize: 14.0,
                            fontWeight: .w400,
                          ),
                          maxLines: 1,
                          overflow: .ellipsis,
                        ),
                      ),
                      chevronIcon,
                    ],
                  ],
                ),
              );

              return customTheme.buildPressEffect(
                isPressed: isPressed,
                child: folderBox,
              );
            },
          ),
        );
      },
    );

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        folderHeader,
        SizeTransition(
          sizeFactor: _expandAnimation,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: widget.item.children!.map((JustSidebarItem childItem) {
              // Recursive build with incremented depth
              return _JustSidebarItemWidget(
                item: childItem,
                depth: widget.depth + 1,
                isCollapsed: widget.isCollapsed,
                activeColor: widget.activeColor,
                inactiveColor: widget.inactiveColor,
                themeStyle: widget.themeStyle,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Stateful/Stateless Indentation Helper widget
class _JustSidebarItemWidget extends StatelessWidget {
  final JustSidebarItem item;
  final int depth;
  final bool isCollapsed;
  final Color activeColor;
  final Color inactiveColor;
  final JustSidebarStyle? themeStyle;

  const _JustSidebarItemWidget({
    required this.item,
    required this.depth,
    required this.isCollapsed,
    required this.activeColor,
    required this.inactiveColor,
    this.themeStyle,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context, aspect: .colors).theme;
    final colors = customTheme.colors;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final radius = JustThemeProvider.of(context).theme.radius;

    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final isRtl = Directionality.of(context) == .rtl;
    final double indent = depth * 16.0;

    final itemPadding =
        themeStyle?.itemPadding ??
        .symmetric(horizontal: spacing.lg, vertical: spacing.sm);
    final resolvedItemPadding = itemPadding.resolve(Directionality.of(context));
    final itemRadius = themeStyle?.itemBorderRadius ?? .all(radius.md);

    Widget content = JustPressable(
      enabled: item.enabled,
      onTap: item.onTap,
      builder: (context, isHovered, isPressed, isFocused, focusNode) {
        final double itemOpacity = item.enabled ? 1.0 : 0.5;

        final Color itemBg = isPressed
            ? activeColor.withValues(alpha: 0.12)
            : (isHovered
                  ? activeColor.withValues(alpha: 0.05)
                  : const Color(0x00000000));

        final isNeobrutalism = true;
        final Color foregroundColor = isNeobrutalism
            ? colors.textPrimary
            : (isHovered || isPressed ? activeColor : inactiveColor);

        final Border? itemBorder = isNeobrutalism
            ? .all(
                color: isHovered ? colors.textPrimary : const Color(0x00000000),
                width: 1.5,
              )
            : null;

        return Opacity(
          opacity: itemOpacity,
          child: Container(
            decoration: BoxDecoration(
              color: itemBg,
              borderRadius: itemRadius,
              border: itemBorder,
            ),
            padding: resolvedItemPadding.copyWith(
              left: !isRtl
                  ? resolvedItemPadding.left + indent
                  : resolvedItemPadding.left,
              right: isRtl
                  ? resolvedItemPadding.right + indent
                  : resolvedItemPadding.right,
            ),
            child: Row(
              children: [
                IconTheme.merge(
                  data: IconThemeData(size: 20.0, color: foregroundColor),
                  child: item.icon,
                ),
                if (!isCollapsed) ...[
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      item.label,
                      style: typography.bodyMd.copyWith(color: foregroundColor),
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                  ),
                  if (item.badge != null) ...[
                    SizedBox(width: spacing.sm),
                    item.badge!,
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );

    if (isCollapsed && !hasChildren) {
      content = JustTooltipOverlay(message: item.label, child: content);
    }

    if (hasChildren) {
      return _JustSidebarFolder(
        item: item,
        depth: depth,
        isCollapsed: isCollapsed,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        themeStyle: themeStyle,
        itemWidget: content,
      );
    }

    return content;
  }
}
