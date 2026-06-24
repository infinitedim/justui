// justui-meta: registry=840b18272408dca9471db7828131cc467607959aa6aac6af9a0eddd3dae8b2f7 local=840b18272408dca9471db7828131cc467607959aa6aac6af9a0eddd3dae8b2f7
import 'package:flutter/widgets.dart';

/// A lightweight loading spinner built using CustomPaint and Animation primitives.
///
/// Ensures zero-Material-dependency by avoiding CircularProgressIndicator.
class JustProgressSpinner extends StatefulWidget {
  /// The diameter of the spinner.
  final double size;

  /// The color of the spinner stroke.
  final Color color;

  /// The thickness of the spinner line.
  final double strokeWidth;

  /// Creates a [JustProgressSpinner] indicator.
  const JustProgressSpinner({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  State<JustProgressSpinner> createState() => _JustProgressSpinnerState();
}

class _JustProgressSpinnerState extends State<JustProgressSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: RotationTransition(
        turns: _controller,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _SpinnerPainter(
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _SpinnerPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = .stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = .round;

    final Rect rect = .fromLTWH(0.0, 0.0, size.width, size.height);
    // Draw a 270 degree (3/4 of a circle) arc
    canvas.drawArc(rect, 0.0, 4.712, false, paint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
