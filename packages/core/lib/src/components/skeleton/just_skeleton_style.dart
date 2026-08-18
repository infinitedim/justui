import 'package:flutter/widgets.dart';

/// Customized per-instance overrides for [JustSkeleton] styling.
class const JustSkeletonStyle({
  /// Base background color of the shimmer shapes.
  final Color? backgroundColor,

  /// Highlight color of the sweep animation.
  final Color? shimmerColor,

  /// Duration of one complete shimmer animation cycle.
  final Duration? duration,

  /// Border radius applied to leaf elements with no explicit radius (like [Text]).
  final BorderRadius? fallbackRadius,
});
