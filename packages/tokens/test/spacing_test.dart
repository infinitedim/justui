import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
