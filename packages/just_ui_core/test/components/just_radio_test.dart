import 'dart:ui' show CheckedState;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';

enum TestEnum { optionA, optionB, optionC }

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );
  }

  group('JustRadio and JustRadioGroup Tests', () {
    testWidgets('Group selection works with enum types', (
      WidgetTester tester,
    ) async {
      TestEnum? selectedValue = TestEnum.optionA;

      await tester.pumpWidget(
        buildTestableWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return JustRadioGroup<TestEnum>(
                value: selectedValue,
                onChanged: (val) => setState(() => selectedValue = val),
                options: const [
                  JustRadioOption(value: TestEnum.optionA, label: Text('A')),
                  JustRadioOption(value: TestEnum.optionB, label: Text('B')),
                  JustRadioOption(value: TestEnum.optionC, label: Text('C')),
                ],
              );
            },
          ),
        ),
      );

      // Verify initial selected state semantics
      var semanticsA = tester
          .getSemantics(
            find.byWidgetPredicate(
              (w) => w is JustRadio<TestEnum> && w.value == TestEnum.optionA,
            ),
          )
          .getSemanticsData();
      expect(semanticsA.flagsCollection.isChecked, CheckedState.isTrue);
      expect(semanticsA.flagsCollection.isInMutuallyExclusiveGroup, isTrue);

      var semanticsB = tester
          .getSemantics(
            find.byWidgetPredicate(
              (w) => w is JustRadio<TestEnum> && w.value == TestEnum.optionB,
            ),
          )
          .getSemanticsData();
      expect(semanticsB.flagsCollection.isChecked, CheckedState.isFalse);
      expect(semanticsB.flagsCollection.isInMutuallyExclusiveGroup, isTrue);

      // Select Option B by tapping label text
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(selectedValue, equals(TestEnum.optionB));

      semanticsB = tester
          .getSemantics(
            find.byWidgetPredicate(
              (w) => w is JustRadio<TestEnum> && w.value == TestEnum.optionB,
            ),
          )
          .getSemanticsData();
      expect(semanticsB.flagsCollection.isChecked, CheckedState.isTrue);

      semanticsA = tester
          .getSemantics(
            find.byWidgetPredicate(
              (w) => w is JustRadio<TestEnum> && w.value == TestEnum.optionA,
            ),
          )
          .getSemanticsData();
      expect(semanticsA.flagsCollection.isChecked, CheckedState.isFalse);
    });

    testWidgets('Group selection works with integer types', (
      WidgetTester tester,
    ) async {
      int? selectedValue = 1;

      await tester.pumpWidget(
        buildTestableWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return JustRadioGroup<int>(
                value: selectedValue,
                onChanged: (val) => setState(() => selectedValue = val),
                options: const [
                  JustRadioOption(value: 1, label: Text('One')),
                  JustRadioOption(value: 2, label: Text('Two')),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(selectedValue, equals(2));
    });

    testWidgets('Disabled option does not respond to tap', (
      WidgetTester tester,
    ) async {
      int? selectedValue = 1;

      await tester.pumpWidget(
        buildTestableWidget(
          JustRadioGroup<int>(
            value: selectedValue,
            onChanged: (val) => selectedValue = val,
            options: const [
              JustRadioOption(value: 1, label: Text('One')),
              JustRadioOption(value: 2, label: Text('Two'), isDisabled: true),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Two'));
      await tester.pump();

      expect(selectedValue, equals(1));
    });

    testWidgets('Supports keyboard selection (space/enter keys)', (
      WidgetTester tester,
    ) async {
      int? selectedValue = 1;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        buildTestableWidget(
          JustRadio<int>(
            value: 2,
            groupValue: selectedValue,
            onChanged: (val) => selectedValue = val,
            label: const Text('Two'),
            focusNode: focusNode,
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(selectedValue, equals(2));

      selectedValue = 1; // Reset

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selectedValue, equals(2));

      focusNode.dispose();
    });
  });
}
