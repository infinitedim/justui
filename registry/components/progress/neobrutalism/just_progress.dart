import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import 'just_progress_style.dart';
import 'just_progress_theme.dart';
import 'just_progress_variants.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// A custom progress indicator supporting linear and circular shapes,
/// with determinate and indeterminate states.
class JustProgress extends StatefulWidget {
  /// The current value of the progress (between [min] and [max]).
  /// If null, the progress indicator runs in an indeterminate loop.
  final double? value;

  /// The minimum value of the progress. Defaults to 0.0.
  final double min;

  /// The maximum value of the progress. Defaults to 1.0.
  final double max;

  /// The size classification.
  final JustProgressSize size;

  /// The visual shape variant (linear or circular).
  final JustProgressVariant variant;

  /// Whether to show the percentage or custom label.
  final bool showLabel;

  /// Custom label text override. If null, displays the percentage (e.g. "60%").
  final String? label;

  /// Per-instance style overrides.
  final JustProgressStyle? style;

  /// Custom animation duration for value transitions.
  final Duration? animationDuration;

  /// Default constructor creating a linear progress indicator.
  const JustProgress({
    super.key,
    this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.size = .md,
    this.showLabel = false,
    this.label,
    this.style,
    this.animationDuration,
  }) : variant = .linear;

  /// Named constructor creating a circular progress indicator.
  const JustProgress.circular({
    super.key,
    this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.size = .md,
    this.showLabel = false,
    this.label,
    this.style,
    this.animationDuration,
  }) : variant = .circular;

  @override
  State<JustProgress> createState() => _JustProgressState();
}

