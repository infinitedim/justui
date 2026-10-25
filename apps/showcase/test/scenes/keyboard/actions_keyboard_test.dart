import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// AC12 for the Actions scenes: Tab in, Tab out, activate.
void main() {
  testWidgets('button: one stop, Enter activates', (WidgetTester tester) async {
    await pumpDefault(tester, 'button');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(1));
    expect(await activate(tester, stops.single), isTrue);
  });

  testWidgets('icon-button: one stop, Enter activates', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'icon-button');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(1));
    expect(await activate(tester, stops.single), isTrue);
    expect(find.bySemanticsLabel('Add'), findsOneWidget);
  });
}
