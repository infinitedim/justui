import 'package:flutter/material.dart' show ThemeExtension;

import 'just_skeleton_style.dart';

/// Global theme configuration for skeletons, extending Flutter's [ThemeExtension].
class JustSkeletonTheme extends ThemeExtension<JustSkeletonTheme> {
  /// The global base style override for all skeletons.
  final JustSkeletonStyle? style;

  /// Creates a [JustSkeletonTheme] configuration.
  const JustSkeletonTheme({this.style});

  /// Default configuration for the theme.
  static const defaults = JustSkeletonTheme();

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
