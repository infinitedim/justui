import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );
  }

  group('JustTabs Tests', () {
    testWidgets('Renders all tab headers and the initial content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const SizedBox(
            height: 300,
            child: JustTabs(
              tabs: [
                JustTab(label: 'Tab A', content: Text('Content A')),
                JustTab(label: 'Tab B', content: Text('Content B')),
              ],
            ),
          ),
        ),
      );

      // Headers should exist
      expect(find.text('Tab A'), findsOneWidget);
      expect(find.text('Tab B'), findsOneWidget);

      // Active content should exist, inactive should not be rendered yet (lazy loading)
      expect(find.text('Content A'), findsOneWidget);
      expect(find.text('Content B'), findsNothing);
    });

    testWidgets('Tapping a tab updates selection and content page', (
      WidgetTester tester,
    ) async {
      int? changedIndex;

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 300,
            child: JustTabs(
              onChanged: (idx) => changedIndex = idx,
              tabs: [
                const JustTab(label: 'Tab A', content: Text('Content A')),
                const JustTab(label: 'Tab B', content: Text('Content B')),
              ],
            ),
          ),
        ),
      );

      // Tap on Tab B
      await tester.tap(find.text('Tab B'));
      await tester.pumpAndSettle();

      expect(changedIndex, equals(1));
      expect(find.text('Content A'), findsNothing);
      expect(find.text('Content B'), findsOneWidget);
    });

    testWidgets('Disabled tabs do not trigger callbacks or navigation', (
      WidgetTester tester,
    ) async {
      int? changedIndex;

      await tester.pumpWidget(
        buildTestableWidget(
          SizedBox(
            height: 300,
            child: JustTabs(
              onChanged: (idx) => changedIndex = idx,
              tabs: [
                const JustTab(label: 'Tab A', content: Text('Content A')),
                const JustTab(
                  label: 'Tab B',
                  enabled: false,
                  content: Text('Content B'),
                ),
              ],
            ),
          ),
        ),
      );

      // Tap on disabled Tab B
      await tester.tap(find.text('Tab B'));
      await tester.pumpAndSettle();

      expect(changedIndex, isNull);
      expect(find.text('Content A'), findsOneWidget);
      expect(find.text('Content B'), findsNothing);
    });

    testWidgets('Keyboard arrow navigation switches tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const SizedBox(
            height: 300,
            child: JustTabs(
              initialIndex: 0,
              tabs: [
                JustTab(label: 'Tab A', content: Text('Content A')),
                JustTab(label: 'Tab B', content: Text('Content B')),
              ],
            ),
          ),
        ),
      );

      // Direct focus to the tabs key listener
      final focusNodeFinder = find.byType(KeyboardListener);
      expect(focusNodeFinder, findsOneWidget);

      // Send Right Arrow key to switch tab
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Now Tab B content should be active
      expect(find.text('Content B'), findsOneWidget);
    });

    testWidgets(
      'Swapping JustTabController updates active tab and does not throw',
      (WidgetTester tester) async {
        final controllerA = JustTabController(length: 2, initialIndex: 0);
        final controllerB = JustTabController(length: 2, initialIndex: 1);

        // Render with controllerA
        await tester.pumpWidget(
          buildTestableWidget(
            SizedBox(
              height: 300,
              child: JustTabs(
                controller: controllerA,
                tabs: const [
                  JustTab(label: 'Tab A', content: Text('Content A')),
                  JustTab(label: 'Tab B', content: Text('Content B')),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Content A'), findsOneWidget);
        expect(find.text('Content B'), findsNothing);

        // Re-render with controllerB
        await tester.pumpWidget(
          buildTestableWidget(
            SizedBox(
              height: 300,
              child: JustTabs(
                controller: controllerB,
                tabs: const [
                  JustTab(label: 'Tab A', content: Text('Content A')),
                  JustTab(label: 'Tab B', content: Text('Content B')),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Active content should now be Content B and no exception should be thrown
        expect(find.text('Content A'), findsNothing);
        expect(find.text('Content B'), findsOneWidget);

        controllerA.dispose();
        controllerB.dispose();
      },
    );
  });
}
