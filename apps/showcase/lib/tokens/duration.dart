import 'package:flutter/animation.dart';

/// Duration tokens for JustUI.
///
/// Exposes standard time ranges to be used for micro-feedbacks, hover states,
/// transitions, and complex animations.
/// All values are compile-time constants.
abstract final class JustDuration {
  /// Instant feedback duration (50ms) - active/pressed states
  static const Duration instant = Duration(milliseconds: 50);

  /// Fast duration (150ms) - hover/focus transitions
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal duration (250ms) - default collapses, switches, scale transitions
  static const Duration normal = Duration(milliseconds: 250);

  /// Slow duration (400ms) - page transitions or complex path animations
  static const Duration slow = Duration(milliseconds: 400);

  /// Slower duration (600ms) - sequential/orchestrated animations
  static const Duration slower = Duration(milliseconds: 600);

  /// Dynamically scales animation duration based on travel distance (in pixels).
  ///
  /// Uses a physics-based velocity constant (pixels per millisecond) to compute
  /// the ideal duration, clamped between [min] and [max] values.
  static Duration scaleForDistance(
    double distancePixels, {
    double speedPixelsPerMs = 1.5,
    Duration min = JustDuration.fast,
    Duration max = JustDuration.slow,
  }) {
    if (distancePixels <= 0) return min;
    final int durationMs = (distancePixels / speedPixelsPerMs).round();
    final int minMs = min.inMilliseconds;
    final int maxMs = max.inMilliseconds;
    final int clampedMs = durationMs.clamp(minMs, maxMs);
    return Duration(milliseconds: clampedMs);
  }
}

/// Curve tokens for JustUI animations.
///
/// Exposes functional easing curves for entrance, exit, standard movement, and physics.
/// All values are compile-time constants.
abstract final class JustCurves {
  // --- Material 3 / Modern Emphasized Set ---

  /// Emphasized curve for elements moving within screen bounds.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Emphasized decelerate curve for elements entering the viewport.
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Emphasized accelerate curve for elements exiting the viewport.
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  // --- Productive & Utility Set ---

  /// Standard ease-in-out for subtle micro-interactions.
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Standard decelerate for productive enter transitions.
  static const Curve standardDecelerate = Cubic(0.0, 0.0, 0.2, 1.0);

  /// Sharp exit curve for quick dismissals.
  static const Curve sharp = Cubic(0.4, 0.0, 0.6, 1.0);

  /// Controlled, enterprise-friendly low-overshoot spring curve.
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1.0);

  /// Mechanical / Snappy linear curve for Neobrutalism transitions.
  static const Curve mechanical = Curves.linear;

  // --- Backward Compatibility Aliases ---

  /// Default easing curve for general state transitions.
  static const Curve default_ = emphasized;

  /// Entrance easing curve for sliding or scaling into view.
  static const Curve enter = emphasizedDecelerate;

  /// Exit easing curve for elements disappearing from view.
  static const Curve exit = emphasizedAccelerate;
}
