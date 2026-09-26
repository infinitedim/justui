// justui-meta: registry=a8f67914d14cc52293dd5857099377fdd4a0aa271750b08dea7b15bd2a0fd85f local=a0b686fbeaf857419f98d3e3c4f6134befd794aa92d79bb0aae9092770661b7e
import 'package:flutter/widgets.dart';
import 'package:showcase/core/theme/preset_tokens.dart';
import 'package:showcase/tokens/just_ui_tokens.dart'
    show JustColorScheme, JustMotionProfile;

import 'package:showcase/core/just_ui_core.dart';

/// A decorator widget that draws a focus ring around its child with smooth animation.
class FocusIndicator extends StatelessWidget {
  final bool isFocused;
  final BorderRadius borderRadius;
  final Widget child;

  const FocusIndicator({
    required this.isFocused,
    required this.borderRadius,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = JustThemeProvider.of(
      context,
      aspect: .colors,
    ).theme.colors;
    final JustMotionProfile animations = JustThemeProvider.of(
      context,
      aspect: .animations,
    ).theme.animations;
    final JustPresetTokens presetTokens = JustThemeProvider.of(context)
        .theme
        .presetTokens;
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    final Color focusColor = presetTokens.showsDefaultBorder
        ? colors.textPrimary
        : colors.borderFocus;
    final double strokeWidth = presetTokens.showsDefaultBorder
        ? presetTokens.borderWidth
        : 2.0;

    return TweenAnimationBuilder<double>(
      duration: disableAnimations ? Duration.zero : animations.fast,
      tween: Tween<double>(begin: 0.0, end: isFocused ? 1.0 : 0.0),
      builder: (BuildContext context, double value, Widget? child) {
        return CustomPaint(
          foregroundPainter: value > 0.001
              ? _FocusRingPainter(
                  color: focusColor.withValues(alpha: value),
                  borderRadius: borderRadius,
                  strokeWidth: strokeWidth,
                )
              : null,
          child: child,
        );
      },
      child: child,
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  final Color color;
  final BorderRadius borderRadius;
  final double strokeWidth;

  const _FocusRingPainter({
    required this.color,
    required this.borderRadius,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = .stroke
      ..strokeWidth = strokeWidth;

    // Expand rect by offset to draw the ring outside the element bounds
    final double offset = strokeWidth + 1.0;
    final Rect rect = .fromLTWH(
      -offset,
      -offset,
      size.width + (offset * 2),
      size.height + (offset * 2),
    );
    final RRect rrect = .fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft + .circular(offset),
      topRight: borderRadius.topRight + .circular(offset),
      bottomLeft: borderRadius.bottomLeft + .circular(offset),
      bottomRight: borderRadius.bottomRight + .circular(offset),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
