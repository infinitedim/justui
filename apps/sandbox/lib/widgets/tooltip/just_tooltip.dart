// justui-meta: registry=84f91016d5b21e4a3dd4edb4bac73d74c8050503179ddabe22711b23a1a60ac5 local=3e59f4bd94875759501d4b6aaaa65317288a8375b368466bb3523ca50c3be956
import 'dart:async';

import 'package:flutter/services.dart' show KeyDownEvent;
import 'package:flutter/widgets.dart';
import 'package:sandbox/core/just_ui_core.dart';

import 'just_tooltip_style.dart';
import 'just_tooltip_theme.dart';
import 'just_tooltip_variants.dart';

class _TooltipVisuals {
  const _TooltipVisuals({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.padding,
    required this.textStyle,
    required this.shadows,
    required this.maxWidth,
  });

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final List<BoxShadow> shadows;
  final double? maxWidth;
}

/// Standalone visual bubble surface for a tooltip.
class JustTooltipBubble extends StatelessWidget {
  /// Text message rendered inside the bubble.
  final String message;

  /// Per-instance style overrides.
  final JustTooltipStyle? style;

  const JustTooltipBubble({super.key, required this.message, this.style});

  _TooltipVisuals _resolveVisuals(BuildContext context) {
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
    final Color resolvedBorderColor =
        style?.borderColor ??
        themeStyle?.borderColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderDefault);
    final double resolvedBorderWidth =
        style?.borderWidth ??
        themeStyle?.borderWidth ??
        (presetTokens.showsDefaultBorder ? presetTokens.borderWidth : 0.0);
    final Color resolvedTextColor =
        style?.foregroundColor ??
        style?.textStyle?.color ??
        themeStyle?.foregroundColor ??
        themeStyle?.textStyle?.color ??
        colors.textPrimary;
    final TextStyle baseTextStyle =
        style?.textStyle ?? themeStyle?.textStyle ?? typography.bodySm;
    final List<BoxShadow> defaultShadows =
        presetTokens.showsDefaultBorder &&
            shadows.md.any((BoxShadow s) => s.color == resolvedBg)
        ? const <BoxShadow>[]
        : shadows.md;
    final List<BoxShadow> resolvedShadows =
        style?.shadows ?? themeStyle?.shadows ?? defaultShadows;

    return _TooltipVisuals(
      backgroundColor: resolvedBg,
      borderColor: resolvedBorderColor,
      borderWidth: resolvedBorderWidth,
      borderRadius:
          style?.borderRadius ?? themeStyle?.borderRadius ?? .all(radius.sm),
      padding:
          style?.padding ??
          themeStyle?.padding ??
          .symmetric(horizontal: spacing.sm, vertical: spacing.xs),
      textStyle: baseTextStyle.copyWith(color: resolvedTextColor),
      shadows: resolvedShadows,
      maxWidth: style?.maxWidth ?? themeStyle?.maxWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _TooltipVisuals v = _resolveVisuals(context);
    final Container bubble = Container(
      padding: v.padding,
      decoration: BoxDecoration(
        color: v.backgroundColor,
        borderRadius: v.borderRadius,
        border: v.borderWidth > 0.0
            ? .all(color: v.borderColor, width: v.borderWidth)
            : null,
        boxShadow: v.shadows,
      ),
      child: Text(message, style: v.textStyle),
    );

    if (v.maxWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: v.maxWidth!),
        child: bubble,
      );
    }
    return bubble;
  }
}

/// A declarative, accessible tooltip widget that displays a floating label
/// relative to its target using the native [OverlayPortal.overlayChildLayoutBuilder] API.
class JustTooltip extends StatefulWidget {
  final String message;
  final Widget child;
  final TooltipPosition preferredPosition;
  final bool triggerOnHover;
  final bool triggerOnLongPress;
  final Duration showDelay;
  final Duration hideDelay;
  final JustTooltipStyle? style;
  final bool showArrow;
  final OverlayPortalController? controller;
  final AnimationController? animationController;
  final Widget Function(BuildContext, Animation<double>, Widget)?
  animationBuilder;

  const JustTooltip({
    required this.message,
    required this.child,
    super.key,
    this.preferredPosition = .auto,
    this.triggerOnHover = true,
    this.triggerOnLongPress = true,
    this.showDelay = .zero,
    this.hideDelay = const Duration(milliseconds: 150),
    this.style,
    this.showArrow = false,
    this.controller,
    this.animationController,
    this.animationBuilder,
  });

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
