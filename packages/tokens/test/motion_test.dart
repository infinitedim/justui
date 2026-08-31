import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Duration & Curve Tokens Validation', () {
    test('Duration static constants are positive', () {
      expect(JustDuration.instant.inMilliseconds, equals(50));
      expect(JustDuration.fast.inMilliseconds, equals(150));
      expect(JustDuration.normal.inMilliseconds, equals(250));
      expect(JustDuration.slow.inMilliseconds, equals(400));
      expect(JustDuration.slower.inMilliseconds, equals(600));
    });

    test('JustDuration.scaleForDistance handles zero, negative, default speed, mid, and max clamped distances', () {
      expect(
        JustDuration.scaleForDistance(
          0,
          min: JustDuration.fast,
          max: JustDuration.slow,
        ),
        equals(JustDuration.fast),
      );
      expect(
        JustDuration.scaleForDistance(
          -100.0,
          min: JustDuration.fast,
          max: JustDuration.slow,
        ),
        equals(JustDuration.fast),
      );
      // Default speedPixelsPerMs = 1.5
      expect(
        JustDuration.scaleForDistance(
          150.0,
          min: JustDuration.fast,
          max: JustDuration.slow,
        ),
        equals(JustDuration.fast),
      );
      expect(
        JustDuration.scaleForDistance(
          600.0,
          min: JustDuration.fast,
          max: JustDuration.slow,
        ),
        equals(JustDuration.slow),
      );
      expect(
        JustDuration.scaleForDistance(
          2000.0,
          min: JustDuration.fast,
          max: JustDuration.slow,
        ),
        equals(JustDuration.slow),
      );
    });

    test('Curves are non-null', () {
      expect(JustCurves.default_, isNotNull);
      expect(JustCurves.enter, isNotNull);
      expect(JustCurves.exit, isNotNull);
      expect(JustCurves.spring, isNotNull);
    });

    test('JustSpring physics constants are valid', () {
      expect(JustSpring.snappy.stiffness, equals(400.0));
      expect(JustSpring.smooth.stiffness, equals(220.0));
      expect(JustSpring.expressive.stiffness, equals(180.0));
    });
  });

  group('JustMotionProfile Validation', () {
    testWidgets('JustMotionProfile resolution, equality, and hashCode', (
      WidgetTester tester,
    ) async {
      const std = JustMotionProfile.standard;
      const exp = JustMotionProfile.expressive;
      const red = JustMotionProfile.reduced;

      expect(std == std, isTrue);
      expect(std == JustMotionProfile.standard, isTrue);
      expect(std.hashCode, equals(JustMotionProfile.standard.hashCode));

      expect(std == exp, isFalse);
      expect(std == Object(), isFalse);

      expect(red.instant, equals(Duration.zero));
      expect(red.fast, equals(Duration.zero));
      expect(red.normal, equals(Duration.zero));
      expect(red.slow, equals(Duration.zero));
      expect(red.slower, equals(Duration.zero));

      // Test all operator == property inequality branches
      JustMotionProfile createVariant({
        Duration? instant,
        Duration? fast,
        Duration? normal,
        Duration? slow,
        Duration? slower,
        Curve? defaultCurve,
        Curve? enter,
        Curve? exit,
        Curve? spring,
        Curve? sharp,
        SpringDescription? springPhysics,
      }) {
        return JustMotionProfile(
          instant: instant ?? std.instant,
          fast: fast ?? std.fast,
          normal: normal ?? std.normal,
          slow: slow ?? std.slow,
          slower: slower ?? std.slower,
          defaultCurve: defaultCurve ?? std.defaultCurve,
          enter: enter ?? std.enter,
          exit: exit ?? std.exit,
          spring: spring ?? std.spring,
          sharp: sharp ?? std.sharp,
          springPhysics: springPhysics ?? std.springPhysics,
        );
      }

      const diffDuration = Duration(milliseconds: 999);
      const diffCurve = Curves.bounceIn;
      const diffPhysics = SpringDescription(
        mass: 2.0,
        stiffness: 200,
        damping: 20,
      );

      expect(std == createVariant(instant: diffDuration), isFalse);
      expect(std == createVariant(fast: diffDuration), isFalse);
      expect(std == createVariant(normal: diffDuration), isFalse);
      expect(std == createVariant(slow: diffDuration), isFalse);
      expect(std == createVariant(slower: diffDuration), isFalse);
      expect(std == createVariant(defaultCurve: diffCurve), isFalse);
      expect(std == createVariant(enter: diffCurve), isFalse);
      expect(std == createVariant(exit: diffCurve), isFalse);
      expect(std == createVariant(spring: diffCurve), isFalse);
      expect(std == createVariant(sharp: diffCurve), isFalse);
      expect(std == createVariant(springPhysics: diffPhysics), isFalse);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: Builder(
            builder: (context) {
              final resolved = std.resolve(context);
              expect(resolved.normal, equals(JustDuration.normal));
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              final resolved = std.resolve(context);
              expect(resolved.normal, equals(Duration.zero));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
