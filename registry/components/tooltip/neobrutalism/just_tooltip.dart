import 'dart:async';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import '../../../shared/default/_shared_tokens.dart';

import '../../theme/theme_provider.dart';
import 'just_tooltip_style.dart';
import 'just_tooltip_theme.dart';
import 'just_tooltip_variants.dart';

/// A declarative tooltip widget that displays a floating label when hovered or long-pressed.
class JustTooltip extends StatefulWidget {
  /// The message to display inside the tooltip.
  final String message;

  /// The target widget that triggers the tooltip.
  final Widget child;

  /// The position of the tooltip relative to the target. Defaults to [TooltipPosition.auto].
  final TooltipPosition position;

  /// Whether the tooltip should trigger on hover (mouse hover).
  final bool triggerOnHover;

  /// Whether the tooltip should trigger on long press (touch/gesture).
  final bool triggerOnLongPress;

  /// Delay before the tooltip becomes visible.
  final Duration showDelay;

  /// Delay before the tooltip disappears after the trigger ends.
  final Duration hideDelay;

  /// Per-instance style overrides.
  final JustTooltipStyle? style;

  /// Optional custom animation controller.
  final AnimationController? animationController;

  /// Optional custom animation builder.
  final Widget Function(BuildContext, Animation<double>, Widget)?
  animationBuilder;

  /// Creates a [JustTooltip].
  const JustTooltip({
    super.key,
    required this.message,
    required this.child,
    this.position = TooltipPosition.auto,
    this.triggerOnHover = true,
    this.triggerOnLongPress = true,
    this.showDelay = Duration.zero,
    this.hideDelay = const Duration(milliseconds: 150),
    this.style,
    this.animationController,
    this.animationBuilder,
  });

  @override
  State<JustTooltip> createState() => _JustTooltipState();
}

class _JustTooltipState extends State<JustTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _localAnimController;
  AnimationController get _animController =>
      widget.animationController ?? _localAnimController;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  Timer? _hideTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _localAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _removeOverlayImmediate();
    _localAnimController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    _hideTimer?.cancel();
    if (_isVisible) return;

    _showTimer = Timer(widget.showDelay, () {
      _createAndInsertOverlay();
    });
  }

  void _hideTooltip() {
    _showTimer?.cancel();
    if (!_isVisible) return;

    _hideTimer = Timer(widget.hideDelay, () {
      _performHide();
    });
  }

  void _createAndInsertOverlay() {
    if (_overlayEntry != null) return;

    // Resolve dynamic position based on available screen space
    final resolvedPosition = _resolvePosition();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final theme = JustThemeProvider.of(context).theme;
        final colors = theme.colors;
        final spacing = theme.spacing;
        final radius = theme.radius;
        final motion = theme.animations.resolve(context);

        final globalTheme = Theme.of(context).extension<JustTooltipTheme>();
        final themeStyle = globalTheme?.style;
        final entryStyle = widget.style;

        // Resolve styles
        final bgColor =
            entryStyle?.backgroundColor ??
            themeStyle?.backgroundColor ??
            colors
                .textPrimary; // Dark background by default for high contrast tooltips
        final fgColor =
            entryStyle?.foregroundColor ??
            themeStyle?.foregroundColor ??
            colors.background; // Light text by default
        final borderRadius =
            entryStyle?.borderRadius ??
            themeStyle?.borderRadius ??
            .all(radius.xs);
        final padding =
            entryStyle?.padding ??
            themeStyle?.padding ??
            .symmetric(horizontal: spacing.sm, vertical: spacing.xs);
        final maxWidth = entryStyle?.maxWidth ?? themeStyle?.maxWidth ?? 240.0;

        final isNeobrutalism = true;
        final borderSide = BorderSide(
          color: isNeobrutalism ? colors.textPrimary : colors.borderDefault,
          width: isNeobrutalism ? 2.5 : 1.0,
        );

        // Map TooltipPosition to CompositedTransformFollower anchors
        Alignment targetAnchor;
        Alignment followerAnchor;
        Offset offset;
        final double gap = spacing.xs;

        switch (resolvedPosition) {
          case TooltipPosition.top:
            targetAnchor = Alignment.topCenter;
            followerAnchor = Alignment.bottomCenter;
            offset = Offset(0.0, -gap);
            break;
          case TooltipPosition.bottom:
            targetAnchor = Alignment.bottomCenter;
            followerAnchor = Alignment.topCenter;
            offset = Offset(0.0, gap);
            break;
          case TooltipPosition.left:
            targetAnchor = Alignment.centerLeft;
            followerAnchor = Alignment.centerRight;
            offset = Offset(-gap, 0.0);
            break;
          case TooltipPosition.right:
            targetAnchor = Alignment.centerRight;
            followerAnchor = Alignment.centerLeft;
            offset = Offset(gap, 0.0);
            break;
          case TooltipPosition.auto:
            targetAnchor = Alignment.topCenter;
            followerAnchor = Alignment.bottomCenter;
            offset = Offset(0.0, -gap);
            break;
        }

        final Widget tooltipBubble = Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            border: isNeobrutalism ? .fromBorderSide(borderSide) : null,
            boxShadow: isNeobrutalism
                ? theme.resolveShadows(const [], isPressed: false)
                : null,
          ),
          padding: padding,
          child: Text(
            widget.message,
            style: JustFluidTypo.bodySm(
              context,
            ).copyWith(color: fgColor, fontSize: 12.0),
          ),
        );

        final curvedAnimation = CurvedAnimation(
          parent: _animController,
          curve: motion.enter,
          reverseCurve: motion.exit,
        );

        Widget animatedBubble;
        if (widget.animationBuilder != null) {
          animatedBubble = widget.animationBuilder!(
            context,
            _animController,
            tooltipBubble,
          );
        } else {
          animatedBubble = FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(curvedAnimation),
              child: tooltipBubble,
            ),
          );
        }

        return RepaintBoundary(
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: targetAnchor,
            followerAnchor: followerAnchor,
            offset: offset,
            child: Align(
              alignment: Alignment.topLeft,
              child: Semantics(tooltip: widget.message, child: animatedBubble),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isVisible = true;
    _animController.forward();
  }

  void _performHide() {
    if (_overlayEntry == null) return;
    _animController.reverse().then((_) {
      _removeOverlayImmediate();
    });
  }

  void _removeOverlayImmediate() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    _isVisible = false;
  }

  TooltipPosition _resolvePosition() {
    if (widget.position != TooltipPosition.auto) {
      return widget.position;
    }

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return TooltipPosition.top;
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    final spaceTop = offset.dy;
    final spaceBottom = screenSize.height - (offset.dy + size.height);
    final spaceLeft = offset.dx;
    final spaceRight = screenSize.width - (offset.dx + size.width);

    // Priority: top -> bottom -> left -> right
    if (spaceTop > 48.0) {
      return TooltipPosition.top;
    } else if (spaceBottom > 48.0) {
      return TooltipPosition.bottom;
    } else if (spaceLeft > 80.0) {
      return TooltipPosition.left;
    } else if (spaceRight > 80.0) {
      return TooltipPosition.right;
    }

    return TooltipPosition.top;
  }

  @override
  Widget build(BuildContext context) {
    Widget result = CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );

    if (widget.triggerOnHover) {
      result = MouseRegion(
        onEnter: (_) => _showTooltip(),
        onExit: (_) => _hideTooltip(),
        child: result,
      );
    }

    if (widget.triggerOnLongPress) {
      result = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: (_) => _showTooltip(),
        onLongPressEnd: (_) => _hideTooltip(),
        child: result,
      );
    }

    return result;
  }
}
