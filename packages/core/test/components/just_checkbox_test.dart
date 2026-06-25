import 'dart:ui' show CheckedState, Tristate;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(textDirection: .ltr, child: child),
    );
  }

  group('JustCheckbox Tests', () {
    testWidgets('Renders all value states correctly', (
      WidgetTester tester,
    ) async {
      // Checked
      await tester.pumpWidget(
        buildTestableWidget(JustCheckbox(value: true, onChanged: (_) {})),
      );
      expect(find.byType(JustCheckbox), findsOneWidget);

      var semantics = tester
          .getSemantics(find.byType(JustCheckbox))
          .getSemanticsData();
      expect(semantics.flagsCollection.isChecked, CheckedState.isTrue);
      expect(semantics.flagsCollection.isEnabled, Tristate.isTrue);

      // Unchecked
      await tester.pumpWidget(
        buildTestableWidget(JustCheckbox(value: false, onChanged: (_) {})),
      );
      semantics = tester
          .getSemantics(find.byType(JustCheckbox))
          .getSemanticsData();
      expect(semantics.flagsCollection.isChecked, CheckedState.isFalse);
      expect(semantics.flagsCollection.isEnabled, Tristate.isTrue);

      // Indeterminate
      await tester.pumpWidget(
        buildTestableWidget(JustCheckbox(value: null, onChanged: (_) {})),
      );
      semantics = tester
          .getSemantics(find.byType(JustCheckbox))
          .getSemanticsData();
      expect(semantics.flagsCollection.isChecked, CheckedState.mixed);
      expect(semantics.flagsCollection.isEnabled, Tristate.isTrue);
    });

    testWidgets('Triggers onChanged when tapped', (WidgetTester tester) async {
      bool? checkedValue = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustCheckbox(value: false, onChanged: (val) => checkedValue = val),
        ),
      );

      await tester.tap(find.byType(JustCheckbox));
      await tester.pump();
      expect(checkedValue, isTrue);
    });

    testWidgets('Does not trigger onChanged when disabled', (
      WidgetTester tester,
    ) async {
      bool? checkedValue = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustCheckbox(
            value: false,
            onChanged: (val) => checkedValue = val,
            isDisabled: true,
          ),
        ),
      );

      await tester.tap(find.byType(JustCheckbox));
      await tester.pump();
      expect(checkedValue, isFalse);
    });

    testWidgets('Tapping label triggers onChanged', (
      WidgetTester tester,
    ) async {
      bool? checkedValue = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustCheckbox(
            value: false,
            onChanged: (val) => checkedValue = val,
            label: const Text('My Label'),
          ),
        ),
      );

      await tester.tap(find.text('My Label'));
      await tester.pump();
      expect(checkedValue, isTrue);
    });

    testWidgets('Indeterminate value transitions to true when tapped', (
      WidgetTester tester,
    ) async {
      bool? checkedValue = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustCheckbox(value: null, onChanged: (val) => checkedValue = val),
        ),
      );

      await tester.tap(find.byType(JustCheckbox));
      await tester.pump();
      expect(checkedValue, isTrue);
    });

    testWidgets('Supports keyboard navigation (space/enter keys)', (
      WidgetTester tester,
    ) async {
      bool? checkedValue = false;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        buildTestableWidget(
          JustCheckbox(
            value: false,
            onChanged: (val) => checkedValue = val,
            focusNode: focusNode,
          ),
        ),
      );

      // Focus the checkbox
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      // Press Space Key
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(checkedValue, isTrue);

      // Reset
      checkedValue = false;

      // Press Enter Key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(checkedValue, isTrue);

      focusNode.dispose();
    });

    testWidgets('Triggers haptic feedback when selection haptics are enabled', (
      WidgetTester tester,
    ) async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return null;
          });

      await tester.pumpWidget(
        buildTestableWidget(
          JustCheckbox(value: false, onChanged: (_) {}, enableHaptic: true),
        ),
      );

      await tester.tap(find.byType(JustCheckbox));
      await tester.pump();

      expect(
        log.any(
          (c) =>
              c.method == 'HapticFeedback.vibrate' &&
              c.arguments == 'HapticFeedbackType.selectionClick',
        ),
        isTrue,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('Renders correctly under neobrutalism preset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          lightTheme: JustThemeData.neobrutalismLight,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: JustCheckbox(value: true, onChanged: (_) {}),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(JustCheckbox), findsOneWidget);
    });
  });
}
