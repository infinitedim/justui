import 'dart:async' show Timer;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart'
    show PointerScrollEvent, PointerSignalEvent;
import 'package:flutter/material.dart' show Icons, Theme;
import 'package:flutter/services.dart'
    show KeyDownEvent, KeyEvent, KeyRepeatEvent;
import 'package:flutter/widgets.dart';

import '../../../just_ui_core.dart';
import '../shared/_shared_focus_indicator.dart';
import 'just_carousel_style.dart';
import 'just_carousel_theme.dart';
import 'just_carousel_variants.dart';

export 'just_carousel_style.dart';
export 'just_carousel_theme.dart';
export 'just_carousel_variants.dart';

/// Virtual count multiplier used for infinite virtual looping.
///
/// Mathematical rationale: 1000 repetitions with an initial offset placed
/// exactly at midpoint (500) provides 500 bidirectional iterations, far exceeding
/// any human manual swiping session while preventing integer overflow or floating precision issues.
const int _kVirtualLoopMultiplier = 1000;
const int _kVirtualLoopMidpoint = 500;

/// Controller that coordinates page transitions, indexing, and animation states for [JustCarousel].
class JustCarouselController extends ChangeNotifier {
  /// Creates a controller with an optional [initialPage].
  JustCarouselController({int initialPage = 0})
    : _pageNotifier = ValueNotifier<int>(initialPage);

  _JustCarouselState? _state;
  final ValueNotifier<int> _pageNotifier;

  /// Currently active slide index in real items range (0 <= currentIndex < children.length).
  int get currentIndex => _pageNotifier.value;

  /// Reactive listenable for the current page index.
  ///
  /// Can be consumed by external widgets (e.g. thumbnail strips, progress bars, indicator dots)
  /// via [ValueListenableBuilder] to update without triggering rebuild cascades on the carousel itself.
  ValueListenable<int> get pageListenable => _pageNotifier;

  /// Whether this controller is currently attached to a live [JustCarousel] instance.
  bool get isAttached => _state != null;

  void _attach(_JustCarouselState state) {
    _state = state;
  }

  void _detach(_JustCarouselState state) {
    if (_state == state) {
      _state = null;
    }
  }

  void _updateIndex(int newIndex) {
    if (_pageNotifier.value == newIndex) return;
    _pageNotifier.value = newIndex;
    notifyListeners();
  }

  /// Navigates to the next slide.
  Future<void> next({Duration? duration, Curve? curve}) async {
    if (_state == null) return;
    await _state!._handleNext(duration: duration, curve: curve);
  }

  /// Navigates to the previous slide.
  Future<void> previous({Duration? duration, Curve? curve}) async {
    if (_state == null) return;
    await _state!._handlePrevious(duration: duration, curve: curve);
  }

  /// Smoothly animates to the specified [page] index with shortest modular geodesic routing.
  Future<void> animateToPage(
    int page, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (_state == null) return;
    await _state!._handleAnimateToPage(page, duration: duration, curve: curve);
  }

  /// Instantly jumps to the specified [page] index without animation.
  void jumpToPage(int page) {
    if (_state == null) return;
    _state!._handleJumpToPage(page);
  }

  @override
  void dispose() {
    _pageNotifier.dispose();
    super.dispose();
  }
}

/// A performant, accessible carousel widget built on Flutter's [PageView].
///
/// Features infinite virtual looping with modulo index mapping, dual-orientation support
/// (horizontal & vertical), auto-scrolling with hover/touch pause, interactive indicators
/// (dots, line, fraction), per-pixel slide transitions, desktop wheel & keyboard navigation,
/// and preset theming.
class JustCarousel extends StatefulWidget {
  /// Creates a [JustCarousel] instance.
  const JustCarousel({
    super.key,
    required this.children,
    this.controller,
    this.orientation = .horizontal,
    this.loop = true,
    this.viewportFraction = 1.0,
    this.initialPage = 0,
    this.onPageChanged,
    this.autoScroll,
    this.indicator,
    this.indicatorPosition,
    this.transition,
    this.transitionBuilder,
    this.interactiveIndicators,
    this.enableMouseWheel,
    this.enableKeyboardNavigation,
    this.showArrows,
    this.style,
    this.physics,
    this.clipBehavior = .hardEdge,
  });

