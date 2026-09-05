export 'package:flutter/widgets.dart' show Axis, Curve;

import 'package:flutter/widgets.dart' show Curve;

/// Visual indicator display styles for [JustCarousel].
enum JustCarouselIndicator {
  /// Circular dots or pills indicating current page.
  dots,

  /// Continuous progress bar or line segmented across pages.
  line,

  /// Textual numeric fraction display (e.g. "2 / 5").
  fraction,

  /// No visual page indicators rendered.
  none,
}

/// Placement position for carousel indicators relative to the slide viewport.
enum JustCarouselIndicatorPosition {
  /// Rendered overlapping inside the slide viewport bounds.
  inside,

  /// Rendered outside the slide viewport bounds (adjacent in flex layout).
  outside,
}

/// Slide transition animation effects for [JustCarousel].
enum JustCarouselTransition {
  /// Standard page-turn without scale or opacity morphing.
  none,

  /// Linear slide translation along the scroll axis.
  slide,

  /// Subtly scales inactive neighboring slides down.
  scale,

  /// Cross-fades opacity between incoming and outgoing slides.
  fade,
}

/// Configuration options for automatic slide advancement in [JustCarousel].
class const JustCarouselAutoScroll({
  /// Interval between automatic page transitions. Defaults to 4 seconds.
  final Duration interval = const Duration(seconds: 4),

  /// Optional custom animation duration for the auto-scroll transition.
  final Duration? animationDuration,

  /// Optional custom animation curve for the auto-scroll transition.
  final Curve? animationCurve,

  /// Whether auto-scrolling pauses when the pointer hovers over the carousel. Defaults to true.
  final bool pauseOnHover = true,

  /// Whether auto-scrolling pauses when the user drags or touches the carousel. Defaults to true.
  final bool pauseOnTouch = true,
}) {
  /// Default configuration for auto-scrolling.
  static const defaults = JustCarouselAutoScroll();

  /// Returns a copy with given fields replaced.
  JustCarouselAutoScroll copyWith({
    Duration? interval,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? pauseOnHover,
    bool? pauseOnTouch,
  }) {
    return JustCarouselAutoScroll(
      interval: interval ?? this.interval,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      pauseOnHover: pauseOnHover ?? this.pauseOnHover,
      pauseOnTouch: pauseOnTouch ?? this.pauseOnTouch,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustCarouselAutoScroll &&
          runtimeType == other.runtimeType &&
          interval == other.interval &&
          animationDuration == other.animationDuration &&
          animationCurve == other.animationCurve &&
          pauseOnHover == other.pauseOnHover &&
          pauseOnTouch == other.pauseOnTouch;

  @override
  int get hashCode => Object.hash(
    interval,
    animationDuration,
    animationCurve,
    pauseOnHover,
    pauseOnTouch,
  );
}
