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

  group('JustSkeleton Tests', () {
    testWidgets('Renders original child when loading is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSkeleton(loading: false, child: Text('Hello World')),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
      // Ensure no skeleton shape is rendered
      final shapeFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
      );
      expect(shapeFinder, findsNothing);
    });

    testWidgets('Transforms short Text into skeleton shape', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSkeleton(loading: true, child: Text('Short Text')),
        ),
      );

      expect(find.text('Short Text'), findsNothing);
      final shapeFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
      );
      expect(shapeFinder, findsOneWidget);
    });

    testWidgets('Transforms long Text paragraph into Column of lines', (
      WidgetTester tester,
    ) async {
      const longText =
          'This is an extremely long text paragraph that exceeds forty characters and should trigger multi-line layout.';
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSkeleton(loading: true, child: Text(longText)),
        ),
      );

      expect(find.text(longText), findsNothing);
      expect(find.byType(Column), findsOneWidget);
      // Since it has length ~108, it should produce 3 lines (clamped to max 4)
      final shapeFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
      );
      expect(shapeFinder, findsNWidgets(3));
    });

    testWidgets('Preserves Container decoration and recurses child', (
      WidgetTester tester,
    ) async {
      const boxDecoration = BoxDecoration(
        color: Color(0xFFFF0000),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      );
      await tester.pumpWidget(
        buildTestableWidget(
          JustSkeleton(
            loading: true,
            child: Container(
              decoration: boxDecoration,
              child: const Text('Nested Text'),
            ),
          ),
        ),
      );

      // Verify container with decoration is preserved
      final containerFinder = find.byType(Container);
      expect(
        containerFinder,
        findsNWidgets(2),
      ); // Container and _JustSkeletonShape container
      final Container container = tester.widget<Container>(
        containerFinder.first,
      );
      expect(container.decoration, equals(boxDecoration));

      // Verify nested child is transformed to skeleton shape
      final shapeFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
      );
      expect(shapeFinder, findsOneWidget);
    });

    testWidgets('Escape Hatch: JustSkeletonIgnore keeps widget intact', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSkeleton(
            loading: true,
            child: Column(
              children: [
                Text('Transformed Text'),
                JustSkeletonIgnore(child: Text('Ignored Text')),
              ],
            ),
          ),
        ),
      );

      // Ignored text should be fully visible
      expect(find.text('Ignored Text'), findsOneWidget);
      expect(find.text('Transformed Text'), findsNothing);

      // Only one skeleton shape should be rendered for the transformed text
      final shapeFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
      );
      expect(shapeFinder, findsOneWidget);
    });

    testWidgets(
      'Escape Hatch: JustSkeletonAtomic collapses sub-tree to single shape',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const JustSkeleton(
              loading: true,
              child: JustSkeletonAtomic(
                width: 80.0,
                height: 80.0,
                borderRadius: .all(Radius.circular(10.0)),
                child: Column(
                  children: [Text('Child Text 1'), Text('Child Text 2')],
                ),
              ),
            ),
          ),
        );

        // Children are ignored and not rendered
        expect(find.text('Child Text 1'), findsNothing);
        expect(find.text('Child Text 2'), findsNothing);

        // One single shape is rendered with the specified dimensions
        final shapeFinder = find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
        );
        expect(shapeFinder, findsOneWidget);

        final shapeWidget = tester.widget(shapeFinder);
        // Access width/height using dynamic to avoid private wrapper issues
        expect((shapeWidget as dynamic).width, equals(80.0));
        expect((shapeWidget as dynamic).height, equals(80.0));
      },
    );

    testWidgets('Transforms whitelisted registry components', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSkeleton(
            loading: true,
            child: Column(
              children: [
                JustAvatar(imageUrl: 'https://example.com/pic.png', size: .lg),
                JustBadge(label: 'Tag', size: .sm),
                JustButton(label: 'Submit', onPressed: null, size: .md),
              ],
            ),
          ),
        ),
      );

      // Original components labels/elements should be gone
      expect(find.text('Tag'), findsNothing);
      expect(find.text('Submit'), findsNothing);

      // Verify skeleton shapes are created
      final shapeFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
      );
      expect(shapeFinder, findsNWidgets(3));
    });

    testWidgets('Manual constructors render correct shapes standalone', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Column(
            children: [
              JustSkeleton.circle(size: 50.0),
              JustSkeleton.rect(width: 100.0, height: 20.0),
            ],
          ),
        ),
      );

      final shapeFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
      );
      expect(shapeFinder, findsNWidgets(2));
    });

    testWidgets(
      'AbsorbPointer is applied selectively, keeping JustSkeletonIgnore interactive',
      (WidgetTester tester) async {
        bool ignoredPressed = false;
        bool normalPressed = false;

        await tester.pumpWidget(
          buildTestableWidget(
            JustSkeleton(
              loading: true,
              child: Column(
                children: [
                  GestureDetector(
                    key: const Key('normal-detector'),
                    onTap: () => normalPressed = true,
                    child: const Text('Normal Tap Target'),
                  ),
                  JustSkeletonIgnore(
                    child: GestureDetector(
                      key: const Key('ignored-detector'),
                      onTap: () => ignoredPressed = true,
                      child: const Text('Ignored Tap Target'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final normalFinder = find.byKey(const Key('normal-detector'));
        final normalAbsorb = find.ancestor(
          of: normalFinder,
          matching: find.byType(AbsorbPointer),
        );
        expect(normalAbsorb, findsOneWidget);

        final ignoredFinder = find.byKey(const Key('ignored-detector'));
        final ignoredAbsorb = find.ancestor(
          of: ignoredFinder,
          matching: find.byType(AbsorbPointer),
        );
        expect(ignoredAbsorb, findsNothing);

        await tester.tap(normalFinder);
        expect(normalPressed, isFalse);

        await tester.tap(ignoredFinder);
        expect(ignoredPressed, isTrue);
      },
    );

    testWidgets('JustSkeletonAtomic fallback sizing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSkeleton(
            loading: true,
            child: JustSkeletonAtomic(
              child: SizedBox(width: 150.0, height: 100.0),
            ),
          ),
        ),
      );
      final shapeFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
      );
      final shapeWidget1 = tester.widget(shapeFinder);
      expect((shapeWidget1 as dynamic).width, equals(150.0));
      expect((shapeWidget1 as dynamic).height, equals(100.0));

      await tester.pumpWidget(
        buildTestableWidget(
          const JustSkeleton(
            loading: true,
            child: JustSkeletonAtomic(child: Text('some custom child')),
          ),
        ),
      );
      final shapeWidget2 = tester.widget(shapeFinder);
      expect((shapeWidget2 as dynamic).width, equals(double.infinity));
      expect((shapeWidget2 as dynamic).height, equals(56.0));
    });

    testWidgets(
      'Generic fallback transforms custom single-child layout wrapper',
      (WidgetTester tester) async {
        const wrapper = _TestSingleChildWrapper(child: Text('Test Child'));

        await tester.pumpWidget(
          buildTestableWidget(
            const JustSkeleton(loading: true, child: wrapper),
          ),
        );

        expect(find.text('Test Child'), findsNothing);

        final shapeFinder = find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
        );
        expect(shapeFinder, findsOneWidget);
      },
    );

    testWidgets('Preserves Semantics label with loading tag', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          JustSkeleton(
            loading: true,
            child: Semantics(label: 'Submit Form', child: const Text('Submit')),
          ),
        ),
      );

      final semanticsFinder = find.byType(Semantics);
      expect(semanticsFinder, findsOneWidget);

      final Semantics semantics = tester.widget<Semantics>(semanticsFinder);
      expect(semantics.properties.label, equals('Submit Form (loading)'));
    });

    testWidgets('Stack falls back to rect shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSkeleton(
            loading: true,
            child: Stack(children: [Text('Stack Child')]),
          ),
        ),
      );

      expect(find.text('Stack Child'), findsNothing);

      final shapeFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustSkeletonShape',
      );
      expect(shapeFinder, findsOneWidget);
      final shapeWidget = tester.widget(shapeFinder);
      expect((shapeWidget as dynamic).width, equals(double.infinity));
      expect((shapeWidget as dynamic).height, equals(120.0));
    });

    testWidgets('Renders correctly under neobrutalism preset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          lightTheme: JustThemeData.neobrutalismLight,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: JustSkeleton(
              loading: true,
              child: Text('Neobrutalist Loading...'),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(JustSkeleton), findsOneWidget);
    });
  });
}

class _TestSingleChildWrapper extends StatelessWidget {
  final Widget child;
  const _TestSingleChildWrapper({required this.child});
  @override
  Widget build(BuildContext context) => child;
}
