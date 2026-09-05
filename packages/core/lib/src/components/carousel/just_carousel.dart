import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

import 'just_carousel_style.dart';
import 'just_carousel_theme.dart';

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
  Future<void> animateToPage(int page, {Duration? duration, Curve? curve}) async {
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
/// (horizontal & vertical), programmatic navigation via [JustCarouselController],
/// and safe lifecycle guards.
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

  JustCarouselController get _effectiveController =>
      widget.controller ??
      (_internalController ??=
          JustCarouselController(initialPage: widget.initialPage));

  bool get _isLooping => widget.loop && widget.children.length > 1;

  int _calculateVirtualPage(int realIndex) {
    if (!_isLooping) {
      return realIndex.clamp(0, math.max(0, widget.children.length - 1));
    }
    return (_kVirtualLoopMidpoint * widget.children.length) +
        (realIndex % widget.children.length);
  }

  void _initPageController() {
    final effectiveFraction =
        widget.style?.viewportFraction ?? widget.viewportFraction;
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
    _initPageController();
    _effectiveController._attach(this);
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
  }

  void _recreatePageController() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();

    final currentIndex = _effectiveController.currentIndex;
    final effectiveIndex = widget.children.isEmpty
        ? 0
        : currentIndex.clamp(0, widget.children.length - 1);

    final effectiveFraction =
        widget.style?.viewportFraction ?? widget.viewportFraction;
    final initialVirtual = _calculateVirtualPage(effectiveIndex);

    _pageController = PageController(
      initialPage: initialVirtual,
      viewportFraction: effectiveFraction,
    );
    _pageController.addListener(_onPageScroll);
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _effectiveController._detach(this);
    _internalController?.dispose();
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
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

    final theme =
        Theme.of(context).extension<JustCarouselTheme>() ?? .defaults;
    final animDuration = duration ??
        widget.style?.animationDuration ??
        theme.style?.animationDuration ??
        theme.animationDuration;
    final animCurve = curve ??
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

    final theme =
        Theme.of(context).extension<JustCarouselTheme>() ?? .defaults;
    final animDuration = duration ??
        widget.style?.animationDuration ??
        theme.style?.animationDuration ??
        theme.animationDuration;
    final animCurve = curve ??
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

    final theme =
        Theme.of(context).extension<JustCarouselTheme>() ?? .defaults;
    final animDuration = duration ??
        widget.style?.animationDuration ??
        theme.style?.animationDuration ??
        theme.animationDuration;
    final animCurve = curve ??
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

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemCount = _isLooping
        ? widget.children.length * _kVirtualLoopMultiplier
        : widget.children.length;

    return PageView.builder(
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
        return widget.children[realIndex];
      },
    );
  }
}
