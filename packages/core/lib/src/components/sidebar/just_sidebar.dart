import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Icons;
import 'package:just_ui_core/src/theme/preset_tokens.dart';
import 'package:just_ui_core/src/theme/theme_data.dart';

import 'package:just_ui_tokens/just_ui_tokens.dart'
    show JustBreakpoints, JustColorScheme, JustMotionProfile;

import '../../theme/theme_data_material.dart';
import '../../theme/theme_provider.dart';
import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import '../shared/_shared_tooltip_overlay.dart';
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
class const JustSidebar({
  super.key,

  /// The list of sidebar navigation items.
  required final List<JustSidebarItem> items,

  /// Logo or brand widget displayed at the top of the sidebar.
  final Widget? header,

  /// User profile or actions widget displayed at the bottom of the sidebar.
  final Widget? footer,

  /// The expanded width of the sidebar (defaults to 260px).
  final double width = 260.0,

  /// The collapsed width of the sidebar (defaults to 68px).
  final double collapsedWidth = 68.0,

  /// Whether the sidebar can be collapsed.
  final bool isCollapsible = true,

  /// Whether the sidebar is currently collapsed.
  final bool isCollapsed = false,

  /// Callback executed when collapse state changes.
  final ValueChanged<bool>? onCollapsedChanged,

  /// The active item index in the flattened top-level items.
  final int selectedIndex = 0,

  /// Callback executed when a top-level menu item is selected.
  final ValueChanged<int>? onItemSelected,

  /// The layout variant (default_, floating, inset).
  final JustSidebarVariant variant = .default_,

  /// Custom style overrides.
  final JustSidebarStyle? style,

  /// Optional accessible label for the sidebar navigation container.
  final String? semanticsLabel,

  /// Whether the sidebar automatically collapses on viewports at or below
  /// [JustBreakpoints.md].
  final bool autoCollapse = true,
}) extends StatefulWidget {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final JustMotionProfile animations = JustThemeProvider.of(
      context,
      aspect: .animations,
    ).theme.animations.resolve(context);
    _collapseController.duration = animations.normal;
  }

  @override
  void didUpdateWidget(covariant JustSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      final double target = widget.isCollapsed ? 0.0 : 1.0;
      if (_collapseController.duration == Duration.zero) {
        _collapseController.value = target;
      } else {
        _collapseController.animateTo(target);
      }
    }
  }

  @override
  void dispose() {
    _collapseController.dispose();
    super.dispose();
  }

  JustSidebarStyle? _resolveThemeStyle(JustSidebarTheme? sidebarTheme) {
    if (sidebarTheme == null) return null;
    switch (widget.variant) {
      case .default_:
        return sidebarTheme.defaultStyle;
      case .floating:
        return sidebarTheme.floatingStyle;
      case .inset:
        return sidebarTheme.insetStyle;
    }
  }

  List<Widget> _buildItemWidgets({
    required bool isCollapsed,
    required Color activeColor,
    required Color inactiveColor,
    required JustSidebarStyle? themeStyle,
    required double itemSpacing,
  }) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < widget.items.length; i++) {
      if (itemSpacing > 0.0 && i > 0) {
        children.add(SizedBox(height: itemSpacing));
      }
      final JustSidebarItem item = widget.items[i];
      children.add(
        _JustSidebarItemWidget(
          item: item,
          depth: 0,
          isCollapsed: isCollapsed,
          isSelected: widget.selectedIndex == i,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          variant: widget.variant,
          style: widget.style,
          themeStyle: themeStyle,
          itemSpacing: itemSpacing,
          onTap: () {
            item.onTap?.call();
            widget.onItemSelected?.call(i);
          },
        ),
      );
    }
    return children;
  }

  Widget _buildPanel({
    required double currentWidth,
    required bool hasBoundedHeight,
    required Widget itemsColumn,
    required BoxDecoration decoration,
    required EdgeInsetsGeometry finalPadding,
    required JustSpacingScheme spacing,
  }) {
    return Container(
      width: currentWidth,
      height: hasBoundedHeight ? .infinity : null,
      decoration: decoration,
      padding: finalPadding,
      child: Column(
        mainAxisSize: hasBoundedHeight ? .max : .min,
        crossAxisAlignment: .stretch,
        children: <Widget>[
          if (widget.header != null) ...<Widget>[
            ClipRect(
              child: Align(
                alignment: .centerLeft,
                heightFactor: 1.0,
                child: SizedBox(height: 48.0, child: widget.header!),
              ),
            ),
            SizedBox(height: spacing.lg),
          ],
          if (hasBoundedHeight)
            Expanded(child: SingleChildScrollView(child: itemsColumn))
          else
            itemsColumn,
          if (widget.footer != null) ...<Widget>[
            SizedBox(height: spacing.lg),
            ClipRect(
              child: Align(alignment: .centerLeft, child: widget.footer!),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
    final JustSidebarTheme? sidebarTheme = context
        .justThemeExtension<JustSidebarTheme>();
    final JustColorScheme colors = JustThemeProvider.of(
      context,
      aspect: .colors,
    ).theme.colors;
    final JustSpacingScheme spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final JustRadiusScheme radius = customTheme.radius;
    final JustShadowScheme shadows = customTheme.shadows;
    final JustPresetTokens presetTokens = customTheme.presetTokens;
    final JustSidebarStyle? themeStyle = _resolveThemeStyle(sidebarTheme);

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isAutoCollapsed =
        widget.autoCollapse && screenWidth <= JustBreakpoints.md;
    final bool activeCollapsed = widget.isCollapsed || isAutoCollapsed;

    final Color containerBg =
        widget.style?.backgroundColor ??
        themeStyle?.backgroundColor ??
        colors.elevated;
    final Color activeColor =
        widget.style?.activeColor ??
        themeStyle?.activeColor ??
        colors.borderFocus;
    final Color inactiveColor =
        widget.style?.inactiveColor ??
        themeStyle?.inactiveColor ??
        colors.textSecondary;
    final Color resolvedBorderColor =
        widget.style?.borderColor ??
        themeStyle?.borderColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderDefault);
    final double itemSpacing =
        widget.style?.itemSpacing ?? themeStyle?.itemSpacing ?? 0.0;

    final EdgeInsetsGeometry defaultPadding = widget.variant == .floating
        ? .all(spacing.md)
        : (widget.variant == .inset
              ? .symmetric(horizontal: spacing.md, vertical: spacing.lg)
              : .symmetric(vertical: spacing.lg));
    final EdgeInsetsGeometry finalPadding =
        widget.style?.padding ?? themeStyle?.padding ?? defaultPadding;

    final BorderRadius borderRadius =
        widget.style?.borderRadius ??
        themeStyle?.borderRadius ??
        (presetTokens.showsDefaultBorder
            ? .zero
            : (widget.variant == .floating
                  ? .all(radius.xl)
                  : (widget.variant == .inset ? .all(radius.lg) : .zero)));

    final Border borderStyle = widget.variant == .default_
        ? Border(
            right: BorderSide(
              color: resolvedBorderColor,
              width: presetTokens.borderWidth,
            ),
          )
        : .all(color: resolvedBorderColor, width: presetTokens.borderWidth);

    final BoxDecoration panelDecoration = BoxDecoration(
      color: containerBg,
      borderRadius: borderRadius,
      border: borderStyle,
      boxShadow: widget.variant != .default_
          ? (presetTokens.showsDefaultBorder
                ? customTheme.resolveShadows(shadows.lg, isPressed: false)
                : shadows.md)
          : null,
    );
    final Widget itemsColumn = Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: _buildItemWidgets(
        isCollapsed: activeCollapsed,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        themeStyle: themeStyle,
        itemSpacing: itemSpacing,
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticsLabel,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return AnimatedBuilder(
            animation: _collapseAnimation,
            builder: (BuildContext context, Widget? child) {
              final double currentWidth = isAutoCollapsed
                  ? widget.collapsedWidth
                  : widget.collapsedWidth +
                        (widget.width - widget.collapsedWidth) *
                            _collapseAnimation.value;

              return _buildPanel(
                currentWidth: currentWidth,
                hasBoundedHeight: constraints.hasBoundedHeight,
                itemsColumn: itemsColumn,
                decoration: panelDecoration,
                finalPadding: finalPadding,
                spacing: spacing,
              );
            },
          );
        },
      ),
    );
  }
}

class const _JustSidebarFolder({
  required final JustSidebarItem item,
  required final int depth,
  required final bool isCollapsed,
  required final Color activeColor,
  required final Color inactiveColor,
  required final JustSidebarVariant variant,
  final JustSidebarStyle? style,
  final JustSidebarStyle? themeStyle,
  final double itemSpacing = 0.0,
}) extends StatefulWidget {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final JustMotionProfile animations = JustThemeProvider.of(
      context,
      aspect: .animations,
    ).theme.animations.resolve(context);
    _expandController.duration = animations.normal;
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_expandController.duration == Duration.zero) {
      _expandController.value = _isExpanded ? 1.0 : 0.0;
    } else if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  Widget _buildFolderBox({
    required JustColorScheme colors,
    required JustSpacingScheme spacing,
    required JustPresetTokens presetTokens,
    required EdgeInsets itemPadding,
    required BorderRadius itemRadius,
    required TextStyle labelStyle,
    required bool isRtl,
    required Widget chevronIcon,
    required JustInteractionState state,
  }) {
    final Color itemBg = state.isPressed
        ? widget.activeColor.withValues(alpha: 0.12)
        : (state.isHovered
              ? widget.activeColor.withValues(alpha: 0.05)
              : const Color(0x00000000));
    final Color foregroundColor = presetTokens.showsDefaultBorder
        ? colors.textPrimary
        : (state.isHovered || state.isPressed
              ? widget.activeColor
              : widget.inactiveColor);
    final Border? itemBorder = presetTokens.showsDefaultBorder
        ? .all(
            color: state.isHovered
                ? colors.textPrimary
                : const Color(0x00000000),
            width: 1.5,
          )
        : null;
    final EdgeInsets effectivePadding = widget.isCollapsed
        ? .only(top: itemPadding.top, bottom: itemPadding.bottom)
        : itemPadding.copyWith(
            left: !isRtl
                ? itemPadding.left + (widget.depth * 16.0)
                : itemPadding.left,
            right: isRtl
                ? itemPadding.right + (widget.depth * 16.0)
                : itemPadding.right,
          );

    return Opacity(
      opacity: widget.item.enabled ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: itemRadius,
          border: itemBorder,
        ),
        padding: effectivePadding,
        child: Row(
          mainAxisAlignment: widget.isCollapsed ? .center : .start,
          children: <Widget>[
            IconTheme.merge(
              data: IconThemeData(size: 20.0, color: foregroundColor),
              child: widget.item.icon,
            ),
            if (!widget.isCollapsed) ...<Widget>[
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: labelStyle.copyWith(color: foregroundColor),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ),
              chevronIcon,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFolderHeader({
    required JustColorScheme colors,
    required JustSpacingScheme spacing,
    required JustTypographyScheme typography,
    required JustPresetTokens presetTokens,
    required JustMotionProfile animations,
    required EdgeInsets itemPadding,
    required BorderRadius itemRadius,
    required bool isRtl,
    required Widget chevronIcon,
  }) {
    final TextStyle labelStyle =
        widget.style?.textStyle ??
        widget.themeStyle?.textStyle ??
        typography.bodyMd;

    return JustPressable(
      enabled: widget.item.enabled,
      onTap: _toggleExpand,
      builder: (BuildContext context, JustInteractionState state) {
        final Widget folderBox = _buildFolderBox(
          colors: colors,
          spacing: spacing,
          presetTokens: presetTokens,
          itemPadding: itemPadding,
          itemRadius: itemRadius,
          labelStyle: labelStyle,
          isRtl: isRtl,
          chevronIcon: chevronIcon,
          state: state,
        );

        return Semantics(
          button: true,
          expanded: _isExpanded,
          enabled: widget.item.enabled,
          label: widget.item.label,
          excludeSemantics: true,
          child: FocusIndicator(
            isFocused: state.isFocusVisible,
            borderRadius: itemRadius,
            child: presetTokens.buildPressEffect(
              isPressed: state.isPressed,
              animations: animations,
              child: folderBox,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
    final JustColorScheme colors = customTheme.colors;
    final JustSpacingScheme spacing = customTheme.spacing;
    final JustTypographyScheme typography = customTheme.typography;
    final JustRadiusScheme radius = customTheme.radius;
    final JustPresetTokens presetTokens = customTheme.presetTokens;
    final JustMotionProfile animations = customTheme.animations.resolve(
      context,
    );
    final bool isRtl = Directionality.of(context) == .rtl;

    final EdgeInsets defaultItemPadding = widget.variant == .inset
        ? .symmetric(horizontal: spacing.md, vertical: spacing.sm)
        : .symmetric(horizontal: spacing.lg, vertical: spacing.sm);
    final EdgeInsets itemPadding =
        widget.style?.itemPadding ??
        widget.themeStyle?.itemPadding ??
        defaultItemPadding;
    final BorderRadius itemRadius =
        widget.style?.itemBorderRadius ??
        widget.themeStyle?.itemBorderRadius ??
        presetTokens.resolveBorderRadius(radius);

    // Chevron pointing to the reading side when collapsed, down when
    // expanded. Flutter mirrors chevron_right in RTL itself, so RTL turns
    // the other way to reach down.
    final Widget chevronIcon = RotationTransition(
      turns: _expandAnimation.drive(
        Tween<double>(begin: 0.0, end: isRtl ? -0.25 : 0.25),
      ),
      child: Icon(Icons.chevron_right, size: 16.0, color: widget.inactiveColor),
    );

    final Widget folderHeader = _buildFolderHeader(
      colors: colors,
      spacing: spacing,
      typography: typography,
      presetTokens: presetTokens,
      animations: animations,
      itemPadding: itemPadding,
      itemRadius: itemRadius,
      isRtl: isRtl,
      chevronIcon: chevronIcon,
    );

    final List<JustSidebarItem> subItems = widget.item.children!;
    final List<Widget> subChildren = <Widget>[];
    for (int i = 0; i < subItems.length; i++) {
      if (widget.itemSpacing > 0.0) {
        subChildren.add(SizedBox(height: widget.itemSpacing));
      }
      final JustSidebarItem childItem = subItems[i];
      subChildren.add(
        _JustSidebarItemWidget(
          item: childItem,
          depth: widget.depth + 1,
          isCollapsed: widget.isCollapsed,
          isSelected: false,
          activeColor: widget.activeColor,
          inactiveColor: widget.inactiveColor,
          variant: widget.variant,
          style: widget.style,
          themeStyle: widget.themeStyle,
          itemSpacing: widget.itemSpacing,
          onTap: childItem.onTap,
        ),
      );
    }

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: <Widget>[
        folderHeader,
        SizeTransition(
          sizeFactor: _expandAnimation,
          alignment: .topCenter,
          child: ExcludeFocus(
            excluding: !_isExpanded,
            child: ExcludeSemantics(
              excluding: !_isExpanded,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: subChildren,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class const _JustSidebarItemWidget({
  required final JustSidebarItem item,
  required final int depth,
  required final bool isCollapsed,
  required final bool isSelected,
  required final Color activeColor,
  required final Color inactiveColor,
  required final JustSidebarVariant variant,
  final VoidCallback? onTap,
  final JustSidebarStyle? style,
  final JustSidebarStyle? themeStyle,
  final double itemSpacing = 0.0,
}) extends StatelessWidget {
  BoxDecoration _buildLeafDecoration({
    required JustColorScheme colors,
    required JustPresetTokens presetTokens,
    required BorderRadius itemRadius,
    required Color? customSelectedBg,
    required bool isRtl,
    required JustInteractionState state,
  }) {
    final Color itemBg = isSelected
        ? (customSelectedBg ??
              (presetTokens.showsDefaultBorder
                  ? activeColor.withValues(alpha: 0.35)
                  : (variant == .default_
                        ? colors.card
                        : activeColor.withValues(alpha: 0.08))))
        : (state.isPressed
              ? activeColor.withValues(alpha: 0.12)
              : (state.isHovered
                    ? activeColor.withValues(alpha: 0.05)
                    : const Color(0x00000000)));

    final Border? itemBorder = presetTokens.showsDefaultBorder
        ? .all(
            color: (isSelected || state.isHovered)
                ? colors.textPrimary
                : const Color(0x00000000),
            width: 1.5,
          )
        : (isSelected && variant == .default_
              ? Border(
                  left: !isRtl
                      ? BorderSide(color: activeColor, width: 3.0)
                      : .none,
                  right: isRtl
                      ? BorderSide(color: activeColor, width: 3.0)
                      : .none,
                )
              : null);

    return BoxDecoration(
      color: itemBg,
      borderRadius: itemRadius,
      border: itemBorder,
    );
  }

  Widget _buildLeafRow({
    required JustColorScheme colors,
    required JustSpacingScheme spacing,
    required JustPresetTokens presetTokens,
    required EdgeInsets resolvedItemPadding,
    required BorderRadius itemRadius,
    required TextStyle textStyle,
    required TextStyle activeTextStyle,
    required Color? customSelectedBg,
    required Color? customSelectedFg,
    required bool isRtl,
    required double indent,
    required JustInteractionState state,
  }) {
    final Color foregroundColor = isSelected && customSelectedFg != null
        ? customSelectedFg
        : (presetTokens.showsDefaultBorder
              ? colors.textPrimary
              : (isSelected
                    ? activeColor
                    : (state.isHovered || state.isPressed
                          ? activeColor
                          : inactiveColor)));
    final TextStyle resolvedTextStyle = isSelected
        ? activeTextStyle
        : textStyle;
    final EdgeInsets effectivePadding = isCollapsed
        ? .only(
            top: resolvedItemPadding.top,
            bottom: resolvedItemPadding.bottom,
          )
        : resolvedItemPadding.copyWith(
            left: !isRtl
                ? resolvedItemPadding.left + indent
                : resolvedItemPadding.left,
            right: isRtl
                ? resolvedItemPadding.right + indent
                : resolvedItemPadding.right,
          );

    return Opacity(
      opacity: item.enabled ? 1.0 : 0.5,
      child: Container(
        decoration: _buildLeafDecoration(
          colors: colors,
          presetTokens: presetTokens,
          itemRadius: itemRadius,
          customSelectedBg: customSelectedBg,
          isRtl: isRtl,
          state: state,
        ),
        padding: effectivePadding,
        child: Row(
          mainAxisAlignment: isCollapsed ? .center : .start,
          children: <Widget>[
            IconTheme.merge(
              data: IconThemeData(size: 20.0, color: foregroundColor),
              child: item.icon,
            ),
            if (!isCollapsed) ...<Widget>[
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  item.label,
                  style: resolvedTextStyle.copyWith(color: foregroundColor),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ),
              if (item.badge != null) ...<Widget>[
                SizedBox(width: spacing.sm),
                item.badge!,
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChildren = item.children != null && item.children!.isNotEmpty;
    if (hasChildren) {
      return _JustSidebarFolder(
        item: item,
        depth: depth,
        isCollapsed: isCollapsed,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        variant: variant,
        style: style,
        themeStyle: themeStyle,
        itemSpacing: itemSpacing,
      );
    }

    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
    final JustColorScheme colors = customTheme.colors;
    final JustSpacingScheme spacing = customTheme.spacing;
    final JustTypographyScheme typography = customTheme.typography;
    final JustRadiusScheme radius = customTheme.radius;
    final JustPresetTokens presetTokens = customTheme.presetTokens;
    final JustMotionProfile animations = customTheme.animations.resolve(
      context,
    );

    final bool isRtl = Directionality.of(context) == .rtl;
    final double indent = depth * 16.0;

    final EdgeInsetsGeometry defaultItemPadding = variant == .inset
        ? .symmetric(horizontal: spacing.md, vertical: spacing.sm)
        : .symmetric(horizontal: spacing.lg, vertical: spacing.sm);
    final EdgeInsets resolvedItemPadding =
        (style?.itemPadding ?? themeStyle?.itemPadding ?? defaultItemPadding)
            .resolve(Directionality.of(context));
    final BorderRadius itemRadius =
        style?.itemBorderRadius ??
        themeStyle?.itemBorderRadius ??
        presetTokens.resolveBorderRadius(radius);

    final TextStyle textStyle =
        style?.textStyle ?? themeStyle?.textStyle ?? typography.bodyMd;
    final TextStyle activeTextStyle =
        style?.activeTextStyle ??
        themeStyle?.activeTextStyle ??
        typography.bodyMd.copyWith(fontWeight: .w600);
    final Color? customSelectedBg =
        style?.selectedBackgroundColor ?? themeStyle?.selectedBackgroundColor;
    final Color? customSelectedFg =
        style?.selectedForegroundColor ?? themeStyle?.selectedForegroundColor;

    Widget content = JustPressable(
      enabled: item.enabled,
      onTap: onTap,
      builder: (BuildContext context, JustInteractionState state) {
        final Widget itemRow = _buildLeafRow(
          colors: colors,
          spacing: spacing,
          presetTokens: presetTokens,
          resolvedItemPadding: resolvedItemPadding,
          itemRadius: itemRadius,
          textStyle: textStyle,
          activeTextStyle: activeTextStyle,
          customSelectedBg: customSelectedBg,
          customSelectedFg: customSelectedFg,
          isRtl: isRtl,
          indent: indent,
          state: state,
        );

        return Semantics(
          button: true,
          selected: isSelected,
          enabled: item.enabled,
          label: item.label,
          excludeSemantics: true,
          child: FocusIndicator(
            isFocused: state.isFocusVisible,
            borderRadius: itemRadius,
            child: presetTokens.buildPressEffect(
              isPressed: state.isPressed,
              animations: animations,
              child: itemRow,
            ),
          ),
        );
      },
    );

    if (isCollapsed) {
      content = JustTooltipOverlay(message: item.label, child: content);
    }

    return content;
  }
}
