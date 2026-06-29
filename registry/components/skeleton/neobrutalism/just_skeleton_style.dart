import 'package:flutter/widgets.dart';

/// Customized per-instance overrides for [JustSkeleton] styling.
class JustSkeletonStyle {
  /// Base background color of the shimmer shapes.
  final Color? backgroundColor;

  /// Highlight color of the sweep animation.
  final Color? shimmerColor;

  /// Duration of one complete shimmer animation cycle.
  final Duration? duration;

  /// Border radius applied to leaf elements with no explicit radius (like [Text]).
  final BorderRadius? fallbackRadius;

  /// Creates a [JustSkeletonStyle] override.
  const JustSkeletonStyle({
    this.backgroundColor,
    this.shimmerColor,
    this.duration,
    this.fallbackRadius,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JustSkeletonStyle &&
        other.backgroundColor == backgroundColor &&
        other.shimmerColor == shimmerColor &&
        other.duration == duration &&
        other.fallbackRadius == fallbackRadius;
  }

  @override
  int get hashCode =>
      Object.hash(backgroundColor, shimmerColor, duration, fallbackRadius);
}
