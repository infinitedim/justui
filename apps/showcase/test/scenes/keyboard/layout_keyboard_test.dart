import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// AC12 for the Layout scenes: only the resizable splitter takes focus.
void main() {
  for (final String scene in <String>['separator']) {
    testWidgets('$scene has no tab stops', (WidgetTester tester) async {
      await pumpDefault(tester, scene);
      await expectNoStops(tester);
    });
  }

  testWidgets('resizable: one stop, the arrow keys move the split', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'resizable');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(1));
    // Each label is centered in its pane, so the split moves both.
    final double before = tester.getCenter(find.text('Editor')).dx;
    stops.single.requestFocus();
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(tester.getCenter(find.text('Editor')).dx, greaterThan(before));
  });
}
