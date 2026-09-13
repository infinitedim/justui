// justui-meta: registry=89d6056d064cf2f6a7c630ab7b703702ddd40a16d9f8d106944a8f845cffbeae local=89d6056d064cf2f6a7c630ab7b703702ddd40a16d9f8d106944a8f845cffbeae
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_skeleton_style.dart';

/// Global theme configuration for skeletons, extending Flutter's [ThemeExtension].
class const JustSkeletonTheme({
  /// The global base style override for all skeletons.
  final JustSkeletonStyle? style,
}) extends ThemeExtension<JustSkeletonTheme> {
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
