import 'dart:async';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

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

  /// The position of the tooltip relative to the target. Defaults to [.auto].
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
    this.position = .auto,
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
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  Timer? _hideTimer;
  bool _isVisible = false;

  bool _isHovered = false;
  bool _isFocused = false;
  bool _isLongPressed = false;

  @override
  void initState() {
    super.initState();
    _localAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _removeOverlayImmediate();
    _localAnimController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    _isFocused = _focusNode.hasFocus;
    _updateTooltipVisibility();
  }

  void _updateTooltipVisibility() {
    if (_isHovered || _isFocused || _isLongPressed) {
      _showTooltip();
    } else {
      _hideTooltip();
    }
  }

  void _showTooltip() {
    _hideTimer?.cancel();
    if (_isVisible || _showTimer?.isActive == true) return;

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

        final globalTheme = Theme.of(context).extension<JustTooltipTheme>();
        final themeStyle = globalTheme?.style;
        final entryStyle = widget.style;

        final resolvedBg =
            entryStyle?.backgroundColor ??
            themeStyle?.backgroundColor ??
            (theme.presetTokens.showsDefaultBorder
                ? colors.background
                : colors.elevated);

        final resolvedBorderColor =
            theme.presetTokens.showsDefaultBorder
                ? colors.textPrimary
                : colors.borderDefault;

        final resolvedTextColor =
            entryStyle?.foregroundColor ??
            themeStyle?.foregroundColor ??
            colors.textPrimary;

        final resolvedPadding =
            entryStyle?.padding ??
            themeStyle?.padding ??
            .symmetric(horizontal: spacing.sm, vertical: spacing.xs);

        final resolvedRadius =
            entryStyle?.borderRadius ??
            themeStyle?.borderRadius ??
            .all(radius.sm);

        final showBorder = theme.presetTokens.showsDefaultBorder;
        final borderWidth = showBorder ? theme.presetTokens.borderWidth : 0.0;

        Alignment targetAnchor;
        Alignment followerAnchor;
        Offset offset;

        switch (resolvedPosition) {
          case .top:
            targetAnchor = .topCenter;
            followerAnchor = .bottomCenter;
            offset = const Offset(0, -6.0);
            break;
          case .bottom:
            targetAnchor = .bottomCenter;
            followerAnchor = .topCenter;
            offset = const Offset(0, 6.0);
            break;
          case .left:
            targetAnchor = .centerLeft;
            followerAnchor = .centerRight;
            offset = const Offset(-6.0, 0);
            break;
          case .right:
            targetAnchor = .centerRight;
            followerAnchor = .centerLeft;
            offset = const Offset(6.0, 0);
            break;
          case .auto:
            targetAnchor = .topCenter;
            followerAnchor = .bottomCenter;
            offset = const Offset(0, -6.0);
            break;
        }

        final animatedBubble = AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.95 + 0.05 * _animController.value,
              child: Opacity(
                opacity: _animController.value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: resolvedPadding,
            decoration: BoxDecoration(
              color: resolvedBg,
              borderRadius: resolvedRadius,
              border: showBorder
                  ? .all(color: resolvedBorderColor, width: borderWidth)
                  : null,
              boxShadow: theme.shadows.md,
            ),
            child: Text(
              widget.message,
              style: theme.typography.bodySm.copyWith(color: resolvedTextColor),
            ),
          ),
        );

        return RepaintBoundary(
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: targetAnchor,
            followerAnchor: followerAnchor,
            offset: offset,
            child: Align(
              alignment: .topLeft,
              child: Semantics(tooltip: widget.message, child: animatedBubble),
            ),
          ),
        );
      },
    );

    final overlayState = Overlay.maybeOf(context);
    if (overlayState != null && overlayState.mounted) {
      overlayState.insert(_overlayEntry!);
      _isVisible = true;
      _animController.forward();
    } else {
      _overlayEntry = null;
    }
  }

  void _performHide() {
    if (_overlayEntry == null) return;
    _animController.reverse().then((_) {
      _removeOverlayImmediate();
    });
  }

  void _removeOverlayImmediate() {
    if (_overlayEntry != null) {
      try {
        if (_overlayEntry!.mounted) {
          _overlayEntry!.remove();
        }
      } catch (_) {}
      try {
        _overlayEntry!.dispose();
      } catch (_) {}
      _overlayEntry = null;
    }
    _isVisible = false;
  }

  TooltipPosition _resolvePosition() {
    if (widget.position != .auto) {
      return widget.position;
    }

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return .top;
    }

    final offset = renderBox.localToGlobal(.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    final spaceTop = offset.dy;
    final spaceBottom = screenSize.height - (offset.dy + size.height);
    final spaceLeft = offset.dx;
    final spaceRight = screenSize.width - (offset.dx + size.width);

    // Priority: top -> bottom -> left -> right
    if (spaceTop > 48.0) {
      return .top;
    } else if (spaceBottom > 48.0) {
      return .bottom;
    } else if (spaceLeft > 80.0) {
      return .left;
    } else if (spaceRight > 80.0) {
      return .right;
    }

    return .top;
  }

  @override
  Widget build(BuildContext context) {
    Widget result = CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );

    result = Focus(focusNode: _focusNode, child: result);

    if (widget.triggerOnHover) {
      result = MouseRegion(
        onEnter: (_) {
          _isHovered = true;
          _updateTooltipVisibility();
        },
        onExit: (_) {
          _isHovered = false;
          _updateTooltipVisibility();
        },
        child: result,
      );
    }

    if (widget.triggerOnLongPress) {
      result = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: (_) {
          _isLongPressed = true;
          _updateTooltipVisibility();
        },
        onLongPressEnd: (_) {
          _isLongPressed = false;
          _updateTooltipVisibility();
        },
        child: result,
      );
    }

    return Semantics(tooltip: widget.message, child: result);
  }
}
