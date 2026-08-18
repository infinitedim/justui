import 'package:flutter/widgets.dart';

import '../../theme/theme_provider.dart';

/// A decorator widget that draws a focus ring around its child with smooth animation.
class const FocusIndicator({
  required final bool isFocused,
  required final BorderRadius borderRadius,
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final animations = JustThemeProvider.of(
      context,
      aspect: .animations,
    ).theme.animations;
    final presetTokens = JustThemeProvider.of(context).theme.presetTokens;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final focusColor = presetTokens.showsDefaultBorder
        ? colors.textPrimary
        : colors.borderFocus;
    final strokeWidth = presetTokens.showsDefaultBorder
        ? presetTokens.borderWidth
        : 2.0;

    return TweenAnimationBuilder<double>(
      duration: disableAnimations ? Duration.zero : animations.fast,
      tween: Tween<double>(begin: 0.0, end: isFocused ? 1.0 : 0.0),
      builder: (context, value, child) {
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

class const _FocusRingPainter({
  required final Color color,
  required final BorderRadius borderRadius,
  final double strokeWidth = 2.0,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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
