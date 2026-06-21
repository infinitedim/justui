import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:just_ui_tokens/just_ui_tokens.dart';
import '../../theme/theme_provider.dart';
import '../shared/just_pressable.dart';
import 'just_bottom_nav_style.dart';
import 'just_bottom_nav_theme.dart';
import 'just_bottom_nav_variants.dart';

/// Represents a single destination item in the bottom navigation bar.
class JustBottomNavItem {
  /// The label text of the destination.
  final String label;

  /// The default icon widget.
  final Widget icon;

  /// An optional active icon displayed when this item is selected.
  final Widget? activeIcon;

  /// An optional notification badge displayed on top of the icon.
  final Widget? badge;

  /// Creates a [JustBottomNavItem] destination.
  const JustBottomNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badge,
  });
}

/// A premium, Material-free bottom navigation bar widget supporting fixed, shifting,
/// and floating visual layout variants.
class JustBottomNav extends StatefulWidget {
  /// The list of items to display (must be between 3 and 5 items).
  final List<JustBottomNavItem> items;

  /// The active index.
  final int selectedIndex;

  /// Callback triggered when an item is selected.
  final ValueChanged<int>? onItemSelected;

  /// The visual structure variant (fixed, shifting, floating).
  final JustBottomNavVariant variant;

  /// Whether to display text labels under the icons (defaults to true).
  final bool showLabels;

  /// Whether to trigger a Selection Click haptic feedback on tab changes (defaults to true).
  final bool hapticFeedback;

  /// Custom style overrides.
  final JustBottomNavStyle? style;

  /// Creates a [JustBottomNav] component.
  const JustBottomNav({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onItemSelected,
    this.variant = .fixed,
    this.showLabels = true,
    this.hapticFeedback = true,
    this.style,
  }) : assert(
         items.length >= 3 && items.length <= 5,
         'JustBottomNav must have between 3 and 5 items.',
       );

  @override
  State<JustBottomNav> createState() => _JustBottomNavState();
}

