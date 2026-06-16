import 'package:flutter/gestures.dart';
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

  group('JustCard Tests', () {
    testWidgets('Renders child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const JustCard(child: Text('Card Content'))),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('Renders header and footer sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustCard(
            header: Text('Card Header'),
            footer: Text('Card Footer'),
            child: Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Header'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
      expect(find.text('Card Footer'), findsOneWidget);
    });

    testWidgets('Triggers onTap when interactive', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustCard(
            onTap: () => tapped = true,
            child: const Text('Interactive Card'),
          ),
        ),
      );

      await tester.tap(find.text('Interactive Card'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Applies hover and pressed states', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          JustCard(onTap: () {}, child: const Text('State Card')),
        ),
      );

      final cardFinder = find.byType(JustCard);

      // Verify default state
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();

      // Hover over the card
      await gesture.moveTo(tester.getCenter(cardFinder));
      await tester.pump();

      // Mouse leaves the card
      await gesture.moveTo(Offset.zero);
      await tester.pump();

      await gesture.removePointer();
    });
  });
}
