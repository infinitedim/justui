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

  group('JustButton Tests', () {
    testWidgets('Renders label and responds to tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustButton(label: 'Tap Me', onPressed: () => tapped = true),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('Does not trigger onTap when disabled', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustButton(
            label: 'Disabled',
            onPressed: () => tapped = true,
            isDisabled: true,
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      expect(tapped, isFalse);
    });

    testWidgets('Does not trigger onTap when loading', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustButton(
            label: 'Loading',
            onPressed: () => tapped = true,
            isLoading: true,
          ),
        ),
      );

      // Label is hidden when loading, check spinner presence instead
      expect(find.byType(JustProgressSpinner), findsOneWidget);
      expect(find.text('Loading'), findsNothing);

      await tester.tap(find.byType(JustProgressSpinner));
      expect(tapped, isFalse);
    });

    testWidgets('Renders leading and trailing widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustButton(
            label: 'With Icons',
            onPressed: null,
            leading: Text('L'),
            trailing: Text('T'),
          ),
        ),
      );

      expect(find.text('L'), findsOneWidget);
      expect(find.text('With Icons'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });
  });

  group('JustIconButton Tests', () {
    testWidgets('Renders and requires tooltip assertion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustIconButton(
            icon: SizedBox(width: 20, height: 20),
            onPressed: null,
            tooltip: 'Add Item',
          ),
        ),
      );

      expect(find.byType(JustIconButton), findsOneWidget);
    });

    test('Asserts tooltip is not null in debug mode', () {
      expect(
        () => JustIconButton(
          icon: const SizedBox(),
          onPressed: () {},
          tooltip: null,
        ),
        throwsAssertionError,
      );
    });
  });

  group('JustButtonGroup Tests', () {
    testWidgets('Renders children in attached layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          JustButtonGroup(
            attached: true,
            children: [
              JustButton(label: 'Btn 1', onPressed: () {}),
              JustButton(label: 'Btn 2', onPressed: () {}),
            ],
          ),
        ),
      );

      expect(find.text('Btn 1'), findsOneWidget);
      expect(find.text('Btn 2'), findsOneWidget);
    });
  });

  group('Golden Tests for JustButton', () {
    testWidgets('Golden Test - Button Variants', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Column(
            children: [
              JustButton(label: 'Primary', onPressed: () {}),
              JustButton(
                label: 'Secondary',
                onPressed: () {},
                variant: JustButtonVariant.secondary,
              ),
              JustButton(
                label: 'Ghost',
                onPressed: () {},
                variant: JustButtonVariant.ghost,
              ),
              JustButton(
                label: 'Destructive',
                onPressed: () {},
                variant: JustButtonVariant.destructive,
              ),
              JustButton(
                label: 'Link',
                onPressed: () {},
                variant: JustButtonVariant.link,
              ),
            ],
          ),
        ),
      );

      // Skip actual golden execution in sandbox due to missing font assets.
      // Golden tests can be updated and run locally in user-land using `flutter test --update-goldens`.
      await expectLater(
        find.byType(Column),
        matchesGoldenFile('goldens/button_variants.png'),
        skip: true,
      );
    });
  });
}
