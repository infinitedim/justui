import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A lightweight loading spinner built using CustomPaint and Animation primitives.
///
/// Implements Material 3 variable arc sweep animation while maintaining
/// zero-Material-dependency.
class const JustProgressSpinner({
  required final double size,
  required final Color color,
  super.key,
  final double strokeWidth = 2.0,
  final StrokeCap strokeCap = .round,
  final Color? trackColor,
  final String? semanticLabel = 'Loading',
  final bool excludeSemantics = false,
}) extends StatefulWidget {
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
      duration: const Duration(milliseconds: 1333),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget spinner = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double value = disableAnimations ? 0.5 : _controller.value;
          // Variable arc sweep oscillation (M3 style: expands & contracts)
          final double headValue = CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.75, curve: Curves.fastOutSlowIn),
          ).value;
          final double tailValue = CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn),
          ).value;

          final double rotationAngle = disableAnimations
              ? 0.0
              : value * 2.0 * math.pi;
          final double sweepAngle = disableAnimations
              ? math.pi * 1.5
              : (headValue - tailValue).abs() * 1.75 * math.pi +
                    (math.pi * 0.1);
          final double startAngle = disableAnimations
              ? 0.0
              : rotationAngle + (tailValue * 1.75 * math.pi);

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _SpinnerPainter(
                color: widget.color,
                strokeWidth: widget.strokeWidth,
                strokeCap: widget.strokeCap,
                trackColor: widget.trackColor,
                startAngle: startAngle,
                sweepAngle: sweepAngle,
              ),
            ),
          );
        },
      ),
    );

    if (!widget.excludeSemantics && widget.semanticLabel != null) {
      spinner = Semantics(
        label: widget.semanticLabel,
        container: true,
        child: spinner,
      );
    }

    return spinner;
  }
}

class const _SpinnerPainter({
  required final Color color,
  required final double strokeWidth,
  required final StrokeCap strokeCap,
  final Color? trackColor,
  required final double startAngle,
  required final double sweepAngle,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = .fromLTWH(0.0, 0.0, size.width, size.height);

    if (trackColor != null) {
      final trackPaint = Paint()
        ..color = trackColor!
        ..style = .stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, 0.0, math.pi * 2.0, false, trackPaint);
    }

    final paint = Paint()
      ..color = color
      ..style = .stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.strokeCap != strokeCap ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle;
  }
}
