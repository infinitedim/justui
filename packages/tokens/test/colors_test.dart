import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Raw Color Palette & Static Tokens', () {
    test(
      'Raw palette colors and JustColors static constants are valid ARGB',
      () {
        const rawColors = [
          JustColorPalette.white,
          JustColorPalette.black,
          JustColorPalette.neutral50,
          JustColorPalette.neutral100,
          JustColorPalette.neutral200,
          JustColorPalette.neutral300,
          JustColorPalette.neutral400,
          JustColorPalette.neutral500,
          JustColorPalette.neutral600,
          JustColorPalette.neutral700,
          JustColorPalette.neutral800,
          JustColorPalette.neutral900,
          JustColorPalette.neutral950,
          JustColorPalette.primary50,
          JustColorPalette.primary100,
          JustColorPalette.primary200,
          JustColorPalette.primary300,
          JustColorPalette.primary400,
          JustColorPalette.primary500,
          JustColorPalette.primary600,
          JustColorPalette.primary700,
          JustColorPalette.primary800,
          JustColorPalette.primary900,
          JustColorPalette.primary950,
          JustColorPalette.success50,
          JustColorPalette.success100,
          JustColorPalette.success200,
          JustColorPalette.success300,
          JustColorPalette.success400,
          JustColorPalette.success500,
          JustColorPalette.success600,
          JustColorPalette.success700,
          JustColorPalette.success800,
          JustColorPalette.success900,
          JustColorPalette.success950,
          JustColorPalette.warning50,
          JustColorPalette.warning100,
          JustColorPalette.warning200,
          JustColorPalette.warning300,
          JustColorPalette.warning400,
          JustColorPalette.warning500,
          JustColorPalette.warning600,
          JustColorPalette.warning700,
          JustColorPalette.warning800,
          JustColorPalette.warning900,
          JustColorPalette.warning950,
          JustColorPalette.error50,
          JustColorPalette.error100,
          JustColorPalette.error200,
          JustColorPalette.error300,
          JustColorPalette.error400,
          JustColorPalette.error500,
          JustColorPalette.error600,
          JustColorPalette.error700,
          JustColorPalette.error800,
          JustColorPalette.error900,
          JustColorPalette.error950,
          JustColorPalette.info50,
          JustColorPalette.info100,
          JustColorPalette.info200,
          JustColorPalette.info300,
          JustColorPalette.info400,
          JustColorPalette.info500,
          JustColorPalette.info600,
          JustColorPalette.info700,
          JustColorPalette.info800,
          JustColorPalette.info900,
          JustColorPalette.info950,
        ];

        for (final color in rawColors) {
          expect(color.toARGB32(), isNotNull);
          expect(color.toARGB32(), greaterThanOrEqualTo(0x00000000));
          expect(color.toARGB32(), lessThanOrEqualTo(0xFFFFFFFF));
        }

        expect(JustColors.white, equals(JustColorPalette.white));
        expect(JustColors.black, equals(JustColorPalette.black));
        expect(JustColors.neutral50, equals(JustColorPalette.neutral50));
        expect(JustColors.neutral100, equals(JustColorPalette.neutral100));
        expect(JustColors.neutral200, equals(JustColorPalette.neutral200));
        expect(JustColors.neutral300, equals(JustColorPalette.neutral300));
        expect(JustColors.neutral400, equals(JustColorPalette.neutral400));
        expect(JustColors.neutral500, equals(JustColorPalette.neutral500));
        expect(JustColors.neutral600, equals(JustColorPalette.neutral600));
        expect(JustColors.neutral700, equals(JustColorPalette.neutral700));
        expect(JustColors.neutral800, equals(JustColorPalette.neutral800));
        expect(JustColors.neutral900, equals(JustColorPalette.neutral900));
        expect(JustColors.neutral950, equals(JustColorPalette.neutral950));
        expect(JustColors.primary50, equals(JustColorPalette.primary50));
        expect(JustColors.primary100, equals(JustColorPalette.primary100));
        expect(JustColors.primary200, equals(JustColorPalette.primary200));
        expect(JustColors.primary300, equals(JustColorPalette.primary300));
        expect(JustColors.primary400, equals(JustColorPalette.primary400));
        expect(JustColors.primary500, equals(JustColorPalette.primary500));
        expect(JustColors.primary600, equals(JustColorPalette.primary600));
        expect(JustColors.primary700, equals(JustColorPalette.primary700));
        expect(JustColors.primary800, equals(JustColorPalette.primary800));
        expect(JustColors.primary900, equals(JustColorPalette.primary900));
        expect(JustColors.primary950, equals(JustColorPalette.primary950));
        expect(JustColors.success50, equals(JustColorPalette.success50));
        expect(JustColors.success100, equals(JustColorPalette.success100));
        expect(JustColors.success200, equals(JustColorPalette.success200));
        expect(JustColors.success300, equals(JustColorPalette.success300));
        expect(JustColors.success400, equals(JustColorPalette.success400));
        expect(JustColors.success500, equals(JustColorPalette.success500));
        expect(JustColors.success600, equals(JustColorPalette.success600));
        expect(JustColors.success700, equals(JustColorPalette.success700));
        expect(JustColors.success800, equals(JustColorPalette.success800));
        expect(JustColors.success900, equals(JustColorPalette.success900));
        expect(JustColors.success950, equals(JustColorPalette.success950));
        expect(JustColors.warning50, equals(JustColorPalette.warning50));
        expect(JustColors.warning100, equals(JustColorPalette.warning100));
        expect(JustColors.warning200, equals(JustColorPalette.warning200));
        expect(JustColors.warning300, equals(JustColorPalette.warning300));
        expect(JustColors.warning400, equals(JustColorPalette.warning400));
        expect(JustColors.warning500, equals(JustColorPalette.warning500));
        expect(JustColors.warning600, equals(JustColorPalette.warning600));
        expect(JustColors.warning700, equals(JustColorPalette.warning700));
        expect(JustColors.warning800, equals(JustColorPalette.warning800));
        expect(JustColors.warning900, equals(JustColorPalette.warning900));
        expect(JustColors.warning950, equals(JustColorPalette.warning950));
        expect(JustColors.error50, equals(JustColorPalette.error50));
        expect(JustColors.error100, equals(JustColorPalette.error100));
        expect(JustColors.error200, equals(JustColorPalette.error200));
        expect(JustColors.error300, equals(JustColorPalette.error300));
        expect(JustColors.error400, equals(JustColorPalette.error400));
        expect(JustColors.error500, equals(JustColorPalette.error500));
        expect(JustColors.error600, equals(JustColorPalette.error600));
        expect(JustColors.error700, equals(JustColorPalette.error700));
        expect(JustColors.error800, equals(JustColorPalette.error800));
        expect(JustColors.error900, equals(JustColorPalette.error900));
        expect(JustColors.error950, equals(JustColorPalette.error950));
        expect(JustColors.info50, equals(JustColorPalette.info50));
        expect(JustColors.info100, equals(JustColorPalette.info100));
        expect(JustColors.info200, equals(JustColorPalette.info200));
        expect(JustColors.info300, equals(JustColorPalette.info300));
        expect(JustColors.info400, equals(JustColorPalette.info400));
        expect(JustColors.info500, equals(JustColorPalette.info500));
        expect(JustColors.info600, equals(JustColorPalette.info600));
        expect(JustColors.info700, equals(JustColorPalette.info700));
        expect(JustColors.info800, equals(JustColorPalette.info800));
        expect(JustColors.info900, equals(JustColorPalette.info900));
        expect(JustColors.info950, equals(JustColorPalette.info950));
      },
    );
  });

  group('Semantic Colors & Color Scheme Validation', () {
    test('Light and Dark semantic schemes match specification', () {
      expect(
        JustColorSemanticLight.background,
        equals(JustColorPalette.neutral50),
      );
      expect(JustColorSemanticLight.card, equals(JustColorPalette.white));
      expect(JustColorSemanticLight.elevated, equals(JustColorPalette.white));
      expect(JustColorSemanticLight.muted, equals(JustColorPalette.neutral100));
      expect(JustColorSemanticLight.overlay, equals(JustColorPalette.black));
      expect(
        JustColorSemanticLight.textPrimary,
        equals(JustColorPalette.neutral900),
      );
      expect(
        JustColorSemanticLight.textSecondary,
        equals(JustColorPalette.neutral600),
      );
      expect(
        JustColorSemanticLight.textDisabled,
        equals(JustColorPalette.neutral400),
      );
      expect(
        JustColorSemanticLight.textInverse,
        equals(JustColorPalette.neutral50),
      );
      expect(
        JustColorSemanticLight.borderDefault,
        equals(JustColorPalette.neutral200),
      );
      expect(
        JustColorSemanticLight.borderFocus,
        equals(JustColorPalette.primary500),
      );
      expect(
        JustColorSemanticLight.borderError,
        equals(JustColorPalette.error500),
      );
      expect(
        JustColorSemanticLight.success,
        equals(JustColorPalette.success600),
      );
      expect(
        JustColorSemanticLight.warning,
        equals(JustColorPalette.warning600),
      );
      expect(JustColorSemanticLight.error, equals(JustColorPalette.error600));
      expect(JustColorSemanticLight.info, equals(JustColorPalette.info600));

      expect(
        JustColorSemanticDark.background,
        equals(JustColorPalette.neutral950),
      );
      expect(JustColorSemanticDark.card, equals(JustColorPalette.neutral900));
      expect(
        JustColorSemanticDark.elevated,
        equals(JustColorPalette.neutral800),
      );
      expect(JustColorSemanticDark.muted, equals(JustColorPalette.neutral800));
      expect(JustColorSemanticDark.overlay, equals(JustColorPalette.black));
      expect(
        JustColorSemanticDark.textPrimary,
        equals(JustColorPalette.neutral50),
      );
      expect(
        JustColorSemanticDark.textSecondary,
        equals(JustColorPalette.neutral400),
      );
      expect(
        JustColorSemanticDark.textDisabled,
        equals(JustColorPalette.neutral600),
      );
      expect(
        JustColorSemanticDark.textInverse,
        equals(JustColorPalette.neutral900),
      );
      expect(
        JustColorSemanticDark.borderDefault,
        equals(JustColorPalette.neutral800),
      );
      expect(
        JustColorSemanticDark.borderFocus,
        equals(JustColorPalette.primary500),
      );
      expect(
        JustColorSemanticDark.borderError,
        equals(JustColorPalette.error500),
      );
      expect(
        JustColorSemanticDark.success,
        equals(JustColorPalette.success400),
      );
      expect(
        JustColorSemanticDark.warning,
        equals(JustColorPalette.warning400),
      );
      expect(JustColorSemanticDark.error, equals(JustColorPalette.error400));
      expect(JustColorSemanticDark.info, equals(JustColorPalette.info400));
    });

    test('JustColors factory methods return correct scheme instances', () {
      final light = JustColors.light();
      final dark = JustColors.dark();
      final neoLight = JustColors.neobrutalismLight();
      final neoDark = JustColors.neobrutalismDark();

      expect(light, equals(JustColors.lightScheme));
      expect(dark, equals(JustColors.darkScheme));
      expect(neoLight, equals(JustColors.neobrutalismLightScheme));
      expect(neoDark, equals(JustColors.neobrutalismDarkScheme));
    });

    test('CustomColorScheme constructor and resolveSemantic factory', () {
      const custom = CustomColorScheme(
        background: Color(0xFF111111),
        card: Color(0xFF222222),
        elevated: Color(0xFF333333),
        muted: Color(0xFF444444),
        overlay: Color(0xFF555555),
        textPrimary: Color(0xFF666666),
        textSecondary: Color(0xFF777777),
        textDisabled: Color(0xFF888888),
        textInverse: Color(0xFF999999),
        borderDefault: Color(0xFFAAAAAA),
        borderFocus: Color(0xFFBBBBBB),
        borderError: Color(0xFFCCCCCC),
        success: Color(0xFFDDDDDD),
        warning: Color(0xFFEEEEEE),
        error: Color(0xFFFFFFFF),
        info: Color(0xFF000000),
      );

      expect(custom.background, equals(const Color(0xFF111111)));
      expect(custom.card, equals(const Color(0xFF222222)));
      expect(custom.elevated, equals(const Color(0xFF333333)));
      expect(custom.muted, equals(const Color(0xFF444444)));
      expect(custom.overlay, equals(const Color(0xFF555555)));
      expect(custom.textPrimary, equals(const Color(0xFF666666)));
      expect(custom.textSecondary, equals(const Color(0xFF777777)));
      expect(custom.textDisabled, equals(const Color(0xFF888888)));
      expect(custom.textInverse, equals(const Color(0xFF999999)));
      expect(custom.borderDefault, equals(const Color(0xFFAAAAAA)));
      expect(custom.borderFocus, equals(const Color(0xFFBBBBBB)));
      expect(custom.borderError, equals(const Color(0xFFCCCCCC)));
      expect(custom.success, equals(const Color(0xFFDDDDDD)));
      expect(custom.warning, equals(const Color(0xFFEEEEEE)));
      expect(custom.error, equals(const Color(0xFFFFFFFF)));
      expect(custom.info, equals(const Color(0xFF000000)));

      // resolveSemantic neobrutalism (light & dark)
      final neoLightResolved = CustomColorScheme.resolveSemantic(
        background: const Color(0xFFFFF8E7),
        card: const Color(0xFFFFFFFF),
        elevated: const Color(0xFFFFFFFF),
        muted: const Color(0xFFF1F5F9),
        overlay: const Color(0x99000000),
        borderFocus: const Color(0xFF000000),
        success: const Color(0xFF38E54D),
        warning: const Color(0xFFFFD93D),
        error: const Color(0xFFFF4B4B),
        info: const Color(0xFF4D96FF),
        isDark: false,
        preset: JustThemePreset.neobrutalism,
      );
      expect(neoLightResolved.textPrimary, equals(const Color(0xFF000000)));
      expect(neoLightResolved.textInverse, equals(const Color(0xFFFFFFFF)));
      expect(neoLightResolved.borderDefault, equals(const Color(0xFF000000)));

      final neoDarkResolved = CustomColorScheme.resolveSemantic(
        background: const Color(0xFF1A1A1A),
        card: const Color(0xFF262626),
        elevated: const Color(0xFF333333),
        muted: const Color(0xFF333333),
        overlay: const Color(0xCC000000),
        borderFocus: const Color(0xFFFFFFFF),
        success: const Color(0xFF4ADE80),
        warning: const Color(0xFFFFE033),
        error: const Color(0xFFFF5353),
        info: const Color(0xFF60A5FA),
        isDark: true,
        preset: JustThemePreset.neobrutalism,
      );
      expect(neoDarkResolved.textPrimary, equals(const Color(0xFFFFFFFF)));
      expect(neoDarkResolved.textInverse, equals(const Color(0xFF000000)));
      expect(neoDarkResolved.borderDefault, equals(const Color(0xFFFFFFFF)));

      // resolveSemantic default_ (light & dark)
      final stdLightResolved = CustomColorScheme.resolveSemantic(
        background: JustColorSemanticLight.background,
        card: JustColorSemanticLight.card,
        elevated: JustColorSemanticLight.elevated,
        muted: JustColorSemanticLight.muted,
        overlay: JustColorSemanticLight.overlay,
        borderFocus: JustColorSemanticLight.borderFocus,
        success: JustColorSemanticLight.success,
        warning: JustColorSemanticLight.warning,
        error: JustColorSemanticLight.error,
        info: JustColorSemanticLight.info,
        isDark: false,
        preset: JustThemePreset.default_,
      );
      expect(
        stdLightResolved.textPrimary,
        equals(JustColorSemanticLight.textPrimary),
      );

      final stdDarkResolved = CustomColorScheme.resolveSemantic(
        background: JustColorSemanticDark.background,
        card: JustColorSemanticDark.card,
        elevated: JustColorSemanticDark.elevated,
        muted: JustColorSemanticDark.muted,
        overlay: JustColorSemanticDark.overlay,
        borderFocus: JustColorSemanticDark.borderFocus,
        success: JustColorSemanticDark.success,
        warning: JustColorSemanticDark.warning,
        error: JustColorSemanticDark.error,
        info: JustColorSemanticDark.info,
        isDark: true,
        preset: JustThemePreset.default_,
      );
      expect(
        stdDarkResolved.textPrimary,
        equals(JustColorSemanticDark.textPrimary),
      );
    });

    test('JustColorScheme operator == exercises all 16 property inequality branches', () {
      final base = JustColors.light();
      expect(base == base, isTrue);
      expect(base == Object(), isFalse);

      CustomColorScheme createVariant({
        Color? background,
        Color? card,
        Color? elevated,
        Color? muted,
        Color? overlay,
        Color? textPrimary,
        Color? textSecondary,
        Color? textDisabled,
        Color? textInverse,
        Color? borderDefault,
        Color? borderFocus,
        Color? borderError,
        Color? success,
        Color? warning,
        Color? error,
        Color? info,
      }) {
        return CustomColorScheme(
          background: background ?? base.background,
          card: card ?? base.card,
          elevated: elevated ?? base.elevated,
          muted: muted ?? base.muted,
          overlay: overlay ?? base.overlay,
          textPrimary: textPrimary ?? base.textPrimary,
          textSecondary: textSecondary ?? base.textSecondary,
          textDisabled: textDisabled ?? base.textDisabled,
          textInverse: textInverse ?? base.textInverse,
          borderDefault: borderDefault ?? base.borderDefault,
          borderFocus: borderFocus ?? base.borderFocus,
          borderError: borderError ?? base.borderError,
          success: success ?? base.success,
          warning: warning ?? base.warning,
          error: error ?? base.error,
          info: info ?? base.info,
        );
      }

      const diff = Color(0xFF123456);

      expect(base == createVariant(background: diff), isFalse);
      expect(base == createVariant(card: diff), isFalse);
      expect(base == createVariant(elevated: diff), isFalse);
      expect(base == createVariant(muted: diff), isFalse);
      expect(base == createVariant(overlay: diff), isFalse);
      expect(base == createVariant(textPrimary: diff), isFalse);
      expect(base == createVariant(textSecondary: diff), isFalse);
      expect(base == createVariant(textDisabled: diff), isFalse);
      expect(base == createVariant(textInverse: diff), isFalse);
      expect(base == createVariant(borderDefault: diff), isFalse);
      expect(base == createVariant(borderFocus: diff), isFalse);
      expect(base == createVariant(borderError: diff), isFalse);
      expect(base == createVariant(success: diff), isFalse);
      expect(base == createVariant(warning: diff), isFalse);
      expect(base == createVariant(error: diff), isFalse);
      expect(base == createVariant(info: diff), isFalse);
    });
  });

  group('Accessibility Contrast & Dynamic Scaling Validation', () {
    test('Contrast ratio calculation and WCAG AA compliance', () {
      const black = JustColors.black;
      const white = JustColors.white;

      expect(black.contrastRatioWith(white), closeTo(21.0, 0.01));
      expect(white.contrastRatioWith(black), closeTo(21.0, 0.01));
      expect(black.contrastRatioWith(black), closeTo(1.0, 0.01));

      expect(black.isAccessibleWith(white, isLargeText: false), isTrue);
      expect(black.isAccessibleWith(white, isLargeText: true), isTrue);

      const lowContrastText = Color(0xFFCCCCCC);
      expect(
        lowContrastText.isAccessibleWith(white, isLargeText: false),
        isFalse,
      );
    });

    test('JustColorScale generates complete 11-step scale from seed across engines', () {
      const seed = Color(0xFF3B82F6);

      for (final engine in JustColorSpaceEngine.values) {
        final scale = JustColorScale.fromSeed(seed, engine: engine);

        expect(scale.c50, isNotNull);
        expect(scale.c100, isNotNull);
        expect(scale.c200, isNotNull);
        expect(scale.c300, isNotNull);
        expect(scale.c400, isNotNull);
        expect(scale.c500, equals(seed)); // Zero-drift guarantee for seed
        expect(scale.c600, isNotNull);
        expect(scale.c700, isNotNull);
        expect(scale.c800, isNotNull);
        expect(scale.c900, isNotNull);
        expect(scale.c950, isNotNull);

        // Monotonic lightness: c50 > c950
        expect(
          scale.c50.computeLuminance(),
          greaterThan(scale.c950.computeLuminance()),
        );
      }
    });

    test(
      'OKLCH engine handles conversions, roundtrips, and chroma pre-damping',
      () {
        const seed = Color(0xFF3B82F6);
        final oklch = OklchEngine.fromColor(seed);

        expect(oklch.l, inInclusiveRange(0.0, 1.0));
        expect(oklch.c, greaterThan(0.0));
        expect(oklch.h, inInclusiveRange(0.0, 360.0));

        final roundtrip = OklchEngine.toColor(oklch);
        expect(roundtrip.r, closeTo(seed.r, 0.02));
        expect(roundtrip.g, closeTo(seed.g, 0.02));
        expect(roundtrip.b, closeTo(seed.b, 0.02));

        final dampedC = OklchEngine.dampChroma(oklch.c, 0.05);
        expect(dampedC, lessThan(oklch.c));
      },
    );

    test('HSLuv engine handles conversions, roundtrips, and max chroma', () {
      const seed = Color(0xFF3B82F6);
      final hsluv = HsluvEngine.fromColor(seed);

      expect(hsluv.l, inInclusiveRange(0.0, 100.0));
      expect(hsluv.s, inInclusiveRange(0.0, 100.0));
      expect(hsluv.h, inInclusiveRange(0.0, 360.0));

      final roundtrip = HsluvEngine.toColor(hsluv);
      expect(roundtrip.r, closeTo(seed.r, 0.02));
      expect(roundtrip.g, closeTo(seed.g, 0.02));
      expect(roundtrip.b, closeTo(seed.b, 0.02));
    });

    test('Yellow seed scale does not produce grayish dark shades in OKLCH', () {
      const yellowSeed = Color(0xFFF59E0B);
      final scale = JustColorScale.fromSeed(
        yellowSeed,
        engine: JustColorSpaceEngine.oklch,
      );

      expect(scale.c500, equals(yellowSeed));
      final c900Oklch = OklchEngine.fromColor(scale.c900);
      expect(c900Oklch.c, greaterThan(0.005));
    });

    test('adjustLightnessForContrast covers early return and dark/light background branches across engines', () {
      const lightBg = Color(0xFFFFFFFF);
      const darkBg = Color(0xFF000000);
      const sufficientText = Color(0xFF000000);
      const lowContrastGrey = Color(0xFF94A3B8);

      for (final engine in JustColorSpaceEngine.values) {
        expect(
          sufficientText.adjustLightnessForContrast(
            background: lightBg,
            targetRatio: 4.5,
            engine: engine,
          ),
          equals(sufficientText),
        );

        final darkerResult = lowContrastGrey.adjustLightnessForContrast(
          background: lightBg,
          targetRatio: 4.5,
          engine: engine,
        );
        expect(
          darkerResult.contrastRatioWith(lightBg),
          greaterThanOrEqualTo(4.5),
        );

        final lighterResult = lowContrastGrey.adjustLightnessForContrast(
          background: darkBg,
          targetRatio: 4.5,
          engine: engine,
        );
        expect(
          lighterResult.contrastRatioWith(darkBg),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('JustDynamicSurfaces.generateDarkSurface produces dark tinted surfaces across engines', () {
      const seed = Color(0xFF3B82F6);

      for (final engine in JustColorSpaceEngine.values) {
        final darkSurface = JustDynamicSurfaces.generateDarkSurface(
          seed,
          lightness: 0.05,
          engine: engine,
        );

        expect(darkSurface.computeLuminance(), lessThan(0.05));
      }
    });

    // =========================================================
    // --- Tier 1: CSS-4 Gamut Mapping Tests ---
    // =========================================================

    test('gamutMap preserves hue for out-of-gamut vivid colors', () {
      // Highly saturated OKLCH colors that are outside sRGB gamut
      const vividColors = [
        OklchColor(0.7, 0.35, 30.0), // vivid red-orange
        OklchColor(0.7, 0.35, 150.0), // vivid green
        OklchColor(0.5, 0.35, 270.0), // vivid blue-purple
        OklchColor(0.85, 0.30, 90.0), // vivid yellow
      ];

      for (final oklch in vividColors) {
        final mapped = OklchEngine.gamutMap(oklch);
        final roundtrip = OklchEngine.fromColor(mapped);

        // Hue must not drift more than 2° after gamut mapping
        double hueDiff = (roundtrip.h - oklch.h).abs();
        if (hueDiff > 180.0) hueDiff = 360.0 - hueDiff;
        expect(
          hueDiff,
          lessThan(2.0),
          reason:
              'Hue drifted ${hueDiff.toStringAsFixed(2)}° for OKLCH(${oklch.l}, ${oklch.c}, ${oklch.h})',
        );

        // Lightness must be preserved within tolerance
        expect(
          roundtrip.l,
          closeTo(oklch.l, 0.02),
          reason:
              'Lightness drifted for OKLCH(${oklch.l}, ${oklch.c}, ${oklch.h})',
        );
      }
    });

    test('gamutMap returns identical color for in-gamut inputs', () {
      const inGamutColors = [
        Color(0xFF3B82F6), // blue
        Color(0xFFEF4444), // red
        Color(0xFF22C55E), // green
        Color(0xFFF59E0B), // amber
        Color(0xFF000000), // black
        Color(0xFFFFFFFF), // white
        Color(0xFF808080), // mid gray
      ];

      for (final color in inGamutColors) {
        final oklch = OklchEngine.fromColor(color);
        final gamutMapped = OklchEngine.gamutMap(oklch);
        final rawMapped = OklchEngine.toRawColor(oklch);

        expect(gamutMapped.r, closeTo(rawMapped.r, 0.005));
        expect(gamutMapped.g, closeTo(rawMapped.g, 0.005));
        expect(gamutMapped.b, closeTo(rawMapped.b, 0.005));
      }
    });

    test('toColor uses gamutMap (not raw clamping)', () {
      // A color that is clearly out of gamut
      const outOfGamut = OklchColor(0.7, 0.40, 150.0);
      final viaToColor = OklchEngine.toColor(outOfGamut);
      final viaGamutMap = OklchEngine.gamutMap(outOfGamut);

      expect(viaToColor.r, equals(viaGamutMap.r));
      expect(viaToColor.g, equals(viaGamutMap.g));
      expect(viaToColor.b, equals(viaGamutMap.b));
    });

    test('toRawColor preserves backward-compatible clamping behavior', () {
      const oklch = OklchColor(0.7, 0.35, 150.0);
      final raw = OklchEngine.toRawColor(oklch);

      // Raw clamping must produce valid sRGB values
      expect(raw.r, inInclusiveRange(0.0, 1.0));
      expect(raw.g, inInclusiveRange(0.0, 1.0));
      expect(raw.b, inInclusiveRange(0.0, 1.0));
    });

    // =========================================================
    // --- Tier 2: Hue-Aware Chroma Damping Tests ---
    // =========================================================

    test('maxChromaForLH returns positive values for mid-lightness', () {
      // Test across 12 hue angles
      for (double h = 0.0; h < 360.0; h += 30.0) {
        final maxC = OklchEngine.maxChromaForLH(0.5, h);
        expect(
          maxC,
          greaterThan(0.01),
          reason: 'maxChroma at L=0.5, H=$h should be > 0.01, got $maxC',
        );

        // Verify the returned chroma is actually in-gamut
        final color = OklchEngine.toRawColor(OklchColor(0.5, maxC, h));
        expect(color.r, inInclusiveRange(0.0, 1.0));
        expect(color.g, inInclusiveRange(0.0, 1.0));
        expect(color.b, inInclusiveRange(0.0, 1.0));
      }
    });

    test('maxChromaForLH returns 0 at extreme lightness', () {
      expect(OklchEngine.maxChromaForLH(0.0, 180.0), equals(0.0));
      expect(OklchEngine.maxChromaForLH(1.0, 180.0), equals(0.0));
    });

    test('maxChromaForLH varies by hue (yellow > blue at high lightness)', () {
      // Yellow (H≈90°) has wider gamut at high lightness than blue (H≈265°)
      final maxYellow = OklchEngine.maxChromaForLH(0.85, 90.0);
      final maxBlue = OklchEngine.maxChromaForLH(0.85, 265.0);

      expect(
        maxYellow,
        greaterThan(maxBlue),
        reason: 'Yellow should have wider gamut at L=0.85 than blue',
      );
    });

    test(
      'dampChromaHueAware preserves more chroma than legacy for yellow darks',
      () {
        const yellowHue = 90.0;
        const seedChroma = 0.18;
        const darkTargetL = 0.15;

        final legacy = OklchEngine.dampChroma(seedChroma, darkTargetL);
        final hueAware = OklchEngine.dampChromaHueAware(
          seedChroma,
          darkTargetL,
          yellowHue,
        );

        // Hue-aware should preserve more chroma for yellow at dark lightness
        // because yellow's gamut boundary is wider than the blind heuristic assumes
        expect(
          hueAware,
          greaterThan(legacy),
          reason:
              'Hue-aware damping should preserve more chroma for yellow darks '
              '(hueAware=$hueAware vs legacy=$legacy)',
        );
      },
    );

    test(
      'Yellow seed scale with hue-aware damping produces richer dark shades',
      () {
        const yellowSeed = Color(0xFFF59E0B);
        final scale = JustColorScale.fromSeed(
          yellowSeed,
          engine: JustColorSpaceEngine.oklch,
        );

        // c900 and c950 should have meaningful chroma (not grayish)
        final c900Oklch = OklchEngine.fromColor(scale.c900);
        final c950Oklch = OklchEngine.fromColor(scale.c950);

        expect(
          c900Oklch.c,
          greaterThan(0.01),
          reason:
              'Yellow c900 should be chromatic, not gray (c=${c900Oklch.c})',
        );
        expect(
          c950Oklch.c,
          greaterThan(0.005),
          reason: 'Yellow c950 should retain some warmth (c=${c950Oklch.c})',
        );
      },
    );

    // =========================================================
    // --- Tier 3: OKLCH Interpolation Tests ---
    // =========================================================

    test('OklchEngine.lerp avoids dead gray zone between blue and yellow', () {
      const blue = Color(0xFF2563EB);
      const yellow = Color(0xFFFBBF24);

      final midpoint = OklchEngine.lerp(blue, yellow, 0.5);
      final midOklch = OklchEngine.fromColor(midpoint);

      // The midpoint must have significant chroma (not gray/muddy)
      expect(
        midOklch.c,
        greaterThan(0.05),
        reason:
            'OKLCH lerp midpoint between blue and yellow should be vibrant, '
            'not gray (c=${midOklch.c})',
      );
    });

    test('OklchEngine.lerp edge cases: t=0 returns a, t=1 returns b', () {
      const a = Color(0xFFFF0000);
      const b = Color(0xFF0000FF);

      final atZero = OklchEngine.lerp(a, b, 0.0);
      final atOne = OklchEngine.lerp(a, b, 1.0);

      expect(atZero.r, equals(a.r));
      expect(atZero.g, equals(a.g));
      expect(atZero.b, equals(a.b));

      expect(atOne.r, equals(b.r));
      expect(atOne.g, equals(b.g));
      expect(atOne.b, equals(b.b));
    });

    test('OklchEngine.lerp uses shortest-arc hue interpolation', () {
      // Red (H≈29°) to Magenta (H≈328°): shortest arc goes backward (29→0→328)
      const red = Color(0xFFFF0000);
      const magenta = Color(0xFFFF00FF);

      final redOklch = OklchEngine.fromColor(red);
      final magentaOklch = OklchEngine.fromColor(magenta);

      final midpoint = OklchEngine.lerp(red, magenta, 0.5);
      final midOklch = OklchEngine.fromColor(midpoint);

      // The hue should be near 0/360° (passing through red), not near 180° (going through cyan)
      // Since shortest arc crosses 0°, the midpoint hue should be < 30 or > 330
      final isNearZero = midOklch.h < 40.0 || midOklch.h > 320.0;
      expect(
        isNearZero,
        isTrue,
        reason:
            'Shortest-arc hue interpolation: expected hue near 0/360°, '
            'got ${midOklch.h}° (red=${redOklch.h}°, magenta=${magentaOklch.h}°)',
      );
    });

    test('OklchEngine.lerp interpolates alpha correctly', () {
      final a = const Color(0xFFFF0000).withValues(alpha: 0.2);
      final b = const Color(0xFF0000FF).withValues(alpha: 0.8);

      final mid = OklchEngine.lerp(a, b, 0.5);
      expect(mid.a, closeTo(0.5, 0.01));
    });

    test(
      'Color.lerpToOklch extension works identically to OklchEngine.lerp',
      () {
        const a = Color(0xFF3B82F6);
        const b = Color(0xFFF59E0B);

        final viaStatic = OklchEngine.lerp(a, b, 0.5);
        final viaExtension = a.lerpToOklch(b, 0.5);

        expect(viaExtension.r, equals(viaStatic.r));
        expect(viaExtension.g, equals(viaStatic.g));
        expect(viaExtension.b, equals(viaStatic.b));
      },
    );

    test('OklchColorTween produces correct interpolation', () {
      final tween = OklchColorTween(
        begin: const Color(0xFF2563EB),
        end: const Color(0xFFFBBF24),
      );

      final atZero = tween.transform(0.0);
      final atMid = tween.transform(0.5);
      final atOne = tween.transform(1.0);

      expect(atZero.r, closeTo(const Color(0xFF2563EB).r, 0.01));
      expect(atOne.r, closeTo(const Color(0xFFFBBF24).r, 0.01));

      // Midpoint should be vibrant
      final midOklch = OklchEngine.fromColor(atMid);
      expect(midOklch.c, greaterThan(0.05));
    });

    // =========================================================
    // --- Phase A: Analytical Gamut Mapping + Premultiplied Alpha ---
    // =========================================================

    test('analytical maxChromaForLH produces colors AT the gamut boundary', () {
      // The analytical result should be right at the boundary —
      // the maxC color should be in-gamut, but maxC+epsilon should NOT.
      const testPoints = [
        (l: 0.3, h: 0.0), // dark red
        (l: 0.5, h: 90.0), // mid yellow
        (l: 0.5, h: 180.0), // mid cyan
        (l: 0.5, h: 270.0), // mid blue
        (l: 0.7, h: 30.0), // light orange
        (l: 0.85, h: 90.0), // light yellow
        (l: 0.2, h: 265.0), // dark blue
        (l: 0.6, h: 145.0), // mid green
      ];

      for (final tp in testPoints) {
        final maxC = OklchEngine.maxChromaForLH(tp.l, tp.h);

        // maxC itself must produce an in-gamut color
        final (rL, gL, bL) = _oklchToLinearRgbForTest(tp.l, maxC, tp.h);
        final inGamut =
            rL >= -0.001 &&
            rL <= 1.001 &&
            gL >= -0.001 &&
            gL <= 1.001 &&
            bL >= -0.001 &&
            bL <= 1.001;

        expect(
          inGamut,
          isTrue,
          reason:
              'maxChromaForLH(${tp.l}, ${tp.h}) = $maxC should be in-gamut '
              '(r=$rL, g=$gL, b=$bL)',
        );

        // maxC + small epsilon should be OUT of gamut (proving we're at the boundary)
        if (maxC > 0.001) {
          final (rO, gO, bO) = _oklchToLinearRgbForTest(
            tp.l,
            maxC + 0.005,
            tp.h,
          );
          final outOfGamut =
              rO < -0.001 ||
              rO > 1.001 ||
              gO < -0.001 ||
              gO > 1.001 ||
              bO < -0.001 ||
              bO > 1.001;

          expect(
            outOfGamut,
            isTrue,
            reason:
                'maxChroma + 0.005 at L=${tp.l}, H=${tp.h} should be out-of-gamut '
                '(r=$rO, g=$gO, b=$bO)',
          );
        }
      }
    });

    test('analytical maxChromaForLH is symmetric at achromatic boundaries', () {
      // Very dark and very light: chroma should approach 0
      expect(OklchEngine.maxChromaForLH(0.001, 180.0), lessThan(0.01));
      expect(OklchEngine.maxChromaForLH(0.999, 180.0), lessThan(0.01));
    });

    test('premultiplied alpha lerp: no halo during fade-out', () {
      // Opaque cyan fading to fully transparent
      const opaque = Color(0xFF00BCD4);
      final transparent = const Color(0xFF00BCD4).withValues(alpha: 0.0);

      // Sample 10 points along the transition
      for (double t = 0.1; t < 1.0; t += 0.1) {
        final mid = OklchEngine.lerp(opaque, transparent, t);
        final midOklch = OklchEngine.fromColor(mid);

        // With premultiplied alpha, the visible color should stay cyan —
        // NOT drift toward gray/black (which is the "halo" artifact)
        if (mid.a > 0.1) {
          final opaqueOklch = OklchEngine.fromColor(opaque);
          // Lightness should stay close to the opaque color's lightness
          expect(
            midOklch.l,
            closeTo(opaqueOklch.l, 0.15),
            reason:
                'At t=$t, lightness should not drift during fade-out '
                '(expected ~${opaqueOklch.l}, got ${midOklch.l})',
          );
        }
      }
    });

    test('premultiplied alpha lerp: fully transparent returns transparent', () {
      final a = const Color(0xFFFF0000).withValues(alpha: 0.0);
      final b = const Color(0xFF0000FF).withValues(alpha: 0.0);

      final mid = OklchEngine.lerp(a, b, 0.5);
      expect(mid.a, closeTo(0.0, 0.01));
    });

    test('lerp achromatic hue handling: gray to color uses color hue', () {
      const gray = Color(0xFF808080); // achromatic, c ≈ 0
      const blue = Color(0xFF2563EB); // chromatic

      final mid = OklchEngine.lerp(gray, blue, 0.5);
      final midOklch = OklchEngine.fromColor(mid);
      final blueOklch = OklchEngine.fromColor(blue);

      // The hue of the midpoint should be close to blue's hue (not 0°)
      if (midOklch.c > 0.01) {
        double hueDiff = (midOklch.h - blueOklch.h).abs();
        if (hueDiff > 180.0) hueDiff = 360.0 - hueDiff;
        expect(
          hueDiff,
          lessThan(15.0),
          reason:
              'Gray-to-blue midpoint hue should follow blue hue '
              '(mid=${midOklch.h}°, blue=${blueOklch.h}°)',
        );
      }
    });
  });
}

/// Test helper: replicates OklchEngine._oklchToLinearRgb for boundary testing.
(double, double, double) _oklchToLinearRgbForTest(
  double L,
  double C,
  double H,
) {
  final double hRad = H * (math.pi / 180.0);
  final double labA = C * math.cos(hRad);
  final double labB = C * math.sin(hRad);

  final double lCap = L + 0.3963377774 * labA + 0.2158037573 * labB;
  final double mCap = L - 0.1055613458 * labA - 0.0638541728 * labB;
  final double sCap = L - 0.0894841775 * labA - 1.2914855480 * labB;

  final double l = lCap * lCap * lCap;
  final double m = mCap * mCap * mCap;
  final double s = sCap * sCap * sCap;

  return (
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  );
}
