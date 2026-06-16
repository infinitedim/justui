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

    testWidgets('Responsive constructor resolves direction adaptively based on width and breakpoint', (
      WidgetTester tester,
    ) async {
      // Set width below breakpoint (640) -> should be horizontal -> renders Row when label is provided
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableWidget(
          const JustSeparator.responsive(breakpoint: 640.0, label: 'SEP'),
        ),
      );
      await tester.pump();

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsNothing);

      // Set width above breakpoint (640) -> should be vertical -> renders Column when label is provided
      tester.view.physicalSize = const Size(800, 1000);
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSeparator.responsive(breakpoint: 640.0, label: 'SEP'),
        ),
      );
      await tester.pump();

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });
  });
}

