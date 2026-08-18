import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../shared/_shared_pressable.dart';
import '../shared/_shared_focus_indicator.dart';
import 'just_scroll_area_style.dart';
import 'just_scroll_area_theme.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// A performance-optimized scroll area with custom scrollbars, fade edges,
/// scroll-to-top floating button, infinite scroll triggers, and an optional
/// Lenis-style smooth scroll engine for ultra-fluid mouse wheel & keyboard
/// scrolling on desktop/web platforms.
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
  ///
  /// When [smoothScroll] is enabled, this is overridden with
  /// [NeverScrollableScrollPhysics] to prevent conflicts with the lerp engine.
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

  /// Enables the Lenis-style smooth scroll engine.
  ///
  /// When `null` (default), auto-detects platform:
  /// - **Desktop** (macOS, Windows, Linux): enabled
  /// - **Mobile** (iOS, Android): disabled (native touch physics preserved)
  ///
  /// Set explicitly to `true` or `false` to override auto-detection.
  final bool? smoothScroll;

  /// The lerp interpolation factor controlling scroll smoothness (0.01–1.0).
  ///
  /// Lower values produce smoother, more cinematic scrolling with longer deceleration.
  /// Higher values produce snappier, more responsive scrolling.
  ///
  /// - `0.05`: Very cinematic and elegant
  /// - `0.10`: Lenis signature default (ideal balance)
  /// - `0.20+`: Very responsive and snappy
  ///
  /// Defaults to `0.10`.
  final double lerpFactor;

  /// Multiplier applied to mouse wheel scroll distance per notch.
  ///
  /// Increase to make wheel scrolling cover more distance per notch.
  /// Defaults to `1.0`.
  final double wheelMultiplier;

  /// Multiplier applied to touch/trackpad scroll distance.
  ///
  /// Defaults to `1.0`.
  final double touchMultiplier;

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
    this.smoothScroll,
    this.lerpFactor = 0.10,
    this.wheelMultiplier = 1.0,
    this.touchMultiplier = 1.0,
  });

  @override
  State<JustScrollArea> createState() => _JustScrollAreaState();
}

