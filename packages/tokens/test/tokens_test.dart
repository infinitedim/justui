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

      // Test all getters of light scheme
      expect(light.background, equals(JustColorSemanticLight.background));
      expect(light.card, equals(JustColorSemanticLight.card));
      expect(light.elevated, equals(JustColorSemanticLight.elevated));
      expect(light.muted, equals(JustColorSemanticLight.muted));
      expect(light.overlay, equals(JustColorSemanticLight.overlay));
      expect(light.textPrimary, equals(JustColorSemanticLight.textPrimary));
      expect(light.textSecondary, equals(JustColorSemanticLight.textSecondary));
      expect(light.textDisabled, equals(JustColorSemanticLight.textDisabled));
      expect(light.textInverse, equals(JustColorSemanticLight.textInverse));
      expect(light.borderDefault, equals(JustColorSemanticLight.borderDefault));
      expect(light.borderFocus, equals(JustColorSemanticLight.borderFocus));
      expect(light.borderError, equals(JustColorSemanticLight.borderError));
      expect(light.success, equals(JustColorSemanticLight.success));
      expect(light.warning, equals(JustColorSemanticLight.warning));
      expect(light.error, equals(JustColorSemanticLight.error));
      expect(light.info, equals(JustColorSemanticLight.info));

      // Test all getters of dark scheme
      expect(dark.background, equals(JustColorSemanticDark.background));
      expect(dark.card, equals(JustColorSemanticDark.card));
      expect(dark.elevated, equals(JustColorSemanticDark.elevated));
      expect(dark.muted, equals(JustColorSemanticDark.muted));
      expect(dark.overlay, equals(JustColorSemanticDark.overlay));
      expect(dark.textPrimary, equals(JustColorSemanticDark.textPrimary));
      expect(dark.textSecondary, equals(JustColorSemanticDark.textSecondary));
      expect(dark.textDisabled, equals(JustColorSemanticDark.textDisabled));
      expect(dark.textInverse, equals(JustColorSemanticDark.textInverse));
      expect(dark.borderDefault, equals(JustColorSemanticDark.borderDefault));
      expect(dark.borderFocus, equals(JustColorSemanticDark.borderFocus));
      expect(dark.borderError, equals(JustColorSemanticDark.borderError));
      expect(dark.success, equals(JustColorSemanticDark.success));
      expect(dark.warning, equals(JustColorSemanticDark.warning));
      expect(dark.error, equals(JustColorSemanticDark.error));
      expect(dark.info, equals(JustColorSemanticDark.info));

      // Test all getters of neobrutalism light scheme
      expect(neoLight.background, equals(const Color(0xFFFFF8E7)));
      expect(neoLight.card, equals(const Color(0xFFFFFFFF)));
      expect(neoLight.elevated, equals(const Color(0xFFFFFFFF)));
      expect(neoLight.muted, equals(const Color(0xFFF1F5F9)));
      expect(neoLight.overlay, equals(const Color(0x99000000)));
      expect(neoLight.textPrimary, equals(const Color(0xFF000000)));
      expect(neoLight.textSecondary, equals(const Color(0xFF222222)));
      expect(neoLight.textDisabled, equals(const Color(0xFF777777)));
      expect(neoLight.textInverse, equals(const Color(0xFFFFFFFF)));
      expect(neoLight.borderDefault, equals(const Color(0xFF000000)));
      expect(neoLight.borderFocus, equals(const Color(0xFF000000)));
      expect(neoLight.borderError, equals(const Color(0xFF000000)));
      expect(neoLight.success, equals(const Color(0xFF38E54D)));
      expect(neoLight.warning, equals(const Color(0xFFFFD93D)));
      expect(neoLight.error, equals(const Color(0xFFFF4B4B)));
      expect(neoLight.info, equals(const Color(0xFF4D96FF)));

      // Test all getters of neobrutalism dark scheme
      expect(neoDark.background, equals(const Color(0xFF1A1A1A)));
      expect(neoDark.card, equals(const Color(0xFF262626)));
      expect(neoDark.elevated, equals(const Color(0xFF333333)));
      expect(neoDark.muted, equals(const Color(0xFF333333)));
      expect(neoDark.overlay, equals(const Color(0xCC000000)));
      expect(neoDark.textPrimary, equals(const Color(0xFFFFFFFF)));
      expect(neoDark.textSecondary, equals(const Color(0xFFCCCCCC)));
      expect(neoDark.textDisabled, equals(const Color(0xFF666666)));
      expect(neoDark.textInverse, equals(const Color(0xFF000000)));
      expect(neoDark.borderDefault, equals(const Color(0xFFFFFFFF)));
      expect(neoDark.borderFocus, equals(const Color(0xFFFFFFFF)));
      expect(neoDark.borderError, equals(const Color(0xFFFF5353)));
      expect(neoDark.success, equals(const Color(0xFF4ADE80)));
      expect(neoDark.warning, equals(const Color(0xFFFFE033)));
      expect(neoDark.error, equals(const Color(0xFFFF5353)));
      expect(neoDark.info, equals(const Color(0xFF60A5FA)));
    });

    test('JustThemePreset enum contains default_ and neobrutalism values', () {
      expect(JustThemePreset.values.length, equals(2));
      expect(JustThemePreset.values, contains(JustThemePreset.default_));
      expect(JustThemePreset.values, contains(JustThemePreset.neobrutalism));
    });

    test(
      'JustColorScheme equality (operator ==) and hashCode cover all branches',
      () {
        final light = JustColors.light();
        final dark = JustColors.dark();
        final neoLight = JustColors.neobrutalismLight();
        final neoDark = JustColors.neobrutalismDark();

        // Identical check
        expect(light == light, isTrue);
        expect(light == JustColors.light(), isTrue);
        expect(light.hashCode, equals(JustColors.light().hashCode));
        expect(dark.hashCode, equals(JustColors.dark().hashCode));
        expect(
          neoLight.hashCode,
          equals(JustColors.neobrutalismLight().hashCode),
        );
        expect(
          neoDark.hashCode,
          equals(JustColors.neobrutalismDark().hashCode),
        );

        // Non-scheme object check
        expect(light == Object(), isFalse);

        // Differing scheme checks
        expect(light == dark, isFalse);
        expect(light == neoLight, isFalse);
        expect(dark == neoDark, isFalse);
      },
    );
  });

  group('Breakpoints Tokens Validation', () {
    test('Breakpoints values match desktop/tablet/mobile specs', () {
      expect(JustBreakpoints.sm, equals(640.0));
      expect(JustBreakpoints.md, equals(768.0));
      expect(JustBreakpoints.lg, equals(1024.0));
      expect(JustBreakpoints.xl, equals(1280.0));
      expect(JustBreakpoints.xxl, equals(1536.0));
    });
  });

  group('Spacing & Gap Tokens Validation', () {
    test('Spacing values are positive and monotonically increasing', () {
      expect(JustSpacing.xxs, equals(2.0));
      expect(JustSpacing.xs, equals(4.0));
      expect(JustSpacing.sm, equals(8.0));
      expect(JustSpacing.md, equals(12.0));
      expect(JustSpacing.lg, equals(16.0));
      expect(JustSpacing.xl, equals(24.0));
      expect(JustSpacing.xxl, equals(32.0));
      expect(JustSpacing.xxxl, equals(48.0));
      expect(JustSpacing.huge, equals(64.0));
    });

    test('EdgeInsets helper covers all parameters and combinations', () {
      final all = JustSpacing.insets(all: JustSpacing.md);
      expect(all, equals(const EdgeInsets.all(12.0)));

      final symmetric = JustSpacing.insets(
        h: JustSpacing.lg,
        v: JustSpacing.sm,
      );
      expect(
        symmetric,
        equals(const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
      );

      final zeroInsets = JustSpacing.insets();
      expect(zeroInsets, equals(EdgeInsets.zero));
    });

    testWidgets('JustGap static SizedBox widgets match spacing dimensions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
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

      final gaps = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(gaps.length, equals(9));
      expect(gaps[0].width, equals(JustSpacing.xxs));
      expect(gaps[1].width, equals(JustSpacing.xs));
      expect(gaps[2].width, equals(JustSpacing.sm));
      expect(gaps[3].width, equals(JustSpacing.md));
      expect(gaps[4].width, equals(JustSpacing.lg));
      expect(gaps[5].width, equals(JustSpacing.xl));
      expect(gaps[6].width, equals(JustSpacing.xxl));
      expect(gaps[7].width, equals(JustSpacing.xxxl));
      expect(gaps[8].width, equals(JustSpacing.huge));
    });
  });

  group('Typography Tokens Validation', () {
    test('Font family definitions and fallback chains are correct', () {
      expect(JustTypo.fontFamily, equals('Inter'));
      expect(
        JustTypo.fontFamilyFallback,
        equals([
          'SF Pro Text',
          'Roboto',
          'Segoe UI',
          'system-ui',
          'sans-serif',
        ]),
      );
      expect(JustTypo.monoFontFamily, equals('JetBrains Mono'));
      expect(
        JustTypo.monoFontFamilyFallback,
        equals(['SF Mono', 'Fira Code', 'Consolas', 'monospace']),
      );
    });

    test('All static TextStyle scales have expected font properties', () {
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
        expect(style.fontFamily, equals('Inter'));
        expect(style.fontSize, isNotNull);
        expect(style.fontWeight, isNotNull);
        expect(style.height, isNotNull);
        expect(style.letterSpacing, isNotNull);
      }
    });
  });

  group('Radius & BorderRadius Tokens Validation', () {
    test('Radius and BorderRadius scales match', () {
      expect(JustRadius.none.x, equals(0.0));
      expect(JustRadius.xs.x, equals(2.0));
      expect(JustRadius.sm.x, equals(4.0));
      expect(JustRadius.md.x, equals(8.0));
      expect(JustRadius.lg.x, equals(12.0));
      expect(JustRadius.xl.x, equals(16.0));
      expect(JustRadius.xxl.x, equals(24.0));
      expect(JustRadius.full.x, equals(9999.0));

      expect(JustBorderRadius.none, equals(BorderRadius.zero));
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
    test('Static shadow lists are correctly formatted', () {
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

      for (final list in shadowLists) {
        expect(list, isNotEmpty);
        for (final shadow in list) {
          expect(shadow.color, isNotNull);
          expect(shadow.blurRadius, greaterThanOrEqualTo(0.0));
        }
      }
    });

    test(
      'JustShadows.generate covers all elevation branches and dark/light modes',
      () {
        const seed = Color(0xFF3B82F6);

        // elevation <= 4 branch (light & dark)
        final elev2Light = JustShadows.generate(
          seedColor: seed,
          elevation: 2,
          isDark: false,
        );
        final elev2Dark = JustShadows.generate(
          seedColor: seed,
          elevation: 2,
          isDark: true,
        );
        expect(elev2Light.length, equals(2));
        expect(elev2Dark.length, equals(2));

        // elevation <= 8 branch (light & dark)
        final elev6Light = JustShadows.generate(
          seedColor: seed,
          elevation: 6,
          isDark: false,
        );
        final elev6Dark = JustShadows.generate(
          seedColor: seed,
          elevation: 6,
          isDark: true,
        );
        expect(elev6Light.length, equals(2));
        expect(elev6Dark.length, equals(2));

        // elevation <= 16 branch (light & dark)
        final elev12Light = JustShadows.generate(
          seedColor: seed,
          elevation: 12,
          isDark: false,
        );
        final elev12Dark = JustShadows.generate(
          seedColor: seed,
          elevation: 12,
          isDark: true,
        );
        expect(elev12Light.length, equals(2));
        expect(elev12Dark.length, equals(2));

        // elevation > 16 branch (light & dark)
        final elev24Light = JustShadows.generate(
          seedColor: seed,
          elevation: 24,
          isDark: false,
        );
        final elev24Dark = JustShadows.generate(
          seedColor: seed,
          elevation: 24,
          isDark: true,
        );
        expect(elev24Light.length, equals(2));
        expect(elev24Dark.length, equals(2));
      },
    );
  });

  group('Duration & Curve Tokens Validation', () {
    test('Duration static constants are positive', () {
      expect(JustDuration.instant.inMilliseconds, equals(50));
      expect(JustDuration.fast.inMilliseconds, equals(150));
      expect(JustDuration.normal.inMilliseconds, equals(250));
      expect(JustDuration.slow.inMilliseconds, equals(400));
      expect(JustDuration.slower.inMilliseconds, equals(600));
    });

    test('JustDuration.scaleForDistance handles zero, negative, mid, and max clamped distances', () {
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

      // Early return: ratio already satisfied
      expect(
        sufficientText.adjustLightnessForContrast(
          background: lightBg,
          targetRatio: 4.5,
        ),
        equals(sufficientText),
      );

      // makeLighter = false branch (background luminance >= 0.5)
      final darkerResult = lowContrastGrey.adjustLightnessForContrast(
        background: lightBg,
        targetRatio: 4.5,
      );
      expect(
        darkerResult.contrastRatioWith(lightBg),
        greaterThanOrEqualTo(4.5),
      );

      // makeLighter = true branch (background luminance < 0.5)
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

  group('Fluid Typography & Motion Profile Validation', () {
    testWidgets('Fluid typography extension and adaptive heights', (
      WidgetTester tester,
    ) async {
      const style = TextStyle(fontSize: 16.0);

      final fluidStyle = style.fluid(
        screenWidth: 800.0,
        minWidth: 640.0,
        maxWidth: 1024.0,
        minSize: 20.0,
        maxSize: 32.0,
      );
      expect(fluidStyle.fontSize, isNotNull);

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

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800.0, 600.0)),
          child: Builder(
            builder: (context) {
              // Test null fontSize fallback in withAdaptiveHeight (line 36)
              const nullFontSizeStyle = TextStyle();
              final adaptiveFallback = nullFontSizeStyle.withAdaptiveHeight(
                context,
              );
              expect(adaptiveFallback.height, isNotNull);

              // Test all JustFluidTypo static methods
              expect(JustFluidTypo.displayLg(context).fontSize, isNotNull);
              expect(JustFluidTypo.displayMd(context).fontSize, isNotNull);
              expect(JustFluidTypo.displaySm(context).fontSize, isNotNull);
              expect(JustFluidTypo.headingLg(context).fontSize, isNotNull);
              expect(JustFluidTypo.headingMd(context).fontSize, isNotNull);
              expect(JustFluidTypo.headingSm(context).fontSize, isNotNull);
              expect(JustFluidTypo.bodyLg(context).fontSize, isNotNull);
              expect(JustFluidTypo.bodyMd(context).fontSize, isNotNull);
              expect(JustFluidTypo.bodySm(context).fontSize, isNotNull);

              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

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
