import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart' show HapticFeedback, LogicalKeyboardKey, KeyDownEvent, KeyEvent;
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import '../../shared/default/_shared_theme_provider.dart';
import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import 'just_accordion_style.dart';
import 'just_accordion_theme.dart';
import 'just_accordion_variants.dart';

/// Data model representing an individual panel in the [JustAccordion].
class JustAccordionItem {
  /// The header title text.
  final String title;

  /// The widget content displayed when the panel is expanded.
  final Widget content;

  /// Optional subtitle text displayed below the title.
  final Widget? subtitle;

  /// Optional leading widget (such as an icon).
  final Widget? leading;

  /// Whether this item can be interacted with.
  final bool enabled;

  /// Creates a [JustAccordionItem].
  const JustAccordionItem({
    required this.title,
    required this.content,
    this.subtitle,
    this.leading,
    this.enabled = true,
  });
}

/// A highly customizable, accessible accordion component supporting single and multi-expansion.
class JustAccordion extends StatefulWidget {
  /// The list of accordion items to display.
  final List<JustAccordionItem> items;

  /// If false, only one item can be expanded at a time (default).
  /// If true, multiple items can be expanded concurrently.
  final bool allowMultiple;

  /// The indices of items that should be expanded initially.
  final Set<int>? initialExpanded;

  /// Callback when the set of expanded item indices changes.
  final ValueChanged<Set<int>>? onChanged;

  /// The visual layout variant.
  final JustAccordionVariant variant;

  /// Per-instance style overrides.
  final JustAccordionStyle? style;

  /// Creates a [JustAccordion] component.
  const JustAccordion({
    super.key,
    required this.items,
    this.allowMultiple = false,
    this.initialExpanded,
    this.onChanged,
    this.variant = JustAccordionVariant.default_,
    this.style,
  });

  @override
  State<JustAccordion> createState() => _JustAccordionState();
}

class _JustAccordionState extends State<JustAccordion> {
  late Set<int> _expandedIndices;

  @override
  void initState() {
    super.initState();
    _expandedIndices = Set<int>.from(widget.initialExpanded ?? {});
    if (!widget.allowMultiple && _expandedIndices.length > 1) {
      _expandedIndices = {_expandedIndices.first};
    }
  }

  void _toggleItem(int index) {
    if (!widget.items[index].enabled) return;

    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        if (!widget.allowMultiple) {
          _expandedIndices.clear();
        }
        _expandedIndices.add(index);
      }
    });

    if (widget.onChanged != null) {
      widget.onChanged!(Set<int>.from(_expandedIndices));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context).theme;
    final accordionTheme = Theme.of(context).extension<JustAccordionTheme>();
    final themeStyle = accordionTheme?.style;

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final spacing = JustThemeProvider.of(context, aspect: .spacing).theme.spacing;
    final radius = customTheme.radius;
    final shadows = customTheme.shadows;
    final typography = JustThemeProvider.of(context, aspect: .typography).theme.typography;
    final isNeobrutalism = true;

    final resolvedGap = widget.style?.gap ?? themeStyle?.gap ?? 8.0;
    final BorderRadius defaultBorderRadius = isNeobrutalism ? BorderRadius.zero : .all(radius.md);
    final finalRadius = widget.style?.borderRadius ?? themeStyle?.borderRadius ?? defaultBorderRadius;

    final borderColor = widget.style?.borderColor ??
        themeStyle?.borderColor ??
        (isNeobrutalism ? colors.textPrimary : colors.borderDefault);

    if (widget.variant == JustAccordionVariant.contained) {
      // Contained Variant: single outer container
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: isNeobrutalism ? 2.5 : 1.0,
          ),
          borderRadius: finalRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            final isLast = index == widget.items.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _JustAccordionItemWidget(
                  item: item,
                  isExpanded: _expandedIndices.contains(index),
                  onToggle: () => _toggleItem(index),
                  variant: widget.variant,
                  style: widget.style,
                  themeStyle: themeStyle,
                  isNeobrutalism: isNeobrutalism,
                  colors: colors,
                  spacing: spacing,
                  radius: radius,
                  shadows: shadows,
                  typography: typography,
                  customTheme: customTheme,
                  index: index,
                  totalItems: widget.items.length,
                ),
                if (!isLast)
                  Container(
                    height: isNeobrutalism ? 2.5 : 1.0,
                    color: borderColor,
                  ),
              ],
            );
          }),
        ),
      );
    }

    // Default or Flush variants
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isLast = index == widget.items.length - 1;

        Widget child = _JustAccordionItemWidget(
          item: item,
          isExpanded: _expandedIndices.contains(index),
          onToggle: () => _toggleItem(index),
          variant: widget.variant,
          style: widget.style,
          themeStyle: themeStyle,
          isNeobrutalism: isNeobrutalism,
          colors: colors,
          spacing: spacing,
          radius: radius,
          shadows: shadows,
          typography: typography,
          customTheme: customTheme,
          index: index,
          totalItems: widget.items.length,
        );

        if (widget.variant == JustAccordionVariant.default_) {
          // Add gap between items
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0.0 : resolvedGap),
            child: child,
          );
        } else {
          // Flush variant: separator line between items, no gap
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              if (!isLast)
                Container(
                  height: isNeobrutalism ? 2.5 : 1.0,
                  color: borderColor,
                ),
            ],
          );
        }
      }),
    );
  }
}

