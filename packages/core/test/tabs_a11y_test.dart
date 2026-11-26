import 'dart:ui' show SemanticsFlags, Tristate;

import 'package:flutter/semantics.dart' show SemanticsNode, SemanticsRole;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/shared/_shared_focus_indicator.dart';
import 'package:just_ui_core/src/components/tabs/just_tab_indicator.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs_style.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;

const List<JustTab> _sampleTabs = <JustTab>[
  JustTab(label: 'Account', content: Text('Account body')),
  JustTab(label: 'Billing', content: Text('Billing body')),
  JustTab(label: 'Team', content: Text('Team body')),
];

Widget _wrapTabs(
  Widget child, {
  JustThemeData? theme,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    home: JustThemeProvider(
      lightTheme: theme ?? JustThemeData.light,
      darkTheme: theme ?? JustThemeData.dark,
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          body: SizedBox(width: 400.0, height: 300.0, child: child),
        ),
      ),
    ),
  );
}

Future<List<FocusNode>> _collectTabStops(WidgetTester tester) async {
  final List<FocusNode> seen = <FocusNode>[];
  for (int i = 0; i < 12; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final FocusNode? node = FocusManager.instance.primaryFocus;
    if (node == null || seen.contains(node)) break;
    if (node is! FocusScopeNode) seen.add(node);
  }
  return seen;
}

List<SemanticsNode> _collectSemanticsNodes(SemanticsNode root) {
  final List<SemanticsNode> nodes = <SemanticsNode>[root];
  root.visitChildren((SemanticsNode child) {
    nodes.addAll(_collectSemanticsNodes(child));
    return true;
  });
  return nodes;
}

BoxDecoration _indicatorDecoration(WidgetTester tester) =>
    tester
            .widget<Container>(
              find.descendant(
                of: find.byType(JustTabIndicator),
                matching: find.byType(Container),
              ),
            )
            .decoration!
        as BoxDecoration;

