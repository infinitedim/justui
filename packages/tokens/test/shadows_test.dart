import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
