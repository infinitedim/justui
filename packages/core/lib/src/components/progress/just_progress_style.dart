import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustProgress].
class JustProgressStyle {
  /// Custom background color of the progress track.
  final Color? trackColor;

  /// Custom fill color of the active progress indicator.
  final Color? fillColor;

  /// Custom text color for the percentage label.
  final Color? labelColor;

  /// Custom stroke width (only applicable to circular progress).
  final double? strokeWidth;

  /// Custom border radius (only applicable to linear progress).
  final BorderRadius? borderRadius;

  /// Creates a [JustProgressStyle] override.
  const JustProgressStyle({
    this.trackColor,
    this.fillColor,
    this.labelColor,
    this.strokeWidth,
    this.borderRadius,
  });
}
