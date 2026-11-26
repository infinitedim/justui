import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// AC12 for the Layout scenes: resizable splitter and scroll-area take focus.
void main() {
  testWidgets('separator has no tab stops', (WidgetTester tester) async {
    await pumpDefault(tester, 'separator');
    await expectNoStops(tester);
  });

  testWidgets('scroll-area: one stop, ArrowDown scrolls and Home resets', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'scroll-area');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(1));

    final ScrollableState scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable),
    );
    expect(scrollable.position.pixels, 0.0);

    stops.single.requestFocus();
    await tester.pump();
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(scrollable.position.pixels, greaterThan(0.0));

    await press(tester, LogicalKeyboardKey.home);
    expect(scrollable.position.pixels, 0.0);
  });

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
