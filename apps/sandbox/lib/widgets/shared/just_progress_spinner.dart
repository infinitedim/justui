// justui-meta: registry=9dd731b42752f06dc1450a74a852922170375f698372bb53400e4bc6a3aaf316 local=df43e1745b29363173428cfb810f53b07cf1612b86f872038bf96f48a14ba29a
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A lightweight loading spinner built using CustomPaint and Animation primitives.
///
/// Implements Material 3 variable arc sweep animation while maintaining
/// zero-Material-dependency.
class JustProgressSpinner extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final Color? trackColor;
  final String? semanticLabel;
  final bool excludeSemantics;

  const JustProgressSpinner({
    required this.size,
    required this.color,
    super.key,
    this.strokeWidth = 2.0,
    this.strokeCap = .round,
    this.trackColor,
    this.semanticLabel = 'Loading',
    this.excludeSemantics = false,
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
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget spinner = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
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

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final Color? trackColor;
  final double startAngle;
  final double sweepAngle;

  const _SpinnerPainter({
    required this.color,
    required this.strokeWidth,
    required this.strokeCap,
    this.trackColor,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = .fromLTWH(0.0, 0.0, size.width, size.height);

    if (trackColor != null) {
      final Paint trackPaint = Paint()
        ..color = trackColor!
        ..style = .stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, 0.0, math.pi * 2.0, false, trackPaint);
    }

    final Paint paint = Paint()
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