class _JustAccordionItemWidget extends StatefulWidget {
  final JustAccordionItem item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final JustAccordionVariant variant;
  final JustAccordionStyle? style;
  final JustAccordionStyle? themeStyle;
  final bool isNeobrutalism;
  final JustColorScheme colors;
  final JustSpacingScheme spacing;
  final JustRadiusScheme radius;
  final JustShadowScheme shadows;
  final JustTypographyScheme typography;
  final JustThemeData customTheme;
  final int index;
  final int totalItems;

  const _JustAccordionItemWidget({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.variant,
    required this.style,
    required this.themeStyle,
    required this.isNeobrutalism,
    required this.colors,
    required this.spacing,
    required this.radius,
    required this.shadows,
    required this.typography,
    required this.customTheme,
    required this.index,
    required this.totalItems,
  });

  @override
  State<_JustAccordionItemWidget> createState() => _JustAccordionItemWidgetState();
}

class _JustAccordionItemWidgetState extends State<_JustAccordionItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.customTheme.animations.normal,
    );
    _expandAnimation = _controller.drive(
      CurveTween(curve: widget.customTheme.animations.defaultCurve),
    );
    _rotationAnimation = _controller.drive(
      Tween<double>(begin: 0.0, end: 0.5).chain(
        CurveTween(curve: widget.customTheme.animations.defaultCurve),
      ),
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _JustAccordionItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve styling parameters
    final headerBg = widget.style?.headerBackgroundColor ??
        widget.themeStyle?.headerBackgroundColor ??
        const Color(0x00000000);

    final contentBg = widget.style?.contentBackgroundColor ??
        widget.themeStyle?.contentBackgroundColor ??
        const Color(0x00000000);

    final titleColor = widget.style?.titleColor ??
        widget.themeStyle?.titleColor ??
        widget.colors.textPrimary;

    final subtitleColor = widget.style?.subtitleColor ??
        widget.themeStyle?.subtitleColor ??
        widget.colors.textSecondary;

    final iconColor = widget.style?.iconColor ??
        widget.themeStyle?.iconColor ??
        widget.colors.textPrimary;

    final headerPadding = widget.style?.headerPadding ??
        widget.themeStyle?.headerPadding ??
        .symmetric(horizontal: widget.spacing.lg, vertical: widget.spacing.md);

    final contentPadding = widget.style?.contentPadding ??
        widget.themeStyle?.contentPadding ??
        .symmetric(horizontal: widget.spacing.lg, vertical: widget.spacing.md);

    final borderColor = widget.style?.borderColor ??
        widget.themeStyle?.borderColor ??
        (widget.isNeobrutalism ? widget.colors.textPrimary : widget.colors.borderDefault);

    final BorderRadius defaultBorderRadius = widget.isNeobrutalism ? BorderRadius.zero : .all(widget.radius.md);
    final finalRadius = widget.style?.borderRadius ?? widget.themeStyle?.borderRadius ?? defaultBorderRadius;

    Widget header = Row(
      children: [
        if (widget.item.leading != null) ...[
          widget.item.leading!,
          SizedBox(width: widget.spacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item.title,
                style: widget.typography.bodyMd.copyWith(
                  fontWeight: .w600,
                  color: widget.item.enabled
                      ? titleColor
                      : titleColor.withValues(alpha: 0.4),
                ),
              ),
              if (widget.item.subtitle != null) ...[
                SizedBox(height: widget.spacing.xs),
                widget.item.subtitle!,
              ],
            ],
          ),
        ),
        SizedBox(width: widget.spacing.sm),
        RotationTransition(
          turns: _rotationAnimation,
          child: Icon(
            const IconData(0xe5c5, fontFamily: 'MaterialIcons'),
            color: widget.item.enabled
                ? iconColor
                : iconColor.withValues(alpha: 0.4),
            size: 20,
          ),
        ),
      ],
    );

    Widget headerButton = JustPressable(
      enabled: widget.item.enabled,
      onTap: widget.onToggle,
      builder: (context, isHovered, isPressed, isFocused, focusNode) {
        Color resolvedHeaderBg = headerBg;
        if (isHovered && widget.item.enabled) {
          resolvedHeaderBg = widget.colors.borderDefault.withValues(alpha: 0.08);
        }

        Widget innerHeader = Container(
          padding: headerPadding,
          color: resolvedHeaderBg,
          child: header,
        );

        if (widget.isNeobrutalism) {
          innerHeader = widget.customTheme.buildPressEffect(
            isPressed: isPressed,
            child: innerHeader,
          );
        }

        return Focus(
          focusNode: focusNode,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              widget.onToggle();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: FocusIndicator(
            isFocused: isFocused,
            focusColor: widget.colors.borderFocus,
            borderRadius: widget.variant == JustAccordionVariant.contained
                ? (widget.index == 0
                    ? .only(topLeft: finalRadius.topLeft, topRight: finalRadius.topRight)
                    : (widget.index == widget.totalItems - 1
                        ? .only(bottomLeft: finalRadius.bottomLeft, bottomRight: finalRadius.bottomRight)
                        : BorderRadius.zero))
                : finalRadius,
            child: innerHeader,
          ),
        );
      },
    );

    Widget contentArea = SizeTransition(
      sizeFactor: _expandAnimation,
      child: Container(
        padding: contentPadding,
        color: contentBg,
        child: widget.item.content,
      ),
    );

    final itemWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        headerButton,
        contentArea,
      ],
    );

    // Styling for Default Variant (Card-based)
    if (widget.variant == JustAccordionVariant.default_) {
      final itemDecoration = BoxDecoration(
        color: contentBg,
        border: Border.all(
          color: borderColor,
          width: widget.isNeobrutalism ? 2.5 : 1.0,
        ),
        borderRadius: finalRadius,
        boxShadow: widget.isExpanded
            ? (widget.isNeobrutalism
                ? [
                    BoxShadow(
                      color: widget.colors.textPrimary,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    )
                  ]
                : widget.shadows.sm)
            : null,
      );

      return Container(
        decoration: itemDecoration,
        clipBehavior: Clip.antiAlias,
        child: itemWidget,
      );
    }

    // Flush or Contained Variants (no individual card borders)
    return Semantics(
      container: true,
      label: 'Accordion Panel: ${widget.item.title}',
      value: widget.isExpanded ? 'Expanded' : 'Collapsed',
      enabled: widget.item.enabled,
      child: itemWidget,
    );
  }
}
