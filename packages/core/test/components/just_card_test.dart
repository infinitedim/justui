import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/card/just_card.dart';

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

    testWidgets('Renders modular composable widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustCard(
            child: Column(
              children: [
                JustCardHeader(
                  child: Column(
                    children: [
                      JustCardTitle(child: Text('Modular Title')),
                      JustCardDescription(child: Text('Modular Description')),
                    ],
                  ),
                ),
                JustCardContent(child: Text('Modular Content')),
                JustCardFooter(child: Text('Modular Footer')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Modular Title'), findsOneWidget);
      expect(find.text('Modular Description'), findsOneWidget);
      expect(find.text('Modular Content'), findsOneWidget);
      expect(find.text('Modular Footer'), findsOneWidget);
    });

    testWidgets('Renders correctly under neobrutalism preset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          lightTheme: JustThemeData.neobrutalismLight,
          child: const Directionality(
            textDirection: .ltr,
            child: JustCard(child: Text('Neobrutalist Card Content')),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Neobrutalist Card Content'), findsOneWidget);
    });
  });
}
