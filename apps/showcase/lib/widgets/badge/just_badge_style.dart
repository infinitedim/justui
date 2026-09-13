// justui-meta: registry=f6fb80db7bc065b6e39da3bb3b1e59c6cd4ebadd114188ed63f5b5b671be65c9 local=f6fb80db7bc065b6e39da3bb3b1e59c6cd4ebadd114188ed63f5b5b671be65c9
import 'package:flutter/widgets.dart';

/// Customized per-instance overrides for [JustBadge] styling.
class const JustBadgeStyle({
  /// Custom background color of the badge.
  final Color? backgroundColor,

  /// Custom text or icon color of the badge.
  final Color? foregroundColor,

  /// Custom border color of the badge.
  final Color? borderColor,

  /// Custom border radius of the badge.
  final BorderRadius? borderRadius,

  /// Custom padding inside the badge container.
  final EdgeInsetsGeometry? padding,

  /// Custom text style overrides.
  final TextStyle? textStyle,

  /// Custom pulse animation maximum scale factor for dot badges.
  final double? pulseScale,
});
