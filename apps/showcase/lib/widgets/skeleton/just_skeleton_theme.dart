// justui-meta: registry=f84f6e7fc1fdbfa607555590bf6c423bd2c86291ecf88f2625c8c14510df7a43 local=2811d3c36f5a10c4347145a95718e97791984122dd33fa896f5746ab7602c172
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_skeleton_style.dart';

/// Global theme configuration for skeletons, extending Flutter's [ThemeExtension].
class JustSkeletonTheme extends ThemeExtension<JustSkeletonTheme> {
  /// The global base style override for all skeletons.
  final JustSkeletonStyle? style;

  const JustSkeletonTheme({this.style});

  /// Default configuration for the theme.
  static const JustSkeletonTheme defaults = JustSkeletonTheme();

  @override
  JustSkeletonTheme copyWith({JustSkeletonStyle? style}) {
    return JustSkeletonTheme(style: style ?? this.style);
  }

  @override
  JustSkeletonTheme lerp(ThemeExtension<JustSkeletonTheme>? other, double t) {
    if (other is! JustSkeletonTheme) return this;
    return t < 0.5 ? this : other;
  }
}
