import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/carousel/just_carousel.dart';

Widget buildTestApp(
  Widget child, {
  JustThemeData? theme,
  ThemeData? materialTheme,
}) {
  return MaterialApp(
    theme: materialTheme,
    home: JustThemeProvider(
      lightTheme: theme ?? JustThemeData.light,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('JustCarousel Core Engine & Looping Math', () {
    testWidgets('Renders items horizontally and displays initial page', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              children: [Text('Slide 0'), Text('Slide 1'), Text('Slide 2')],
            ),
          ),
        ),
      );

      expect(find.text('Slide 0'), findsOneWidget);
      expect(find.text('Slide 1'), findsNothing);
    });

    testWidgets('Renders items vertically when orientation is Axis.vertical', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              orientation: Axis.vertical,
              children: [Text('Vertical 0'), Text('Vertical 1')],
            ),
          ),
        ),
      );

      expect(find.text('Vertical 0'), findsOneWidget);

      // Drag up to reveal vertical slide 1
      await tester.drag(find.text('Vertical 0'), const Offset(0.0, -300.0));
      await tester.pumpAndSettle();

      expect(find.text('Vertical 1'), findsOneWidget);
    });

    testWidgets(
      'Infinite looping wraps backwards to last slide on left-to-right swipe',
      (tester) async {
        final controller = JustCarouselController();

        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                controller: controller,
                loop: true,
                children: const [
                  Text('Slide 0'),
                  Text('Slide 1'),
                  Text('Slide 2'),
                ],
              ),
            ),
          ),
        );

        expect(controller.currentIndex, 0);

        // Drag right (swipe backwards from Slide 0 -> wraps to Slide 2)
        await tester.drag(find.text('Slide 0'), const Offset(400.0, 0.0));
        await tester.pumpAndSettle();

        expect(find.text('Slide 2'), findsOneWidget);
        expect(controller.currentIndex, 2);
      },
    );

    testWidgets(
      'Infinite looping wraps forwards to first slide on right-to-left swipe',
      (tester) async {
        final controller = JustCarouselController(initialPage: 2);

        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                controller: controller,
                initialPage: 2,
                loop: true,
                children: const [
                  Text('Slide 0'),
                  Text('Slide 1'),
                  Text('Slide 2'),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Slide 2'), findsOneWidget);
        expect(controller.currentIndex, 2);

        // Drag left (swipe forward from Slide 2 -> wraps to Slide 0)
        await tester.drag(find.text('Slide 2'), const Offset(-400.0, 0.0));
        await tester.pumpAndSettle();

        expect(find.text('Slide 0'), findsOneWidget);
        expect(controller.currentIndex, 0);
      },
    );

    testWidgets('Single-item carousel disables looping without crashing', (
      tester,
    ) async {
      final controller = JustCarouselController();

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              controller: controller,
              loop: true, // Should be auto-disabled because length <= 1
              children: const [Text('Single Item')],
            ),
          ),
        ),
      );

      expect(find.text('Single Item'), findsOneWidget);
      expect(controller.currentIndex, 0);

      // Attempt swipe backwards
      await tester.drag(find.text('Single Item'), const Offset(400.0, 0.0));
      await tester.pumpAndSettle();
      expect(find.text('Single Item'), findsOneWidget);
      expect(controller.currentIndex, 0);

      // Programmatic next / previous are safe no-ops
      await controller.next();
      await tester.pumpAndSettle();
      expect(controller.currentIndex, 0);

      await controller.previous();
      await tester.pumpAndSettle();
      expect(controller.currentIndex, 0);
    });

    testWidgets('Empty carousel renders safely with SizedBox.shrink', (
      tester,
    ) async {
      final controller = JustCarouselController();

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(controller: controller, children: const []),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(controller.currentIndex, 0);

      // Controller methods do not throw
      await controller.next();
      await controller.previous();
      await controller.animateToPage(2);
      controller.jumpToPage(1);
    });
  });

  group('JustCarouselController Programmatic Navigation', () {
    testWidgets('next() and previous() advance and retreat slides', (
      tester,
    ) async {
      final controller = JustCarouselController();

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              controller: controller,
              children: const [
                Text('Slide 0'),
                Text('Slide 1'),
                Text('Slide 2'),
              ],
            ),
          ),
        ),
      );

      expect(controller.currentIndex, 0);

      // next()
      await controller.next();
      await tester.pumpAndSettle();
      expect(find.text('Slide 1'), findsOneWidget);
      expect(controller.currentIndex, 1);

      // next() again
      await controller.next();
      await tester.pumpAndSettle();
      expect(find.text('Slide 2'), findsOneWidget);
      expect(controller.currentIndex, 2);

      // previous()
      await controller.previous();
      await tester.pumpAndSettle();
      expect(find.text('Slide 1'), findsOneWidget);
      expect(controller.currentIndex, 1);
    });

    testWidgets(
      'pageListenable triggers synchronously without carousel rebuilds',
      (tester) async {
        final controller = JustCarouselController();
        final observedPages = <int>[];

        controller.pageListenable.addListener(() {
          observedPages.add(controller.pageListenable.value);
        });

        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                controller: controller,
                children: const [
                  Text('Slide 0'),
                  Text('Slide 1'),
                  Text('Slide 2'),
                ],
              ),
            ),
          ),
        );

        await controller.next();
        await tester.pumpAndSettle();

        await controller.next();
        await tester.pumpAndSettle();

        expect(observedPages, contains(1));
        expect(observedPages, contains(2));
      },
    );

    testWidgets('animateToPage uses shortest circular path in loop mode', (
      tester,
    ) async {
      final controller = JustCarouselController();

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              controller: controller,
              loop: true,
              children: const [
                Text('Slide 0'),
                Text('Slide 1'),
                Text('Slide 2'),
                Text('Slide 3'),
                Text('Slide 4'),
              ],
            ),
          ),
        ),
      );

      expect(controller.currentIndex, 0);

      // From index 0, animating to index 4 should step backwards (-1) because diff -1 is shorter than +4
      await controller.animateToPage(4);
      await tester.pumpAndSettle();

      expect(find.text('Slide 4'), findsOneWidget);
      expect(controller.currentIndex, 4);

      // From index 4, animating to index 0 should step forward (+1) because diff +1 is shorter than -4
      await controller.animateToPage(0);
      await tester.pumpAndSettle();

      expect(find.text('Slide 0'), findsOneWidget);
      expect(controller.currentIndex, 0);
    });

    testWidgets('jumpToPage updates immediately without animation duration', (
      tester,
    ) async {
      final controller = JustCarouselController();

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              controller: controller,
              children: const [
                Text('Slide 0'),
                Text('Slide 1'),
                Text('Slide 2'),
              ],
            ),
          ),
        ),
      );

      controller.jumpToPage(2);
      await tester.pump(); // No need for pumpAndSettle

      expect(find.text('Slide 2'), findsOneWidget);
      expect(controller.currentIndex, 2);
    });

    testWidgets(
      'Non-looping carousel respects boundaries for next and previous',
      (tester) async {
        final controller = JustCarouselController();

        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                controller: controller,
                loop: false,
                children: const [Text('Slide 0'), Text('Slide 1')],
              ),
            ),
          ),
        );

        // At start, previous() does nothing
        await controller.previous();
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 0);

        // Move to end
        await controller.next();
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 1);

        // At end, next() does nothing
        await controller.next();
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 1);
      },
    );
  });

  group('JustCarousel Dynamic Updates & Lifecycle', () {
    testWidgets('didUpdateWidget updates safely when children count changes', (
      tester,
    ) async {
      final controller = JustCarouselController(initialPage: 2);

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              controller: controller,
              children: const [Text('Item 0'), Text('Item 1'), Text('Item 2')],
            ),
          ),
        ),
      );

      expect(controller.currentIndex, 2);

      // Shrink children to 2 items (index 2 is now out of bounds)
      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              controller: controller,
              children: const [Text('Item 0'), Text('Item 1')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Controller clamped safely
      expect(controller.currentIndex, 1);
      expect(find.text('Item 1'), findsOneWidget);
    });

    test('Detached controller calls do not throw', () async {
      final controller = JustCarouselController();
      expect(controller.isAttached, isFalse);

      await controller.next();
      await controller.previous();
      await controller.animateToPage(1);
      controller.jumpToPage(1);
      controller.dispose();
    });
  });

  group('JustCarousel Theme & Style Specifications', () {
    test('JustCarouselTheme.fromTheme resolves tokens correctly', () {
      final theme = JustCarouselTheme.fromTheme(JustThemeData.light);
      expect(theme.indicatorColor, JustThemeData.light.colors.borderDefault);
      expect(
        theme.activeIndicatorColor,
        JustThemeData.light.colors.borderFocus,
      );
      expect(theme.indicator, JustCarouselIndicator.dots);
      expect(theme.indicatorPosition, JustCarouselIndicatorPosition.inside);
      expect(theme.transition, JustCarouselTransition.slide);
    });

    test(
      'JustCarouselTheme.neobrutalism matches high-contrast specifications',
      () {
        final theme = JustCarouselTheme.neobrutalism(JustThemeData.light);
        expect(
          theme.activeIndicatorColor,
          JustThemeData.light.colors.textPrimary,
        );
        expect(theme.indicatorRadius, BorderRadius.zero);
        expect(theme.indicatorSize, 10.0);
      },
    );

    test(
      'JustCarouselStyle and JustCarouselTheme support copyWith and lerp',
      () {
        const styleA = JustCarouselStyle(
          viewportFraction: 0.8,
          indicatorSize: 6.0,
        );
        const styleB = JustCarouselStyle(
          viewportFraction: 1.0,
          indicatorSize: 10.0,
        );

        final lerpedStyle = JustCarouselStyle.lerp(styleA, styleB, 0.5);
        expect(lerpedStyle?.viewportFraction, closeTo(0.9, 0.001));
        expect(lerpedStyle?.indicatorSize, closeTo(8.0, 0.001));

        const themeA = JustCarouselTheme(
          viewportFraction: 0.8,
          indicatorSize: 6.0,
        );
        const themeB = JustCarouselTheme(
          viewportFraction: 1.0,
          indicatorSize: 10.0,
        );

        final lerpedTheme = themeA.lerp(themeB, 0.5);
        expect(lerpedTheme.viewportFraction, closeTo(0.9, 0.001));
        expect(lerpedTheme.indicatorSize, closeTo(8.0, 0.001));
      },
    );
  });
}
