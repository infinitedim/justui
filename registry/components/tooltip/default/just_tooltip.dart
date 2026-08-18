import 'dart:async';

import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'just_tooltip_style.dart';
import 'just_tooltip_theme.dart';
import 'just_tooltip_variants.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// A declarative, accessible tooltip widget that displays a floating label
/// relative to its target using the native [OverlayPortal.overlayChildLayoutBuilder] API.
class const JustTooltip({
  required final String message,
  required final Widget child,
  super.key,
  final TooltipPosition preferredPosition = TooltipPosition.auto,
  final bool triggerOnHover = true,
  final bool triggerOnLongPress = true,
  final Duration showDelay = Duration.zero,
  final Duration hideDelay = const Duration(milliseconds: 150),
  final JustTooltipStyle? style,
  final bool showArrow = false,
  final OverlayPortalController? controller,
  final AnimationController? animationController,
  final Widget Function(BuildContext, Animation<double>, Widget)?
  animationBuilder,
}) extends StatefulWidget {
  @override
  State<JustTooltip> createState() => _JustTooltipState();
}

class _JustTooltipState extends State<JustTooltip>
    with SingleTickerProviderStateMixin {
  late OverlayPortalController _overlayController;
  late final AnimationController _localAnimController;
  AnimationController get _animController =>
      widget.animationController ?? _localAnimController;

  final FocusNode _focusNode = FocusNode();
  Timer? _showTimer;
  Timer? _hideTimer;
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isLongPressed = false;

  @override
  void initState() {
    super.initState();
    _overlayController = widget.controller ?? OverlayPortalController();
    _localAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant JustTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _overlayController = widget.controller ?? OverlayPortalController();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _showTimer?.cancel();
    _hideTimer?.cancel();
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
    if (_overlayController.isShowing || _showTimer?.isActive == true) return;

    _showTimer = Timer(widget.showDelay, () {
      if (mounted) {
        _overlayController.show();
        _animController.forward();
      }
    });
  }

  void _hideTooltip() {
    _showTimer?.cancel();
    if (!_overlayController.isShowing) return;

    _hideTimer = Timer(widget.hideDelay, () {
      if (mounted) {
        _animController.reverse().then((_) {
          if (mounted && !_isHovered && !_isFocused && !_isLongPressed) {
            _overlayController.hide();
          }
        });
      }
    });
  }

  TooltipPosition _resolvePosition(Size screenSize, Rect childRect) {
    if (widget.preferredPosition != .auto) {
      return widget.preferredPosition;
    }

    final spaceTop = childRect.top;
    final spaceBottom = screenSize.height - childRect.bottom;
    final spaceLeft = childRect.left;
    final spaceRight = screenSize.width - childRect.right;

    if (spaceTop > 48.0) return .top;
    if (spaceBottom > 48.0) return .bottom;
    if (spaceLeft > 80.0) return .left;
    if (spaceRight > 80.0) return .right;
    return .top;
  }

  @override
  Widget build(BuildContext context) {
    Widget target = Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            _overlayController.isShowing) {
          _isHovered = false;
          _isFocused = false;
          _isLongPressed = false;
          _overlayController.hide();
          return .handled;
        }
        return .ignored;
      },
      child: widget.child,
    );

    if (widget.triggerOnHover) {
      target = MouseRegion(
        onEnter: (_) {
          _isHovered = true;
          _updateTooltipVisibility();
        },
        onExit: (_) {
          _isHovered = false;
          _updateTooltipVisibility();
        },
        child: target,
      );
    }

    if (widget.triggerOnLongPress) {
      target = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: (_) {
          _isLongPressed = true;
          _updateTooltipVisibility();
        },
        onLongPressEnd: (_) {
          _isLongPressed = false;
          _updateTooltipVisibility();
        },
        child: target,
      );
    }

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (BuildContext context, info) {
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

        final resolvedBorderColor = theme.presetTokens.showsDefaultBorder
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

        final targetOffset = MatrixUtils.transformPoint(
          info.childPaintTransform,
          .zero,
        );
        final childSize = info.childSize;
        final childRect = targetOffset & childSize;
        final screenSize = MediaQuery.of(context).size;

        final resolvedPos = _resolvePosition(screenSize, childRect);

        double left = 0.0;
        double top = 0.0;
        const double gap = 6.0;

        switch (resolvedPos) {
          case .top:
            left = childRect.left + (childRect.width / 2);
            top = childRect.top - gap;
            break;
          case .bottom:
            left = childRect.left + (childRect.width / 2);
            top = childRect.bottom + gap;
            break;
          case .left:
            left = childRect.left - gap;
            top = childRect.top + (childRect.height / 2);
            break;
          case .right:
            left = childRect.right + gap;
            top = childRect.top + (childRect.height / 2);
            break;
          case .auto:
            left = childRect.left + (childRect.width / 2);
            top = childRect.top - gap;
            break;
        }

        final tooltipBubble = Container(
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
        );

        final animatedTooltip = AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.95 + 0.05 * _animController.value,
              child: Opacity(opacity: _animController.value, child: child),
            );
          },
          child: tooltipBubble,
        );

        return Positioned(
          left: left,
          top: top,
          child: FractionalTranslation(
            translation: switch (resolvedPos) {
              .top => const Offset(-0.5, -1.0),
              .bottom => const Offset(-0.5, 0.0),
              .left => const Offset(-1.0, -0.5),
              .right => const Offset(0.0, -0.5),
              .auto => const Offset(-0.5, -1.0),
            },
            child: IgnorePointer(
              child: Semantics(tooltip: widget.message, child: animatedTooltip),
            ),
          ),
        );
      },
      child: Semantics(tooltip: widget.message, child: target),
    );
  }
}
