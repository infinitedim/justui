import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';

class _CustomTypographyScheme extends JustTypographyScheme {
  const _CustomTypographyScheme();
  @override
  TextStyle get displayLg => const TextStyle(fontSize: 48);
  @override
  TextStyle get displayMd => const TextStyle(fontSize: 36);
  @override
  TextStyle get displaySm => const TextStyle(fontSize: 30);
  @override
  TextStyle get headingLg => const TextStyle(fontSize: 24);
  @override
  TextStyle get headingMd => const TextStyle(fontSize: 20);
  @override
  TextStyle get headingSm => const TextStyle(fontSize: 18);
  @override
  TextStyle get bodyLg => const TextStyle(fontSize: 16);
  @override
  TextStyle get bodyMd => const TextStyle(fontSize: 14);
  @override
  TextStyle get bodySm => const TextStyle(fontSize: 12);
  @override
  TextStyle get caption => const TextStyle(fontSize: 10);
  @override
  TextStyle get overline => const TextStyle(fontSize: 9);
}

class _TestOverlayController extends JustOverlayController {
  bool _visible = false;
  bool disposed = false;
  bool dismissed = false;

  @override
  bool get isVisible => _visible;

  void show() => _visible = true;

  @override
  void dismiss() {
    dismissed = true;
    _visible = false;
  }

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JustRadiusScheme Tests', () {
    test('DefaultRadiusScheme returns token values', () {
      const scheme = DefaultRadiusScheme();
      expect(scheme.none, equals(JustRadius.none));
      expect(scheme.xs, equals(JustRadius.xs));
      expect(scheme.sm, equals(JustRadius.sm));
      expect(scheme.md, equals(JustRadius.md));
      expect(scheme.lg, equals(JustRadius.lg));
      expect(scheme.xl, equals(JustRadius.xl));
      expect(scheme.xxl, equals(JustRadius.xxl));
      expect(scheme.full, equals(JustRadius.full));
      expect(scheme.resolve(1200), equals(scheme));
    });

    test(
      'FluidRadiusScheme calculates fluid values across viewport ranges',
      () {
        const minScheme = FluidRadiusScheme(width: 500.0); // Clamped to 640
        const midScheme = FluidRadiusScheme(
          width: 832.0,
        ); // Midpoint between 640 and 1024
        const maxScheme = FluidRadiusScheme(width: 1200.0); // Clamped to 1024

        expect(minScheme.none, equals(Radius.zero));
        expect(minScheme.full, equals(const Radius.circular(9999.0)));
        expect(minScheme.xs.x, closeTo(1.5, 0.01));
        expect(minScheme.sm.x, closeTo(3.0, 0.01));
        expect(minScheme.md.x, closeTo(6.0, 0.01));
        expect(minScheme.lg.x, closeTo(8.0, 0.01));
        expect(minScheme.xl.x, closeTo(12.0, 0.01));
        expect(minScheme.xxl.x, closeTo(16.0, 0.01));

        expect(maxScheme.xs.x, closeTo(2.0, 0.01));
        expect(maxScheme.sm.x, closeTo(4.0, 0.01));
        expect(maxScheme.md.x, closeTo(8.0, 0.01));
        expect(maxScheme.lg.x, closeTo(12.0, 0.01));
        expect(maxScheme.xl.x, closeTo(16.0, 0.01));
        expect(maxScheme.xxl.x, closeTo(24.0, 0.01));

        expect(midScheme.xs.x, greaterThan(minScheme.xs.x));
        expect(midScheme.xs.x, lessThan(maxScheme.xs.x));

        final resolved = minScheme.resolve(1024.0);
        expect(resolved, isA<FluidRadiusScheme>());
        expect((resolved as FluidRadiusScheme).width, equals(1024.0));
      },
    );