  /// The list of slide widgets rendered in this carousel.
  final List<Widget> children;

  /// Programmatic controller to drive pagination, listen to index changes, and trigger animations.
  final JustCarouselController? controller;

  /// Scroll orientation axis (horizontal by default, or vertical for stories / news feeds).
  final Axis orientation;

  /// Whether the carousel wraps seamlessly in an infinite loop.
  ///
  /// Automatically disabled when [children.length] <= 1.
  final bool loop;

  /// Proportional fraction of the viewport occupied by each item.
  ///
  /// Defaults to 1.0 (full viewport). Values like 0.85 permit peeking at adjacent slides.
  final double viewportFraction;

  /// Initial item index visible upon mounting.
  final int initialPage;

  /// Callback fired whenever the active slide index changes.
  final ValueChanged<int>? onPageChanged;

  /// Configuration for automatic slide advancement.
  final JustCarouselAutoScroll? autoScroll;

  /// Visual display variant for page indicators.
  final JustCarouselIndicator? indicator;

  /// Relative placement of page indicators (inside vs outside slide bounds).
  final JustCarouselIndicatorPosition? indicatorPosition;

  /// Visual transition animation between adjacent slides.
  final JustCarouselTransition? transition;

  /// Optional custom builder function to transform each slide based on its continuous scroll progress.
  final Widget Function(BuildContext context, Widget child, double progress)?
  transitionBuilder;

  /// Whether clicking / tapping on an indicator dot directly navigates to that slide.
  final bool? interactiveIndicators;

  /// Whether pointer wheel / trackpad scroll gestures navigate slides on desktop/web.
  final bool? enableMouseWheel;

  /// Whether arrow keys and spacebar control navigation and playback.
  final bool? enableKeyboardNavigation;

  /// Whether visual previous/next navigation arrow buttons are rendered.
  final bool? showArrows;

  /// Per-instance visual style customization.
  final JustCarouselStyle? style;

  /// Custom scroll physics (e.g. [BouncingScrollPhysics], [ClampingScrollPhysics]).
  final ScrollPhysics? physics;

  /// Clip behavior applied to the scrollable viewport.
  final Clip clipBehavior;

  @override
  State<JustCarousel> createState() => _JustCarouselState();
}

class _JustCarouselState extends State<JustCarousel> {
  late PageController _pageController;
  JustCarouselController? _internalController;
  late final FocusNode _focusNode;

  Timer? _autoScrollTimer;
  bool _isHovered = false;
  bool _isInteracting = false;
  bool _isPausedManually = false;
  bool _isFocused = false;
  int _lastWheelTime = 0;

  JustCarouselController get _effectiveController =>
      widget.controller ??
      (_internalController ??= JustCarouselController(
        initialPage: widget.initialPage,
      ));

  bool get _isLooping => widget.loop && widget.children.length > 1;

  JustCarouselTheme get _theme =>
      Theme.of(context).extension<JustCarouselTheme>() ?? .defaults;

  JustCarouselAutoScroll? get _resolvedAutoScroll =>
      widget.autoScroll ??
      widget.style?.autoScroll ??
      _theme.style?.autoScroll ??
      _theme.autoScroll;

  int _calculateVirtualPage(int realIndex) {
    if (!_isLooping) {
      return realIndex.clamp(0, math.max(0, widget.children.length - 1));
    }
    return (_kVirtualLoopMidpoint * widget.children.length) +
        (realIndex % widget.children.length);
  }

