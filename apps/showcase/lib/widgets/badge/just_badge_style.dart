// justui-meta: registry=f94f7833c7b52d3727492ccd4e47e8dab8a413e9b8024491b684c996bce9c32f local=f94f7833c7b52d3727492ccd4e47e8dab8a413e9b8024491b684c996bce9c32f
import 'package:flutter/widgets.dart';

/// Customized per-instance overrides for [JustBadge] styling.
class JustBadgeStyle {
  /// Custom background color of the badge.
  final Color? backgroundColor;

  /// Custom text or icon color of the badge.
  final Color? foregroundColor;

  /// Custom border color of the badge.
  final Color? borderColor;

  /// Custom border radius of the badge.
  final BorderRadius? borderRadius;

  /// Custom padding inside the badge container.
  final EdgeInsetsGeometry? padding;

  /// Custom text style overrides.
  final TextStyle? textStyle;

  /// Custom pulse animation maximum scale factor for dot badges.
  final double? pulseScale;

  /// Creates a [JustBadgeStyle] override.
  const JustBadgeStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.pulseScale,
  });
}
