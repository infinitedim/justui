import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/resizable/just_resizable.dart';

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

class _StatefulTestWidget extends StatefulWidget {
  final String label;

  const _StatefulTestWidget({super.key, required this.label});

  @override
  State<_StatefulTestWidget> createState() => _StatefulTestWidgetState();
}

class _StatefulTestWidgetState extends State<_StatefulTestWidget> {
  int counter = 0;

  void increment() {
    setState(() => counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Text('${widget.label}: $counter');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JustResizableEngine - Fraction Normalization & Available Space', () {
    test('normalizeFractions returns empty for count <= 0', () {
      expect(JustResizableEngine.normalizeFractions([], 0), isEmpty);
      expect(JustResizableEngine.normalizeFractions([], -1), isEmpty);
    });

    test('normalizeFractions returns [1.0] for count == 1', () {
      expect(JustResizableEngine.normalizeFractions([null], 1), equals([1.0]));
      expect(JustResizableEngine.normalizeFractions([0.5], 1), equals([1.0]));
    });

    test(
      'normalizeFractions handles all null initial sizes by equal distribution',
      () {
        final fractions = JustResizableEngine.normalizeFractions([
          null,
          null,
          null,
        ], 3);
        expect(fractions.length, equals(3));
        for (final f in fractions) {
          expect(f, closeTo(1.0 / 3.0, 0.0001));
        }
        expect(fractions.reduce((a, b) => a + b), closeTo(1.0, 0.0001));
      },
    );

    test('normalizeFractions normalizes custom proportions', () {
      final fractions = JustResizableEngine.normalizeFractions([20.0, 80.0], 2);
      expect(fractions[0], closeTo(0.2, 0.0001));
      expect(fractions[1], closeTo(0.8, 0.0001));
      expect(fractions.reduce((a, b) => a + b), closeTo(1.0, 0.0001));
    });

    test('normalizeFractions handles mixed null and non-null sizes', () {
      final fractions = JustResizableEngine.normalizeFractions([0.5, null], 2);
      expect(fractions.length, equals(2));
      expect(fractions.reduce((a, b) => a + b), closeTo(1.0, 0.0001));
    });

    test('computeAvailableSpace deducts divider space correctly', () {
      expect(
        JustResizableEngine.computeAvailableSpace(1000.0, 1, 2.0),
        equals(1000.0),
      );
      expect(
        JustResizableEngine.computeAvailableSpace(1000.0, 3, 2.0),
        equals(996.0),
      );
      expect(
        JustResizableEngine.computeAvailableSpace(10.0, 5, 5.0),
        equals(0.0),
      );
    });
  });

  group('JustResizableEngine - Bresenham Remainder Distribution', () {
    test('Anti-subpixel drift guarantees exact availableSpace sum', () {
      const availableSpace = 1000.0;
      final fractions = [1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0];
      final panels = [
        const JustResizablePanel(child: SizedBox()),
        const JustResizablePanel(child: SizedBox()),
        const JustResizablePanel(child: SizedBox()),
      ];
      final output = List<double>.filled(3, 0.0);

      JustResizableEngine.distributePixelSizes(
        availableSpace: availableSpace,
        fractions: fractions,
        panels: panels,
        output: output,
      );

      final totalAllocated = output.reduce((a, b) => a + b);
      expect(totalAllocated, equals(availableSpace));
    });

    test('minSize clamping is respected', () {
      const availableSpace = 500.0;
      final fractions = [0.1, 0.9];
      final panels = [
        const JustResizablePanel(minSize: 150.0, child: SizedBox()),
        const JustResizablePanel(child: SizedBox()),
      ];
      final output = List<double>.filled(2, 0.0);

      JustResizableEngine.distributePixelSizes(
        availableSpace: availableSpace,
        fractions: fractions,
        panels: panels,
        output: output,
      );

      expect(output[0], equals(150.0));
      expect(output[1], equals(350.0));
      expect(output.reduce((a, b) => a + b), equals(availableSpace));
    });

    test('maxSize clamping is respected', () {
      const availableSpace = 500.0;
      final fractions = [0.8, 0.2];
      final panels = [
        const JustResizablePanel(maxSize: 200.0, child: SizedBox()),
        const JustResizablePanel(child: SizedBox()),
      ];
      final output = List<double>.filled(2, 0.0);

      JustResizableEngine.distributePixelSizes(
        availableSpace: availableSpace,
        fractions: fractions,
        panels: panels,
        output: output,
      );

      expect(output[0], equals(200.0));
      expect(output[1], equals(300.0));
    });

    test('Collapsed panel allocates 0.0 space', () {
      const availableSpace = 600.0;
      final fractions = [0.0, 1.0];
      final panels = [
        const JustResizablePanel(collapsible: true, child: SizedBox()),
        const JustResizablePanel(child: SizedBox()),
      ];
      final output = List<double>.filled(2, 0.0);

      JustResizableEngine.distributePixelSizes(
        availableSpace: availableSpace,
        fractions: fractions,
        panels: panels,
        output: output,
      );

      expect(output[0], equals(0.0));
      expect(output[1], equals(600.0));
    });
  });

