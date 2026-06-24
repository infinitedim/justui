import 'package:flutter/widgets.dart';

/// A decorator widget that draws a 2px focus ring around its child.
class FocusIndicator extends StatelessWidget {
  /// Whether the focused state is active.
  final bool isFocused;

  /// The color of the focus ring.
  final Color focusColor;

  /// The radius boundary of the element.
  final BorderRadius borderRadius;

  /// The child layout.
  final Widget child;

  /// Creates a [FocusIndicator].
  const FocusIndicator({
    super.key,
    required this.isFocused,
    required this.focusColor,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFocused) return child;
    return CustomPaint(
      foregroundPainter: _FocusRingPainter(
        color: focusColor,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  final Color color;
  final BorderRadius borderRadius;

  const _FocusRingPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = .stroke
      ..strokeWidth = 2.0;

    // Expand rect by 3px offset to draw the ring outside the element bounds
    final Rect rect = .fromLTWH(
      -3.0,
      -3.0,
      size.width + 6.0,
      size.height + 6.0,
    );
    final RRect rrect = .fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft + const .circular(3.0),
      topRight: borderRadius.topRight + const .circular(3.0),
      bottomLeft: borderRadius.bottomLeft + const .circular(3.0),
      bottomRight: borderRadius.bottomRight + const .circular(3.0),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
