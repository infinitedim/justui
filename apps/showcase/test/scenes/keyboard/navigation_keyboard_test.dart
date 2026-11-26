// ignore_for_file: implementation_imports
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// AC12 for the Navigation scenes: Tab in, through and out, and keyboard
/// activation for tabs, bottom-nav and sidebar.
void main() {
  testWidgets('breadcrumb: plain text, no stop', (WidgetTester tester) async {
    await pumpDefault(tester, 'breadcrumb');
    await expectNoStops(tester);
  });

  testWidgets('tabs: one roving stop, ArrowRight/End/Home switch active tab', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'tabs');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(1));

    final JustTabs tabsWidget = tester.widget<JustTabs>(find.byType(JustTabs));
    final JustTabController controller = tabsWidget.controller!;
    expect(controller.index, 0);

    stops.single.requestFocus();
    await tester.pump();
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(controller.index, 1);
    expect(focused, nodeOf(tester, find.text('Billing').first));

    await press(tester, LogicalKeyboardKey.end);
    expect(controller.index, 2);
    expect(focused, nodeOf(tester, find.text('Team').first));

    await press(tester, LogicalKeyboardKey.home);
    expect(controller.index, 0);
    expect(focused, nodeOf(tester, find.text('Account').first));
  });

  testWidgets('bottom-nav: 3 stops, Tab/Shift+Tab, Enter activates Search', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'bottom-nav');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(3));
    await shiftTab(tester);
    expect(focused, stops.last);

    await activate(tester, stops[1], LogicalKeyboardKey.enter);
    final JustBottomNav nav = tester.widget<JustBottomNav>(
      find.byType(JustBottomNav),
    );
    expect(nav.selectedIndex, 1);

    await activate(tester, stops[2], LogicalKeyboardKey.space);
    final JustBottomNav navAfterSpace = tester.widget<JustBottomNav>(
      find.byType(JustBottomNav),
    );
    expect(navAfterSpace.selectedIndex, 2);
  });

  testWidgets('sidebar: 3 stops, Tab/Shift+Tab, Enter activates Settings', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'sidebar');
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(3));
    await shiftTab(tester);
    expect(focused, stops.last);

    await activate(tester, stops[2], LogicalKeyboardKey.enter);
    final JustSidebar sidebar = tester.widget<JustSidebar>(
      find.byType(JustSidebar),
    );
    expect(sidebar.selectedIndex, 2);

    await activate(tester, stops[0], LogicalKeyboardKey.space);
    final JustSidebar sidebarAfterSpace = tester.widget<JustSidebar>(
      find.byType(JustSidebar),
    );
    expect(sidebarAfterSpace.selectedIndex, 0);
  });
}
