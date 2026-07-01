import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../theme/theme_provider.dart';
import '../shared/_shared_pressable.dart';
import '../shared/_shared_focus_indicator.dart';
import 'just_scroll_area_style.dart';
import 'just_scroll_area_theme.dart';

/// A performance-optimized scroll area with custom scrollbars, fade edges,
/// scroll-to-top floating button, and infinite scroll triggers.
///
/// Adheres to zero-Material visual policy and maps styles using JustUI design system.
class JustScrollArea extends StatefulWidget {
  /// The child layout inside the scroll view.
  final Widget child;

  /// The scroll axis direction. Defaults to [.vertical].
  final Axis direction;

  /// Whether to display the custom styled scrollbar. Defaults to true.
  final bool showScrollbar;

  /// Whether to apply transparent fade effects to the boundaries of the scroll view. Defaults to false.
  final bool fadeEdges;

  /// The rendering mode used for the fade gradients. Defaults to [.overlay].
  final JustScrollFadeMode fadeMode;

  /// Whether to show a floating button to scroll back to the top when scrolling down. Defaults to false.
  final bool scrollToTopButton;

  /// The distance scrolled before showing the scroll-to-top button. Defaults to 400.0.
  final double scrollToTopThreshold;

  /// The positioning alignment of the scroll-to-top button. Defaults to [.bottomRight].
  final Alignment scrollToTopAlignment;

  /// Optional custom padding offset for placing the scroll-to-top button.
  final Offset? scrollToTopOffset;

  /// The bottom scroll distance remaining before triggering [onReachBottom]. Defaults to 200.0.
  final double reachBottomThreshold;

  /// Callback executed when the scroll offset approaches the bottom, useful for infinite scrolling.
  final VoidCallback? onReachBottom;

  /// Callback executed when scrolling starts.
  final VoidCallback? onScrollStart;

  /// Callback executed when scrolling stops.
  final VoidCallback? onScrollEnd;

  /// The physics configuration of the scroll view.
  final ScrollPhysics? physics;

  /// External [ScrollController] to monitor or programmatically drive scrolling.
  final ScrollController? controller;

  /// Inner padding of the scroll viewport.
  final EdgeInsets? padding;

  /// Optional maximum height constraint.
  final double? maxHeight;

  /// The distance scrolled per keyboard arrow keypress. Defaults to 50.0.
  final double keyboardScrollStep;

  /// Per-instance style overrides.
  final JustScrollAreaStyle? style;

  /// Creates a [JustScrollArea].
  const JustScrollArea({
    super.key,
    required this.child,
    this.direction = .vertical,
    this.showScrollbar = true,
    this.fadeEdges = false,
    this.fadeMode = .overlay,
    this.scrollToTopButton = false,
    this.scrollToTopThreshold = 400.0,
    this.scrollToTopAlignment = .bottomRight,
    this.scrollToTopOffset,
    this.reachBottomThreshold = 200.0,
    this.onReachBottom,
    this.onScrollStart,
    this.onScrollEnd,
    this.physics,
    this.controller,
    this.padding,
    this.maxHeight,
    this.keyboardScrollStep = 50.0,
    this.style,
  });

  @override
  State<JustScrollArea> createState() => _JustScrollAreaState();
}

class _JustScrollAreaState extends State<JustScrollArea> {
  late final ScrollController _internalController;
  late final FocusNode _focusNode;
  final ValueNotifier<double> _topFadeOpacity = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _bottomFadeOpacity = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _showScrollToTop = ValueNotifier<bool>(false);
  bool _reachedBottomFlag = false;

  ScrollController get _resolvedController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _focusNode = FocusNode();

