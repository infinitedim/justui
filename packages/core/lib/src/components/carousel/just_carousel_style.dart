import 'package:flutter/widgets.dart';

import 'just_carousel_variants.dart';

/// Customized per-instance visual styles for [JustCarousel].
class const JustCarouselStyle({
  /// Visible fraction of the viewport occupied by each slide item (0.0 < fraction <= 1.0).
  final double? viewportFraction,

  /// Duration for programmatic or auto-scrolling page transitions.
  final Duration? animationDuration,

  /// Animation curve used for animated transitions between slides.
  final Curve? animationCurve,

  /// Visual display variant for page indicators.
  final JustCarouselIndicator? indicator,

  /// Relative placement of page indicators (inside vs outside slide bounds).
  final JustCarouselIndicatorPosition? indicatorPosition,

  /// Visual transition animation between adjacent slides.
  final JustCarouselTransition? transition,

  /// Inactive background color of indicator items.
  final Color? indicatorColor,

  /// Active background color of current indicator item.
  final Color? activeIndicatorColor,

  /// Size / diameter in pixels of inactive indicator items.
  final double? indicatorSize,

  /// Size / diameter in pixels of the active indicator item.
  final double? activeIndicatorSize,

  /// Spacing in pixels separating adjacent indicator items.
  final double? indicatorSpacing,

  /// Border radius applied to indicator items.
  final BorderRadius? indicatorRadius,
}) {
  /// Returns a copy with given fields replaced.
  JustCarouselStyle copyWith({
    double? viewportFraction,
    Duration? animationDuration,
    Curve? animationCurve,
    JustCarouselIndicator? indicator,
    JustCarouselIndicatorPosition? indicatorPosition,
    JustCarouselTransition? transition,
    Color? indicatorColor,
    Color? activeIndicatorColor,
    double? indicatorSize,
    double? activeIndicatorSize,
    double? indicatorSpacing,
    BorderRadius? indicatorRadius,
  }) {
    return JustCarouselStyle(
      viewportFraction: viewportFraction ?? this.viewportFraction,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      indicator: indicator ?? this.indicator,
      indicatorPosition: indicatorPosition ?? this.indicatorPosition,
      transition: transition ?? this.transition,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      activeIndicatorColor: activeIndicatorColor ?? this.activeIndicatorColor,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      activeIndicatorSize: activeIndicatorSize ?? this.activeIndicatorSize,
      indicatorSpacing: indicatorSpacing ?? this.indicatorSpacing,
      indicatorRadius: indicatorRadius ?? this.indicatorRadius,
    );
  }

  /// Linearly interpolates between two [JustCarouselStyle] instances.
  static JustCarouselStyle? lerp(
    JustCarouselStyle? a,
    JustCarouselStyle? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;

    return JustCarouselStyle(
      viewportFraction: b.viewportFraction != null && a.viewportFraction != null
          ? a.viewportFraction! +
                (b.viewportFraction! - a.viewportFraction!) * t
          : (t < 0.5 ? a.viewportFraction : b.viewportFraction),
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration,
      animationCurve: t < 0.5 ? a.animationCurve : b.animationCurve,
      indicator: t < 0.5 ? a.indicator : b.indicator,
      indicatorPosition: t < 0.5 ? a.indicatorPosition : b.indicatorPosition,
      transition: t < 0.5 ? a.transition : b.transition,
      indicatorColor: Color.lerp(a.indicatorColor, b.indicatorColor, t),
      activeIndicatorColor: Color.lerp(
        a.activeIndicatorColor,
        b.activeIndicatorColor,
        t,
      ),
      indicatorSize: b.indicatorSize != null && a.indicatorSize != null
          ? a.indicatorSize! + (b.indicatorSize! - a.indicatorSize!) * t
          : (t < 0.5 ? a.indicatorSize : b.indicatorSize),
      activeIndicatorSize:
          b.activeIndicatorSize != null && a.activeIndicatorSize != null
          ? a.activeIndicatorSize! +
                (b.activeIndicatorSize! - a.activeIndicatorSize!) * t
          : (t < 0.5 ? a.activeIndicatorSize : b.activeIndicatorSize),
      indicatorSpacing: b.indicatorSpacing != null && a.indicatorSpacing != null
          ? a.indicatorSpacing! +
                (b.indicatorSpacing! - a.indicatorSpacing!) * t
          : (t < 0.5 ? a.indicatorSpacing : b.indicatorSpacing),
      indicatorRadius: BorderRadius.lerp(
        a.indicatorRadius,
        b.indicatorRadius,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustCarouselStyle &&
          runtimeType == other.runtimeType &&
          viewportFraction == other.viewportFraction &&
          animationDuration == other.animationDuration &&
          animationCurve == other.animationCurve &&
          indicator == other.indicator &&
          indicatorPosition == other.indicatorPosition &&
          transition == other.transition &&
          indicatorColor == other.indicatorColor &&
          activeIndicatorColor == other.activeIndicatorColor &&
          indicatorSize == other.indicatorSize &&
          activeIndicatorSize == other.activeIndicatorSize &&
          indicatorSpacing == other.indicatorSpacing &&
          indicatorRadius == other.indicatorRadius;

  @override
  int get hashCode => Object.hash(
    viewportFraction,
    animationDuration,
    animationCurve,
    indicator,
    indicatorPosition,
    transition,
    indicatorColor,
    activeIndicatorColor,
    indicatorSize,
    activeIndicatorSize,
    indicatorSpacing,
    indicatorRadius,
  );
}