class _JustProgressState extends State<JustProgress>
    with SingleTickerProviderStateMixin {
  AnimationController? _indeterminateController;

  @override
  void initState() {
    super.initState();
    _updateAnimationController();
  }

  @override
  void didUpdateWidget(covariant JustProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationController();
  }

  void _updateAnimationController() {
    if (widget.value == null) {
      _indeterminateController ??= AnimationController(
        vsync: this,
        duration: JustDuration.slower,
      )..repeat();
    } else {
      _indeterminateController?.dispose();
      _indeterminateController = null;
    }
  }

  @override
  void dispose() {
    _indeterminateController?.dispose();
    super.dispose();
  }

  double get _fraction {
    if (widget.value == null) return 0.0;
    final val = widget.value!;
    final range = widget.max - widget.min;
    if (range <= 0) return 0.0;
    return ((val - widget.min) / range).clamp(0.0, 1.0);
  }

  String get _resolvedLabel {
    if (widget.label != null) return widget.label!;
    return '${(_fraction * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context).theme;
    final presetTokens = customTheme.presetTokens;
    final progressTheme = customTheme
        .toThemeData()
        .extension<JustProgressTheme>();
    final themeStyle = progressTheme?.style;

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final radius = customTheme.radius;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;

    // Resolve Style Properties
    final finalTrackColor =
        widget.style?.trackColor ??
        themeStyle?.trackColor ??
        (presetTokens.showsDefaultBorder
            ? const Color(0x00000000)
            : colors.borderDefault.withValues(alpha: 0.3));

    final finalFillColor =
        widget.style?.fillColor ??
        themeStyle?.fillColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderFocus);

    final finalLabelColor =
        widget.style?.labelColor ??
        themeStyle?.labelColor ??
        colors.textPrimary;

    // Build semantics
    return Semantics(
      container: true,
      label: 'Progress indicator',
      value: widget.value != null ? _resolvedLabel : 'Loading',
      child: widget.variant == .linear
          ? _buildLinear(
              context,
              colors,
              spacing,
              radius,
              typography,
              presetTokens,
              finalTrackColor,
              finalFillColor,
              finalLabelColor,
            )
          : _buildCircular(
              context,
              colors,
              spacing,
              radius,
              typography,
              presetTokens,
              finalTrackColor,
              finalFillColor,
              finalLabelColor,
            ),
    );
  }

  Widget _buildLinear(
    BuildContext context,
    JustColorScheme colors,
    JustSpacingScheme spacing,
    JustRadiusScheme radius,
    JustTypographyScheme typography,
    JustPresetTokens presetTokens,
    Color trackBg,
    Color fillBg,
    Color labelColor,
  ) {
    // Resolve height based on size
    double height;
    switch (widget.size) {
      case .sm:
        height = 4.0;
        break;
      case .md:
        height = 8.0;
        break;
      case .lg:
        height = 12.0;
        break;
    }

    final BorderRadius defaultRadius = presetTokens.showsDefaultBorder
        ? BorderRadius.zero
        : .all(radius.full);
    final finalRadius =
        widget.style?.borderRadius ??
        themeStyleBorderRadius(context) ??
        defaultRadius;

    final Widget bar = Container(
      height: height,
      decoration: BoxDecoration(
        color: trackBg,
        border: presetTokens.showsDefaultBorder
            ? Border.all(
                color: colors.textPrimary,
                width: presetTokens.borderWidth,
              )
            : null,
        borderRadius: finalRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (widget.value != null)
            // Determinate Linear Progress
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: _fraction),
              duration: widget.animationDuration ?? JustDuration.fast,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: fillBg,
                      borderRadius: finalRadius,
                    ),
                  ),
                );
              },
            )
          else
            // Indeterminate Linear Progress
            AnimatedBuilder(
              animation: _indeterminateController!,
              builder: (context, child) {
                final animVal = _indeterminateController!.value;
                // Sliding alignment from -1.5 to 1.5
                final alignmentX = -1.5 + (animVal * 3.0);
                return Align(
                  alignment: Alignment(alignmentX, 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: fillBg,
                        borderRadius: finalRadius,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );

    if (widget.showLabel) {
      return Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Expanded(child: bar),
              SizedBox(width: spacing.md),
              Text(
                _resolvedLabel,
                style:
                    (widget.size == .sm
                            ? typography.caption
                            : typography.bodySm)
                        .copyWith(
                          color: labelColor,
                          fontWeight: presetTokens.progressLabelWeight,
                        ),
              ),
            ],
          ),
        ],
      );
    }

    return bar;
  }

  Widget _buildCircular(
    BuildContext context,
    JustColorScheme colors,
    JustSpacingScheme spacing,
    JustRadiusScheme radius,
    JustTypographyScheme typography,
    JustPresetTokens presetTokens,
    Color trackBg,
    Color fillBg,
    Color labelColor,
  ) {
    // Resolve size dimensions
    double diameter;
    double defaultStrokeWidth;
    switch (widget.size) {
      case .sm:
        diameter = 32.0;
        break;
      case .md:
        diameter = 48.0;
        break;
      case .lg:
        diameter = 64.0;
        break;
    }
    defaultStrokeWidth = presetTokens.resolveProgressStrokeWidth(widget.size);

    final strokeWidth = widget.style?.strokeWidth ?? defaultStrokeWidth;

    Widget indicator;
    if (widget.value != null) {
      // Determinate Circular Progress
      indicator = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: _fraction),
        duration: widget.animationDuration ?? const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            size: Size(diameter, diameter),
            painter: _CircularProgressPainter(
              fraction: value,
              trackColor: trackBg,
              fillColor: fillBg,
              strokeWidth: strokeWidth,
            ),
          );
        },
      );
    } else {
      // Indeterminate Circular Progress
      indicator = RotationTransition(
        turns: _indeterminateController!,
        child: CustomPaint(
          size: Size(diameter, diameter),
          painter: _CircularProgressPainter(
            fraction: 0.75, // constant 3/4 circle spinning
            trackColor: trackBg,
            fillColor: fillBg,
            strokeWidth: strokeWidth,
          ),
        ),
      );
    }

    if (widget.showLabel && widget.value != null) {
      return SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            indicator,
            Text(
              _resolvedLabel,
              style:
                  (widget.size == .lg ? typography.bodySm : typography.caption)
                      .copyWith(
                        color: labelColor,
                        fontWeight: presetTokens.progressLabelWeight,
                      ),
            ),
          ],
        ),
      );
    }

    return SizedBox(width: diameter, height: diameter, child: indicator);
  }

  BorderRadius? themeStyleBorderRadius(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final progressTheme = theme.toThemeData().extension<JustProgressTheme>();
    return progressTheme?.style?.borderRadius;
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double fraction;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  const _CircularProgressPainter({
    required this.fraction,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw track
    if (trackColor.a > 0.0) {
      final trackPaint = Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, trackPaint);
    }

    // Draw fill progress arc
    if (fraction > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // start from top
        fraction * 2 * math.pi,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
