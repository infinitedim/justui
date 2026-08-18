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
