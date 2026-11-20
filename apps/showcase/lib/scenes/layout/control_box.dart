import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// The bordered control frame the docs demos put around the resizable panes
/// (`controlBox` in `kit-panes.tsx`).
///
/// Core's resizable container draws no outer border of its own, so the scene
/// adds the control frame: card fill, control border (ink in neobrutalism) at
/// the preset width, and the preset's control radius. Content clips inside.
class const ControlBox({
  super.key,

  /// Content of the frame.
  required final Widget child,

  /// Fixed width of the frame.
  final double? width,

  /// Fixed height of the frame.
  final double? height,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustPresetTokens tokens = context.justPresetTokens;
    final BorderRadius radius = tokens.resolveBorderRadius(context.justRadius);
    final double line = tokens.borderWidth;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: radius,
        border: .all(
          color: tokens.showsDefaultBorder
              ? colors.textPrimary
              : colors.borderDefault,
          width: line,
        ),
      ),
      child: ClipRRect(
        // The preset radius is uniform; the inner corner follows the border.
        borderRadius: .all(.circular(math.max(0, radius.topLeft.x - line))),
        child: child,
      ),
    );
  }
}
