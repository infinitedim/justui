import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area_style.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area_theme.dart';
import 'package:just_ui_core/src/components/shared/_shared_pressable.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestScrollArea({
    required Widget child,
    ScrollController? controller,
    bool? smoothScroll,
    double lerpFactor = 0.10,
    double wheelMultiplier = 1.0,
    bool showScrollbar = true,
    bool fadeEdges = false,
    JustScrollFadeMode fadeMode = JustScrollFadeMode.overlay,
    bool scrollToTopButton = false,
    double scrollToTopThreshold = 400.0,
    Alignment scrollToTopAlignment = Alignment.bottomRight,
    Offset? scrollToTopOffset,
    double reachBottomThreshold = 200.0,
    VoidCallback? onReachBottom,
    VoidCallback? onScrollStart,
    VoidCallback? onScrollEnd,
    Axis direction = Axis.vertical,
    EdgeInsets? padding,
    double? maxHeight,
    double keyboardScrollStep = 50.0,
    JustScrollAreaStyle? style,
    JustThemeData? theme,
    JustScrollAreaTheme? scrollTheme,
  }) {
    return MaterialApp(
      theme: ThemeData(
        extensions: [scrollTheme ?? const JustScrollAreaTheme()],
      ),
      home: JustThemeProvider(
        lightTheme: theme ?? JustThemeData.light,
        child: Scaffold(
          body: JustScrollArea(
            controller: controller,
            smoothScroll: smoothScroll,
            lerpFactor: lerpFactor,
            wheelMultiplier: wheelMultiplier,
            showScrollbar: showScrollbar,
            fadeEdges: fadeEdges,
            fadeMode: fadeMode,
            scrollToTopButton: scrollToTopButton,
            scrollToTopThreshold: scrollToTopThreshold,
            scrollToTopAlignment: scrollToTopAlignment,
            scrollToTopOffset: scrollToTopOffset,
            reachBottomThreshold: reachBottomThreshold,
            onReachBottom: onReachBottom,
            onScrollStart: onScrollStart,
            onScrollEnd: onScrollEnd,
            direction: direction,
            padding: padding,
            maxHeight: maxHeight,
            keyboardScrollStep: keyboardScrollStep,
            style: style,
            child: child,
          ),
        ),
      ),
    );
  }

  group('JustScrollAreaStyle & JustScrollAreaTheme Unit Tests', () {
    test('JustScrollAreaStyle stores all configured properties', () {
      const style = JustScrollAreaStyle(
        fadeColor: Color(0xFF112233),
        fadeHeight: 32.0,
        scrollbarThumbColor: Color(0xFF445566),
        scrollbarTrackColor: Color(0xFF778899),
        scrollbarThickness: 8.0,
        scrollbarRadius: Radius.circular(4.0),
        scrollbarPadding: EdgeInsets.all(2.0),
        scrollbarMargin: 4.0,
        smoothScroll: true,
        lerpFactor: 0.15,
        wheelMultiplier: 1.2,
        touchMultiplier: 1.1,
      );

      expect(style.fadeColor, equals(const Color(0xFF112233)));
      expect(style.fadeHeight, equals(32.0));
      expect(style.scrollbarThumbColor, equals(const Color(0xFF445566)));
      expect(style.scrollbarTrackColor, equals(const Color(0xFF778899)));
      expect(style.scrollbarThickness, equals(8.0));
      expect(style.scrollbarRadius, equals(const Radius.circular(4.0)));
      expect(style.scrollbarPadding, equals(const EdgeInsets.all(2.0)));
      expect(style.scrollbarMargin, equals(4.0));
      expect(style.smoothScroll, isTrue);
      expect(style.lerpFactor, equals(0.15));
      expect(style.wheelMultiplier, equals(1.2));
      expect(style.touchMultiplier, equals(1.1));
    });

    test('JustScrollAreaTheme defaults, copyWith, and lerp', () {
      const defaults = JustScrollAreaTheme.defaults;
      expect(defaults.style, isNull);

      const customStyle = JustScrollAreaStyle(fadeHeight: 40.0);
      final updated = defaults.copyWith(style: customStyle);
      expect(updated.style?.fadeHeight, equals(40.0));

      final fallback = updated.copyWith();
      expect(fallback.style?.fadeHeight, equals(40.0));

      // lerp
      expect(updated.lerp(null, 0.5), equals(updated));
      expect(defaults.lerp(updated, 0.3), equals(defaults));
      expect(defaults.lerp(updated, 0.7), equals(updated));
    });

    test('JustScrollFadeMode enum values', () {
      expect(
        JustScrollFadeMode.values,
        containsAll([JustScrollFadeMode.overlay, JustScrollFadeMode.mask]),
      );
    });
  });

  group('JustScrollArea Widget & Layout Tests', () {
    testWidgets('Renders scroll area child content and RawScrollbar', (
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
      expect(find.byType(RawScrollbar), findsOneWidget);
    });

    testWidgets('showScrollbar = false omits RawScrollbar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestScrollArea(
          showScrollbar: false,
          child: Column(
            children: List.generate(
              20,
              (index) => SizedBox(height: 100, child: Text('Item $index')),
            ),
          ),
        ),
      );

      expect(find.byType(RawScrollbar), findsNothing);
    });

    testWidgets('Applies style and theme overrides to scrollbar', (
      WidgetTester tester,
    ) async {
      const style = JustScrollAreaStyle(
        scrollbarThumbColor: Color(0xFF00FF00),
        scrollbarTrackColor: Color(0xFF0000FF),
        scrollbarThickness: 10.0,
        scrollbarRadius: Radius.circular(5.0),
        scrollbarPadding: EdgeInsets.all(4.0),
        scrollbarMargin: 8.0,
      );

      await tester.pumpWidget(
        buildTestScrollArea(
          style: style,
          child: Column(
            children: List.generate(
              20,
              (index) => SizedBox(height: 100, child: Text('Item $index')),
            ),
          ),
        ),
      );

      final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
      expect(scrollbar.thumbColor, equals(const Color(0xFF00FF00)));
      expect(scrollbar.trackColor, equals(const Color(0xFF0000FF)));
      expect(scrollbar.thickness, equals(10.0));
      expect(scrollbar.radius, equals(const Radius.circular(5.0)));
      expect(scrollbar.padding, equals(const EdgeInsets.all(4.0)));
      expect(scrollbar.mainAxisMargin, equals(8.0));
    });

    testWidgets('Neobrutalism preset forces zero radius scrollbar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestScrollArea(
          theme: JustThemeData.neobrutalismLight,
          child: Column(
            children: List.generate(
              20,
              (index) => SizedBox(height: 100, child: Text('Item $index')),
            ),
          ),
        ),
      );

      final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
      expect(scrollbar.radius, equals(Radius.zero));
    });

    testWidgets('maxHeight wraps scroll area in ConstrainedBox', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestScrollArea(
          maxHeight: 250.0,
          child: Column(
            children: List.generate(
              20,
              (index) => SizedBox(height: 100, child: Text('Item $index')),
            ),
          ),
        ),
      );

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final hasMaxHeight = constrainedBoxes.any(
        (box) => box.constraints.maxHeight == 250.0,
      );
      expect(hasMaxHeight, isTrue);
    });

    testWidgets('Horizontal direction configures horizontal scrolling', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        buildTestScrollArea(
          direction: Axis.horizontal,
          controller: controller,
          smoothScroll: false,
          child: Row(
            children: List.generate(
              30,
              (index) => SizedBox(width: 150, child: Text('Col $index')),
            ),
          ),
        ),
      );

      expect(find.text('Col 0'), findsOneWidget);
      final singleChild = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(singleChild.scrollDirection, equals(Axis.horizontal));
    });
  });

  group('Fade Edges & Shader Mask Tests', () {
    testWidgets('fadeEdges with overlay mode updates opacities correctly', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        buildTestScrollArea(
          controller: controller,
          fadeEdges: true,
          fadeMode: JustScrollFadeMode.overlay,
          smoothScroll: false,
          child: Column(
            children: List.generate(
              40,
              (index) => SizedBox(height: 100, child: Text('Entry $index')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Initially at top: top fade is invisible, bottom fade is visible
      expect(find.byType(Positioned), findsWidgets);

      // Scroll to middle
      controller.jumpTo(500.0);
      await tester.pumpAndSettle();

      // Scroll to bottom
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();
    });

    testWidgets(
      'fadeEdges with mask mode renders ShaderMask for vertical & horizontal',
      (WidgetTester tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          buildTestScrollArea(
            controller: controller,
            fadeEdges: true,
            fadeMode: JustScrollFadeMode.mask,
            smoothScroll: false,
            child: Column(
              children: List.generate(
                40,
                (index) => SizedBox(height: 100, child: Text('Mask $index')),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(ShaderMask), findsOneWidget);

        // Test horizontal mask
        await tester.pumpWidget(
          buildTestScrollArea(
            direction: Axis.horizontal,
            controller: controller,
            fadeEdges: true,
            fadeMode: JustScrollFadeMode.mask,
            smoothScroll: false,
            child: Row(
              children: List.generate(
                40,
                (index) => SizedBox(width: 100, child: Text('HMask $index')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ShaderMask), findsOneWidget);
      },
    );

    testWidgets('fadeEdges with non-scrollable content hides fade overlay', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestScrollArea(
          fadeEdges: true,
          fadeMode: JustScrollFadeMode.overlay,
          child: const SizedBox(height: 50, child: Text('Short Content')),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Short Content'), findsOneWidget);
    });
  });

  group('Scroll-To-Top Button & Callbacks Tests', () {
    testWidgets(
      'Scroll to top button appears when threshold exceeded and resets scroll',
      (WidgetTester tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          buildTestScrollArea(
            controller: controller,
            smoothScroll: false,
            scrollToTopButton: true,
            scrollToTopThreshold: 300.0,
            scrollToTopOffset: const Offset(16, 16),
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

        // Programmatically jump past threshold (300px)
        controller.jumpTo(500.0);
        await tester.pumpAndSettle();

        expect(find.byType(JustPressable), findsOneWidget);

        // Tap scroll-to-top button
        await tester.tap(find.byType(JustPressable));
        await tester.pumpAndSettle();

        expect(controller.offset, equals(0.0));
      },
    );

    testWidgets(
      'Scroll to top button with smoothScroll enabled routes through smooth engine',
      (WidgetTester tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          buildTestScrollArea(
            controller: controller,
            smoothScroll: true,
            scrollToTopButton: true,
            scrollToTopThreshold: 200.0,
            child: Column(
              children: List.generate(
                50,
                (index) => SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        );

        controller.jumpTo(400.0);
        await tester.pumpAndSettle();

        expect(find.byType(JustPressable), findsOneWidget);

        await tester.tap(find.byType(JustPressable));
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpAndSettle();

        expect(controller.offset, closeTo(0.0, 1.0));
      },
    );

    testWidgets(
      'onReachBottom callback triggers near bottom when scrolling downwards',
      (WidgetTester tester) async {
        int reachBottomCalls = 0;
        final controller = ScrollController();

        await tester.pumpWidget(
          buildTestScrollArea(
            controller: controller,
            reachBottomThreshold: 150.0,
            onReachBottom: () => reachBottomCalls++,
            smoothScroll: false,
            child: Column(
              children: List.generate(
                30,
                (index) => SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        );

        expect(reachBottomCalls, equals(0));

        // Scroll close to the bottom
        final maxExtent = controller.position.maxScrollExtent;
        controller.jumpTo(maxExtent - 50.0);
        await tester.pumpAndSettle();

        expect(reachBottomCalls, equals(1));

        // Scroll back up and down to trigger again
        controller.jumpTo(maxExtent - 400.0);
        await tester.pumpAndSettle();

        controller.jumpTo(maxExtent - 20.0);
        await tester.pumpAndSettle();

        expect(reachBottomCalls, equals(2));
      },
    );

    testWidgets('onScrollStart and onScrollEnd fire on user drag', (
      WidgetTester tester,
    ) async {
      bool startFired = false;
      bool endFired = false;

      await tester.pumpWidget(
        buildTestScrollArea(
          smoothScroll: false,
          onScrollStart: () => startFired = true,
          onScrollEnd: () => endFired = true,
          child: Column(
            children: List.generate(
              30,
              (index) => SizedBox(height: 100, child: Text('Item $index')),
            ),
          ),
        ),
      );

      await tester.drag(find.text('Item 0'), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(startFired, isTrue);
      expect(endFired, isTrue);
    });
  });

  group('Smooth Scroll Engine & PointerSignal Physics', () {
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

        // Dispatch mouse wheel pointer scroll event
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
        expect(controller.offset, greaterThan(0.0));
        await tester.pumpAndSettle();
        expect(controller.offset, closeTo(8.0, 0.5));
      },
    );

    testWidgets(
      'Horizontal PointerScrollEvent drives horizontal smooth scroll',
      (WidgetTester tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          buildTestScrollArea(
            direction: Axis.horizontal,
            controller: controller,
            smoothScroll: true,
            child: Row(
              children: List.generate(
                50,
                (index) => SizedBox(width: 100, child: Text('HItem $index')),
              ),
            ),
          ),
        );

        tester.binding.handlePointerEvent(
          const PointerScrollEvent(
            position: Offset(200, 200),
            scrollDelta: Offset(100, 0),
          ),
        );

        await tester.pump(const Duration(milliseconds: 16));
        expect(controller.offset, greaterThan(0.0));
        await tester.pumpAndSettle();
        expect(controller.offset, closeTo(100.0, 1.0));
      },
    );

    testWidgets(
      'Auto-detects smooth scroll on desktop vs mobile target platforms',
      (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        await tester.pumpWidget(
          buildTestScrollArea(
            child: Column(
              children: List.generate(
                10,
                (index) =>
                    SizedBox(height: 100, child: Text('Platform $index')),
              ),
            ),
          ),
        );

        expect(find.byType(Listener), findsWidgets);

        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(
          buildTestScrollArea(
            child: Column(
              children: List.generate(
                10,
                (index) =>
                    SizedBox(height: 100, child: Text('Platform $index')),
              ),
            ),
          ),
        );

        debugDefaultTargetPlatformOverride = null;
      },
    );
  });

  group('Keyboard Scrolling Navigation Tests', () {
    testWidgets('Vertical arrow and page keys drive scroll position', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        buildTestScrollArea(
          controller: controller,
          smoothScroll: false,
          keyboardScrollStep: 60.0,
          child: Column(
            children: List.generate(
              50,
              (index) => SizedBox(height: 100, child: Text('KeyItem $index')),
            ),
          ),
        ),
      );

      // Focus the scroll area
      final focusFinder = find.byType(Focus);
      expect(focusFinder, findsWidgets);
      final focusWidget = tester.widget<Focus>(focusFinder.first);
      focusWidget.focusNode?.requestFocus();
      await tester.pumpAndSettle();

      // Arrow down
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(60.0));

      // Arrow up
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(0.0));

      // Page down
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0.0));

      // Page up
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(0.0));

      // Ignored non-scroll key
      await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(0.0));
    });

    testWidgets('Horizontal arrow and page keys drive scroll position', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        buildTestScrollArea(
          direction: Axis.horizontal,
          controller: controller,
          smoothScroll: false,
          keyboardScrollStep: 80.0,
          child: Row(
            children: List.generate(
              50,
              (index) => SizedBox(width: 120, child: Text('HKey $index')),
            ),
          ),
        ),
      );

      final focusFinder = find.byType(Focus);
      final focusWidget = tester.widget<Focus>(focusFinder.first);
      focusWidget.focusNode?.requestFocus();
      await tester.pumpAndSettle();

      // Arrow right
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(80.0));

      // Arrow left
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(0.0));

      // Page down & page up
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0.0));

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();
      expect(controller.offset, equals(0.0));
    });

    testWidgets('Smooth scroll engine handles keyboard arrow keys', (
      WidgetTester tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        buildTestScrollArea(
          controller: controller,
          smoothScroll: true,
          keyboardScrollStep: 50.0,
          child: Column(
            children: List.generate(
              50,
              (index) => SizedBox(height: 100, child: Text('SmoothKey $index')),
            ),
          ),
        ),
      );

      final focusFinder = find.byType(Focus);
      final focusWidget = tester.widget<Focus>(focusFinder.first);
      focusWidget.focusNode?.requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpAndSettle();
      expect(controller.offset, closeTo(50.0, 1.0));
    });
  });
}