class _JustScrollAreaState extends State<JustScrollArea>
    with SingleTickerProviderStateMixin {
  late final ScrollController _internalController;
  late final FocusNode _focusNode;
  final ValueNotifier<double> _topFadeOpacity = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _bottomFadeOpacity = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _showScrollToTop = ValueNotifier<bool>(false);
  bool _reachedBottomFlag = false;

  // --- Lenis Smooth Scroll Engine State ---
  late final Ticker _smoothTicker;
  double _targetOffset = 0.0;
  double _currentOffset = 0.0;
  bool _isSmoothing = false;
  Duration _lastTickTime = Duration.zero;
  bool _isDragging = false;

  ScrollController get _resolvedController =>
      widget.controller ?? _internalController;

  /// Resolves whether smooth scroll is enabled, checking (in priority order):
  /// 1. Explicit widget parameter
  /// 2. Per-instance style override
  /// 3. Global theme style override
  /// 4. Platform auto-detection (desktop/web = true, mobile = false)
  bool get _isSmoothEnabled {
    if (widget.smoothScroll != null) return widget.smoothScroll!;

    final globalTheme = Theme.of(context).extension<JustScrollAreaTheme>();
    final themeSetting =
        widget.style?.smoothScroll ?? globalTheme?.style?.smoothScroll;
    if (themeSetting != null) return themeSetting;

    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux;
  }

  /// Resolves the effective lerp factor from widget, style, or theme.
  double get _resolvedLerpFactor {
    return widget.style?.lerpFactor ?? widget.lerpFactor;
  }

  /// Resolves the effective wheel multiplier.
  double get _resolvedWheelMultiplier {
    return widget.style?.wheelMultiplier ?? widget.wheelMultiplier;
  }

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _focusNode = FocusNode();
    _smoothTicker = createTicker(_onSmoothTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollMetrics();
      _syncOffsets();
    });
  }

  @override
  void dispose() {
    _stopSmoothing();
    _smoothTicker.dispose();
    _internalController.dispose();
    _focusNode.dispose();
    _topFadeOpacity.dispose();
    _bottomFadeOpacity.dispose();
    _showScrollToTop.dispose();
    super.dispose();
  }

  /// Synchronizes the internal lerp offsets with the actual scroll controller position.
  void _syncOffsets() {
    if (!_resolvedController.hasClients) return;
    _currentOffset = _resolvedController.offset;
    _targetOffset = _currentOffset;
  }

  // ==========================================
  // --- Lenis Smooth Scroll Engine ---
  // ==========================================

  void _startSmoothing() {
    if (_isSmoothing) return;
    _isSmoothing = true;
    _lastTickTime = Duration.zero;
    _smoothTicker.start();
  }

  void _stopSmoothing() {
    if (!_isSmoothing) return;
    _isSmoothing = false;
    _smoothTicker.stop();
    _lastTickTime = Duration.zero;
  }

  /// Per-frame tick callback for the smooth scroll engine.
  ///
  /// Implements frame-rate independent exponential interpolation:
  /// α(Δt) = 1 − (1 − lerp)^(60·Δt)
  /// current += (target − current) × α
  void _onSmoothTick(Duration elapsed) {
    if (!_resolvedController.hasClients) {
      _stopSmoothing();
      return;
    }

    // Calculate frame-rate independent delta time (seconds)
    final double dt = _lastTickTime == Duration.zero
        ? 1.0 /
              60.0 // Assume 60fps for the very first frame
        : (elapsed - _lastTickTime).inMicroseconds / 1000000.0;
    _lastTickTime = elapsed;

    // Clamp dt to prevent huge position jumps after tab switch/app resume
    final double clampedDt = dt.clamp(0.0, 0.1);

    // Frame-rate independent exponential interpolation factor
    final double lerp = _resolvedLerpFactor.clamp(0.01, 1.0);
    final double alpha = 1.0 - math.pow(1.0 - lerp, 60.0 * clampedDt);

    // Interpolate current position toward target
    final double diff = _targetOffset - _currentOffset;
    _currentOffset += diff * alpha;

    // Epsilon threshold: snap when close enough (< 0.1px) and stop the ticker
    if (diff.abs() < 0.1) {
      _currentOffset = _targetOffset;
      _resolvedController.jumpTo(_currentOffset);
      _stopSmoothing();
      return;
    }

    // Apply interpolated position via jumpTo (zero animation overhead)
    _resolvedController.jumpTo(_currentOffset);
  }

  /// Handles mouse wheel and trackpad pointer signal events.
  ///
  /// Accumulates the scroll delta into [_targetOffset] and starts the
  /// smooth ticker if not already running.
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_resolvedController.hasClients) return;

    final maxScroll = _resolvedController.position.maxScrollExtent;

    // Determine raw delta based on scroll axis
    final double rawDelta = widget.direction == .vertical
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;

    // Apply wheel multiplier
    final double delta = rawDelta * _resolvedWheelMultiplier;

    // Accumulate target offset, clamped to valid scroll range
    _targetOffset = (_targetOffset + delta).clamp(0.0, maxScroll);

    // Start the ticker engine if not already running
    _startSmoothing();
  }

  // ==========================================
  // --- Scroll Metrics & Callbacks ---
  // ==========================================

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

      if (notification is ScrollStartNotification) {
        // If scroll started by user drag (not by our jumpTo), immediately
        // stop the smooth engine and sync target to actual position.
        if (notification.dragDetails != null) {
          _isDragging = true;
          if (_isSmoothing) {
            _stopSmoothing();
          }
          _syncOffsets();
        }
        widget.onScrollStart?.call();
      } else if (notification is ScrollEndNotification) {
        if (_isDragging) {
          _isDragging = false;
          // Sync offsets after manual drag finishes
          _syncOffsets();
        }
        widget.onScrollEnd?.call();
      }
    }
    return false;
  }

  // ==========================================
  // --- Keyboard Handling ---
  // ==========================================

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return .ignored;
    if (!_resolvedController.hasClients) return .ignored;

    final double maxScroll = _resolvedController.position.maxScrollExtent;
    final double viewportDimension =
        _resolvedController.position.viewportDimension;

    // Use target offset as baseline when smooth is active (to stack keyboard
    // inputs on top of an in-flight smooth scroll), otherwise use actual offset.
    final double baseOffset = _isSmoothEnabled
        ? _targetOffset
        : _resolvedController.offset;

    double targetOffset = baseOffset;
    final isVertical = widget.direction == .vertical;

    if (isVertical) {
      if (event.logicalKey == .arrowDown) {
        targetOffset = (baseOffset + widget.keyboardScrollStep).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .arrowUp) {
        targetOffset = (baseOffset - widget.keyboardScrollStep).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .pageDown) {
        targetOffset = (baseOffset + viewportDimension).clamp(0.0, maxScroll);
      } else if (event.logicalKey == .pageUp) {
        targetOffset = (baseOffset - viewportDimension).clamp(0.0, maxScroll);
      } else {
        return .ignored;
      }
    } else {
      // Horizontal scrolling keys
      if (event.logicalKey == .arrowRight) {
        targetOffset = (baseOffset + widget.keyboardScrollStep).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .arrowLeft) {
        targetOffset = (baseOffset - widget.keyboardScrollStep).clamp(
          0.0,
          maxScroll,
        );
      } else if (event.logicalKey == .pageDown) {
        targetOffset = (baseOffset + viewportDimension).clamp(0.0, maxScroll);
      } else if (event.logicalKey == .pageUp) {
        targetOffset = (baseOffset - viewportDimension).clamp(0.0, maxScroll);
      } else {
        return .ignored;
      }
    }

    if (_isSmoothEnabled) {
      // Route through the smooth lerp engine
      _targetOffset = targetOffset;
      _startSmoothing();
    } else {
      final animations = JustThemeProvider.of(
        context,
        aspect: .animations,
      ).theme.animations;
      _resolvedController.animateTo(
        targetOffset,
        duration: animations.fast,
        curve: animations.defaultCurve,
      );
    }

    return .handled;
  }

  // ==========================================
  // --- Build ---
  // ==========================================

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

    final bool smoothEnabled = _isSmoothEnabled;

    // Create the viewport layout.
    // When smooth scroll is active, use NeverScrollableScrollPhysics to prevent
    // Flutter's built-in scroll physics from fighting with our lerp engine.
    Widget scrollView = SingleChildScrollView(
      controller: _resolvedController,
      scrollDirection: widget.direction,
      physics: smoothEnabled
          ? const NeverScrollableScrollPhysics()
          : widget.physics,
      padding: widget.padding,
      child: widget.child,
    );

    // Wrap with Listener to intercept pointer signal events (mouse wheel/trackpad)
    if (smoothEnabled) {
      scrollView = Listener(
        onPointerSignal: _handlePointerSignal,
        child: scrollView,
      );
    }

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
                                if (_isSmoothEnabled) {
                                  // Route through smooth engine for consistent feel
                                  _targetOffset = 0.0;
                                  _startSmoothing();
                                } else {
                                  _resolvedController.animateTo(
                                    0.0,
                                    duration: animations.normal,
                                    curve: animations.defaultCurve,
                                  );
                                }
                              },
                              builder:
                                  (
                                    BuildContext context,
                                    JustInteractionState state,
                                  ) {
                                    return FocusIndicator(
                                      isFocused: state.isFocusVisible,
                                      borderRadius: const .all(.circular(20.0)),
                                      child: Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: state.isPressed
                                              ? colors.borderDefault
                                              : (state.isHovered
                                                    ? colors.background
                                                    : colors.card),
                                          shape: .circle,
                                          border: .all(
                                            color: state.isFocused
                                                ? colors.borderFocus
                                                : colors.borderDefault,
                                            width: state.isFocused ? 2.0 : 1.0,
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
