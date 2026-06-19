import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JustThemeData Tests', () {
    test('Default light and dark themes generate valid Material ThemeData', () {
      final lightMaterial = JustThemeData.light.toThemeData();
      final darkMaterial = JustThemeData.dark.toThemeData();

      expect(lightMaterial, isNotNull);
      expect(darkMaterial, isNotNull);
      expect(lightMaterial.brightness, equals(Brightness.light));
      expect(darkMaterial.brightness, equals(Brightness.dark));
    });

    test(
      'ThemeData is lazy-cached and returns identical instance on multiple calls',
      () {
        final theme = JustThemeData.light;
        final first = theme.toThemeData();
        final second = theme.toThemeData();

        // Identity check: should be the exact same instance in memory
        expect(identical(first, second), isTrue);
      },
    );

    test(
      'ThemeData cache is cleared/rebuilt when copied with modifications',
      () {
        final base = JustThemeData.light;
        final originalMaterial = base.toThemeData();

        // Copy with custom colors
        final modified = base.copyWith(colors: JustColors.dark());
        final modifiedMaterial = modified.toThemeData();

        expect(identical(originalMaterial, modifiedMaterial), isFalse);
        expect(modifiedMaterial.brightness, equals(Brightness.dark));
      },
    );

    test(
      'fromSeed factory generates dynamic color scheme and respects contrast',
      () {
        const seedColor = Color(0xFF00FF00); // Super bright green
        final seededLight = JustThemeData.fromSeed(seedColor, isDark: false);
        final seededDark = JustThemeData.fromSeed(seedColor, isDark: true);

        expect(seededLight.colors.background, equals(JustColors.neutral50));
        expect(seededDark.colors.background, equals(JustColors.neutral950));

        // Contrast audits: focus border must meet WCAG AA large text/component contrast (>= 3.0)
        final lightContrast = seededLight.colors.borderFocus.contrastRatioWith(
          seededLight.colors.background,
        );
        final darkContrast = seededDark.colors.borderFocus.contrastRatioWith(
          seededDark.colors.background,
        );

        expect(lightContrast, greaterThanOrEqualTo(3.0));
        expect(darkContrast, greaterThanOrEqualTo(3.0));
      },
    );

    test('ThemeData maps visual tokens to component themes correctly', () {
      final theme = JustThemeData.light;
      final materialTheme = theme.toThemeData();

      // CardTheme check
      expect(materialTheme.cardTheme.color, equals(theme.colors.card));
      expect(materialTheme.cardTheme.elevation, equals(0.0));
      final cardShape =
          materialTheme.cardTheme.shape as RoundedRectangleBorder?;
      expect(
        cardShape?.borderRadius,
        equals(BorderRadius.all(theme.radius.lg)),
      );

      // AppBarTheme check
      expect(
        materialTheme.appBarTheme.backgroundColor,
        equals(theme.colors.background),
      );
      expect(materialTheme.appBarTheme.elevation, equals(0.0));
      expect(
        materialTheme.appBarTheme.titleTextStyle?.color,
        equals(theme.colors.textPrimary),
      );

      // DividerTheme check
      expect(materialTheme.dividerTheme.thickness, equals(1.0));
      expect(materialTheme.dividerTheme.space, equals(1.0));
      expect(
        materialTheme.dividerTheme.color,
        equals(theme.colors.borderDefault),
      );

      // InputDecorationTheme check
      expect(materialTheme.inputDecorationTheme.filled, isTrue);
      expect(
        materialTheme.inputDecorationTheme.fillColor,
        equals(theme.colors.background),
      );
      final border =
          materialTheme.inputDecorationTheme.focusedBorder
              as OutlineInputBorder?;
      expect(border?.borderSide.color, equals(theme.colors.borderFocus));
    });

    test('Dynamic contrast and dark surfaces enforcement in fromSeed', () {
      const seed = Color(0xFF3B82F6);

      // Light Mode seed checks
      final lightTheme = JustThemeData.fromSeed(seed, isDark: false);
      expect(
        lightTheme.colors.success.contrastRatioWith(lightTheme.colors.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        lightTheme.colors.warning.contrastRatioWith(lightTheme.colors.background),
        greaterThanOrEqualTo(3.0),
      );
      expect(
        lightTheme.colors.error.contrastRatioWith(lightTheme.colors.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        lightTheme.colors.info.contrastRatioWith(lightTheme.colors.background),
        greaterThanOrEqualTo(4.5),
      );

      // Dark Mode seed checks
      final darkTheme = JustThemeData.fromSeed(seed, isDark: true);
      expect(
        darkTheme.colors.success.contrastRatioWith(darkTheme.colors.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        darkTheme.colors.warning.contrastRatioWith(darkTheme.colors.background),
        greaterThanOrEqualTo(3.0),
      );

      // Verify Tinted surfaces in dark mode
      final HSLColor hslSeed = HSLColor.fromColor(seed);
      final HSLColor hslBg = HSLColor.fromColor(darkTheme.colors.background);
      expect(hslBg.hue, closeTo(hslSeed.hue, 0.01));
      expect(hslBg.lightness, equals(0.03));
    });

    test('FluidSpacingScheme and FluidRadiusScheme scale based on screen width', () {
      const spacingSmall = FluidSpacingScheme(width: 320.0);
      const spacingLarge = FluidSpacingScheme(width: 1024.0);

      expect(spacingSmall.md, lessThan(spacingLarge.md));
      expect(spacingLarge.md, equals(12.0)); // standard md size is 12

      const radiusSmall = FluidRadiusScheme(width: 320.0);
      const radiusLarge = FluidRadiusScheme(width: 1024.0);

      expect(radiusSmall.md.x, lessThan(radiusLarge.md.x));
      expect(radiusLarge.md.x, equals(8.0)); // standard md radius is 8
    });

    test('TintedShadowScheme generates tinted dual-layer shadows', () {
      const seed = Color(0xFF3B82F6);
      const shadowsScheme = TintedShadowScheme(seedColor: seed, isDark: false);

      final smShadows = shadowsScheme.sm;
      expect(smShadows.length, equals(2));
      expect(smShadows[0].color.computeLuminance(), closeTo(0, 0.01)); // key shadow is dark
      expect(HSLColor.fromColor(smShadows[1].color).hue, closeTo(HSLColor.fromColor(seed).hue, 0.01)); // ambient shadow is tinted
    });
  });

  group('JustThemeProvider Tests', () {
    testWidgets('Initializes with default or custom theme mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          initialThemeMode: ThemeMode.dark,
          child: Builder(
            builder: (context) {
              final state = JustThemeProvider.read(context);
              expect(state.themeMode, equals(ThemeMode.dark));
              expect(
                state.theme.colors.background,
                equals(JustColors.neutral950),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets(
      'Theme toggle triggers state updates and persistence callback',
      (WidgetTester tester) async {
        ThemeMode? persistedMode;

        await tester.pumpWidget(
          JustThemeProvider(
            initialThemeMode: ThemeMode.light,
            onThemeChanged: (mode) {
              persistedMode = mode;
            },
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    JustThemeProvider.read(context).toggleTheme();
                  },
                  child: Text(JustThemeProvider.of(context).themeMode.name),
                );
              },
            ),
          ),
        );

        expect(find.text('light'), findsOneWidget);
        expect(persistedMode, isNull);

        // Tap button to toggle
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.text('dark'), findsOneWidget);
        expect(persistedMode, equals(ThemeMode.dark));
      },
    );

    testWidgets('Aspect-based rebuild works correctly', (
      WidgetTester tester,
    ) async {
      int fullRebuildCount = 0;
      int colorRebuildCount = 0;

      await tester.pumpWidget(
        JustThemeProvider(
          initialThemeMode: ThemeMode.light,
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  // Subscribes to the entire theme
                  context.justTheme;
                  fullRebuildCount++;
                  return const SizedBox.shrink();
                },
              ),
              Builder(
                builder: (context) {
                  // Subscribes *only* to colors
                  context.justColors;
                  colorRebuildCount++;
                  return const SizedBox.shrink();
                },
              ),
              Builder(
                builder: (context) {
                  // Reads theme without subscription
                  context.readTheme();
                  return ElevatedButton(
                    onPressed: () {
                      JustThemeProvider.read(
                        context,
                      ).setThemeMode(ThemeMode.dark);
                    },
                    child: const Text('Change Theme'),
                  );
                },
              ),
            ],
          ),
        ),
      );

      expect(fullRebuildCount, equals(1));
      expect(colorRebuildCount, equals(1));

      // Trigger change
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(fullRebuildCount, equals(2));
      expect(colorRebuildCount, equals(2));
    });

    testWidgets('Exposes transition timing and curve parameters', (
      WidgetTester tester,
    ) async {
      const customDuration = Duration(milliseconds: 500);
      const customCurve = Curves.bounceInOut;

      await tester.pumpWidget(
        JustThemeProvider(
          transitionDuration: customDuration,
          transitionCurve: customCurve,
          child: Builder(
            builder: (context) {
              final state = JustThemeProvider.read(context);
              expect(state.transitionDuration, equals(customDuration));
              expect(state.transitionCurve, equals(customCurve));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets(
      'System theme mode adapts to platform brightness changes dynamically',
      (WidgetTester tester) async {
        tester.platformDispatcher.platformBrightnessTestValue =
            Brightness.light;

        await tester.pumpWidget(
          JustThemeProvider(
            initialThemeMode: ThemeMode.system,
            child: Builder(
              builder: (context) {
                final isDark =
                    context.justTheme.colors.background ==
                    JustColors.neutral950;
                return Text(isDark ? 'dark' : 'light');
              },
            ),
          ),
        );

        expect(find.text('light'), findsOneWidget);

        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        await tester.pumpAndSettle();

        expect(find.text('dark'), findsOneWidget);

        tester.platformDispatcher.clearPlatformBrightnessTestValue();
      },
    );
  });
}
