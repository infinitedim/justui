import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// AC9 for the Overlays scenes: dialog visits Cancel/Discard and activates;
/// static sheet and toast have no Tab stops; tooltip visits Copy once.
void main() {
  testWidgets(
    'dialog: Tab visits Cancel and Discard buttons, Enter activates',
    (WidgetTester tester) async {
      await pumpDefault(tester, 'dialog');
      final List<FocusNode> stops = await tabStops(tester);
      expect(stops, <FocusNode>[
        nodeOf(tester, find.text('Cancel')),
        nodeOf(tester, find.text('Discard')),
      ]);
      await shiftTab(tester);
      expect(focused, stops.last);
      expect(await activate(tester, stops.first), isTrue);
      expect(await activate(tester, stops.last), isTrue);
    },
  );

  testWidgets('sheet: static surface has no focus stops', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'sheet');
    await expectNoStops(tester);
  });

  testWidgets('toast: static surface has no focus stops', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'toast');
    await expectNoStops(tester);
  });

  testWidgets(
    'tooltip: Tab lands on Copy icon button, Enter activates, no duplicate semantics',
    (WidgetTester tester) async {
      await pumpDefault(tester, 'tooltip');
      final List<FocusNode> stops = await tabStops(tester);
      expect(stops, hasLength(1));
      expect(find.bySemanticsLabel('Copy'), findsOneWidget);
      expect(await activate(tester, stops.single), isTrue);
    },
  );
}
