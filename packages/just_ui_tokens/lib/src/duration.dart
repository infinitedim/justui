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
}

/// Curve tokens for JustUI animations.
///
/// Exposes paired easing curves for entrance, exit, and elastic animations.
/// All values are compile-time constants.
abstract final class JustCurves {
  /// Default easing curve (easeInOut) for general state transitions
  static const Curve default_ = Curves.easeInOut;

  /// Entrance easing curve (easeOut) for sliding or scaling into view
  static const Curve enter = Curves.easeOut;

  /// Exit easing curve (easeIn) for elements disappearing from view
  static const Curve exit = Curves.easeIn;

  /// Springy easing curve (elasticOut) for organic bounce animations
  static const Curve spring = Curves.elasticOut;
}
