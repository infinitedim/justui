export 'package:flutter/widgets.dart' show Axis;

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
