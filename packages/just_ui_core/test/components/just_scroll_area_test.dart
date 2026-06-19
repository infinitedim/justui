import 'package:flutter/services.dart';
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

    testWidgets('Handles keyboard arrow and page keys for scrolling', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 300.0,
            child: JustScrollArea(
              controller: controller,
              keyboardScrollStep: 40.0,
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

      final focusFinder = find.byType(Focus);
      expect(focusFinder, findsOneWidget);
      final FocusNode node = tester.widget<Focus>(focusFinder).focusNode!;
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);

      // Send Arrow Down
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(40.0));

      // Send Arrow Up
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(0.0));

      // Send Page Down
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(300.0));

      // Send Page Up
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(0.0));

      controller.dispose();
    });

    testWidgets(
      'Scroll direction guard prevents onReachBottom on upward scroll',
      (WidgetTester tester) async {
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
                    (index) =>
                        SizedBox(height: 50.0, child: Text('Item $index')),
                  ),
                ),
              ),
            ),
          ),
        );

        // Scroll past the threshold to trigger it (moving downwards)
        await tester.drag(find.text('Item 0'), const Offset(0.0, -2000.0));
        await tester.pumpAndSettle();
        expect(triggerCount, greaterThan(0));

        // Reset trigger count
        triggerCount = 0;

        // Drag UPWARDS slightly but staying within bottom threshold range
        await tester.drag(find.text('Item 40'), const Offset(0.0, 10.0));
        await tester.pumpAndSettle();

        // Since we scrolled UPWARDS, reach bottom callback should NOT be triggered
        expect(triggerCount, equals(0));

        controller.dispose();
      },
    );
  });
}
