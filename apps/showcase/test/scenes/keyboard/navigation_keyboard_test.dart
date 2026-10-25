import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// Whether the item labelled [label] reports the selected state.
bool _selected(WidgetTester tester, String label) => tester
    .getSemantics(find.bySemanticsLabel(RegExp('^$label')))
    .getSemanticsData()
    .flagsCollection
    .isSelected
    .toBoolOrNull()!;

/// Core's sidebar has no selected semantics; its current item is bold.
FontWeight? _weight(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style?.fontWeight;

/// AC12 for the Navigation scenes: Tab in, Tab out, activate.
void main() {
  testWidgets('breadcrumb: plain text, no stop', (WidgetTester tester) async {
    await pumpDefault(tester, 'breadcrumb');
    await expectNoStops(tester);
  });

  testWidgets('tabs: Tab reaches each tab, Enter selects it', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpDefault(tester, 'tabs');
    final List<FocusNode> stops = await tabStops(tester);
    // Core's key listener is a stop of its own before the three tabs.
    expect(stops, hasLength(4));
    expect(_selected(tester, 'Account'), isTrue);
    await activate(tester, stops[2]);
    expect(_selected(tester, 'Billing'), isTrue);
    expect(_selected(tester, 'Account'), isFalse);
    semantics.dispose();
  });

  testWidgets('bottom-nav: one stop per item, Enter moves current', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpDefault(tester, 'bottom-nav');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(3));
    expect(_selected(tester, 'Home'), isTrue);
    await activate(tester, stops[1]);
    expect(_selected(tester, 'Search'), isTrue);
    expect(_selected(tester, 'Home'), isFalse);
    semantics.dispose();
  });

  testWidgets('sidebar: one stop per item, Enter moves current', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'sidebar');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(3));
    expect(_weight(tester, 'Components'), FontWeight.w600);
    await activate(tester, stops.first);
    expect(_weight(tester, 'Overview'), FontWeight.w600);
    expect(_weight(tester, 'Components'), isNot(FontWeight.w600));
  });
}
