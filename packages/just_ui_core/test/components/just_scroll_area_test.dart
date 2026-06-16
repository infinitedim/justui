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

  group('JustScrollArea Tests', () {
    testWidgets('Renders scroll container with child content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          JustScrollArea(
            child: Container(
              height: 1000.0,
              width: 300.0,
              color: const Color(0xFF111111),
              child: const Text('Scrollable Content'),
            ),
          ),
        ),
      );

      expect(find.text('Scrollable Content'), findsOneWidget);
    });

    testWidgets('Triggers scroll notification start and end callbacks', (
      WidgetTester tester,
    ) async {
      bool started = false;
      bool ended = false;

      final controller = ScrollController();

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 300.0,
            child: JustScrollArea(
              controller: controller,
              onScrollStart: () => started = true,
              onScrollEnd: () => ended = true,
              child: Column(
                children: List.generate(50, (index) => Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      // Trigger scroll
      await tester.drag(find.text('Item 0'), const Offset(0.0, -100.0));
      await tester.pumpAndSettle();

      expect(started, isTrue);
      expect(ended, isTrue);

      controller.dispose();
    });

    testWidgets('Triggers onReachBottom callback at threshold', (
      WidgetTester tester,
    ) async {
      int triggerCount = 0;
      final controller = ScrollController();

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 300.0,
            child: JustScrollArea(
              controller: controller,
              reachBottomThreshold: 100.0,
              onReachBottom: () => triggerCount++,
              child: Column(
                children: List.generate(
                  50,
                  (index) => SizedBox(height: 50.0, child: Text('Item $index')),
                ),
              ),
            ),
          ),
        ),
      );

      // Scroll near the bottom
      await tester.drag(find.text('Item 0'), const Offset(0.0, -2000.0));
      await tester.pumpAndSettle();

      // Should have triggered reach bottom
      expect(triggerCount, greaterThan(0));

      controller.dispose();
    });

    testWidgets('Shows and handles scroll-to-top button tap', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 300.0,
            child: JustScrollArea(
              controller: controller,
              scrollToTopButton: true,
              scrollToTopThreshold: 100.0,
              child: Column(
                children: List.generate(
                  50,
                  (index) => SizedBox(height: 50.0, child: Text('Item $index')),
                ),
              ),
            ),
          ),
        ),
      );

      // Scroll down past the 100 threshold
      await tester.drag(find.text('Item 0'), const Offset(0.0, -200.0));
      await tester.pumpAndSettle();

      // Scroll to top button should be visible (using Semantic label)
      final scrollToTopFinder = find.bySemanticsLabel('Scroll to top');
      expect(scrollToTopFinder, findsOneWidget);

      // Tap the scroll-to-top button
      await tester.tap(scrollToTopFinder);
      await tester.pumpAndSettle();

      // Verifying it scrolled back to top (offset 0)
      expect(controller.offset, equals(0.0));

      controller.dispose();
    });
  });
}
