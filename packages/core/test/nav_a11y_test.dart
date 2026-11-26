import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart' show SemanticsNode;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_style.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_variants.dart';
import 'package:just_ui_core/src/components/shared/_shared_focus_indicator.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_style.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_variants.dart';
import 'package:material_ui/material_ui.dart' show Icons, MaterialApp, Scaffold;

Widget _wrapNavTest({
  required Widget child,
  JustThemeData? theme,
  Size? mediaSize,
  bool disableAnimations = false,
}) {
  final Widget body = (mediaSize == null && !disableAnimations)
      ? child
      : Builder(
          builder: (BuildContext context) {
            final MediaQueryData base = MediaQuery.of(context);
            return MediaQuery(
              data: base.copyWith(
                size: mediaSize ?? base.size,
                disableAnimations: disableAnimations,
              ),
              child: child,
            );
          },
        );
  return JustThemeProvider(
    lightTheme: theme ?? .light,
    child: MaterialApp(home: Scaffold(body: body)),
  );
}

Widget _wrapBottomNav(
  JustBottomNav nav, {
  JustThemeData? theme,
  bool disableAnimations = false,
}) => _wrapNavTest(
  theme: theme,
  disableAnimations: disableAnimations,
  child: Align(alignment: .bottomCenter, child: nav),
);

void _expectNeoBorderAndFocus(
  WidgetTester tester,
  BoxDecoration deco,
  JustThemeData neoTheme,
) {
  expect(deco.borderRadius, BorderRadius.zero);
  expect(
    deco.border,
    Border.all(
      color: neoTheme.colors.textPrimary,
      width: neoTheme.presetTokens.borderWidth,
    ),
  );
  final FocusIndicator focus = tester.widget<FocusIndicator>(
    find.byType(FocusIndicator).first,
  );
  expect(focus.borderRadius, BorderRadius.zero);
}

