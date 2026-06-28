import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/badge/just_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(textDirection: .ltr, child: child),
    );
  }

  group('JustBadge Tests', () {
    testWidgets('Renders label', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const JustBadge(label: 'Active')),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('Renders dot variant without label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const JustBadge.dot()));

      expect(find.byType(JustBadge), findsOneWidget);
      expect(find.text('Active'), findsNothing);
    });

    testWidgets('Triggers onDismiss callback', (WidgetTester tester) async {
      bool dismissed = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustBadge(label: 'Tag', onDismiss: () => dismissed = true),
        ),
      );

      final dismissButton = find.text('✕');
      expect(dismissButton, findsOneWidget);
      await tester.tap(dismissButton);
      expect(dismissed, isTrue);
    });

    testWidgets('Truncates text based on maxWidth constraint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustBadge(
            label: 'Extremely long badge tag label',
            maxWidth: 50.0,
          ),
        ),
      );

      final constrainedBoxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox && widget.constraints.maxWidth == 50.0,
      );
      expect(constrainedBoxFinder, findsOneWidget);
      final ConstrainedBox box = tester.widget<ConstrainedBox>(
        constrainedBoxFinder,
      );
      expect(box.constraints.maxWidth, equals(50.0));
    });

    testWidgets('Positions badge overlay correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          JustBadge.overlay(
            child: const SizedBox(width: 100, height: 100),
            badge: const JustBadge.dot(),
          ),
        ),
      );

      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('Renders pulsing dot animation widget when pulse is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const JustBadge.dot(pulse: true)),
      );

      final pulsingDotFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustPulsingDot',
      );
      expect(pulsingDotFinder, findsOneWidget);
    });

    testWidgets('Does not render pulsing dot when pulse is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const JustBadge.dot(pulse: false)),
      );

      final pulsingDotFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_JustPulsingDot',
      );
      expect(pulsingDotFinder, findsNothing);
    });

    testWidgets('Renders correctly under neobrutalism preset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          lightTheme: JustThemeData.neobrutalismLight,
          child: const Directionality(
            textDirection: .ltr,
            child: JustBadge(label: 'Neobrutalist Badge'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Neobrutalist Badge'), findsOneWidget);
    });
  });
}
