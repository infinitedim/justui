// justui-meta: registry=a9fa5102b62a4241cbe553c1adfd60b5a71b61969fc3c5713a3cfb494a6da3c4 local=a9fa5102b62a4241cbe553c1adfd60b5a71b61969fc3c5713a3cfb494a6da3c4
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustProgress].
class const JustProgressStyle({
  /// Custom background color of the progress track.
  final Color? trackColor,

  /// Custom fill color of the active progress indicator.
  final Color? fillColor,

  /// Custom text color for the percentage label.
  final Color? labelColor,

  /// Custom stroke width (only applicable to circular progress).
  final double? strokeWidth,

  /// Custom border radius (only applicable to linear progress).
  final BorderRadius? borderRadius,
});