BoxDecoration _firstDeco(
  WidgetTester tester,
  Type ancestorType,
  bool Function(BoxDecoration d) match,
) {
  final Finder finder = find.descendant(
    of: find.byType(ancestorType),
    matching: find.byWidgetPredicate(
      (Widget w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          match(w.decoration! as BoxDecoration),
    ),
  );
  return tester.widget<Container>(finder.first).decoration! as BoxDecoration;
}

const List<JustBottomNavItem> _bottomItems = <JustBottomNavItem>[
  JustBottomNavItem(label: 'Home', icon: Icon(Icons.home)),
  JustBottomNavItem(label: 'Search', icon: Icon(Icons.search)),
  JustBottomNavItem(label: 'Profile', icon: Icon(Icons.person)),
];

const List<JustSidebarItem> _sidebarItems = <JustSidebarItem>[
  JustSidebarItem(label: 'Overview', icon: Icon(Icons.home)),
  JustSidebarItem(
    label: 'Projects',
    icon: Icon(Icons.folder),
    children: <JustSidebarItem>[
      JustSidebarItem(label: 'Alpha', icon: Icon(Icons.article)),
    ],
  ),
  JustSidebarItem(
    label: 'Settings',
    icon: Icon(Icons.settings),
    enabled: false,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JustBottomNav a11y, preset, and motion', () {
    testWidgets('shows FocusIndicator, semanticsLabel, and single item label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrapBottomNav(
          JustBottomNav(
            items: _bottomItems,
            selectedIndex: 0,
            semanticsLabel: 'App navigation',
          ),
        ),
      );

      expect(find.byType(FocusIndicator), findsNWidgets(3));
      expect(
        tester.getSemantics(find.byType(JustBottomNav)).label,
        'App navigation',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final Iterable<FocusIndicator> focused = tester
          .widgetList<FocusIndicator>(find.byType(FocusIndicator))
          .where((FocusIndicator f) => f.isFocused);
      expect(focused, hasLength(1));

      final SemanticsNode homeNode = tester.getSemantics(find.text('Home'));
      expect(homeNode.label, 'Home');
      expect(homeNode.flagsCollection.isButton, isTrue);
      expect(homeNode.flagsCollection.isSelected, Tristate.isTrue);

      final SemanticsNode searchNode = tester.getSemantics(find.text('Search'));
      expect(searchNode.label, 'Search');
      expect(searchNode.flagsCollection.isSelected, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('applies Neobrutalism border/radius and style overrides', (
      WidgetTester tester,
    ) async {
      final JustThemeData neoTheme = .neobrutalismLight;
      const Color indicatorColor = Color(0xFF123456);
      await tester.pumpWidget(
        _wrapBottomNav(
          JustBottomNav(
            items: _bottomItems,
            variant: JustBottomNavVariant.floating,
            style: const JustBottomNavStyle(
              showActiveIndicator: true,
              activeIndicatorColor: indicatorColor,
            ),
          ),
          theme: neoTheme,
        ),
      );

      final BoxDecoration deco = _firstDeco(
        tester,
        JustBottomNav,
        (BoxDecoration d) => d.border != null,
      );
      _expectNeoBorderAndFocus(tester, deco, neoTheme);
      expect(
        find.byWidgetPredicate((Widget w) {
          if (w is! AnimatedContainer || w.decoration is! BoxDecoration) {
            return false;
          }
          final BoxDecoration d = w.decoration! as BoxDecoration;
          return d.color == indicatorColor &&
              w.constraints?.minWidth == 20.0 &&
              w.constraints?.minHeight == 4.0 &&
              d.borderRadius == BorderRadius.zero;
        }),
        findsOneWidget,
      );

      const Color customBorder = Color(0xFF654321);
      await tester.pumpWidget(
        _wrapBottomNav(
          JustBottomNav(
            items: _bottomItems,
            style: const JustBottomNavStyle(borderColor: customBorder),
          ),
        ),
      );
      final BoxDecoration fixedDeco = _firstDeco(
        tester,
        JustBottomNav,
        (BoxDecoration d) => d.border != null,
      );
      expect((fixedDeco.border! as Border).top.color, equals(customBorder));
    });

    testWidgets('honors reduced motion by clamping animation duration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapBottomNav(
          JustBottomNav(
            items: _bottomItems,
            style: const JustBottomNavStyle(
              animationDuration: Duration(milliseconds: 300),
            ),
          ),
          disableAnimations: true,
        ),
      );

      final AnimatedDefaultTextStyle label = tester
          .widget<AnimatedDefaultTextStyle>(
            find
                .descendant(
                  of: find.byType(JustBottomNav),
                  matching: find.byType(AnimatedDefaultTextStyle),
                )
                .first,
          );
      expect(label.duration, equals(Duration.zero));
    });
  });

  group('JustSidebar a11y, preset, layout, and motion', () {
    testWidgets('wraps items and folders with FocusIndicator and Semantics', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrapNavTest(
          child: const JustSidebar(
            items: _sidebarItems,
            selectedIndex: 0,
            semanticsLabel: 'Workspace navigation',
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(JustSidebar)).label,
        'Workspace navigation',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final List<FocusIndicator> indicators = tester
          .widgetList<FocusIndicator>(find.byType(FocusIndicator))
          .toList();
      expect(indicators, hasLength(4));
      expect(indicators.where((FocusIndicator f) => f.isFocused), hasLength(1));

      final SemanticsNode overview = tester.getSemantics(find.text('Overview'));
      expect(overview.label, 'Overview');
      expect(overview.flagsCollection.isButton, isTrue);
      expect(overview.flagsCollection.isSelected, Tristate.isTrue);

      final SemanticsNode projects = tester.getSemantics(find.text('Projects'));
      expect(projects.label, 'Projects');
      expect(projects.flagsCollection.isButton, isTrue);
      expect(projects.flagsCollection.isExpanded, Tristate.isFalse);

      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Projects')).flagsCollection.isExpanded,
        Tristate.isTrue,
      );
      expect(tester.getSemantics(find.text('Alpha')).label, 'Alpha');
      handle.dispose();
    });

    testWidgets('applies Neobrutalism border/radius and selected overrides', (
      WidgetTester tester,
    ) async {
      final JustThemeData neoTheme = .neobrutalismLight;
      await tester.pumpWidget(
        _wrapNavTest(
          theme: neoTheme,
          child: const JustSidebar(
            items: _sidebarItems,
            variant: JustSidebarVariant.floating,
          ),
        ),
      );

      final BoxDecoration panelDeco = _firstDeco(
        tester,
        JustSidebar,
        (BoxDecoration d) => d.boxShadow != null,
      );
      _expectNeoBorderAndFocus(tester, panelDeco, neoTheme);

      const Color customBg = Color(0xFF111111);
      const Color customFg = Color(0xFFFAFAFA);
      const Color customBorder = Color(0xFF444444);
      await tester.pumpWidget(
        _wrapNavTest(
          theme: neoTheme,
          child: const JustSidebar(
            items: _sidebarItems,
            selectedIndex: 0,
            variant: JustSidebarVariant.floating,
            style: JustSidebarStyle(
              borderColor: customBorder,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              selectedBackgroundColor: customBg,
              selectedForegroundColor: customFg,
              itemSpacing: 8.0,
            ),
          ),
        ),
      );

      expect(tester.widget<Text>(find.text('Overview')).style?.color, customFg);
      final BoxDecoration selectedDeco = _firstDeco(
        tester,
        JustSidebar,
        (BoxDecoration d) => d.color == customBg,
      );
      expect(selectedDeco.color, customBg);
      expect(
        find.byWidgetPredicate((Widget w) => w is SizedBox && w.height == 8.0),
        findsWidgets,
      );
    });

    testWidgets('respects autoCollapse at 320px and unbounded height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapNavTest(
          mediaSize: const Size(320.0, 600.0),
          child: const JustSidebar(items: _sidebarItems),
        ),
      );
      expect(find.text('Overview'), findsNothing);
      expect(tester.getSize(find.byType(JustSidebar)).width, 68.0);

      await tester.pumpWidget(
        _wrapNavTest(
          mediaSize: const Size(320.0, 600.0),
          child: const JustSidebar(items: _sidebarItems, autoCollapse: false),
        ),
      );
      expect(find.text('Overview'), findsOneWidget);
      expect(tester.getSize(find.byType(JustSidebar)).width, 260.0);

      await tester.pumpWidget(
        _wrapNavTest(
          child: const SingleChildScrollView(
            child: JustSidebar(
              items: _sidebarItems,
              header: Text('Header'),
              footer: Text('Footer'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('honors reduced motion for collapse and folder expand', (
      WidgetTester tester,
    ) async {
      bool collapsed = false;
      late StateSetter outerSetState;
      await tester.pumpWidget(
        _wrapNavTest(
          disableAnimations: true,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              outerSetState = setState;
              return JustSidebar(items: _sidebarItems, isCollapsed: collapsed);
            },
          ),
        ),
      );

      await tester.tap(find.text('Projects'));
      await tester.pump();
      expect(
        tester
            .widget<SizeTransition>(find.byType(SizeTransition))
            .sizeFactor
            .value,
        1.0,
      );

      outerSetState(() => collapsed = true);
      await tester.pump();
      expect(tester.getSize(find.byType(JustSidebar)).width, 68.0);
    });
  });
}
