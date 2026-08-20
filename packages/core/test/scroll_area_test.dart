import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area.dart';
import 'package:just_ui_core/src/components/shared/_shared_pressable.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JustScrollArea Physics & Smooth Engine Tests', () {
    Widget buildTestScrollArea({
      required Widget child,
      ScrollController? controller,
      bool? smoothScroll,
      double lerpFactor = 0.10,
      double wheelMultiplier = 1.0,
      bool scrollToTopButton = false,
      Axis direction = Axis.vertical,
    }) {
      return MaterialApp(
        home: JustThemeProvider(
          lightTheme: JustThemeData.light,
          child: Scaffold(
            body: JustScrollArea(
              controller: controller,
              smoothScroll: smoothScroll,
              lerpFactor: lerpFactor,
              wheelMultiplier: wheelMultiplier,
              scrollToTopButton: scrollToTopButton,
              direction: direction,
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('Renders scroll area child content correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestScrollArea(
          child: Column(
            children: List.generate(
              20,
              (index) => SizedBox(height: 100, child: Text('Item $index')),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets(
      'Responds to PointerScrollEvent and drives smooth scroll offset',
      (WidgetTester tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          buildTestScrollArea(
            controller: controller,
            smoothScroll: true,
            child: Column(
              children: List.generate(
                50,
                (index) => SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        );

        expect(controller.offset, equals(0.0));

        // Dispatch mouse wheel pointer scroll event to binding
        tester.binding.handlePointerEvent(
          const PointerScrollEvent(
            position: Offset(200, 200),
            scrollDelta: Offset(0, 150),
          ),
        );

        // Pump frame to trigger smooth ticker
        await tester.pump(const Duration(milliseconds: 16));
        expect(controller.offset, greaterThan(0.0));

        // Pump remaining frames until lerp engine snaps to target
        await tester.pumpAndSettle();
        expect(controller.offset, closeTo(150.0, 1.0));
      },
    );

    testWidgets(
      'Detects trackpad signal profile and uses 1:1 responsive lerp factor',
      (WidgetTester tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          buildTestScrollArea(
            controller: controller,
            smoothScroll: true,
            child: Column(
              children: List.generate(
                50,
                (index) => SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        );

        // Rapid micro-events typical of precision trackpads (< 20ms apart, < 15px delta)
        tester.binding.handlePointerEvent(
          const PointerScrollEvent(
            position: Offset(200, 200),
            scrollDelta: Offset(0, 8),
          ),
        );

        await tester.pump(const Duration(milliseconds: 16));
        // Responsive trackpad lerp (0.35) advances faster toward target
        expect(controller.offset, greaterThan(0.0));
        await tester.pumpAndSettle();
        expect(controller.offset, closeTo(8.0, 0.5));
      },
    );

    testWidgets(
      'Scroll to top button appears when threshold exceeded and resets scroll',
      (WidgetTester tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          buildTestScrollArea(
            controller: controller,
            smoothScroll: false,
            scrollToTopButton: true,
            child: Column(
              children: List.generate(
                50,
                (index) => SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        );

        // Initially scroll-to-top button is invisible
        expect(find.byType(JustPressable), findsNothing);

        // Programmatically jump past threshold (400px)
        controller.jumpTo(500.0);
        await tester.pumpAndSettle();

        expect(find.byType(JustPressable), findsOneWidget);

        // Tap scroll-to-top button
        await tester.tap(find.byType(JustPressable));
        await tester.pumpAndSettle();

        expect(controller.offset, equals(0.0));
      },
    );
  });
}