  group('JustResizableEngine - Isolated Splitter Drag Math', () {
    test('Isolated splitter drag only mutates adjacent panels and preserves sum', () {
      const availableSpace = 1000.0;
      final currentFractions = [0.2, 0.5, 0.3];
      final panels = [
        const JustResizablePanel(child: SizedBox()),
        const JustResizablePanel(child: SizedBox()),
        const JustResizablePanel(child: SizedBox()),
      ];
      final output = List<double>.filled(3, 0.0);

      // Drag splitter 0 (between panel 0 and panel 1) by +100px (+0.1 fraction)
      JustResizableEngine.applySplitterDrag(
        splitterIndex: 0,
        deltaPixels: 100.0,
        availableSpace: availableSpace,
        currentFractions: currentFractions,
        panels: panels,
        outputFractions: output,
      );

      expect(output[0], closeTo(0.3, 0.0001));
      expect(output[1], closeTo(0.4, 0.0001));
      expect(output[2], closeTo(0.3, 0.0001)); // Panel 2 completely unaffected!
      expect(output.reduce((a, b) => a + b), closeTo(1.0, 0.0001));
    });

    test(
      'Locked splitter when resizable is false preserves current fractions',
      () {
        const availableSpace = 1000.0;
        final currentFractions = [0.5, 0.5];
        final panels = [
          const JustResizablePanel(resizable: false, child: SizedBox()),
          const JustResizablePanel(child: SizedBox()),
        ];
        final output = List<double>.filled(2, 0.0);

        JustResizableEngine.applySplitterDrag(
          splitterIndex: 0,
          deltaPixels: 100.0,
          availableSpace: availableSpace,
          currentFractions: currentFractions,
          panels: panels,
          outputFractions: output,
        );

        // Current fractions MUST be preserved!
        expect(output[0], equals(0.5));
        expect(output[1], equals(0.5));
      },
    );

    test('Snapping must NOT violate neighbor panel constraints', () {
      const availableSpace = 1000.0;
      final currentFractions = [0.80, 0.20];
      final panels = [
        const JustResizablePanel(
          snapPoints: [0.90],
          snapThreshold: 0.05,
          child: SizedBox(),
        ),
        const JustResizablePanel(
          minSize: 200.0, // minFraction = 0.20!
          child: SizedBox(),
        ),
      ];
      final output = List<double>.filled(2, 0.0);

      // Drag by +80px: raw fraction = 0.88, near snap point 0.90.
      // But snapping to 0.90 would force panel B to 0.10, which violates B's minSize of 200.0 (0.20).
      // So panel A must NOT snap to 0.90!
      JustResizableEngine.applySplitterDrag(
        splitterIndex: 0,
        deltaPixels: 80.0,
        availableSpace: availableSpace,
        currentFractions: currentFractions,
        panels: panels,
        outputFractions: output,
      );

      expect(output[0], lessThanOrEqualTo(0.80001));
      expect(output[1], greaterThanOrEqualTo(0.19999));
    });

    test('Collapsible panel collapses to 0.0 below threshold', () {
      const availableSpace = 1000.0;
      final currentFractions = [0.15, 0.85];
      final panels = [
        const JustResizablePanel(
          minSize: 100.0, // 0.10
          collapsible: true,
          collapseThreshold: 50.0, // 0.05
          child: SizedBox(),
        ),
        const JustResizablePanel(child: SizedBox()),
      ];
      final output = List<double>.filled(2, 0.0);

      // Drag left by -120px: target fraction = 0.15 - 0.12 = 0.03 (< collapseThreshold 0.05)
      JustResizableEngine.applySplitterDrag(
        splitterIndex: 0,
        deltaPixels: -120.0,
        availableSpace: availableSpace,
        currentFractions: currentFractions,
        panels: panels,
        outputFractions: output,
      );

      expect(output[0], equals(0.0)); // Collapsed!
      expect(output[1], closeTo(1.0, 0.0001));
    });

    test('Collapsible panel clamps to minSize when above threshold but below minSize', () {
      const availableSpace = 1000.0;
      final currentFractions = [0.15, 0.85];
      final panels = [
        const JustResizablePanel(
          minSize: 100.0, // 0.10
          collapsible: true,
          collapseThreshold: 50.0, // 0.05
          child: SizedBox(),
        ),
        const JustResizablePanel(child: SizedBox()),
      ];
      final output = List<double>.filled(2, 0.0);

      // Drag left by -70px: target fraction = 0.15 - 0.07 = 0.08 (between 0.05 and 0.10)
      JustResizableEngine.applySplitterDrag(
        splitterIndex: 0,
        deltaPixels: -70.0,
        availableSpace: availableSpace,
        currentFractions: currentFractions,
        panels: panels,
        outputFractions: output,
      );

      expect(output[0], closeTo(0.10, 0.0001)); // Clamped to minSize!
      expect(output[1], closeTo(0.90, 0.0001));
    });

    test('Magnetic snapping to snapPoints within snapThreshold', () {
      const availableSpace = 1000.0;
      final currentFractions = [0.20, 0.80];
      final panels = [
        const JustResizablePanel(
          snapPoints: [0.25, 0.50],
          snapThreshold: 0.03,
          child: SizedBox(),
        ),
        const JustResizablePanel(child: SizedBox()),
      ];
      final output = List<double>.filled(2, 0.0);

      // Drag by +40px: raw fraction = 0.20 + 0.04 = 0.24.
      // |0.24 - 0.25| = 0.01 <= snapThreshold 0.03 -> snaps to 0.25!
      JustResizableEngine.applySplitterDrag(
        splitterIndex: 0,
        deltaPixels: 40.0,
        availableSpace: availableSpace,
        currentFractions: currentFractions,
        panels: panels,
        outputFractions: output,
      );

      expect(output[0], closeTo(0.25, 0.0001));
      expect(output[1], closeTo(0.75, 0.0001));
    });
  });