    // Trigger initial metrics calculation after the first frame layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollMetrics();
    });
  }

  @override
  void dispose() {
    _internalController.dispose();
    _focusNode.dispose();
    _topFadeOpacity.dispose();
    _bottomFadeOpacity.dispose();
    _showScrollToTop.dispose();
    super.dispose();
  }

  void _updateScrollMetrics() {
    if (!_resolvedController.hasClients) return;

    final metrics = _resolvedController.position;
    final offset = metrics.pixels;
    final maxScroll = metrics.maxScrollExtent;

    // Resolve theme variables
    final globalTheme = Theme.of(context).extension<JustScrollAreaTheme>();
    final themeStyle = globalTheme?.style;
    final resolvedFadeHeight =
        widget.style?.fadeHeight ?? themeStyle?.fadeHeight ?? 24.0;

    // Fade overlay updates
    if (widget.fadeEdges) {
      if (maxScroll <= 0) {
        _topFadeOpacity.value = 0.0;
        _bottomFadeOpacity.value = 0.0;
      } else {
        final double topOpacity = (offset / resolvedFadeHeight).clamp(0.0, 1.0);
        final double bottomOpacity = ((maxScroll - offset) / resolvedFadeHeight)
            .clamp(0.0, 1.0);

        _topFadeOpacity.value = topOpacity;
        _bottomFadeOpacity.value = bottomOpacity;
      }
    }

    // Scroll to Top visibility
    if (widget.scrollToTopButton) {
      _showScrollToTop.value = offset > widget.scrollToTopThreshold;
    }
  }

  void _checkReachBottom(ScrollNotification notification) {
    if (widget.onReachBottom == null) return;
    if (!_resolvedController.hasClients) return;

    // Guard: Only trigger when scrolling downwards
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0.0;
      if (delta <= 0) return; // Upwards or stationary scroll
    }

    final metrics = _resolvedController.position;
    final offset = metrics.pixels;
    final maxScroll = metrics.maxScrollExtent;

    // Check if within threshold range
    if (maxScroll - offset <= widget.reachBottomThreshold) {
      if (!_reachedBottomFlag) {
        _reachedBottomFlag = true;
        widget.onReachBottom?.call();
      }
    } else {
      _reachedBottomFlag = false;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      _updateScrollMetrics();
      _checkReachBottom(notification);

      // Trigger standard callbacks
      if (notification is ScrollStartNotification) {
        widget.onScrollStart?.call();
      } else if (notification is ScrollEndNotification) {
        widget.onScrollEnd?.call();
      }
    }
    return false;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return .ignored;
    if (!_resolvedController.hasClients) return .ignored;

    final double currentOffset = _resolvedController.offset;
    final double maxScroll = _resolvedController.position.maxScrollExtent;
    final double viewportDimension =
        _resolvedController.position.viewportDimension;

    double targetOffset = currentOffset;
    final isVertical = widget.direction == .vertical;

    if (isVertical) {
      if (event.logicalKey == .arrowDown) {
        targetOffset = (currentOffset + widget.keyboardScrollStep).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .arrowUp) {
        targetOffset = (currentOffset - widget.keyboardScrollStep).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .pageDown) {
        targetOffset = (currentOffset + viewportDimension).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .pageUp) {
        targetOffset = (currentOffset - viewportDimension).clamp(
          0.0,
          maxScroll,
        );
      } else {
        return .ignored;
      }
    } else {
      // Horizontal scrolling keys
      if (event.logicalKey == .arrowRight) {
        targetOffset = (currentOffset + widget.keyboardScrollStep).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .arrowLeft) {
        targetOffset = (currentOffset - widget.keyboardScrollStep).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .pageDown) {
        targetOffset = (currentOffset + viewportDimension).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .pageUp) {
        targetOffset = (currentOffset - viewportDimension).clamp(
          0.0,
          maxScroll,
        );
      } else {
        return .ignored;
      }
    }

    final animations = JustThemeProvider.of(
      context,
      aspect: .animations,
    ).theme.animations;
    _resolvedController.animateTo(
      targetOffset,
      duration: animations.fast,
      curve: animations.defaultCurve,
    );

    return .handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final shadows = JustThemeProvider.of(
      context,
      aspect: .shadows,
    ).theme.shadows;
    final animations = JustThemeProvider.of(
      context,
      aspect: .animations,
    ).theme.animations;

    final globalTheme = Theme.of(context).extension<JustScrollAreaTheme>();
    final themeStyle = globalTheme?.style;

    // Resolve spacing/colors configurations
    final resolvedFadeColor =
        widget.style?.fadeColor ?? themeStyle?.fadeColor ?? colors.background;
    final resolvedFadeHeight =
        widget.style?.fadeHeight ?? themeStyle?.fadeHeight ?? 24.0;

    final scrollbarThumbColor =
        widget.style?.scrollbarThumbColor ??
        themeStyle?.scrollbarThumbColor ??
        colors.textSecondary.withValues(alpha: 0.3);
    final scrollbarTrackColor =
        widget.style?.scrollbarTrackColor ??
        themeStyle?.scrollbarTrackColor ??
        const Color(0x00000000);
    final scrollbarThickness =
        widget.style?.scrollbarThickness ??
        themeStyle?.scrollbarThickness ??
        6.0;
    final presetTokens = JustThemeProvider.of(context).theme.presetTokens;
    final scrollbarRadius = presetTokens.showsDefaultBorder
        ? Radius.zero
        : (widget.style?.scrollbarRadius ??
              themeStyle?.scrollbarRadius ??
              const .circular(3.0));

    // Create the viewport layout
    Widget scrollView = SingleChildScrollView(
      controller: _resolvedController,
      scrollDirection: widget.direction,
      physics: widget.physics,
      padding: widget.padding,
      child: widget.child,
    );

    // Apply custom scrollbar wrapper
    if (widget.showScrollbar) {
      scrollView = RawScrollbar(
        controller: _resolvedController,
        thumbColor: scrollbarThumbColor,
        trackColor: scrollbarTrackColor,
        thickness: scrollbarThickness,
        radius: scrollbarRadius,
        child: scrollView,
      );
    }

    // Apply fade edges
    if (widget.fadeEdges) {
      if (widget.fadeMode == .overlay) {
        scrollView = Stack(
          children: [
            scrollView,
            // Top/Left boundary fade overlay
            Positioned(
              left: 0.0,
              top: 0.0,
              right: widget.direction == .vertical ? 0.0 : null,
              bottom: widget.direction == .horizontal ? 0.0 : null,
              width: widget.direction == .horizontal
                  ? resolvedFadeHeight
                  : null,
              height: widget.direction == .vertical ? resolvedFadeHeight : null,
              child: ValueListenableBuilder<double>(
                valueListenable: _topFadeOpacity,
                builder: (context, opacity, child) {
                  if (opacity == 0.0) return const SizedBox.shrink();
                  return IgnorePointer(
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: widget.direction == .vertical
                                ? .topCenter
                                : .centerLeft,
                            end: widget.direction == .vertical
                                ? .bottomCenter
                                : .centerRight,
                            colors: [
                              resolvedFadeColor,
                              resolvedFadeColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom/Right boundary fade overlay
            Positioned(
              left: widget.direction == .horizontal ? null : 0.0,
              top: widget.direction == .vertical ? null : 0.0,
              right: 0.0,
              bottom: 0.0,
              width: widget.direction == .horizontal
                  ? resolvedFadeHeight
                  : null,
              height: widget.direction == .vertical ? resolvedFadeHeight : null,
              child: ValueListenableBuilder<double>(
                valueListenable: _bottomFadeOpacity,
                builder: (context, opacity, child) {
                  if (opacity == 0.0) return const SizedBox.shrink();
                  return IgnorePointer(
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: widget.direction == .vertical
                                ? .bottomCenter
                                : .centerRight,
                            end: widget.direction == .vertical
                                ? .topCenter
                                : .centerLeft,
                            colors: [
                              resolvedFadeColor,
                              resolvedFadeColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      } else {
        // Shader Mask Mode (true alpha masking)
        scrollView = AnimatedBuilder(
          animation: Listenable.merge([_topFadeOpacity, _bottomFadeOpacity]),
          builder: (context, child) {
            final topOpacity = _topFadeOpacity.value;
            final bottomOpacity = _bottomFadeOpacity.value;

            return ShaderMask(
              shaderCallback: (bounds) {
                if (bounds.height <= 0 || bounds.width <= 0) {
                  return const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                  ).createShader(bounds);
                }

                final totalLength = widget.direction == .vertical
                    ? bounds.height
                    : bounds.width;
                final topFraction = (resolvedFadeHeight / totalLength).clamp(
                  0.0,
                  0.5,
                );
                final bottomFraction =
                    (1.0 - (resolvedFadeHeight / totalLength)).clamp(0.5, 1.0);

                return LinearGradient(
                  begin: widget.direction == .vertical
                      ? .topCenter
                      : .centerLeft,
                  end: widget.direction == .vertical
                      ? .bottomCenter
                      : .centerRight,
                  colors: [
                    Color.lerp(
                      const Color(0xFFFFFFFF),
                      const Color(0x00FFFFFF),
                      topOpacity,
                    )!,
                    const Color(0xFFFFFFFF),
                    const Color(0xFFFFFFFF),
                    Color.lerp(
                      const Color(0xFFFFFFFF),
                      const Color(0x00FFFFFF),
                      bottomOpacity,
                    )!,
                  ],
                  stops: [0.0, topFraction, bottomFraction, 1.0],
                ).createShader(bounds);
              },
              blendMode: .dstIn,
              child: child,
            );
          },
          child: scrollView,
        );
      }
    }

    // Wrap in maxHeight constraint if specified
    Widget result = scrollView;
    if (widget.maxHeight != null) {
      result = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: result,
      );
    }

    // Layer Scroll-to-Top Float Button
    if (widget.scrollToTopButton) {
      result = Stack(
        children: [
          result,
          ValueListenableBuilder<bool>(
            valueListenable: _showScrollToTop,
            builder: (context, visible, child) {
              return Align(
                alignment: widget.scrollToTopAlignment,
                child: Padding(
                  padding: widget.scrollToTopOffset != null
                      ? .only(
                          left: widget.scrollToTopOffset!.dx >= 0
                              ? widget.scrollToTopOffset!.dx
                              : 0.0,
                          top: widget.scrollToTopOffset!.dy >= 0
                              ? widget.scrollToTopOffset!.dy
                              : 0.0,
                          right: widget.scrollToTopOffset!.dx < 0
                              ? -widget.scrollToTopOffset!.dx
                              : 0.0,
                          bottom: widget.scrollToTopOffset!.dy < 0
                              ? -widget.scrollToTopOffset!.dy
                              : 0.0,
                        )
                      : .all(spacing.lg),
                  child: AnimatedOpacity(
                    opacity: visible ? 1.0 : 0.0,
                    duration: animations.fast,
                    curve: animations.defaultCurve,
                    child: AnimatedScale(
                      scale: visible ? 1.0 : 0.0,
                      duration: animations.fast,
                      curve: animations.defaultCurve,
                      child: Semantics(
                        button: true,
                        label: 'Scroll to top',
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 48.0,
                            minHeight: 48.0,
                          ),
                          child: Center(
                            child: JustPressable(
                              enabled: visible,
                              onTap: () {
                                _resolvedController.animateTo(
                                  0.0,
                                  duration: animations.normal,
                                  curve: animations.defaultCurve,
                                );
                              },
                              builder:
                                  (
                                    context,
                                    isHovered,
                                    isPressed,
                                    isFocused,
                                    focusNode,
                                  ) {
                                    return FocusIndicator(
                                      isFocused: isFocused,
                                      focusColor: colors.borderFocus,
                                      borderRadius: const .all(.circular(20.0)),
                                      child: Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: isPressed
                                              ? colors.borderDefault
                                              : (isHovered
                                                    ? colors.background
                                                    : colors.card),
                                          shape: .circle,
                                          border: .all(
                                            color: isFocused
                                                ? colors.borderFocus
                                                : colors.borderDefault,
                                            width: isFocused ? 2.0 : 1.0,
                                          ),
                                          boxShadow: shadows.md,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 16.0,
                                            height: 16.0,
                                            child: CustomPaint(
                                              painter: _ChevronUpPainter(
                                                color: colors.textPrimary,
                                                strokeWidth: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: RepaintBoundary(child: result),
      ),
    );
  }
}

class _ChevronUpPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ChevronUpPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = .stroke
      ..strokeCap = .round
      ..strokeJoin = .round;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.65);
    path.lineTo(size.width * 0.5, size.height * 0.35);
    path.lineTo(size.width * 0.75, size.height * 0.65);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronUpPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
