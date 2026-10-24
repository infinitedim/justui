// justui-meta: registry=a79c7696649d11f379e41c2da66d1398071c14f885aa1ceb0ae26040cf7cf673 local=78d7f3b0f78c40001530c40b4400e15906b1ce0045e2a637c93eadf096eb8472
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

  const JustSkeletonStyle({
    this.backgroundColor,
    this.shimmerColor,
    this.duration,
    this.fallbackRadius,
  });
}
