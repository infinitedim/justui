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

    test('JustColorScale generates complete 11-step HSL scale from seed', () {
      const seed = Color(0xFF3B82F6);
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
    });

    test('adjustLightnessForContrast covers early return and dark/light background branches', () {
      const lightBg = Color(0xFFFFFFFF);
      const darkBg = Color(0xFF000000);
      const sufficientText = Color(0xFF000000);
      const lowContrastGrey = Color(0xFF94A3B8);

      expect(
        sufficientText.adjustLightnessForContrast(
          background: lightBg,
          targetRatio: 4.5,
        ),
        equals(sufficientText),
      );

      final darkerResult = lowContrastGrey.adjustLightnessForContrast(
        background: lightBg,
        targetRatio: 4.5,
      );
      expect(
        darkerResult.contrastRatioWith(lightBg),
        greaterThanOrEqualTo(4.5),
      );

      final lighterResult = lowContrastGrey.adjustLightnessForContrast(
        background: darkBg,
        targetRatio: 4.5,
      );
      expect(
        lighterResult.contrastRatioWith(darkBg),
        greaterThanOrEqualTo(4.5),
      );
    });

    test(
      'JustDynamicSurfaces.generateDarkSurface clamps saturation and lightness',
      () {
        const seed = Color(0xFF3B82F6);
        final darkSurface = JustDynamicSurfaces.generateDarkSurface(
          seed,
          lightness: 0.05,
        );

        final HSLColor hslSeed = HSLColor.fromColor(seed);
        final HSLColor hslSurface = HSLColor.fromColor(darkSurface);

        expect(hslSurface.hue, closeTo(hslSeed.hue, 0.01));
        expect(hslSurface.lightness, equals(0.05));
      },
    );
  });
}
