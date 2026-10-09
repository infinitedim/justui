// justui-meta: registry=f84f6e7fc1fdbfa607555590bf6c423bd2c86291ecf88f2625c8c14510df7a43 local=05d6d5c1285566012bdca27779894278e9d02e0a4d5dde85c74ad42f5afbca26
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
