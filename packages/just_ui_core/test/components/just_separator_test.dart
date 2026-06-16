import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(textDirection: .ltr, child: child),
    );
  }

  group('JustSeparator Tests', () {
    testWidgets('Renders horizontal separator without label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const JustSeparator(direction: Axis.horizontal)),
      );

      expect(find.byType(JustSeparator), findsOneWidget);
    });

    testWidgets('Renders horizontal separator with label text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSeparator(direction: Axis.horizontal, label: 'OR'),
        ),
      );

      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('Renders vertical separator and defaults height inside Row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Row(
            children: [
              Text('Left'),
              JustSeparator(direction: Axis.vertical),
              Text('Right'),
            ],
          ),
        ),
      );

      expect(find.byType(JustSeparator), findsOneWidget);
      final separatorSize = tester.getSize(find.byType(JustSeparator));
      // Default vertical length fallback should be 16.0 (spacing.lg)
      expect(separatorSize.height, equals(16.0));
    });

    testWidgets('Renders vertical separator with label text and defaults size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Row(
            children: [
              Text('Left'),
              JustSeparator(direction: Axis.vertical, label: 'AND'),
              Text('Right'),
            ],
          ),
        ),
      );

      expect(find.text('AND'), findsOneWidget);
      final separatorSize = tester.getSize(find.byType(JustSeparator));
      // Default vertical length fallback with label should be spacing.xl * 2 (48.0)
      expect(separatorSize.height, equals(48.0));
    });
  });
}
