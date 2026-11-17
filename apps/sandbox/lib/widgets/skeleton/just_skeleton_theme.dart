// justui-meta: registry=72ba13171090d8115f0a92e8729d9ea639f8ab5b35c897096490bf0e0c4cea3b local=88c6bf4eb040756139bf557c79dcd5bd33b31130f832b58b33d60992e8fa3dd8
import 'package:material_ui/material_ui.dart' show ThemeExtension;

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
