import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('Fluid Typography & Adaptive Line Height Validation', () {
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
              // Test null fontSize fallback in withAdaptiveHeight
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
  });
}
