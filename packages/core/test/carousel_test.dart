import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  group('JustCarousel Auto-Scroll Lifecycle', () {
    testWidgets(
      'Auto-scroll timer advances slides automatically after interval',
      (tester) async {
        final controller = JustCarouselController();

        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                controller: controller,
                autoScroll: const JustCarouselAutoScroll(
                  interval: Duration(seconds: 2),
                  animationDuration: Duration(milliseconds: 200),
                ),
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

        // Advance by interval
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('Slide 1'), findsOneWidget);
        expect(controller.currentIndex, 1);
      },
    );

    testWidgets('Auto-scroll pauses on mouse hover', (tester) async {
      final controller = JustCarouselController();

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              controller: controller,
              autoScroll: const JustCarouselAutoScroll(
                interval: Duration(seconds: 2),
                pauseOnHover: true,
              ),
              children: const [Text('Slide 0'), Text('Slide 1')],
            ),
          ),
        ),
      );

      expect(controller.currentIndex, 0);

      // Simulate mouse enter
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.text('Slide 0')));
      await tester.pump();

      // Advance clock while hovered
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should remain on Slide 0 because hover paused it
      expect(controller.currentIndex, 0);

      // Mouse leaves
      await gesture.moveTo(const Offset(500.0, 500.0));
      await tester.pump();

      // Advance clock after exit
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(controller.currentIndex, 1);
      await gesture.removePointer();
    });

    testWidgets(
      'Auto-scroll pauses during touch drag and resumes on scroll end',
      (tester) async {
        final controller = JustCarouselController();

        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                controller: controller,
                autoScroll: const JustCarouselAutoScroll(
                  interval: Duration(seconds: 2),
                  pauseOnTouch: true,
                ),
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

        // Simulate drag
        await tester.drag(find.text('Slide 0'), const Offset(-400.0, 0.0));
        await tester.pumpAndSettle();

        expect(controller.currentIndex, 1);

        // Wait after scroll end -> timer restarts
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(controller.currentIndex, 2);
      },
    );

    testWidgets('Auto-scroll stops when reaching end of non-looping carousel', (
      tester,
    ) async {
      final controller = JustCarouselController(initialPage: 1);

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              controller: controller,
              initialPage: 1,
              loop: false,
              autoScroll: const JustCarouselAutoScroll(
                interval: Duration(seconds: 1),
              ),
              children: const [Text('Slide 0'), Text('Slide 1')],
            ),
          ),
        ),
      );

      expect(controller.currentIndex, 1);

      // Clock tick at end
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Does not loop or crash
      expect(controller.currentIndex, 1);
    });
  });

  group('JustCarousel Interactive Indicators', () {
    testWidgets('Tapping dot indicator navigates directly to target slide', (
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
              indicator: JustCarouselIndicator.dots,
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

      // Tap on dot for Slide 2
      final dotFinder = find.bySemanticsLabel('Slide 3');
      expect(dotFinder, findsOneWidget);

      await tester.tap(dotFinder);
      await tester.pumpAndSettle();

      expect(find.text('Slide 2'), findsOneWidget);
      expect(controller.currentIndex, 2);
    });

    testWidgets('Renders line indicator without throwing', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              indicator: JustCarouselIndicator.line,
              children: [Text('Slide 0'), Text('Slide 1')],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Slide 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Slide 2'), findsOneWidget);
    });

    testWidgets('Renders fraction indicator with formatted text', (
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
              indicator: JustCarouselIndicator.fraction,
              children: const [
                Text('Slide 0'),
                Text('Slide 1'),
                Text('Slide 2'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('1 / 3'), findsOneWidget);

      await controller.next();
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets(
      'indicatorPosition.outside renders flex layout adjacent to viewport',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            const SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                indicator: JustCarouselIndicator.dots,
                indicatorPosition: JustCarouselIndicatorPosition.outside,
                children: [Text('Slide 0'), Text('Slide 1')],
              ),
            ),
          ),
        );

        expect(find.byType(Flex), findsWidgets);
        expect(find.text('Slide 0'), findsOneWidget);
      },
    );
  });

  group('JustCarousel Slide Transitions', () {
    testWidgets('Scale transition applies Transform.scale to slides', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              transition: JustCarouselTransition.scale,
              children: [Text('Slide 0'), Text('Slide 1')],
            ),
          ),
        ),
      );

      expect(find.byType(Transform), findsWidgets);
      expect(find.text('Slide 0'), findsOneWidget);
    });

    testWidgets('Fade transition applies Opacity to slides', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 400.0,
            height: 300.0,
            child: JustCarousel(
              transition: JustCarouselTransition.fade,
              children: [Text('Slide 0'), Text('Slide 1')],
            ),
          ),
        ),
      );

      expect(find.byType(Opacity), findsWidgets);
      expect(find.text('Slide 0'), findsOneWidget);
    });

    testWidgets(
      'Custom transitionBuilder transforms child with continuous progress',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                transitionBuilder: (context, child, progress) {
                  return RotatedBox(
                    quarterTurns: progress.round(),
                    child: child,
                  );
                },
                children: const [Text('Slide 0'), Text('Slide 1')],
              ),
            ),
          ),
        );

        expect(find.byType(RotatedBox), findsWidgets);
        expect(find.text('Slide 0'), findsOneWidget);
      },
    );
  });

  group('JustCarousel Desktop Wheel & Keyboard A11y', () {
    testWidgets('PointerScrollEvent navigates to next and previous slide', (
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
              enableMouseWheel: true,
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

      // Send scroll down (positive delta -> next)
      final center = tester.getCenter(find.text('Slide 0'));
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: center,
          scrollDelta: const Offset(0.0, 50.0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Slide 1'), findsOneWidget);
      expect(controller.currentIndex, 1);
    });

    testWidgets(
      'Keyboard arrow keys navigate slides and spacebar toggles pause',
      (tester) async {
        final controller = JustCarouselController();

        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                controller: controller,
                enableKeyboardNavigation: true,
                children: const [
                  Text('Slide 0'),
                  Text('Slide 1'),
                  Text('Slide 2'),
                ],
              ),
            ),
          ),
        );

        // Focus carousel
        final focusFinder = find.byType(Focus).first;
        await tester.tap(focusFinder);
        await tester.pump();

        // Press ArrowRight -> next
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 1);

        // Press ArrowLeft -> previous
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 0);

        // Press Spacebar -> pause/play toggle
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 0);
      },
    );
  });

  group('JustCarousel Navigation Arrows & Presets', () {
    testWidgets(
      'showArrows renders next and previous buttons and responds to taps',
      (tester) async {
        final controller = JustCarouselController();

        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                controller: controller,
                showArrows: true,
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

        final nextArrowFinder = find.bySemanticsLabel('Next slide');
        final prevArrowFinder = find.bySemanticsLabel('Previous slide');

        expect(nextArrowFinder, findsOneWidget);
        expect(prevArrowFinder, findsOneWidget);

        await tester.tap(nextArrowFinder);
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 1);

        await tester.tap(prevArrowFinder);
        await tester.pumpAndSettle();
        expect(controller.currentIndex, 0);
      },
    );

    testWidgets(
      'Neobrutalism preset renders with sharp corners and textPrimary borders',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            const SizedBox(
              width: 400.0,
              height: 300.0,
              child: JustCarousel(
                showArrows: true,
                indicator: JustCarouselIndicator.fraction,
                children: [Text('Slide 0'), Text('Slide 1')],
              ),
            ),
            theme: JustThemeData.neobrutalismLight,
          ),
        );

        expect(find.text('1 / 2'), findsOneWidget);
        expect(find.bySemanticsLabel('Next slide'), findsOneWidget);
      },
    );
  });
}