    test('JustRadiusScheme equality and hashCode', () {
      const scheme1 = DefaultRadiusScheme();
      const scheme2 = DefaultRadiusScheme();
      const fluid1 = FluidRadiusScheme(width: 800.0);
      const fluid2 = FluidRadiusScheme(width: 800.0);
      const fluid3 = FluidRadiusScheme(width: 900.0);

      expect(scheme1, equals(scheme2));
      expect(scheme1.hashCode, equals(scheme2.hashCode));

      expect(fluid1, equals(fluid2));
      expect(fluid1.hashCode, equals(fluid2.hashCode));
      expect(fluid1 == fluid3, isFalse);
      expect(scheme1 == fluid1, isFalse);
    });
  });

  group('JustShadowScheme Tests', () {
    test('DefaultShadowSchemeLight and Dark return token values', () {
      const light = DefaultShadowSchemeLight();
      const dark = DefaultShadowSchemeDark();

      expect(light.xs, equals(JustShadows.xs));
      expect(light.sm, equals(JustShadows.sm));
      expect(light.md, equals(JustShadows.md));
      expect(light.lg, equals(JustShadows.lg));
      expect(light.xl, equals(JustShadows.xl));
      expect(light.xxl, equals(JustShadows.xxl));

      expect(dark.xs, equals(JustShadows.xsDark));
      expect(dark.sm, equals(JustShadows.smDark));
      expect(dark.md, equals(JustShadows.mdDark));
      expect(dark.lg, equals(JustShadows.lgDark));
      expect(dark.xl, equals(JustShadows.xlDark));
      expect(dark.xxl, equals(JustShadows.xxlDark));

      expect(light, equals(const DefaultShadowSchemeLight()));
      expect(dark, equals(const DefaultShadowSchemeDark()));
      expect(light == dark, isFalse);
      expect(light.hashCode, equals(const DefaultShadowSchemeLight().hashCode));
    });

    test('TintedShadowScheme generates dynamic tinted shadows', () {
      const seed = Color(0xFF3B82F6);
      const tintedLight = TintedShadowScheme(seedColor: seed, isDark: false);
      const tintedDark = TintedShadowScheme(seedColor: seed, isDark: true);
      const tintedSame = TintedShadowScheme(seedColor: seed, isDark: false);

      expect(tintedLight.xs.isNotEmpty, isTrue);
      expect(tintedLight.sm.isNotEmpty, isTrue);
      expect(tintedLight.md.isNotEmpty, isTrue);
      expect(tintedLight.lg.isNotEmpty, isTrue);
      expect(tintedLight.xl.isNotEmpty, isTrue);
      expect(tintedLight.xxl.isNotEmpty, isTrue);

      expect(tintedLight, equals(tintedSame));
      expect(tintedLight.hashCode, equals(tintedSame.hashCode));
      expect(tintedLight == tintedDark, isFalse);
    });

    test('NeobrutalismShadowScheme produces flat solid offset shadows', () {
      const neoLight = NeobrutalismShadowScheme();
      const neoDark = NeobrutalismShadowScheme(shadowColor: Color(0xFFFFFFFF));
      const neoSame = NeobrutalismShadowScheme();

      expect(neoLight.xs.first.blurRadius, equals(0.0));
      expect(neoLight.xs.first.offset, equals(const Offset(2.0, 2.0)));
      expect(neoLight.sm.first.offset, equals(const Offset(4.0, 4.0)));
      expect(neoLight.md.first.offset, equals(const Offset(6.0, 6.0)));
      expect(neoLight.lg.first.offset, equals(const Offset(8.0, 8.0)));
      expect(neoLight.xl.first.offset, equals(const Offset(10.0, 10.0)));
      expect(neoLight.xxl.first.offset, equals(const Offset(12.0, 12.0)));

      expect(neoLight, equals(neoSame));
      expect(neoLight.hashCode, equals(neoSame.hashCode));
      expect(neoLight == neoDark, isFalse);
    });
  });

  group('JustSpacingScheme Tests', () {
    test('DefaultSpacingScheme returns token spacing values', () {
      const scheme = DefaultSpacingScheme();
      expect(scheme.xxs, equals(JustSpacing.xxs));
      expect(scheme.xs, equals(JustSpacing.xs));
      expect(scheme.sm, equals(JustSpacing.sm));
      expect(scheme.md, equals(JustSpacing.md));
      expect(scheme.lg, equals(JustSpacing.lg));
      expect(scheme.xl, equals(JustSpacing.xl));
      expect(scheme.xxl, equals(JustSpacing.xxl));
      expect(scheme.xxxl, equals(JustSpacing.xxxl));
      expect(scheme.huge, equals(JustSpacing.huge));
      expect(scheme.resolve(1000), equals(scheme));
    });

    test('FluidSpacingScheme calculates fluid values smoothly', () {
      const minScheme = FluidSpacingScheme(width: 600.0); // Clamped to 640
      const midScheme = FluidSpacingScheme(width: 832.0);
      const maxScheme = FluidSpacingScheme(width: 1400.0); // Clamped to 1024

      expect(minScheme.xxs, closeTo(1.5, 0.01));
      expect(minScheme.xs, closeTo(3.0, 0.01));
      expect(minScheme.sm, closeTo(6.0, 0.01));
      expect(minScheme.md, closeTo(9.0, 0.01));
      expect(minScheme.lg, closeTo(12.0, 0.01));
      expect(minScheme.xl, closeTo(18.0, 0.01));
      expect(minScheme.xxl, closeTo(24.0, 0.01));
      expect(minScheme.xxxl, closeTo(36.0, 0.01));
      expect(minScheme.huge, closeTo(48.0, 0.01));

      expect(maxScheme.xxs, closeTo(2.0, 0.01));
      expect(maxScheme.xs, closeTo(4.0, 0.01));
      expect(maxScheme.sm, closeTo(8.0, 0.01));
      expect(maxScheme.md, closeTo(12.0, 0.01));
      expect(maxScheme.lg, closeTo(16.0, 0.01));
      expect(maxScheme.xl, closeTo(24.0, 0.01));
      expect(maxScheme.xxl, closeTo(32.0, 0.01));
      expect(maxScheme.xxxl, closeTo(48.0, 0.01));
      expect(maxScheme.huge, closeTo(64.0, 0.01));

      expect(midScheme.md, greaterThan(minScheme.md));
      expect(midScheme.md, lessThan(maxScheme.md));

      final resolved = minScheme.resolve(800.0);
      expect(resolved, isA<FluidSpacingScheme>());
      expect((resolved as FluidSpacingScheme).width, equals(800.0));
    });

    test('JustSpacingScheme equality and hashCode', () {
      const scheme1 = DefaultSpacingScheme();
      const scheme2 = DefaultSpacingScheme();
      const fluid1 = FluidSpacingScheme(width: 720.0);
      const fluid2 = FluidSpacingScheme(width: 720.0);
      const fluid3 = FluidSpacingScheme(width: 900.0);

      expect(scheme1, equals(scheme2));
      expect(scheme1.hashCode, equals(scheme2.hashCode));

      expect(fluid1, equals(fluid2));
      expect(fluid1.hashCode, equals(fluid2.hashCode));
      expect(fluid1 == fluid3, isFalse);
      expect(scheme1 == fluid1, isFalse);
    });
  });

  group('JustTypographyScheme Tests', () {
    test('DefaultTypographyScheme provides complete typography styles', () {
      const scheme = DefaultTypographyScheme();
      expect(scheme.displayLg.fontSize, equals(JustTypo.displayLg.fontSize));
      expect(scheme.displayMd.fontSize, equals(JustTypo.displayMd.fontSize));
      expect(scheme.displaySm.fontSize, equals(JustTypo.displaySm.fontSize));
      expect(scheme.headingLg.fontSize, equals(JustTypo.headingLg.fontSize));
      expect(scheme.headingMd.fontSize, equals(JustTypo.headingMd.fontSize));
      expect(scheme.headingSm.fontSize, equals(JustTypo.headingSm.fontSize));
      expect(scheme.bodyLg.fontSize, equals(JustTypo.bodyLg.fontSize));
      expect(scheme.bodyMd.fontSize, equals(JustTypo.bodyMd.fontSize));
      expect(scheme.bodySm.fontSize, equals(JustTypo.bodySm.fontSize));
      expect(scheme.caption.fontSize, equals(JustTypo.caption.fontSize));
      expect(scheme.overline.fontSize, equals(JustTypo.overline.fontSize));
    });

    test(
      'JustTypographyScheme.fromFontFamily creates custom font family scheme',
      () {
        const customScheme = DefaultTypographyScheme(
          fontFamily: 'Inter',
          fontFamilyFallback: ['Roboto', 'Arial'],
          monoFontFamily: 'FiraCode',
          monoFontFamilyFallback: ['Courier'],
        );

        expect(customScheme.fontFamily, equals('Inter'));
        expect(customScheme.fontFamilyFallback, equals(['Roboto', 'Arial']));
        expect(customScheme.monoFontFamily, equals('FiraCode'));
        expect(customScheme.monoFontFamilyFallback, equals(['Courier']));

        expect(customScheme.bodyMd.fontFamily, equals('Inter'));
        expect(
          customScheme.bodyMd.fontFamilyFallback,
          equals(['Roboto', 'Arial']),
        );

        const factoryScheme = JustTypographyScheme.fromFontFamily(
          fontFamily: 'Poppins',
        );
        expect(factoryScheme, isA<DefaultTypographyScheme>());
        expect(
          (factoryScheme as DefaultTypographyScheme).fontFamily,
          equals('Poppins'),
        );
      },
    );

    test('JustTypographyScheme equality and hashCode', () {
      const scheme1 = DefaultTypographyScheme();
      const scheme2 = DefaultTypographyScheme();
      const custom1 = DefaultTypographyScheme(
        fontFamily: 'Inter',
        fontFamilyFallback: ['Roboto'],
      );
      const custom2 = DefaultTypographyScheme(
        fontFamily: 'Inter',
        fontFamilyFallback: ['Roboto'],
      );
      const custom3 = DefaultTypographyScheme(fontFamily: 'Poppins');
      const baseCustom1 = _CustomTypographyScheme();
      const baseCustom2 = _CustomTypographyScheme();

      expect(scheme1, equals(scheme2));
      expect(scheme1.hashCode, equals(scheme2.hashCode));

      expect(custom1, equals(custom2));
      expect(custom1.hashCode, equals(custom2.hashCode));
      expect(custom1 == custom3, isFalse);

      expect(baseCustom1, equals(baseCustom2));
      expect(baseCustom1.hashCode, equals(baseCustom2.hashCode));
    });
  });

  group('JustPresetTokens Tests', () {
    test('DefaultPresetTokens properties and token contracts', () {
      const tokens = DefaultPresetTokens();
      const radius = DefaultRadiusScheme();
      const shadows = DefaultShadowSchemeLight();

      expect(tokens.borderWidth, equals(1.0));
      expect(tokens.emphasizedBorderWidth, equals(2.0));
      expect(tokens.showsDefaultBorder, isFalse);

      expect(
        tokens.resolveBorderRadius(radius),
        equals(BorderRadius.all(radius.md)),
      );
      expect(
        tokens.resolveBorderRadius(radius, isPill: true),
        equals(BorderRadius.all(radius.full)),
      );
      expect(
        tokens.resolveBorderRadius(radius, isCircle: true),
        equals(BorderRadius.all(radius.full)),
      );

      final unpressedShadows = tokens.resolveShadow(
        shadows,
        JustShadowLevel.md,
        isPressed: false,
      );
      expect(unpressedShadows, equals(shadows.md));

      final pressedShadows = tokens.resolveShadow(
        shadows,
        JustShadowLevel.md,
        isPressed: true,
      );
      expect(
        pressedShadows.first.blurRadius,
        closeTo(shadows.md.first.blurRadius * 0.6, 0.01),
      );

      // Test all shadow levels
      for (final level in JustShadowLevel.values) {
        expect(
          tokens.resolveShadow(shadows, level, isPressed: false).isNotEmpty,
          isTrue,
        );
      }

      final hoverDeco = tokens.resolveHoverDecoration(
        JustColors.light(),
        accentColor: Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      );
      expect(hoverDeco, isNotNull);
      expect(hoverDeco?.borderRadius, equals(BorderRadius.circular(8.0)));

      expect(tokens.resolveSliderTrackHeight(JustSliderSize.sm), equals(4.0));
      expect(tokens.resolveSliderTrackHeight(JustSliderSize.md), equals(6.0));
      expect(tokens.resolveSliderTrackHeight(JustSliderSize.lg), equals(8.0));

      expect(tokens.resolveSliderThumbSize(JustSliderSize.sm), equals(14.0));
      expect(tokens.resolveSliderThumbSize(JustSliderSize.md), equals(20.0));
      expect(tokens.resolveSliderThumbSize(JustSliderSize.lg), equals(26.0));

      expect(tokens.sliderDefaultHaptic, isFalse);

      expect(
        tokens.resolveProgressStrokeWidth(JustProgressSize.sm),
        equals(2.0),
      );
      expect(
        tokens.resolveProgressStrokeWidth(JustProgressSize.md),
        equals(3.0),
      );
      expect(
        tokens.resolveProgressStrokeWidth(JustProgressSize.lg),
        equals(4.0),
      );

      expect(tokens.progressLabelWeight, equals(FontWeight.w500));
      expect(tokens.resolveSeparatorThickness(1.5), equals(1.5));
      expect(tokens.resolveTabIndicatorThickness(null), equals(2.0));
      expect(tokens.resolveTabIndicatorThickness(3.5), equals(3.5));

      expect(
        tokens.resolveFocusTransitionDuration(JustMotionProfile.standard),
        equals(JustMotionProfile.standard.fast),
      );
      expect(
        tokens.focusTransitionDuration,
        equals(const Duration(milliseconds: 150)),
      );
      expect(
        tokens.resolveDropdownDuration(JustMotionProfile.standard),
        equals(JustMotionProfile.standard.fast),
      );
      expect(
        tokens.resolveDropdownCurve(JustMotionProfile.standard),
        equals(JustMotionProfile.standard.defaultCurve),
      );
      expect(tokens.dropdownOpenCurve, equals(Curves.easeOut));
      expect(
        tokens.dropdownOpenDuration,
        equals(const Duration(milliseconds: 200)),
      );
      expect(tokens.selectionHapticDefault, isFalse);
      expect(tokens.usePulsingSkeleton, isFalse);
    });

    test('NeobrutalismPresetTokens properties and token contracts', () {
      const tokens = NeobrutalismPresetTokens();
      const radius = DefaultRadiusScheme();
      const shadows = NeobrutalismShadowScheme();

      expect(tokens.borderWidth, equals(2.5));
      expect(tokens.emphasizedBorderWidth, equals(3.0));
      expect(tokens.showsDefaultBorder, isTrue);

      expect(tokens.resolveBorderRadius(radius), equals(BorderRadius.zero));
      expect(
        tokens.resolveBorderRadius(radius, isPill: true),
        equals(BorderRadius.all(radius.full)),
      );
      expect(
        tokens.resolveBorderRadius(radius, isCircle: true),
        equals(BorderRadius.all(radius.full)),
      );

      final unpressedShadows = tokens.resolveShadow(
        shadows,
        JustShadowLevel.md,
        isPressed: false,
      );
      expect(unpressedShadows, equals(shadows.md));

      final pressedShadows = tokens.resolveShadow(
        shadows,
        JustShadowLevel.md,
        isPressed: true,
      );
      expect(pressedShadows, isEmpty);

      for (final level in JustShadowLevel.values) {
        expect(
          tokens.resolveShadow(shadows, level, isPressed: false).isNotEmpty,
          isTrue,
        );
      }

      final hoverDeco = tokens.resolveHoverDecoration(
        JustColors.light(),
        accentColor: Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      );
      expect(hoverDeco, isNotNull);
      expect(hoverDeco?.border, isNotNull);

      expect(tokens.resolveSliderTrackHeight(JustSliderSize.sm), equals(6.0));
      expect(tokens.resolveSliderTrackHeight(JustSliderSize.md), equals(10.0));
      expect(tokens.resolveSliderTrackHeight(JustSliderSize.lg), equals(14.0));

      expect(tokens.resolveSliderThumbSize(JustSliderSize.sm), equals(16.0));
      expect(tokens.resolveSliderThumbSize(JustSliderSize.md), equals(22.0));
      expect(tokens.resolveSliderThumbSize(JustSliderSize.lg), equals(28.0));

      expect(tokens.sliderDefaultHaptic, isTrue);

      expect(
        tokens.resolveProgressStrokeWidth(JustProgressSize.sm),
        equals(3.0),
      );
      expect(
        tokens.resolveProgressStrokeWidth(JustProgressSize.md),
        equals(4.0),
      );
      expect(
        tokens.resolveProgressStrokeWidth(JustProgressSize.lg),
        equals(5.0),
      );

      expect(tokens.progressLabelWeight, equals(FontWeight.w700));
      expect(
        tokens.resolveSeparatorThickness(1.0),
        equals(2.0),
      ); // minimum 2.0 in neobrutalism
      expect(tokens.resolveSeparatorThickness(3.0), equals(3.0));
      expect(tokens.resolveTabIndicatorThickness(null), equals(4.0));
      expect(tokens.resolveTabIndicatorThickness(5.0), equals(5.0));

      expect(
        tokens.resolveFocusTransitionDuration(JustMotionProfile.standard),
        equals(JustMotionProfile.standard.instant),
      );
      expect(
        tokens.focusTransitionDuration,
        equals(const Duration(milliseconds: 50)),
      );
      expect(
        tokens.resolveDropdownDuration(JustMotionProfile.standard),
        equals(JustMotionProfile.standard.instant),
      );
      expect(
        tokens.resolveDropdownCurve(JustMotionProfile.standard),
        equals(JustMotionProfile.standard.defaultCurve),
      );
      expect(tokens.dropdownOpenCurve, equals(Curves.linear));
      expect(
        tokens.dropdownOpenDuration,
        equals(const Duration(milliseconds: 80)),
      );
      expect(tokens.selectionHapticDefault, isTrue);
      expect(tokens.usePulsingSkeleton, isTrue);
    });

    test('JustThemePreset enum maps to corresponding tokens extension', () {
      expect(JustThemePreset.default_.tokens, isA<DefaultPresetTokens>());
      expect(
        JustThemePreset.neobrutalism.tokens,
        isA<NeobrutalismPresetTokens>(),
      );
    });

    testWidgets(
      'buildPressEffect renders correctly for default and neobrutalism tokens',
      (tester) async {
        const defaultTokens = DefaultPresetTokens();
        const neoTokens = NeobrutalismPresetTokens();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                defaultTokens.buildPressEffect(
                  isPressed: true,
                  animations: JustMotionProfile.standard,
                  customScale: 0.95,
                  child: const Text('Default Pressed'),
                ),
                neoTokens.buildPressEffect(
                  isPressed: true,
                  animations: JustMotionProfile.neobrutalism,
                  customOffset: const Offset(3.0, 3.0),
                  child: const Text('Neo Pressed'),
                ),
              ],
            ),
          ),
        );

        expect(find.text('Default Pressed'), findsOneWidget);
        expect(find.text('Neo Pressed'), findsOneWidget);
      },
    );
  });

  group('JustOverlayScope and JustOverlayController Tests', () {
    test('JustOverlayController lifecycle and state', () {
      final controller = _TestOverlayController();
      expect(controller.isVisible, isFalse);
      expect(controller.dismissed, isFalse);
      expect(controller.disposed, isFalse);

      controller.show();
      expect(controller.isVisible, isTrue);

      controller.dismiss();
      expect(controller.isVisible, isFalse);
      expect(controller.dismissed, isTrue);

      controller.dispose();
      expect(controller.disposed, isTrue);
    });

    testWidgets('JustOverlayScope exposes controller and handles updates', (
      tester,
    ) async {
      final controller1 = _TestOverlayController();
      final controller2 = _TestOverlayController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: JustOverlayScope<_TestOverlayController>(
            controller: controller1,
            child: Builder(
              builder: (context) {
                final retrieved = JustOverlayScope.of<_TestOverlayController>(
                  context,
                );
                return Text(
                  'Controller matches: ${identical(retrieved, controller1)}',
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Controller matches: true'), findsOneWidget);

      final scope = JustOverlayScope<_TestOverlayController>(
        controller: controller1,
        child: const SizedBox(),
      );
      final sameScope = JustOverlayScope<_TestOverlayController>(
        controller: controller1,
        child: const SizedBox(),
      );
      final differentScope = JustOverlayScope<_TestOverlayController>(
        controller: controller2,
        child: const SizedBox(),
      );

      expect(scope.updateShouldNotify(sameScope), isFalse);
      expect(scope.updateShouldNotify(differentScope), isTrue);
    });

    testWidgets('JustOverlayScope.of throws assertion error when not found', (
      tester,
    ) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => JustOverlayScope.of<_TestOverlayController>(context),
              throwsAssertionError,
            );
            return const SizedBox();
          },
        ),
      );
    });
  });

  group('JustThemeData & Context Extension Tests', () {
    test('Pre-built themes initialization and equality', () {
      final light = JustThemeData.light;
      final dark = JustThemeData.dark;
      final neoLight = JustThemeData.neobrutalismLight;
      final neoDark = JustThemeData.neobrutalismDark;

      expect(light.preset, equals(JustThemePreset.default_));
      expect(dark.preset, equals(JustThemePreset.default_));
      expect(neoLight.preset, equals(JustThemePreset.neobrutalism));
      expect(neoDark.preset, equals(JustThemePreset.neobrutalism));

      expect(light.presetTokens, isA<DefaultPresetTokens>());
      expect(neoLight.presetTokens, isA<NeobrutalismPresetTokens>());

      expect(light.shadowOffset, equals(Offset.zero));
      expect(neoLight.shadowOffset, equals(const Offset(4.0, 4.0)));

      // resolveShadows
      final shadows = [const BoxShadow(offset: Offset(2.0, 2.0))];
      expect(light.resolveShadows(shadows, isPressed: true), equals(shadows));
      expect(
        neoLight.resolveShadows(shadows, isPressed: true).first.offset,
        equals(Offset.zero),
      );
      expect(
        neoLight.resolveShadows(shadows, isPressed: false).first.offset,
        equals(const Offset(2.0, 2.0)),
      );
    });

    test('JustThemeData.copyWith updates all fields properly', () {
      final base = JustThemeData.light;
      final customColors = JustColors.dark();
      const customTypo = _CustomTypographyScheme();
      const customSpacing = DefaultSpacingScheme();
      const customRadius = DefaultRadiusScheme();
      const customShadows = DefaultShadowSchemeDark();
      const customAnimations = JustMotionProfile.reduced;
      const customPreset = JustThemePreset.neobrutalism;

      final updated = base.copyWith(
        colors: customColors,
        typography: customTypo,
        spacing: customSpacing,
        radius: customRadius,
        shadows: customShadows,
        animations: customAnimations,
        preset: customPreset,
      );

      expect(updated.colors, equals(customColors));
      expect(updated.typography, equals(customTypo));
      expect(updated.spacing, equals(customSpacing));
      expect(updated.radius, equals(customRadius));
      expect(updated.shadows, equals(customShadows));
      expect(updated.animations, equals(customAnimations));
      expect(updated.preset, equals(customPreset));

      // Equality and hashCode
      final updated2 = base.copyWith(
        colors: customColors,
        typography: customTypo,
        spacing: customSpacing,
        radius: customRadius,
        shadows: customShadows,
        animations: customAnimations,
        preset: customPreset,
      );
      expect(updated, equals(updated2));
      expect(updated.hashCode, equals(updated2.hashCode));
      expect(base == updated, isFalse);
    });

    test('JustThemeData.fromSeed works with different presets and modes', () {
      const seed = Color(0xFF6366F1); // Indigo
      final seedLight = JustThemeData.fromSeed(seed, isDark: false);
      final seedDark = JustThemeData.fromSeed(seed, isDark: true);
      final seedNeoLight = JustThemeData.fromSeed(
        seed,
        isDark: false,
        preset: JustThemePreset.neobrutalism,
      );
      final seedNeoDark = JustThemeData.fromSeed(
        seed,
        isDark: true,
        preset: JustThemePreset.neobrutalism,
      );

      expect(seedLight.shadows, isA<TintedShadowScheme>());
      expect(seedDark.shadows, isA<TintedShadowScheme>());
      expect(seedNeoLight.shadows, isA<NeobrutalismShadowScheme>());
      expect(seedNeoDark.shadows, isA<NeobrutalismShadowScheme>());

      expect(seedNeoLight.animations, equals(JustMotionProfile.neobrutalism));
    });

    test('applyHighContrastOverrides enforces high contrast colors', () {
      final lightHighContrast = JustThemeData.light
          .applyHighContrastOverrides();
      final darkHighContrast = JustThemeData.dark.applyHighContrastOverrides();

      expect(
        lightHighContrast.colors.textPrimary,
        equals(const Color(0xFF000000)),
      );
      expect(
        darkHighContrast.colors.textPrimary,
        equals(const Color(0xFFFFFFFF)),
      );
    });

    testWidgets(
      'buildPressEffect helper returns interactive animation widgets',
      (tester) async {
        final light = JustThemeData.light;
        final neo = JustThemeData.neobrutalismLight;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                light.buildPressEffect(
                  isPressed: true,
                  child: const Text('Light Effect'),
                ),
                neo.buildPressEffect(
                  isPressed: true,
                  child: const Text('Neo Effect'),
                ),
              ],
            ),
          ),
        );

        expect(find.text('Light Effect'), findsOneWidget);
        expect(find.text('Neo Effect'), findsOneWidget);
      },
    );

    testWidgets(
      'JustThemeContext extension getters subscribe to correct aspects',
      (tester) async {
        late JustThemeData theme;
        late JustColorScheme colors;
        late JustTypographyScheme typo;
        late JustSpacingScheme spacing;
        late JustRadiusScheme radius;
        late JustShadowScheme shadows;
        late JustMotionProfile animations;
        late JustMotionProfile motion;
        late JustPresetTokens presetTokens;
        late JustThemePreset preset;
        late bool isDark;
        late JustThemeData readDirect;

        await tester.pumpWidget(
          JustThemeProvider(
            lightTheme: JustThemeData.light,
            child: Builder(
              builder: (context) {
                theme = context.justTheme;
                colors = context.justColors;
                typo = context.justTypo;
                spacing = context.justSpacing;
                radius = context.justRadius;
                shadows = context.justShadows;
                animations = context.justAnimations;
                motion = context.justMotion;
                presetTokens = context.justPresetTokens;
                preset = context.justPreset;
                isDark = context.isDarkMode;
                readDirect = context.readTheme();
                return const SizedBox();
              },
            ),
          ),
        );

        expect(theme, equals(JustThemeData.light));
        expect(colors, equals(JustThemeData.light.colors));
        expect(typo, equals(JustThemeData.light.typography));
        expect(spacing, equals(JustThemeData.light.spacing));
        expect(radius, equals(JustThemeData.light.radius));
        expect(shadows, equals(JustThemeData.light.shadows));
        expect(animations, equals(JustThemeData.light.animations));
        expect(motion, isNotNull);
        expect(presetTokens, isA<DefaultPresetTokens>());
        expect(preset, equals(JustThemePreset.default_));
        expect(isDark, isFalse);
        expect(readDirect, equals(JustThemeData.light));
      },
    );
  });
}
