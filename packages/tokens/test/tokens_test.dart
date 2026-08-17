import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Color Tokens Validation', () {
    test('Raw palette colors are valid ARGB values', () {
      const colors = [
        JustColors.white,
        JustColors.black,
        JustColors.neutral50,
        JustColors.neutral100,
        JustColors.neutral200,
        JustColors.neutral300,
        JustColors.neutral400,
        JustColors.neutral500,
        JustColors.neutral600,
        JustColors.neutral700,
        JustColors.neutral800,
        JustColors.neutral900,
        JustColors.neutral950,
        JustColors.primary50,
        JustColors.primary100,
        JustColors.primary200,
        JustColors.primary300,
        JustColors.primary400,
        JustColors.primary500,
        JustColors.primary600,
        JustColors.primary700,
        JustColors.primary800,
        JustColors.primary900,
        JustColors.primary950,
        JustColors.success50,
        JustColors.success100,
        JustColors.success200,
        JustColors.success300,
        JustColors.success400,
        JustColors.success500,
        JustColors.success600,
        JustColors.success700,
        JustColors.success800,
        JustColors.success900,
        JustColors.success950,
        JustColors.warning50,
        JustColors.warning100,
        JustColors.warning200,
        JustColors.warning300,
        JustColors.warning400,
        JustColors.warning500,
        JustColors.warning600,
        JustColors.warning700,
        JustColors.warning800,
        JustColors.warning900,
        JustColors.warning950,
        JustColors.error50,
        JustColors.error100,
        JustColors.error200,
        JustColors.error300,
        JustColors.error400,
        JustColors.error500,
        JustColors.error600,
        JustColors.error700,
        JustColors.error800,
        JustColors.error900,
        JustColors.error950,
        JustColors.info50,
        JustColors.info100,
        JustColors.info200,
        JustColors.info300,
        JustColors.info400,
        JustColors.info500,
        JustColors.info600,
        JustColors.info700,
        JustColors.info800,
        JustColors.info900,
        JustColors.info950,
      ];

      for (final color in colors) {
        expect(color.toARGB32(), isNotNull);
        expect(color.toARGB32(), greaterThanOrEqualTo(0x00000000));
        expect(color.toARGB32(), lessThanOrEqualTo(0xFFFFFFFF));
      }
    });

    test('Semantic color schemes mapping matches light/dark specs', () {
      final light = JustColors.light();
      final dark = JustColors.dark();

      expect(light.background, equals(JustColors.neutral50));
      expect(light.card, equals(JustColors.white));
      expect(light.elevated, equals(JustColors.white));
      expect(light.overlay, equals(JustColors.black));
      expect(light.textPrimary, equals(JustColors.neutral900));

      expect(dark.background, equals(JustColors.neutral950));
      expect(dark.card, equals(JustColors.neutral900));
      expect(dark.elevated, equals(JustColors.neutral800));
      expect(dark.textPrimary, equals(JustColors.neutral50));
    });
  });

  group('Spacing Tokens Validation', () {
    test('Spacing values are positive and monotonically increasing', () {
      expect(JustSpacing.xxs, greaterThan(0));
      expect(JustSpacing.xs, greaterThan(JustSpacing.xxs));
      expect(JustSpacing.sm, greaterThan(JustSpacing.xs));
      expect(JustSpacing.md, greaterThan(JustSpacing.sm));
      expect(JustSpacing.lg, greaterThan(JustSpacing.md));
      expect(JustSpacing.xl, greaterThan(JustSpacing.lg));
      expect(JustSpacing.xxl, greaterThan(JustSpacing.xl));
      expect(JustSpacing.xxxl, greaterThan(JustSpacing.xxl));
      expect(JustSpacing.huge, greaterThan(JustSpacing.xxxl));
    });

    test('EdgeInsets helper generates correct values', () {
      final all = JustSpacing.insets(all: JustSpacing.md);
      expect(all.top, equals(JustSpacing.md));
      expect(all.bottom, equals(JustSpacing.md));
      expect(all.left, equals(JustSpacing.md));
      expect(all.right, equals(JustSpacing.md));

      final symmetric = JustSpacing.insets(
        h: JustSpacing.lg,
        v: JustSpacing.sm,
      );
      expect(symmetric.left, equals(JustSpacing.lg));
      expect(symmetric.right, equals(JustSpacing.lg));
      expect(symmetric.top, equals(JustSpacing.sm));
      expect(symmetric.bottom, equals(JustSpacing.sm));
    });

    testWidgets('JustGap returns non-null SizedBox widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: .ltr,
          child: Column(
            children: [
              JustGap.xxs,
              JustGap.xs,
              JustGap.sm,
              JustGap.md,
              JustGap.lg,
              JustGap.xl,
              JustGap.xxl,
              JustGap.xxxl,
              JustGap.huge,
            ],
          ),
        ),
      );

      final gaps = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(gaps.length, equals(9));

      final spacingValues = [
        JustSpacing.xxs,
        JustSpacing.xs,
        JustSpacing.sm,
        JustSpacing.md,
        JustSpacing.lg,
        JustSpacing.xl,
        JustSpacing.xxl,
        JustSpacing.xxxl,
        JustSpacing.huge,
      ];

      int i = 0;
      for (final gap in gaps) {
        expect(gap.width, equals(spacingValues[i]));
        expect(gap.height, equals(spacingValues[i]));
        i++;
      }
    });
  });

  group('Typography Tokens Validation', () {
    test('Font family and styles are defined correctly', () {
      expect(JustTypo.fontFamily, equals('Inter'));
      expect(JustTypo.monoFontFamily, equals('JetBrains Mono'));

      const styles = [
        JustTypo.displayLg,
        JustTypo.displayMd,
        JustTypo.displaySm,
        JustTypo.headingLg,
        JustTypo.headingMd,
        JustTypo.headingSm,
        JustTypo.bodyLg,
        JustTypo.bodyMd,
        JustTypo.bodySm,
        JustTypo.caption,
        JustTypo.overline,
      ];

      for (final style in styles) {
        expect(style.fontSize, isNotNull);
        expect(style.fontWeight, isNotNull);
        expect(style.height, isNotNull);
        expect(style.letterSpacing, isNotNull);
      }
    });
  });

  group('Radius & BorderRadius Tokens Validation', () {
    test('Radius and BorderRadius scales are valid and match', () {
      expect(JustRadius.none.x, equals(0.0));
      expect(JustRadius.xs.x, equals(2.0));
      expect(JustRadius.sm.x, equals(4.0));
      expect(JustRadius.md.x, equals(8.0));
      expect(JustRadius.lg.x, equals(12.0));
      expect(JustRadius.xl.x, equals(16.0));
      expect(JustRadius.xxl.x, equals(24.0));
      expect(JustRadius.full.x, equals(9999.0));

      expect(JustBorderRadius.none.topRight, equals(JustRadius.none));
      expect(JustBorderRadius.xs.topRight, equals(JustRadius.xs));
      expect(JustBorderRadius.sm.topRight, equals(JustRadius.sm));
      expect(JustBorderRadius.md.topRight, equals(JustRadius.md));
      expect(JustBorderRadius.lg.topRight, equals(JustRadius.lg));
      expect(JustBorderRadius.xl.topRight, equals(JustRadius.xl));
      expect(JustBorderRadius.xxl.topRight, equals(JustRadius.xxl));
      expect(JustBorderRadius.full.topRight, equals(JustRadius.full));
    });
  });

  group('Shadows Tokens Validation', () {
    test('Shadow lists are non-empty and have valid styles', () {
      final shadowLists = [
        JustShadows.xs,
        JustShadows.sm,
        JustShadows.md,
        JustShadows.lg,
        JustShadows.xl,
        JustShadows.xxl,
        JustShadows.xsDark,
        JustShadows.smDark,
        JustShadows.mdDark,
        JustShadows.lgDark,
        JustShadows.xlDark,
        JustShadows.xxlDark,
      ];

      for (final shadowList in shadowLists) {
        expect(shadowList, isNotEmpty);
        for (final shadow in shadowList) {
          expect(shadow.color, isNotNull);
          expect(shadow.blurRadius, greaterThanOrEqualTo(0.0));
        }
      }
    });
  });

  group('Duration & Curve Tokens Validation', () {
    test('Duration values are positive', () {
      expect(JustDuration.instant.inMilliseconds, equals(50));
      expect(JustDuration.fast.inMilliseconds, equals(150));
      expect(JustDuration.normal.inMilliseconds, equals(250));
      expect(JustDuration.slow.inMilliseconds, equals(400));
      expect(JustDuration.slower.inMilliseconds, equals(600));
    });

    test('Curves are non-null', () {
      expect(JustCurves.default_, isNotNull);
      expect(JustCurves.enter, isNotNull);
      expect(JustCurves.exit, isNotNull);
      expect(JustCurves.spring, isNotNull);
    });
  });

  group('Accessibility Contrast Validation', () {
    test('Calculates correct contrast ratio for pure black and white', () {
      const black = JustColors.black;
      const white = JustColors.white;

      expect(black.contrastRatioWith(white), closeTo(21.0, 0.01));
      expect(white.contrastRatioWith(black), closeTo(21.0, 0.01));
    });

    test('Identical colors have a contrast ratio of 1.0', () {
      const color = JustColors.primary500;
      expect(color.contrastRatioWith(color), closeTo(1.0, 0.01));
    });

    test('Verifies accessibility compliance for standard pairings', () {
      final light = JustColors.light();

      // textPrimary (dark grey/black) on background (light grey) should be WCAG AA compliant
      expect(light.textPrimary.isAccessibleWith(light.background), isTrue);

      // Inverse text on overlay should also be compliant
      expect(light.textInverse.isAccessibleWith(light.overlay), isTrue);
    });
  });

  group('Dynamic HSL Color & Contrast Correction Validation', () {
    test('JustColorScale generates valid 11-step color scale from seed', () {
      const seed = Color(0xFF0F172A); // Slate 900
      final scale = JustColorScale.fromSeed(seed);

      expect(scale.c50, isNotNull);
      expect(scale.c100, isNotNull);
      expect(scale.c200, isNotNull);
      expect(scale.c300, isNotNull);
      expect(scale.c400, isNotNull);
      expect(scale.c500, equals(seed));
      expect(scale.c600, isNotNull);
      expect(scale.c700, isNotNull);
      expect(scale.c800, isNotNull);
      expect(scale.c900, isNotNull);
      expect(scale.c950, isNotNull);

      // Verify lightness is monotonically decreasing from c50 to c950
      expect(
        HSLColor.fromColor(scale.c50).lightness,
        greaterThan(HSLColor.fromColor(scale.c100).lightness),
      );
      expect(
        HSLColor.fromColor(scale.c100).lightness,
        greaterThan(HSLColor.fromColor(scale.c200).lightness),
      );
      expect(
        HSLColor.fromColor(scale.c200).lightness,
        greaterThan(HSLColor.fromColor(scale.c300).lightness),
      );
      expect(
        HSLColor.fromColor(scale.c300).lightness,
        greaterThan(HSLColor.fromColor(scale.c400).lightness),
      );
      expect(
        HSLColor.fromColor(scale.c400).lightness,
        greaterThan(HSLColor.fromColor(scale.c500).lightness),
      );
      expect(
        HSLColor.fromColor(scale.c500).lightness,
        greaterThan(HSLColor.fromColor(scale.c600).lightness),
      );
      expect(
        HSLColor.fromColor(scale.c600).lightness,
        greaterThan(HSLColor.fromColor(scale.c700).lightness),
      );
      expect(
        HSLColor.fromColor(scale.c700).lightness,
        greaterThan(HSLColor.fromColor(scale.c800).lightness),
      );
      expect(
        HSLColor.fromColor(scale.c800).lightness,
        greaterThan(HSLColor.fromColor(scale.c900).lightness),
      );
      expect(
        HSLColor.fromColor(scale.c900).lightness,
        greaterThan(HSLColor.fromColor(scale.c950).lightness),
      );
    });

    test('adjustLightnessForContrast adjusts color to meet target ratio', () {
      const background = Color(0xFFF8FAFC); // Very light grey
      const text = Color(
        0xFF94A3B8,
      ); // Light grey text (insufficient contrast ~2.1:1)

      expect(text.contrastRatioWith(background), lessThan(4.5));

      final corrected = text.adjustLightnessForContrast(
        background: background,
        targetRatio: 4.5,
      );
      expect(
        corrected.contrastRatioWith(background),
        greaterThanOrEqualTo(4.5),
      );
      // Corrected color should be darker to achieve contrast against light background
      expect(
        HSLColor.fromColor(corrected).lightness,
        lessThan(HSLColor.fromColor(text).lightness),
      );
    });
  });

  group('Fluid Typography & Adaptive Line Height Validation', () {
    testWidgets('Fluid scaling adjusts font size dynamically with width', (
      WidgetTester tester,
    ) async {
      const style = TextStyle(fontSize: 16.0);

      // At minWidth (640), fluid size should be minSize (20)
      final styleMin = style.fluid(
        screenWidth: 640.0,
        minWidth: 640.0,
        maxWidth: 1024.0,
        minSize: 20.0,
        maxSize: 32.0,
      );
      expect(styleMin.fontSize, equals(20.0));

      // At maxWidth (1024), fluid size should be maxSize (32)
      final styleMax = style.fluid(
        screenWidth: 1024.0,
        minWidth: 640.0,
        maxWidth: 1024.0,
        minSize: 20.0,
        maxSize: 32.0,
      );
      expect(styleMax.fontSize, equals(32.0));

      // At midpoint (832), fluid size should be halfway (26)
      final styleMid = style.fluid(
        screenWidth: 832.0,
        minWidth: 640.0,
        maxWidth: 1024.0,
        minSize: 20.0,
        maxSize: 32.0,
      );
      expect(styleMid.fontSize, equals(26.0));
    });

    test('Fluid scaling throws assertion error if minWidth >= maxWidth', () {
      const style = TextStyle(fontSize: 16.0);
      expect(
        () => style.fluid(
          screenWidth: 640.0,
          minWidth: 640.0,
          maxWidth: 640.0,
          minSize: 20.0,
          maxSize: 32.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('Adaptive line height tightens for larger text sizes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            // Small text (fontSize 10) should have a loose line height (~1.6)
            const smallStyle = TextStyle(fontSize: 10.0);
            final resolvedSmall = smallStyle.withAdaptiveHeight(context);
            expect(resolvedSmall.height, closeTo(1.6, 0.01));

            // Large text (fontSize 40) should have a tight line height (~1.15)
            const largeStyle = TextStyle(fontSize: 40.0);
            final resolvedLarge = largeStyle.withAdaptiveHeight(context);
            expect(resolvedLarge.height, closeTo(1.15, 0.01));

            // Medium text (fontSize 24) should have intermediate height (~1.375)
            const midStyle = TextStyle(fontSize: 24.0);
            final resolvedMid = midStyle.withAdaptiveHeight(context);
            expect(resolvedMid.height, closeTo(1.375, 0.01));

            return const SizedBox.shrink();
          },
        ),
      );
    });

    testWidgets('JustFluidTypo preset styles return correct types and scale', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800.0, 600.0)),
          child: Builder(
            builder: (context) {
              final display = JustFluidTypo.displayLg(context);
              expect(display.fontSize, isNotNull);
              expect(display.height, isNotNull);
              expect(display.fontWeight, equals(JustTypo.displayLg.fontWeight));

              final body = JustFluidTypo.bodyMd(context);
              expect(body.fontSize, isNotNull);
              expect(body.height, isNotNull);
              expect(body.fontWeight, equals(JustTypo.bodyMd.fontWeight));

              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('Adaptive Motion Engine Validation', () {
    test(
      'JustDuration.scaleForDistance scales and clamps durations correctly',
      () {
        // Test zero and negative distance returns min duration
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
            -50.0,
            min: JustDuration.fast,
            max: JustDuration.slow,
          ),
          equals(JustDuration.fast),
        );

        // Test mid-range distance: 150px / 1.5 pixels/ms = 100ms. If fast is 150ms, it should clamp to 150ms.
        expect(
          JustDuration.scaleForDistance(
            150.0,
            min: JustDuration.fast,
            max: JustDuration.slow,
          ),
          equals(JustDuration.fast),
        );

        // Test longer distance: 600px / 1.5 pixels/ms = 400ms. If slow is 400ms, it should return 400ms.
        expect(
          JustDuration.scaleForDistance(
            600.0,
            min: JustDuration.fast,
            max: JustDuration.slow,
          ),
          equals(JustDuration.slow),
        );

        // Test extremely long distance: 1500px / 1.5 pixels/ms = 1000ms. Clamps to max (slow - 400ms).
        expect(
          JustDuration.scaleForDistance(
            1500.0,
            min: JustDuration.fast,
            max: JustDuration.slow,
          ),
          equals(JustDuration.slow),
        );
      },
    );

    testWidgets(
      'JustMotionProfile.resolve respects system disableAnimations setting',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: false),
            child: Builder(
              builder: (context) {
                // Should resolve to normal standard animations
                final resolved = JustMotionProfile.standard.resolve(context);
                expect(resolved.normal, equals(JustDuration.normal));
                expect(resolved.defaultCurve, equals(JustCurves.default_));
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
                // Should resolve to reduced animations (Duration.zero and Curves.linear)
                final resolved = JustMotionProfile.standard.resolve(context);
                expect(resolved.normal, equals(Duration.zero));
                expect(resolved.defaultCurve, equals(Curves.linear));
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  });

  group('Advanced Primitives Validation', () {
    test('JustDynamicSurfaces.generateDarkSurface maintains seed hue and clamps saturation/lightness', () {
      const seed = Color(0xFF3B82F6); // Blue seed
      final darkBg = JustDynamicSurfaces.generateDarkSurface(
        seed,
        lightness: 0.03,
      );
      final darkCard = JustDynamicSurfaces.generateDarkSurface(
        seed,
        lightness: 0.07,
      );

      final HSLColor hslSeed = HSLColor.fromColor(seed);
      final HSLColor hslBg = HSLColor.fromColor(darkBg);
      final HSLColor hslCard = HSLColor.fromColor(darkCard);

      expect(hslBg.hue, closeTo(hslSeed.hue, 0.01));
      expect(hslBg.lightness, equals(0.03));
      expect(hslBg.saturation, lessThanOrEqualTo(0.08));

      expect(hslCard.hue, closeTo(hslSeed.hue, 0.01));
      expect(hslCard.lightness, equals(0.07));
      expect(hslCard.saturation, lessThanOrEqualTo(0.12));
    });

    test('JustShadows.generate produces valid dual-layer tinted shadows', () {
      const seed = Color(0xFF3B82F6);
      final shadows = JustShadows.generate(seedColor: seed, elevation: 4);

      expect(shadows.length, equals(2));
      // First layer (key shadow) should be dark/black
      expect(shadows[0].color.a, greaterThan(0.0));
      expect(shadows[0].color.computeLuminance(), closeTo(0, 0.01)); // dark key

      // Second layer (ambient shadow) should be tinted with seed color
      expect(shadows[1].color.a, greaterThan(0.0));
      // Contrast ratios / hues of the tint
      final HSLColor hslShadow = HSLColor.fromColor(shadows[1].color);
      final HSLColor hslSeed = HSLColor.fromColor(seed);
      expect(hslShadow.hue, closeTo(hslSeed.hue, 0.01));
    });
  });
}
