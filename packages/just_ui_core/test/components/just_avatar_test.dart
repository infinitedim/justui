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

  group('JustAvatar Tests', () {
    testWidgets('Renders initials from name', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const JustAvatar(name: 'John Doe')),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('Renders custom painter fallback when name/image are empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const JustAvatar()));

      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('Triggers onTap callback when tapped', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustAvatar(name: 'Jane Smith', onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.text('JS'));
      expect(tapped, isTrue);
    });

    testWidgets('Displays presence status dot', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustAvatar(
            name: 'John Doe',
            statusDot: JustAvatarStatus.online,
          ),
        ),
      );

      // Status dot is placed inside a Stack as a Positioned Container
      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
    });
  });

  group('JustAvatarGroup Tests', () {
    testWidgets('Renders multiple avatars overlapping', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustAvatarGroup(
            avatars: [
              JustAvatar(name: 'Alice'),
              JustAvatar(name: 'Bob'),
              JustAvatar(name: 'Charlie'),
            ],
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('Renders remainder avatar (+X) when size exceeds maxDisplay', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustAvatarGroup(
            maxDisplay: 2,
            avatars: [
              JustAvatar(name: 'Alice'),
              JustAvatar(name: 'Bob'),
              JustAvatar(name: 'Charlie'),
              JustAvatar(name: 'Dave'),
            ],
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsNothing);
      expect(find.text('D'), findsNothing);

      // Remaining count should display '+2'
      expect(find.text('+2'), findsOneWidget);
    });
  });
}
