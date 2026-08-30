import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
