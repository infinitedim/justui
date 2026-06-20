import 'package:flutter/widgets.dart';
import 'duration.dart';

/// A motion profile defining animation durations and curves.
///
/// Predefines profiles to drive different visual personalities (standard, snappy, expressive, or reduced).
class JustMotionProfile {
  /// Instant feedback duration (e.g. active/pressed states).
  final Duration instant;

  /// Fast duration (e.g. hover/focus transitions).
  final Duration fast;

  /// Normal duration (e.g. default collapses, switches, scale transitions).
  final Duration normal;

  /// Slow duration (e.g. page transitions or complex path animations).
  final Duration slow;

  /// Slower duration (e.g. sequential/orchestrated animations).
  final Duration slower;

  /// Default easing curve for general state transitions.
  final Curve defaultCurve;

  /// Entrance easing curve for sliding or scaling into view.
  final Curve enter;

  /// Exit easing curve for elements disappearing from view.
  final Curve exit;

  /// Springy easing curve for organic bounce animations.
  final Curve spring;

  /// Creates a [JustMotionProfile].
  const JustMotionProfile({
    required this.instant,
    required this.fast,
    required this.normal,
    required this.slow,
    required this.slower,
    required this.defaultCurve,
    required this.enter,
    required this.exit,
    required this.spring,
  });

  /// Resolves the motion profile contextually.
  ///
  /// Automatically returns [JustMotionProfile.reduced] if the system requests
  /// reduced motion via accessibility settings (e.g., [MediaQuery.disableAnimationsOf]).
  JustMotionProfile resolve(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return JustMotionProfile.reduced;
    }
    return this;
  }

  /// Standard balanced motion profile.
  static const JustMotionProfile standard = JustMotionProfile(
    instant: JustDuration.instant,
    fast: JustDuration.fast,
    normal: JustDuration.normal,
    slow: JustDuration.slow,
    slower: JustDuration.slower,
    defaultCurve: JustCurves.default_,
    enter: JustCurves.enter,
    exit: JustCurves.exit,
    spring: JustCurves.spring,
  );

  /// Expressive, springy, highly organic motion profile.
  static const JustMotionProfile expressive = JustMotionProfile(
    instant: JustDuration.instant,
    fast: Duration(milliseconds: 200),
    normal: Duration(milliseconds: 350),
    slow: Duration(milliseconds: 500),
    slower: Duration(milliseconds: 700),
    defaultCurve: Curves.easeInOutBack,
    enter: Curves.easeOutBack,
    exit: Curves.easeInBack,
    spring: Curves.elasticOut,
  );

  /// Compact, ultra-fast and snappy motion profile for dense layouts/dashboards.
  static const JustMotionProfile compact = JustMotionProfile(
    instant: JustDuration.instant,
    fast: Duration(milliseconds: 100),
    normal: Duration(milliseconds: 180),
    slow: Duration(milliseconds: 300),
    slower: Duration(milliseconds: 450),
    defaultCurve: Curves.easeOutQuad,
    enter: Curves.easeOutCubic,
    exit: Curves.easeInCubic,
    spring: Curves.easeOutBack,
  );

  /// Reduced motion profile for accessibility.
  ///
  /// Replaces animations with zero-duration state changes and linear eases.
  static const JustMotionProfile reduced = JustMotionProfile(
    instant: .zero,
    fast: .zero,
    normal: .zero,
    slow: .zero,
    slower: .zero,
    defaultCurve: Curves.linear,
    enter: Curves.linear,
    exit: Curves.linear,
    spring: Curves.linear,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustMotionProfile &&
          runtimeType == other.runtimeType &&
          instant == other.instant &&
          fast == other.fast &&
          normal == other.normal &&
          slow == other.slow &&
          slower == other.slower &&
          defaultCurve == other.defaultCurve &&
          enter == other.enter &&
          exit == other.exit &&
          spring == other.spring;

  @override
  int get hashCode => Object.hash(
        instant,
        fast,
        normal,
        slow,
        slower,
        defaultCurve,
        enter,
        exit,
        spring,
      );
}