class _JustBottomNavState extends State<JustBottomNav> {
  void _handleItemTap(int index) {
    if (index == widget.selectedIndex) return;
    if (widget.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    widget.onItemSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context).theme;
    final navTheme = Theme.of(context).extension<JustBottomNavTheme>();
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final radius = customTheme.radius;
    final animations = customTheme.animations;

    // Resolve theme-specific styles
    JustBottomNavStyle? themeStyle;
    if (navTheme != null) {
      switch (widget.variant) {
        case .fixed:
          themeStyle = navTheme.fixedStyle;
          break;
        case .shifting:
          themeStyle = navTheme.shiftingStyle;
          break;
        case .floating:
          themeStyle = navTheme.floatingStyle;
          break;
      }
    }

    final activeColor =
        widget.style?.activeColor ??
        themeStyle?.activeColor ??
        colors.borderFocus;
    final inactiveColor =
        widget.style?.inactiveColor ??
        themeStyle?.inactiveColor ??
        colors.textSecondary;
    final double iconSize =
        widget.style?.iconSize ?? themeStyle?.iconSize ?? 24.0;
    final double defaultHeight = widget.variant == .floating ? 64.0 : 56.0;
    final double height =
        widget.style?.height ?? themeStyle?.height ?? defaultHeight;

    final containerBg =
        widget.style?.backgroundColor ??
        themeStyle?.backgroundColor ??
        colors.elevated;
    final containerBorderRadius =
        widget.style?.borderRadius ??
        themeStyle?.borderRadius ??
        (widget.variant == .floating ? .all(radius.full) : .zero);

    final finalTextStyle =
        widget.style?.textStyle ??
        themeStyle?.textStyle ??
        typography.caption.copyWith(fontWeight: .w500);

    final resolvedDuration =
        widget.style?.animationDuration ??
        themeStyle?.animationDuration ??
        animations.fast;
    final resolvedCurve =
        widget.style?.animationCurve ??
        themeStyle?.animationCurve ??
        animations.defaultCurve;

    // Build items
    final List<Widget> navItems = [];
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final isSelected = widget.selectedIndex == i;

      final Widget iconContent = Stack(
        clipBehavior: .none,
        alignment: .center,
        children: [
          IconTheme.merge(
            data: IconThemeData(
              size: iconSize,
              color: isSelected ? activeColor : inactiveColor,
            ),
            child: item.activeIcon != null
                ? Stack(
                    alignment: .center,
                    children: [
                      AnimatedOpacity(
                        opacity: isSelected ? 0.0 : 1.0,
                        duration: resolvedDuration,
                        child: AnimatedScale(
                          scale: isSelected ? 0.8 : 1.0,
                          duration: resolvedDuration,
                          child: item.icon,
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.0,
                        duration: resolvedDuration,
                        child: AnimatedScale(
                          scale: isSelected ? 1.0 : 0.8,
                          duration: resolvedDuration,
                          child: item.activeIcon!,
                        ),
                      ),
                    ],
                  )
                : item.icon,
          ),
          if (item.badge != null)
            Positioned(top: -4, right: -4, child: item.badge!),
        ],
      );

      final Widget labelContent = AnimatedDefaultTextStyle(
        style: finalTextStyle.copyWith(
          color: isSelected ? activeColor : inactiveColor,
        ),
        duration: resolvedDuration,
        curve: resolvedCurve,
        child: Text(item.label, maxLines: 1, overflow: .ellipsis),
      );

      final Widget itemWidget = JustPressable(
        onTap: () => _handleItemTap(i),
        builder: (context, isHovered, isPressed, isFocused, focusNode) {
          Widget content;
          if (widget.variant == .shifting) {
            content = Column(
              mainAxisAlignment: .center,
              children: [
                iconContent,
                ClipRect(
                  child: AnimatedAlign(
                    alignment: .center,
                    heightFactor: isSelected ? 1.0 : 0.0,
                    duration: resolvedDuration,
                    curve: resolvedCurve,
                    child: Padding(
                      padding: .only(top: spacing.xs),
                      child: labelContent,
                    ),
                  ),
                ),
              ],
            );
          } else {
            content = Column(
              mainAxisAlignment: .center,
              children: [
                iconContent,
                if (widget.showLabels) ...[
                  SizedBox(width: spacing.xs),
                  Padding(
                    padding: .only(top: spacing.xs),
                    child: labelContent,
                  ),
                ],
              ],
            );
          }

          return Semantics(
            label: item.label,
            selected: isSelected,
            button: true,
            child: customTheme.buildPressEffect(
              isPressed: isPressed,
              child: Container(
                color: const Color(0x00000000), // Transparent to allow full tap detection
                child: content,
              ),
            ),
          );
        },
      );

      if (widget.variant == .shifting) {
        navItems.add(
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
            duration: resolvedDuration,
            curve: resolvedCurve,
            child: itemWidget,
            builder: (context, value, child) {
              final flex = 1.0 + value * 0.5;
              return Expanded(flex: (flex * 1000).toInt(), child: child!);
            },
          ),
        );
      } else {
        navItems.add(Expanded(child: itemWidget));
      }
    }

    final isNeobrutalism = customTheme.preset == JustThemePreset.neobrutalism;
    final Border borderStyle = isNeobrutalism
        ? (widget.variant == .floating
            ? .all(color: colors.textPrimary, width: 2.5)
            : Border(top: BorderSide(color: colors.textPrimary, width: 2.5)))
        : (widget.variant == .floating
            ? .all(color: colors.borderDefault, width: 1.0)
            : Border(top: BorderSide(color: colors.borderDefault, width: 1.0)));

    final Widget contentBar = Container(
      height: height,
      padding: widget.style?.padding ?? themeStyle?.padding,
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: containerBorderRadius,
        border: borderStyle,
        boxShadow: widget.variant == .floating ? customTheme.shadows.md : null,
      ),
      child: Row(
        mainAxisAlignment: .spaceEvenly,
        crossAxisAlignment: .stretch,
        children: navItems,
      ),
    );

    // Apply safe area depending on layout format
    if (widget.variant == .floating) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: .symmetric(horizontal: spacing.lg, vertical: spacing.sm),
          child: contentBar,
        ),
      );
    } else {
      return Container(
        color: containerBg,
        child: SafeArea(top: false, child: contentBar),
      );
    }
  }
}
