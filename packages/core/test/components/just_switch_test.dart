import 'dart:ui' show Tristate;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/switch/just_switch.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(textDirection: .ltr, child: child),
    );
  }

  group('JustSwitch Tests', () {
    testWidgets('Renders correct semantics and label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          JustSwitch(
            value: true,
            onChanged: (_) {},
            label: const Text('Enable'),
          ),
        ),
      );

      expect(find.text('Enable'), findsOneWidget);
      final semantics = tester
          .getSemantics(find.byType(JustSwitch))
          .getSemanticsData();
      expect(semantics.flagsCollection.isToggled, Tristate.isTrue);
      expect(semantics.flagsCollection.isEnabled, Tristate.isTrue);
    });

    testWidgets('Triggers onChanged on tap', (WidgetTester tester) async {
      bool value = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustSwitch(value: false, onChanged: (val) => value = val),
        ),
      );

      await tester.tap(find.byType(JustSwitch));
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('Supports keyboard navigation (space/enter keys)', (
      WidgetTester tester,
    ) async {
      bool value = false;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        buildTestableWidget(
          JustSwitch(
            value: false,
            onChanged: (val) => value = val,
            focusNode: focusNode,
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(value, isTrue);

      value = false;

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, isTrue);

      focusNode.dispose();
    });

    testWidgets('Toggles with horizontal drag and snap calculations', (
      WidgetTester tester,
    ) async {
      bool value = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustSwitch(value: false, onChanged: (val) => value = val),
        ),
      );

      final switchFinder = find.byType(JustSwitch);
      final center = tester.getCenter(switchFinder);

      // Drag left to right past 50% threshold to toggle on
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(40.0, 0.0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(value, isTrue);
    });

    testWidgets('Gesture conflict check inside horizontal scrollable (PageView)', (
      WidgetTester tester,
    ) async {
      int pageIndex = 0;
      final pageController = PageController();
      bool switchValue = false;

      await tester.pumpWidget(
        buildTestableWidget(
          PageView(
            controller: pageController,
            onPageChanged: (index) => pageIndex = index,
            children: [
              Container(
                color: const Color(0xFF111111),
                alignment: Alignment.center,
                child: JustSwitch(
                  value: switchValue,
                  onChanged: (val) => switchValue = val,
                ),
              ),
              const Center(child: Text('Page 2')),
            ],
          ),
        ),
      );

      // Verify PageView is initially showing first page
      expect(pageIndex, equals(0));
      expect(find.text('Page 2'), findsNothing);

      // 1. Drag on the switch: should trigger onChanged and NOT scroll the PageView
      final switchFinder = find.byType(JustSwitch);
      final switchCenter = tester.getCenter(switchFinder);

      final gesture = await tester.startGesture(switchCenter);
      // Drag horizontally far enough to trigger snap but PageView should not intercept
      await gesture.moveBy(const Offset(60.0, 0.0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(switchValue, isTrue);
      expect(pageIndex, equals(0));
      expect(find.text('Page 2'), findsNothing);

      // 2. Drag outside the switch: should scroll the PageView to Page 2
      await tester.dragFrom(
        const Offset(20.0, 200.0),
        const Offset(-350.0, 0.0),
      );
      await tester.pumpAndSettle();

      expect(pageIndex, equals(1));
      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('Renders correctly under neobrutalism preset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          lightTheme: JustThemeData.neobrutalismLight,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: JustSwitch(value: true, onChanged: (_) {}),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(JustSwitch), findsOneWidget);
    });
  });
}