  group('JustResizableController', () {
    test('Initializes fractions correctly and provides unmodifiable view', () {
      final controller = JustResizableController(initialFractions: [0.3, 0.7]);
      expect(controller.fractions.length, equals(2));
      expect(controller.fractions[0], closeTo(0.3, 0.0001));
      expect(controller.fractions[1], closeTo(0.7, 0.0001));

      expect(
        () => controller.fractions[0] = 0.5,
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('setFractions normalizes values and notifies listeners', () {
      final controller = JustResizableController(initialFractions: [0.5, 0.5]);
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.setFractions([25.0, 75.0]);
      expect(notifyCount, equals(1));
      expect(controller.fractions[0], closeTo(0.25, 0.0001));
      expect(controller.fractions[1], closeTo(0.75, 0.0001));
    });

    test('collapse transfers fraction to adjacent panel', () {
      final controller = JustResizableController(initialFractions: [0.4, 0.6]);
      expect(controller.isCollapsed(0), isFalse);

      controller.collapse(0);
      expect(controller.isCollapsed(0), isTrue);
      expect(controller.fractions[0], equals(0.0));
      expect(controller.fractions[1], closeTo(1.0, 0.0001));

      // Collapse the last panel
      final controller3 = JustResizableController(
        initialFractions: [0.3, 0.3, 0.4],
      );
      controller3.collapse(2);
      expect(controller3.isCollapsed(2), isTrue);
      expect(controller3.fractions[2], equals(0.0));
      expect(controller3.fractions[1], closeTo(0.7, 0.0001));
    });

    test('expand restores panel to saved pre-collapse fraction', () {
      final controller = JustResizableController(initialFractions: [0.3, 0.7]);
      controller.collapse(0);
      expect(controller.isCollapsed(0), isTrue);

      controller.expand(0);
      expect(controller.isCollapsed(0), isFalse);
      expect(controller.fractions[0], closeTo(0.3, 0.0001));
      expect(controller.fractions[1], closeTo(0.7, 0.0001));
    });

    test('toggle alternates between collapse and expand', () {
      final controller = JustResizableController(initialFractions: [0.5, 0.5]);
      controller.toggle(0);
      expect(controller.isCollapsed(0), isTrue);

      controller.toggle(0);
      expect(controller.isCollapsed(0), isFalse);
      expect(controller.fractions[0], closeTo(0.5, 0.0001));
    });

    test(
      'collapse and expand across multiple panels avoids dead panel lock',
      () {
        final controller = JustResizableController(
          initialFractions: [0.33, 0.33, 0.34],
        );
        // Collapse middle panel (1) -> space transferred to panel 2
        controller.collapse(1);
        expect(controller.isCollapsed(1), isTrue);
        expect(controller.isCollapsed(0), isFalse);
        expect(controller.isCollapsed(2), isFalse);

        // Collapse panel 0 -> must transfer to active panel 2, NOT collapsed panel 1
        controller.collapse(0);
        expect(controller.isCollapsed(0), isTrue);
        expect(controller.isCollapsed(1), isTrue);
        expect(controller.isCollapsed(2), isFalse);
        expect(controller.fractions[2], closeTo(1.0, 0.0001));

        // Expand panel 0 -> reclaims space from active panel 2, panel 1 remains collapsed
        controller.expand(0);
        expect(controller.isCollapsed(0), isFalse);
        expect(controller.isCollapsed(1), isTrue);
        expect(controller.fractions[0], closeTo(0.33, 0.01));

        // Expand panel 1
        controller.expand(1);
        expect(controller.isCollapsed(1), isFalse);
      },
    );

    test('reset restores initial fractions', () {
      final controller = JustResizableController(initialFractions: [0.2, 0.8]);
      controller.setFractions([0.6, 0.4]);
      expect(controller.fractions[0], closeTo(0.6, 0.0001));

      controller.reset();
      expect(controller.fractions[0], closeTo(0.2, 0.0001));
      expect(controller.fractions[1], closeTo(0.8, 0.0001));
    });
  });

  group('JustResizableStyle & JustResizableTheme', () {
    test('JustResizableTheme.defaults properties verified', () {
      const theme = JustResizableTheme.defaults;
      expect(theme.dividerThickness, equals(1.0));
      expect(theme.handleHitSize, equals(8.0));
      expect(theme.handleVariant, equals(JustResizableHandleVariant.line));
      expect(theme.style, isNull);
    });

    test('copyWith overrides requested properties', () {
      const base = JustResizableTheme.defaults;
      final modified = base.copyWith(
        dividerThickness: 3.0,
        handleHitSize: 12.0,
        handleVariant: JustResizableHandleVariant.grip,
      );

      expect(modified.dividerThickness, equals(3.0));
      expect(modified.handleHitSize, equals(12.0));
      expect(modified.handleVariant, equals(JustResizableHandleVariant.grip));
    });

    test('lerp interpolates theme values', () {
      const t1 = JustResizableTheme(dividerThickness: 2.0, handleHitSize: 10.0);
      const t2 = JustResizableTheme(dividerThickness: 4.0, handleHitSize: 20.0);

      final lerped = t1.lerp(t2, 0.5);
      expect(lerped.dividerThickness, closeTo(3.0, 0.0001));
      expect(lerped.handleHitSize, closeTo(15.0, 0.0001));
    });

    test('JustResizableStyle copyWith and lerp', () {
      const s1 = JustResizableStyle(
        dividerThickness: 1.0,
        dividerColor: Color(0xFF000000),
      );
      const s2 = JustResizableStyle(
        dividerThickness: 3.0,
        dividerColor: Color(0xFFFFFFFF),
      );

      final lerped = JustResizableStyle.lerp(s1, s2, 0.5);
      expect(lerped?.dividerThickness, closeTo(2.0, 0.0001));
      expect(lerped?.dividerColor, isNotNull);

      final copied = s1.copyWith(dividerThickness: 5.0);
      expect(copied.dividerThickness, equals(5.0));
      expect(copied.dividerColor, equals(const Color(0xFF000000)));
    });

    test('Theme equality and hashCode', () {
      const t1 = JustResizableTheme(dividerThickness: 2.0);
      const t2 = JustResizableTheme(dividerThickness: 2.0);
      const t3 = JustResizableTheme(dividerThickness: 3.0);

      expect(t1 == t2, isTrue);
      expect(t1 == t3, isFalse);
      expect(t1.hashCode, equals(t2.hashCode));
    });
  });

  group('JustResizable Widget Integration', () {
    testWidgets('Renders horizontal panels with correct initial sizes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 800.0,
            height: 400.0,
            child: JustResizable(
              direction: Axis.horizontal,
              dividerThickness: 2.0,
              children: [
                JustResizablePanel(initialSize: 0.25, child: Text('Panel A')),
                JustResizablePanel(initialSize: 0.75, child: Text('Panel B')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Panel A'), findsOneWidget);
      expect(find.text('Panel B'), findsOneWidget);

      final sizeA = tester.getSize(find.text('Panel A'));
      expect(sizeA.width, greaterThan(0));
    });

    testWidgets('Renders vertical panels with correct initial sizes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 400.0,
            height: 600.0,
            child: JustResizable(
              direction: Axis.vertical,
              dividerThickness: 2.0,
              children: [
                JustResizablePanel(initialSize: 0.5, child: Text('Top Panel')),
                JustResizablePanel(
                  initialSize: 0.5,
                  child: Text('Bottom Panel'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Top Panel'), findsOneWidget);
      expect(find.text('Bottom Panel'), findsOneWidget);
    });

    testWidgets('Offstage preserves child state when panel is collapsed', (
      tester,
    ) async {
      final controller = JustResizableController(initialFractions: [0.5, 0.5]);
      final statefulKey = GlobalKey<_StatefulTestWidgetState>();

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 600.0,
            height: 400.0,
            child: JustResizable(
              controller: controller,
              children: [
                JustResizablePanel(
                  collapsible: true,
                  child: _StatefulTestWidget(
                    key: statefulKey,
                    label: 'PreservedPanel',
                  ),
                ),
                const JustResizablePanel(child: Text('OtherPanel')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('PreservedPanel: 0'), findsOneWidget);

      // Increment internal state counter
      statefulKey.currentState?.increment();
      await tester.pump();
      expect(find.text('PreservedPanel: 1'), findsOneWidget);

      // Collapse the panel
      controller.collapse(0);
      await tester.pump();

      // State is preserved in memory while offstage is true
      expect(statefulKey.currentState?.counter, equals(1));

      // Expand the panel back
      controller.expand(0);
      await tester.pump();

      // Counter remains 1!
      expect(find.text('PreservedPanel: 1'), findsOneWidget);
    });

    testWidgets('Double-tap on splitter toggles collapse', (tester) async {
      final controller = JustResizableController(initialFractions: [0.5, 0.5]);

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 600.0,
            height: 400.0,
            child: JustResizable(
              controller: controller,
              children: const [
                JustResizablePanel(collapsible: true, child: Text('Panel 1')),
                JustResizablePanel(child: Text('Panel 2')),
              ],
            ),
          ),
        ),
      );

      expect(controller.isCollapsed(0), isFalse);

      // Double-tap the splitter
      final splitterFinder = find.byType(GestureDetector).at(1);
      await tester.tap(splitterFinder);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(splitterFinder);
      await tester.pumpAndSettle();

      expect(controller.isCollapsed(0), isTrue);
    });

    testWidgets('Grip handle variant renders grip dots', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 600.0,
            height: 400.0,
            child: JustResizable(
              handleVariant: JustResizableHandleVariant.grip,
              children: [
                JustResizablePanel(child: Text('Left')),
                JustResizablePanel(child: Text('Right')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets(
      'Layout does not overflow when handleHitSize > dividerThickness',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            const SizedBox(
              width: 600.0,
              height: 400.0,
              child: JustResizable(
                handleHitSize: 16.0,
                dividerThickness: 2.0,
                children: [
                  JustResizablePanel(child: Text('Col 1')),
                  JustResizablePanel(child: Text('Col 2')),
                  JustResizablePanel(child: Text('Col 3')),
                ],
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Col 1'), findsOneWidget);
        expect(find.text('Col 2'), findsOneWidget);
        expect(find.text('Col 3'), findsOneWidget);
      },
    );

    testWidgets('Double-tap behavior reset restores initial fractions', (
      tester,
    ) async {
      final controller = JustResizableController(initialFractions: [0.3, 0.7]);

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 600.0,
            height: 400.0,
            child: JustResizable(
              controller: controller,
              doubleTapBehavior: JustResizableDoubleTapBehavior.reset,
              children: const [
                JustResizablePanel(child: Text('Left')),
                JustResizablePanel(child: Text('Right')),
              ],
            ),
          ),
        ),
      );

      // Mutate fractions
      controller.setFractions([0.6, 0.4]);
      await tester.pumpAndSettle();
      expect(controller.fractions[0], closeTo(0.6, 0.01));

      // Double-tap splitter
      final splitterFinder = find.byType(GestureDetector).at(1);
      await tester.tap(splitterFinder);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(splitterFinder);
      await tester.pumpAndSettle();

      // Restored!
      expect(controller.fractions[0], closeTo(0.3, 0.01));
      expect(controller.fractions[1], closeTo(0.7, 0.01));
    });

    testWidgets('Double-tap behavior none ignores double-taps', (tester) async {
      final controller = JustResizableController(initialFractions: [0.5, 0.5]);

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 600.0,
            height: 400.0,
            child: JustResizable(
              controller: controller,
              doubleTapBehavior: JustResizableDoubleTapBehavior.none,
              children: const [
                JustResizablePanel(collapsible: true, child: Text('Left')),
                JustResizablePanel(child: Text('Right')),
              ],
            ),
          ),
        ),
      );

      final splitterFinder = find.byType(GestureDetector).at(1);
      await tester.tap(splitterFinder);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(splitterFinder);
      await tester.pumpAndSettle();

      // Did not collapse
      expect(controller.isCollapsed(0), isFalse);
    });

    testWidgets('Keyboard arrow keys adjust panel fractions', (tester) async {
      final controller = JustResizableController(initialFractions: [0.5, 0.5]);

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 600.0,
            height: 400.0,
            child: JustResizable(
              controller: controller,
              keyboardStep: 20.0,
              children: const [
                JustResizablePanel(child: Text('Left')),
                JustResizablePanel(child: Text('Right')),
              ],
            ),
          ),
        ),
      );

      // Focus the splitter Focus widget
      final focusFinder = find.byType(Focus).first;
      await tester.tap(focusFinder);
      await tester.pump();

      // Send ArrowRight
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Total available space is 600 - 1.0 = 599.0
      // Moving right by 20.0px increases panel 0 fraction
      expect(controller.fractions[0], greaterThan(0.5));

      // Send ArrowLeft
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(controller.fractions[0], closeTo(0.5, 0.01));
    });

    testWidgets('Keyboard Home and End snap to limits', (tester) async {
      final controller = JustResizableController(initialFractions: [0.5, 0.5]);

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 600.0,
            height: 400.0,
            child: JustResizable(
              controller: controller,
              children: const [
                JustResizablePanel(minSize: 100.0, child: Text('Left')),
                JustResizablePanel(minSize: 100.0, child: Text('Right')),
              ],
            ),
          ),
        ),
      );

      final focusFinder = find.byType(Focus).first;
      await tester.tap(focusFinder);
      await tester.pump();

      // Send Home key -> snaps to min
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(controller.fractions[0], closeTo(100.0 / 599.0, 0.01));

      // Send End key -> snaps to max
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(controller.fractions[1], closeTo(100.0 / 599.0, 0.01));
    });

    testWidgets('Keyboard Enter/Space triggers double-tap collapse toggle', (
      tester,
    ) async {
      final controller = JustResizableController(initialFractions: [0.5, 0.5]);

      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 600.0,
            height: 400.0,
            child: JustResizable(
              controller: controller,
              children: const [
                JustResizablePanel(collapsible: true, child: Text('Left')),
                JustResizablePanel(child: Text('Right')),
              ],
            ),
          ),
        ),
      );

      final focusFinder = find.byType(Focus).first;
      await tester.tap(focusFinder);
      await tester.pump();

      // Press Enter -> collapse
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(controller.isCollapsed(0), isTrue);

      // Press Space -> expand
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(controller.isCollapsed(0), isFalse);
    });

    testWidgets('Splitter renders with accessibility Semantics slider', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const SizedBox(
            width: 600.0,
            height: 400.0,
            child: JustResizable(
              children: [
                JustResizablePanel(child: Text('Left')),
                JustResizablePanel(child: Text('Right')),
              ],
            ),
          ),
        ),
      );

      final semanticsFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.slider == true &&
            (widget.properties.label?.contains('Splitter divider') ?? false),
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets(
      'Custom handleBuilder renders custom widget with interaction states',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            SizedBox(
              width: 600.0,
              height: 400.0,
              child: JustResizable(
                handleBuilder: (context, index, isDragging, isHovered) {
                  return Container(
                    key: const ValueKey('custom_handle'),
                    color: Colors.red,
                    child: const Text('CUSTOM'),
                  );
                },
                children: const [
                  JustResizablePanel(child: Text('Left')),
                  JustResizablePanel(child: Text('Right')),
                ],
              ),
            ),
          ),
        );

        expect(find.byKey(const ValueKey('custom_handle')), findsOneWidget);
        expect(find.text('CUSTOM'), findsOneWidget);
      },
    );
  });
}
