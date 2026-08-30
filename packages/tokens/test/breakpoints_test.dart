import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Breakpoints Tokens Validation', () {
    test('Breakpoints values match desktop/tablet/mobile specs', () {
      expect(JustBreakpoints.sm, equals(640.0));
      expect(JustBreakpoints.md, equals(768.0));
      expect(JustBreakpoints.lg, equals(1024.0));
      expect(JustBreakpoints.xl, equals(1280.0));
      expect(JustBreakpoints.xxl, equals(1536.0));
    });
  });
}