  void _initPageController() {
    final effectiveFraction =
        widget.style?.viewportFraction ??
        _theme.style?.viewportFraction ??
        widget.viewportFraction;
    final initialVirtual = _calculateVirtualPage(widget.initialPage);
    _pageController = PageController(
      initialPage: initialVirtual,
      viewportFraction: effectiveFraction,
    );
    _pageController.addListener(_onPageScroll);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _initPageController();
    _effectiveController._attach(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAutoScroll();
    });
  }

  void _onFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(covariant JustCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      _effectiveController._attach(this);
    }

    final oldFraction =
        oldWidget.style?.viewportFraction ?? oldWidget.viewportFraction;
    final newFraction =
        widget.style?.viewportFraction ?? widget.viewportFraction;
    final lengthChanged = oldWidget.children.length != widget.children.length;
    final loopChanged = oldWidget.loop != widget.loop;
    final fractionChanged = oldFraction != newFraction;

    if (lengthChanged || loopChanged || fractionChanged) {
      _recreatePageController();
    }

    if (oldWidget.autoScroll != widget.autoScroll ||
        oldWidget.children.length != widget.children.length) {
      _resetAutoScroll();
    }
  }

  void _recreatePageController() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();

    final currentIndex = _effectiveController.currentIndex;
    final effectiveIndex = widget.children.isEmpty
        ? 0
        : currentIndex.clamp(0, widget.children.length - 1);

    final effectiveFraction =
        widget.style?.viewportFraction ??
        _theme.style?.viewportFraction ??
        widget.viewportFraction;
    final initialVirtual = _calculateVirtualPage(effectiveIndex);

    _pageController = PageController(
      initialPage: initialVirtual,
      viewportFraction: effectiveFraction,
    );
    _pageController.addListener(_onPageScroll);
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller?._detach(this);
    _effectiveController._detach(this);
    _internalController?.dispose();
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _stopAutoScroll();
    final config = _resolvedAutoScroll;
    if (config == null || widget.children.length <= 1) return;

    _autoScrollTimer = .periodic(config.interval, (_) {
      _onAutoScrollTick();
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _resetAutoScroll() {
    if (_resolvedAutoScroll == null) return;
    _startAutoScroll();
  }

  void _toggleAutoScrollPause() {
    setState(() {
      _isPausedManually = !_isPausedManually;
    });
  }

  void _onAutoScrollTick() {
    final config = _resolvedAutoScroll;
    if (config == null || !mounted) return;
    if (_isHovered && config.pauseOnHover) return;
    if (_isInteracting && config.pauseOnTouch) return;
    if (_isPausedManually) return;

    if (!_isLooping &&
        _effectiveController.currentIndex >= widget.children.length - 1) {
      _stopAutoScroll();
      return;
    }

    _handleNext(
      duration: config.animationDuration,
      curve: config.animationCurve,
    );
  }

  void _onPageScroll() {
    if (!_pageController.hasClients ||
        !_pageController.position.hasContentDimensions) {
      return;
    }
    final page = _pageController.page;
    if (page == null) return;

    final rounded = page.round();
    final realIndex = _isLooping
        ? rounded % widget.children.length
        : rounded.clamp(0, widget.children.length - 1);

    if (realIndex != _effectiveController.currentIndex) {
      _effectiveController._updateIndex(realIndex);
      widget.onPageChanged?.call(realIndex);
    }
  }

  Future<void> _handleNext({Duration? duration, Curve? curve}) async {
    if (widget.children.length <= 1) return;
    if (!_pageController.hasClients ||
        !_pageController.position.hasContentDimensions) {
      return;
    }

    final theme = _theme;
    final animDuration =
        duration ??
        widget.style?.animationDuration ??
        theme.style?.animationDuration ??
        theme.animationDuration;
    final animCurve =
        curve ??
        widget.style?.animationCurve ??
        theme.style?.animationCurve ??
        theme.animationCurve;

    if (_isLooping) {
      final currentV =
          _pageController.page?.round() ?? _pageController.initialPage;
      await _pageController.animateToPage(
        currentV + 1,
        duration: animDuration,
        curve: animCurve,
      );
      return;
    }

    final currentReal = _effectiveController.currentIndex;
    if (currentReal < widget.children.length - 1) {
      await _pageController.animateToPage(
        currentReal + 1,
        duration: animDuration,
        curve: animCurve,
      );
    }
  }

  Future<void> _handlePrevious({Duration? duration, Curve? curve}) async {
    if (widget.children.length <= 1) return;
    if (!_pageController.hasClients ||
        !_pageController.position.hasContentDimensions) {
      return;
    }

    final theme = _theme;
    final animDuration =
        duration ??
        widget.style?.animationDuration ??
        theme.style?.animationDuration ??
        theme.animationDuration;
    final animCurve =
        curve ??
        widget.style?.animationCurve ??
        theme.style?.animationCurve ??
        theme.animationCurve;

    if (_isLooping) {
      final currentV =
          _pageController.page?.round() ?? _pageController.initialPage;
      await _pageController.animateToPage(
        currentV - 1,
        duration: animDuration,
        curve: animCurve,
      );
      return;
    }

    final currentReal = _effectiveController.currentIndex;
    if (currentReal > 0) {
      await _pageController.animateToPage(
        currentReal - 1,
        duration: animDuration,
        curve: animCurve,
      );
    }
  }

  int _calculateTargetVirtualPage(int targetRealPage) {
    final length = widget.children.length;
    if (!_isLooping || length <= 1) {
      return targetRealPage.clamp(0, math.max(0, length - 1));
    }

    final targetNormalized = targetRealPage % length;
    final currentV =
        _pageController.page?.round() ?? _pageController.initialPage;
    final currentR = currentV % length;

    var diff = targetNormalized - currentR;
    final half = length / 2;
    if (diff > half) {
      diff -= length;
    } else if (diff < -half) {
      diff += length;
    }

    return currentV + diff;
  }

  Future<void> _handleAnimateToPage(
    int page, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (widget.children.isEmpty) return;
    if (!_pageController.hasClients ||
        !_pageController.position.hasContentDimensions) {
      return;
    }

    final theme = _theme;
    final animDuration =
        duration ??
        widget.style?.animationDuration ??
        theme.style?.animationDuration ??
        theme.animationDuration;
    final animCurve =
        curve ??
        widget.style?.animationCurve ??
        theme.style?.animationCurve ??
        theme.animationCurve;

    final targetV = _calculateTargetVirtualPage(page);
    await _pageController.animateToPage(
      targetV,
      duration: animDuration,
      curve: animCurve,
    );
  }

  void _handleJumpToPage(int page) {
    if (widget.children.isEmpty) return;
    if (!_pageController.hasClients ||
        !_pageController.position.hasContentDimensions) {
      return;
    }

    final targetV = _calculateTargetVirtualPage(page);
    _pageController.jumpToPage(targetV);
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    final effectiveMouseWheel =
        widget.enableMouseWheel ??
        widget.style?.enableMouseWheel ??
        _theme.style?.enableMouseWheel ??
        _theme.enableMouseWheel;
    if (!effectiveMouseWheel) return;
    if (event is! PointerScrollEvent) return;

    final delta = widget.orientation == .horizontal
        ? (event.scrollDelta.dx != 0
              ? event.scrollDelta.dx
              : event.scrollDelta.dy)
        : event.scrollDelta.dy;
    if (delta.abs() < 10.0) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastWheelTime < 250) return;
    _lastWheelTime = now;

    if (delta > 0) {
      _handleNext();
    } else {
      _handlePrevious();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final effectiveKeyboard =
        widget.enableKeyboardNavigation ??
        widget.style?.enableKeyboardNavigation ??
        _theme.style?.enableKeyboardNavigation ??
        _theme.enableKeyboardNavigation;
    if (!effectiveKeyboard) return .ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return .ignored;
    }

    final key = event.logicalKey;
    if (key == .space) {
      _toggleAutoScrollPause();
      return .handled;
    }

    if (widget.orientation == .horizontal) {
      if (key == .arrowLeft) {
        _handlePrevious();
        return .handled;
      }
      if (key == .arrowRight) {
        _handleNext();
        return .handled;
      }
    } else {
      if (key == .arrowUp) {
        _handlePrevious();
        return .handled;
      }
      if (key == .arrowDown) {
        _handleNext();
        return .handled;
      }
    }

    return .ignored;
  }

  Widget _buildBuiltInTransition(
    Widget child,
    double progress,
    JustCarouselTransition transition,
  ) {
    final absProgress = progress.abs().clamp(0.0, 1.0);
    switch (transition) {
      case .scale:
        final scale = 0.85 + (0.15 * (1.0 - absProgress));
        return Transform.scale(scale: scale, child: child);
      case .fade:
        final opacity = 0.4 + (0.6 * (1.0 - absProgress));
        return Opacity(opacity: opacity, child: child);
      case .slide:
      case .none:
        return child;
    }
  }

  Widget _buildIndicators(JustCarouselTheme theme) {
    final effectiveIndicator =
        widget.indicator ??
        widget.style?.indicator ??
        theme.style?.indicator ??
        theme.indicator;

    if (effectiveIndicator == .none || widget.children.length <= 1) {
      return const SizedBox.shrink();
    }

    switch (effectiveIndicator) {
      case .dots:
        return _buildDotsIndicator(theme);
      case .line:
        return _buildLineIndicator(theme);
      case .fraction:
        return _buildFractionIndicator(theme);
      case .none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDotsIndicator(JustCarouselTheme theme) {
    final colors = context.justColors;
    final isNeobrutalism = context.justPreset == .neobrutalism;

    final inactiveColor =
        widget.style?.indicatorColor ??
        theme.style?.indicatorColor ??
        theme.indicatorColor ??
        (isNeobrutalism ? colors.background : colors.borderDefault);
    final activeColor =
        widget.style?.activeIndicatorColor ??
        theme.style?.activeIndicatorColor ??
        theme.activeIndicatorColor ??
        (isNeobrutalism ? colors.textPrimary : colors.borderFocus);
    final indicatorSize =
        widget.style?.indicatorSize ??
        theme.style?.indicatorSize ??
        theme.indicatorSize;
    final activeIndicatorSize =
        widget.style?.activeIndicatorSize ??
        theme.style?.activeIndicatorSize ??
        theme.activeIndicatorSize;
    final spacing =
        widget.style?.indicatorSpacing ??
        theme.style?.indicatorSpacing ??
        theme.indicatorSpacing;
    final BorderRadius radius = isNeobrutalism
        ? .zero
        : (widget.style?.indicatorRadius ??
              theme.style?.indicatorRadius ??
              theme.indicatorRadius ??
              .circular(indicatorSize / 2));
    final isInteractive =
        widget.interactiveIndicators ??
        widget.style?.interactiveIndicators ??
        theme.style?.interactiveIndicators ??
        theme.interactiveIndicators;

    return ValueListenableBuilder<int>(
      valueListenable: _effectiveController.pageListenable,
      builder: (context, activeIndex, _) {
        final dotWidgets = <Widget>[];
        for (var i = 0; i < widget.children.length; i++) {
          final isActive = i == activeIndex;
          final width = isActive ? activeIndicatorSize : indicatorSize;
          final height = indicatorSize;

          Widget dot = AnimatedContainer(
            duration: isNeobrutalism
                ? Duration.zero
                : const Duration(milliseconds: 200),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: radius,
              border: isNeobrutalism
                  ? .all(width: 2.5, color: colors.textPrimary)
                  : null,
            ),
          );

          if (isInteractive) {
            dot = MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _effectiveController.animateToPage(i),
                behavior: .opaque,
                child: dot,
              ),
            );
          }

          dotWidgets.add(
            Semantics(
              button: isInteractive,
              label: 'Slide ${i + 1}',
              selected: isActive,
              child: dot,
            ),
          );
        }

        return Wrap(
          direction: widget.orientation == .horizontal
              ? .horizontal
              : .vertical,
          spacing: spacing,
          runSpacing: spacing,
          alignment: .center,
          children: dotWidgets,
        );
      },
    );
  }

  Widget _buildLineIndicator(JustCarouselTheme theme) {
    final colors = context.justColors;
    final isNeobrutalism = context.justPreset == .neobrutalism;

    final inactiveColor =
        widget.style?.indicatorColor ??
        theme.style?.indicatorColor ??
        theme.indicatorColor ??
        (isNeobrutalism ? colors.background : colors.borderDefault);
    final activeColor =
        widget.style?.activeIndicatorColor ??
        theme.style?.activeIndicatorColor ??
        theme.activeIndicatorColor ??
        (isNeobrutalism ? colors.textPrimary : colors.borderFocus);
    final spacing =
        widget.style?.indicatorSpacing ??
        theme.style?.indicatorSpacing ??
        theme.indicatorSpacing;
    final isInteractive =
        widget.interactiveIndicators ??
        widget.style?.interactiveIndicators ??
        theme.style?.interactiveIndicators ??
        theme.interactiveIndicators;

    return ValueListenableBuilder<int>(
      valueListenable: _effectiveController.pageListenable,
      builder: (context, activeIndex, _) {
        final segments = <Widget>[];
        for (var i = 0; i < widget.children.length; i++) {
          final isActive = i == activeIndex;
          Widget segment = AnimatedContainer(
            duration: isNeobrutalism
                ? Duration.zero
                : const Duration(milliseconds: 200),
            height: 4.0,
            width: 24.0,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: isNeobrutalism ? .zero : const .all(.circular(2.0)),
              border: isNeobrutalism
                  ? .all(width: 1.5, color: colors.textPrimary)
                  : null,
            ),
          );

          if (isInteractive) {
            segment = MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _effectiveController.animateToPage(i),
                child: segment,
              ),
            );
          }

          segments.add(
            Semantics(
              button: isInteractive,
              label: 'Slide ${i + 1}',
              selected: isActive,
              child: segment,
            ),
          );
        }

        return Wrap(
          direction: widget.orientation == .horizontal
              ? .horizontal
              : .vertical,
          spacing: spacing,
          runSpacing: spacing,
          alignment: .center,
          children: segments,
        );
      },
    );
  }

  Widget _buildFractionIndicator(JustCarouselTheme theme) {
    final colors = context.justColors;
    final typo = context.justTypo;
    final isNeobrutalism = context.justPreset == .neobrutalism;

    return ValueListenableBuilder<int>(
      valueListenable: _effectiveController.pageListenable,
      builder: (context, activeIndex, _) {
        return Container(
          padding: const .symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isNeobrutalism
                ? colors.card
                : colors.background.withValues(alpha: 0.85),
            borderRadius: isNeobrutalism ? .zero : const .all(.circular(12.0)),
            border: .all(
              width: isNeobrutalism ? 2.5 : 1.0,
              color: isNeobrutalism ? colors.textPrimary : colors.borderDefault,
            ),
          ),
          child: Text(
            '${activeIndex + 1} / ${widget.children.length}',
            style: typo.bodySm.copyWith(
              color: colors.textPrimary,
              fontWeight: .w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildArrowButton({
    required bool isNext,
    required JustCarouselTheme theme,
  }) {
    final colors = context.justColors;
    final isNeobrutalism = context.justPreset == .neobrutalism;
    final arrowSize =
        widget.style?.arrowSize ?? theme.style?.arrowSize ?? theme.arrowSize;
    final BorderRadius arrowRadius = isNeobrutalism
        ? .zero
        : (widget.style?.arrowRadius ??
              theme.style?.arrowRadius ??
              theme.arrowRadius ??
              .circular(arrowSize / 2));

    final iconData = widget.orientation == .horizontal
        ? (isNext ? Icons.chevron_right_rounded : Icons.chevron_left_rounded)
        : (isNext
              ? Icons.keyboard_arrow_down_rounded
              : Icons.keyboard_arrow_up_rounded);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isNext ? _handleNext : _handlePrevious,
        behavior: .opaque,
        child: Semantics(
          button: true,
          label: isNext ? 'Next slide' : 'Previous slide',
          child: Container(
            width: arrowSize,
            height: arrowSize,
            decoration: BoxDecoration(
              color: colors.background.withValues(
                alpha: isNeobrutalism ? 1.0 : 0.85,
              ),
              borderRadius: arrowRadius,
              border: .all(
                width: isNeobrutalism ? 2.5 : 1.0,
                color: isNeobrutalism
                    ? colors.textPrimary
                    : colors.borderDefault,
              ),
              boxShadow: isNeobrutalism
                  ? [
                      BoxShadow(
                        color: colors.textPrimary,
                        offset: const Offset(2.0, 2.0),
                        blurRadius: 0.0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                iconData,
                size: arrowSize * 0.55,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = _theme;
    final effectiveTransition =
        widget.transition ??
        widget.style?.transition ??
        theme.style?.transition ??
        theme.transition;
    final effectiveIndicatorPosition =
        widget.indicatorPosition ??
        widget.style?.indicatorPosition ??
        theme.style?.indicatorPosition ??
        theme.indicatorPosition;
    final effectiveShowArrows =
        widget.showArrows ??
        widget.style?.showArrows ??
        theme.style?.showArrows ??
        theme.showArrows;

    final itemCount = _isLooping
        ? widget.children.length * _kVirtualLoopMultiplier
        : widget.children.length;

    final Widget pageView = PageView.builder(
      key: widget.key,
      scrollDirection: widget.orientation,
      controller: _pageController,
      physics: widget.physics,
      clipBehavior: widget.clipBehavior,
      itemCount: itemCount,
      itemBuilder: (context, virtualIndex) {
        final realIndex = _isLooping
            ? virtualIndex % widget.children.length
            : virtualIndex;
        final child = widget.children[realIndex];

        if (effectiveTransition == .none && widget.transitionBuilder == null) {
          return child;
        }

        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, _) {
            double progress = 0.0;
            if (_pageController.hasClients &&
                _pageController.position.hasContentDimensions) {
              final page =
                  _pageController.page ??
                  _calculateVirtualPage(widget.initialPage).toDouble();
              progress = page - virtualIndex;
            }

            if (widget.transitionBuilder != null) {
              return widget.transitionBuilder!(context, child, progress);
            }

            return _buildBuiltInTransition(
              child,
              progress,
              effectiveTransition,
            );
          },
        );
      },
    );

    final Widget viewportStack = Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: pageView),
        if (effectiveIndicatorPosition == .inside)
          Positioned(
            left: widget.orientation == .horizontal ? 0.0 : null,
            right: 0.0,
            bottom: widget.orientation == .horizontal ? 12.0 : 0.0,
            top: widget.orientation == .vertical ? 0.0 : null,
            child: Center(child: _buildIndicators(theme)),
          ),
        if (effectiveShowArrows && widget.children.length > 1) ...[
          Positioned(
            left: widget.orientation == .horizontal ? 8.0 : 0.0,
            right: widget.orientation == .horizontal ? null : 0.0,
            top: widget.orientation == .horizontal ? 0.0 : 8.0,
            bottom: widget.orientation == .horizontal ? 0.0 : null,
            child: Center(
              child: _buildArrowButton(isNext: false, theme: theme),
            ),
          ),
          Positioned(
            right: widget.orientation == .horizontal ? 8.0 : 0.0,
            left: widget.orientation == .horizontal ? null : 0.0,
            bottom: widget.orientation == .horizontal ? 0.0 : 8.0,
            top: widget.orientation == .horizontal ? null : 0.0,
            child: Center(child: _buildArrowButton(isNext: true, theme: theme)),
          ),
        ],
      ],
    );

    Widget content;
    if (effectiveIndicatorPosition == .outside) {
      final isHorizontal = widget.orientation == .horizontal;
      content = Flex(
        direction: isHorizontal ? .vertical : .horizontal,
        children: [
          Expanded(child: viewportStack),
          Padding(
            padding: const .all(8.0),
            child: Center(child: _buildIndicators(theme)),
          ),
        ],
      );
    } else {
      content = viewportStack;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _isInteracting = true;
        } else if (notification is ScrollEndNotification) {
          _isInteracting = false;
          _resetAutoScroll();
        }
        return false;
      },
      child: MouseRegion(
        onEnter: (_) {
          _isHovered = true;
        },
        onExit: (_) {
          _isHovered = false;
        },
        child: Listener(
          onPointerSignal: _handlePointerSignal,
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _handleKeyEvent,
            child: FocusIndicator(
              isFocused: _isFocused,
              borderRadius: context.justPreset == .neobrutalism
                  ? .zero
                  : const .all(.circular(8.0)),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
