import 'package:flutter/widgets.dart';

import 'duration.dart';

/// Spring Physics Tokens for Gesture & Reactive Animations.
abstract final class JustSpring {
  /// Snappy spring for controls, toggles, and micro-gestures.
  static const SpringDescription snappy = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 30.0,
  );

  /// Smooth spring for modals, cards, and bottom sheet drags.
  static const SpringDescription smooth = SpringDescription(
    mass: 1.0,
    stiffness: 220.0,
    damping: 25.0,
  );

  /// Expressive spring for organic bounce animations.
  static const SpringDescription expressive = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 14.0,
  );
}

/// A motion profile defining animation durations, curves, and physics.
///
/// Predefines profiles to drive different visual personalities (standard, snappy, neobrutalism, expressive, or reduced).
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

  /// Sharp exit curve for quick dismissals.
  final Curve sharp;

  /// Spring physics description for gesture-driven interactions.
  final SpringDescription springPhysics;

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
    this.sharp = JustCurves.sharp,
    this.springPhysics = JustSpring.snappy,
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
    sharp: JustCurves.sharp,
    springPhysics: JustSpring.snappy,
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
    spring: JustCurves.spring,
    sharp: JustCurves.sharp,
    springPhysics: JustSpring.expressive,
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
    sharp: JustCurves.sharp,
    springPhysics: JustSpring.snappy,
  );

  /// Snappy, mechanical motion profile specifically tailored for Neobrutalism UI.
  static const JustMotionProfile neobrutalism = JustMotionProfile(
    instant: Duration(milliseconds: 40),
    fast: Duration(milliseconds: 100),
    normal: Duration(milliseconds: 150),
    slow: Duration(milliseconds: 250),
    slower: Duration(milliseconds: 400),
    defaultCurve: Curves.linear,
    enter: Curves.easeOutQuad,
    exit: Curves.easeInQuad,
    spring: Curves.easeOutBack,
    sharp: Curves.linear,
    springPhysics: SpringDescription(mass: 0.5, stiffness: 600, damping: 40),
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
    sharp: Curves.linear,
    springPhysics: SpringDescription(mass: 1.0, stiffness: 1000, damping: 100),
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
          spring == other.spring &&
          sharp == other.sharp &&
          springPhysics == other.springPhysics;

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
    sharp,
    springPhysics,
  );
}
