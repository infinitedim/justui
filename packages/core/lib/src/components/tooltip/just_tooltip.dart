import 'dart:async';

import 'package:flutter/services.dart' show KeyDownEvent;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/theme/preset_tokens.dart';
import 'package:just_ui_core/src/theme/theme_data.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart' show JustColorScheme;

import '../../theme/theme_data_material.dart';
import '../../theme/theme_provider.dart';
import 'just_tooltip_style.dart';
import 'just_tooltip_theme.dart';
import 'just_tooltip_variants.dart';

/// Standalone visual bubble surface for a tooltip.
class const JustTooltipBubble({
  super.key,

  /// Text message rendered inside the bubble.
  required final String message,

  /// Per-instance style overrides.
  final JustTooltipStyle? style,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = context.justRadius;
    final JustTypographyScheme typography = context.justTypo;
    final JustShadowScheme shadows = context.justShadows;
    final JustPresetTokens presetTokens = context.justPresetTokens;
    final JustTooltipStyle? themeStyle = context
        .justThemeExtension<JustTooltipTheme>()
        ?.style;

    final Color resolvedBg =
        style?.backgroundColor ??
        themeStyle?.backgroundColor ??
        (presetTokens.showsDefaultBorder ? colors.background : colors.elevated);
    final Color resolvedBorderColor = presetTokens.showsDefaultBorder
        ? colors.textPrimary
        : colors.borderDefault;
    final Color resolvedTextColor =
        style?.foregroundColor ??
        themeStyle?.foregroundColor ??
        colors.textPrimary;
    final EdgeInsets resolvedPadding =
        style?.padding ??
        themeStyle?.padding ??
        .symmetric(horizontal: spacing.sm, vertical: spacing.xs);
    final BorderRadius resolvedRadius =
        style?.borderRadius ?? themeStyle?.borderRadius ?? .all(radius.sm);
    final bool showBorder = presetTokens.showsDefaultBorder;
    final double borderWidth = showBorder ? presetTokens.borderWidth : 0.0;
    final double? maxWidth = style?.maxWidth ?? themeStyle?.maxWidth;

    final Container bubble = Container(
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: resolvedRadius,
        border: showBorder
            ? .all(color: resolvedBorderColor, width: borderWidth)
            : null,
        boxShadow: shadows.md,
      ),
      child: Text(
        message,
        style: typography.bodySm.copyWith(color: resolvedTextColor),
      ),
    );

    if (maxWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: bubble,
      );
    }
    return bubble;
  }
}

/// A declarative, accessible tooltip widget that displays a floating label
/// relative to its target using the native [OverlayPortal.overlayChildLayoutBuilder] API.
class const JustTooltip({
  required final String message,
  required final Widget child,
  super.key,
  final TooltipPosition preferredPosition = .auto,
  final bool triggerOnHover = true,
  final bool triggerOnLongPress = true,
  final Duration showDelay = .zero,
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

    final double spaceTop = childRect.top;
    final double spaceBottom = screenSize.height - childRect.bottom;
    final double spaceLeft = childRect.left;
    final double spaceRight = screenSize.width - childRect.right;

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
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == .escape &&
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
        behavior: .translucent,
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
      overlayChildBuilder: (BuildContext context, OverlayChildLayoutInfo info) {
        final Offset targetOffset = MatrixUtils.transformPoint(
          info.childPaintTransform,
          .zero,
        );
        final Size childSize = info.childSize;
        final Rect childRect = targetOffset & childSize;
        final Size screenSize = MediaQuery.of(context).size;

        final TooltipPosition resolvedPos = _resolvePosition(
          screenSize,
          childRect,
        );

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

        final AnimatedBuilder animatedTooltip = AnimatedBuilder(
          animation: _animController,
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              scale: 0.95 + 0.05 * _animController.value,
              child: Opacity(opacity: _animController.value, child: child),
            );
          },
          child: JustTooltipBubble(
            message: widget.message,
            style: widget.style,
          ),
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
