import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart' show SemanticsData;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

SemanticsData _bold(WidgetTester tester) =>
    tester.getSemantics(find.bySemanticsLabel('Bold')).getSemanticsData();

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

  testWidgets('toggle: one stop, Space flips the pressed state', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpDefault(tester, 'toggle');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(1));
    expect(_bold(tester).flagsCollection.isToggled, Tristate.isTrue);
    await activate(tester, stops.single, LogicalKeyboardKey.space);
    expect(_bold(tester).flagsCollection.isToggled, Tristate.isFalse);
    semantics.dispose();
  });
}