BoxDecoration _outerBarDecoration(WidgetTester tester) =>
    tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(JustTabs),
                matching: find.byType(Container),
              ),
            )
            .firstWhere((Container c) => c.decoration is BoxDecoration)
            .decoration!
        as BoxDecoration;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JustTabs accessibility, keyboard roving tabindex, and styling', () {
    testWidgets(
      'removes outer KeyboardListener stop and enforces roving tabindex (1 Tab stop)',
      (WidgetTester tester) async {
        await tester.pumpWidget(_wrapTabs(const JustTabs(tabs: _sampleTabs)));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(JustTabs),
            matching: find.byType(KeyboardListener),
          ),
          findsNothing,
        );
        expect(await _collectTabStops(tester), hasLength(1));

        await tester.tap(find.text('Billing').last);
        await tester.pumpAndSettle();
        expect(await _collectTabStops(tester), hasLength(1));

        await tester.pumpWidget(
          _wrapTabs(
            const JustTabs.pill(
              tabs: <JustTab>[
                ..._sampleTabs,
                JustTab(label: 'Audit', content: Text('Audit body')),
              ],
              showContent: false,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(await _collectTabStops(tester), hasLength(1));
      },
    );

    testWidgets(
      'arrow keys, KeyRepeatEvent, Home, and End move focus and selection while skipping disabled tabs',
      (WidgetTester tester) async {
        int activeIndex = 0;
        const List<JustTab> tabs = <JustTab>[
          JustTab(label: 'First', content: Text('Body 1')),
          JustTab(label: 'Disabled', content: Text('Body 2'), enabled: false),
          JustTab(label: 'Third', content: Text('Body 3')),
          JustTab(label: 'Fourth', content: Text('Body 4')),
        ];

        await tester.pumpWidget(
          _wrapTabs(
            JustTabs(tabs: tabs, onChanged: (int i) => activeIndex = i),
          ),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        final FocusNode? firstNode = FocusManager.instance.primaryFocus;
        expect(firstNode, isNotNull);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(activeIndex, equals(2));
        expect(FocusManager.instance.primaryFocus, isNot(equals(firstNode)));
        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(activeIndex, equals(0));
        expect(FocusManager.instance.primaryFocus, equals(firstNode));
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        expect(activeIndex, equals(3));
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pumpAndSettle();
        expect(activeIndex, equals(0));
      },
    );

    testWidgets(
      'supports ArrowDown, ArrowUp, Space, and Enter on vertical tabs',
      (WidgetTester tester) async {
        int activeIndex = 0;
        int changeCount = 0;
        const List<JustTab> tabs = <JustTab>[
          JustTab(label: 'One', content: Text('One')),
          JustTab(label: 'Skipped', content: Text('Skipped'), enabled: false),
          JustTab(label: 'Three', content: Text('Three')),
        ];

        await tester.pumpWidget(
          _wrapTabs(
            JustTabs.vertical(
              tabs: tabs,
              showContent: false,
              onChanged: (int i) {
                activeIndex = i;
                changeCount++;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        final FocusNode? firstFocus = FocusManager.instance.primaryFocus;

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(activeIndex, equals(2));
        expect(FocusManager.instance.primaryFocus, isNot(equals(firstFocus)));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(activeIndex, equals(0));
        expect(FocusManager.instance.primaryFocus, equals(firstFocus));

        final int beforeActivate = changeCount;
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(changeCount, equals(beforeActivate + 2));
      },
    );

    testWidgets('shows visible FocusIndicator on keyboard focus', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapTabs(const JustTabs(tabs: _sampleTabs, showContent: false)),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final Iterable<FocusIndicator> indicators = tester
          .widgetList<FocusIndicator>(
            find.descendant(
              of: find.byType(JustTabs),
              matching: find.byType(FocusIndicator),
            ),
          );
      expect(indicators, hasLength(3));
      expect(indicators.where((FocusIndicator f) => f.isFocused), hasLength(1));
    });

    testWidgets(
      'exposes SemanticsRole.tabBar with semanticsLabel and SemanticsRole.tab without button flag',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        const List<JustTab> tabs = <JustTab>[
          JustTab(label: 'Overview', content: Text('Overview body')),
          JustTab(
            label: 'Locked',
            content: Text('Locked body'),
            enabled: false,
          ),
        ];

        await tester.pumpWidget(
          _wrapTabs(
            const JustTabs.line(
              tabs: tabs,
              semanticsLabel: 'Settings sections',
              showContent: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final SemanticsNode tabBarNode = tester.getSemantics(
          find.byType(JustTabs),
        );
        expect(
          tabBarNode.getSemanticsData().role,
          equals(SemanticsRole.tabBar),
        );
        expect(tabBarNode.label, equals('Settings sections'));

        final List<SemanticsNode> tabNodes = _collectSemanticsNodes(tabBarNode)
            .where(
              (SemanticsNode n) =>
                  n.getSemanticsData().role == SemanticsRole.tab,
            )
            .toList();
        expect(tabNodes, hasLength(2));
        final SemanticsFlags firstFlags = tabNodes[0]
            .getSemanticsData()
            .flagsCollection;
        final SemanticsFlags secondFlags = tabNodes[1]
            .getSemanticsData()
            .flagsCollection;
        expect(tabNodes[0].label, equals('Overview'));
        expect(firstFlags.isButton, isFalse);
        expect(firstFlags.isSelected, equals(Tristate.isTrue));
        expect(firstFlags.isEnabled, equals(Tristate.isTrue));
        expect(tabNodes[1].label, equals('Locked'));
        expect(secondFlags.isSelected, equals(Tristate.isFalse));
        expect(secondFlags.isEnabled, equals(Tristate.isFalse));
        handle.dispose();
      },
    );

    testWidgets(
      'showContent: false lays out safely in unbounded height and applies borderBottom style',
      (WidgetTester tester) async {
        const Color hairlineColor = Color(0xFF334455);
        await tester.pumpWidget(
          MaterialApp(
            home: JustThemeProvider(
              lightTheme: JustThemeData.light,
              child: const Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: .min,
                    children: <Widget>[
                      JustTabs.line(
                        tabs: _sampleTabs,
                        showContent: false,
                        style: JustTabsStyle(
                          borderBottomColor: hairlineColor,
                          borderBottomWidth: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PageView), findsNothing);
        expect(find.text('Account body'), findsNothing);
        expect(tester.takeException(), isNull);
        final BoxDecoration deco = _outerBarDecoration(tester);
        expect(
          deco.border,
          equals(
            const Border(bottom: BorderSide(color: hairlineColor, width: 2.0)),
          ),
        );
        expect(deco.borderRadius, isNull);
      },
    );

    testWidgets(
      'uses presetTokens sharp radii and borders across variants in neobrutalism',
      (WidgetTester tester) async {
        final JustThemeData neoTheme = JustThemeData.neobrutalismLight;
        const List<Widget> sharpVariants = <Widget>[
          JustTabs.enclosed(tabs: _sampleTabs, showContent: false),
          JustTabs.line(tabs: _sampleTabs, showContent: false),
          JustTabs.vertical(tabs: _sampleTabs, showContent: false),
        ];

        for (final Widget variant in sharpVariants) {
          await tester.pumpWidget(_wrapTabs(variant, theme: neoTheme));
          await tester.pumpAndSettle();
          expect(_indicatorDecoration(tester).borderRadius, BorderRadius.zero);
          if (variant is JustTabs && variant.variant == .enclosed) {
            expect(_outerBarDecoration(tester).borderRadius, BorderRadius.zero);
          }
        }

        await tester.pumpWidget(
          _wrapTabs(
            const JustTabs.pill(tabs: _sampleTabs, showContent: false),
            theme: neoTheme,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          _indicatorDecoration(tester).borderRadius,
          BorderRadius.all(neoTheme.radius.full),
        );
      },
    );

    testWidgets(
      'respects reduced motion via animations.resolve(context) without animating',
      (WidgetTester tester) async {
        final JustTabController controller = JustTabController(length: 2);
        const List<JustTab> tabs = <JustTab>[
          JustTab(label: 'First', content: Text('Page 1')),
          JustTab(label: 'Second', content: Text('Page 2')),
        ];

        await tester.pumpWidget(
          _wrapTabs(
            JustTabs(tabs: tabs, controller: controller),
            disableAnimations: true,
          ),
        );
        await tester.pump();

        controller.index = 1;
        await tester.pump();
        expect(find.text('Page 2'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('First').last);
        await tester.pump();
        expect(find.text('Page 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
        controller.dispose();
      },
    );
  });
}
