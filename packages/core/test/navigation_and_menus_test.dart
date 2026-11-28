import 'dart:async' show unawaited;

import 'package:material_ui/material_ui.dart'
    show Colors, Icons, MaterialApp, Scaffold, ThemeData, ThemeExtension;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/accordion/just_accordion.dart';
import 'package:just_ui_core/src/components/accordion/just_accordion_style.dart';
import 'package:just_ui_core/src/components/accordion/just_accordion_theme.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_style.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_theme.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_variants.dart';
import 'package:just_ui_core/src/components/breadcrumb/just_breadcrumb.dart';
import 'package:just_ui_core/src/components/breadcrumb/just_breadcrumb_style.dart';
import 'package:just_ui_core/src/components/breadcrumb/just_breadcrumb_theme.dart';
import 'package:just_ui_core/src/components/radio/just_radio.dart';
import 'package:just_ui_core/src/components/radio/just_radio_group.dart';
import 'package:just_ui_core/src/components/radio/just_radio_style.dart';
import 'package:just_ui_core/src/components/radio/just_radio_theme.dart';
import 'package:just_ui_core/src/components/sheet/just_sheet.dart';
import 'package:just_ui_core/src/components/sheet/just_sheet_style.dart';
import 'package:just_ui_core/src/components/sheet/just_sheet_theme.dart';
import 'package:just_ui_core/src/components/sheet/just_sheet_variants.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_style.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_theme.dart';
import 'package:just_ui_core/src/components/table/just_table.dart';
import 'package:just_ui_core/src/components/table/just_table_style.dart';
import 'package:just_ui_core/src/components/table/just_table_theme.dart';
import 'package:just_ui_core/src/components/table/just_table_variants.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs_style.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs_theme.dart';
import 'package:just_ui_core/src/components/toast/just_toast.dart';
import 'package:just_ui_core/src/components/toast/just_toast_style.dart';
import 'package:just_ui_core/src/components/toast/just_toast_theme.dart';
import 'package:just_ui_core/src/components/toast/just_toast_variants.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_group.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_style.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_theme.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_variants.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip_style.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip_theme.dart';

Widget _buildNavWrapper({
  required Widget child,
  JustThemeData? theme,
  JustTabsTheme? tabsTheme,
  JustSidebarTheme? sidebarTheme,
  JustBottomNavTheme? bottomNavTheme,
  JustBreadcrumbTheme? breadcrumbTheme,
  JustSheetTheme? sheetTheme,
  JustToastTheme? toastTheme,
  JustTooltipTheme? tooltipTheme,
  JustAccordionTheme? accordionTheme,
  JustRadioTheme? radioTheme,
  JustTableTheme? tableTheme,
  JustToggleTheme? toggleTheme,
}) {
  final JustThemeData activeTheme = theme ?? .light;
  return JustThemeProvider(
    lightTheme: activeTheme,
    child: MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          ?tabsTheme,
          ?sidebarTheme,
          ?bottomNavTheme,
          ?breadcrumbTheme,
          ?sheetTheme,
          ?toastTheme,
          ?tooltipTheme,
          ?accordionTheme,
          ?radioTheme,
          ?tableTheme,
          ?toggleTheme,
        ],
      ),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // --- 1. JustTabs Tests ---
  // =========================================================================
  group('JustTabs Widget & Theme Tests', () {
    test('JustTabController lifecycle and index management', () {
      final JustTabController controller = JustTabController(
        length: 3,
        initialIndex: 1,
      );
      expect(controller.length, equals(3));
      expect(controller.index, equals(1));
      expect(controller.animationValue, equals(1.0));

      int notified = 0;
      controller.addListener(() => notified++);

      controller.index = 2;
      expect(controller.index, equals(2));
      expect(notified, equals(1));

      controller.updateAnimationValue(0.2);
      expect(controller.index, equals(0));
      expect(controller.animationValue, equals(0.2));

      controller.animateTo(1);
      expect(controller.index, equals(1));

      final JustTabController emptyController = JustTabController(length: 0);
      expect(emptyController.index, equals(0));
      emptyController.index = 0;
      emptyController.animateTo(0);
      emptyController.updateAnimationValue(0);
    });

    testWidgets('Renders tabs variants and handles tab switching', (
      WidgetTester tester,
    ) async {
      int activeIndex = 0;
      final List<JustTab> tabs = <JustTab>[
        const JustTab(label: 'Tab 1', content: Text('Content 1')),
        const JustTab(label: 'Tab 2', content: Text('Content 2')),
        const JustTab(
          label: 'Tab 3',
          content: Text('Content 3'),
          enabled: false,
        ),
      ];

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: <Widget>[
              Expanded(
                child: JustTabs(
                  tabs: tabs,
                  onChanged: (int idx) => activeIndex = idx,
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Tab 1'), findsWidgets);
      expect(find.text('Content 1'), findsOneWidget);

      await tester.tap(find.text('Tab 2').last);
      await tester.pumpAndSettle();
      expect(activeIndex, equals(1));
      expect(find.text('Content 2'), findsOneWidget);

      // Tapping disabled tab 3 does nothing
      await tester.tap(find.text('Tab 3').last, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(activeIndex, equals(1));
    });

    testWidgets('Renders all tab constructor variants', (
      WidgetTester tester,
    ) async {
      final List<JustTab> tabs = <JustTab>[
        const JustTab(label: 'A', content: Text('Page A')),
        const JustTab(label: 'B', content: Text('Page B')),
      ];

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: <Widget>[Expanded(child: JustTabs.line(tabs: tabs))],
          ),
        ),
      );

      expect(find.text('Page A'), findsOneWidget);

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: <Widget>[Expanded(child: JustTabs.enclosed(tabs: tabs))],
          ),
        ),
      );

      expect(find.text('Page A'), findsOneWidget);

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: <Widget>[Expanded(child: JustTabs.pill(tabs: tabs))],
          ),
        ),
      );

      expect(find.text('Page A'), findsOneWidget);

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: <Widget>[Expanded(child: JustTabs.vertical(tabs: tabs))],
          ),
        ),
      );

      expect(find.text('Page A'), findsOneWidget);
    });

    test('JustTabsTheme copyWith and lerp', () {
      const JustTabsTheme theme1 = JustTabsTheme(
        lineStyle: JustTabsStyle(activeColor: Colors.blue),
      );
      const JustTabsTheme theme2 = JustTabsTheme(
        lineStyle: JustTabsStyle(activeColor: Colors.red),
      );

      final JustTabsTheme copied = theme1.copyWith(
        pillStyle: const JustTabsStyle(activeColor: Colors.green),
      );
      expect(copied.lineStyle?.activeColor, equals(Colors.blue));
      expect(copied.pillStyle?.activeColor, equals(Colors.green));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustTabsTheme.defaults.lineStyle, isNull);
    });
  });

  // =========================================================================
  // --- 2. JustSidebar Tests ---
  // =========================================================================
  group('JustSidebar Widget & Theme Tests', () {
    testWidgets(
      'Renders sidebar navigation items and handles selection and collapse',
      (WidgetTester tester) async {
        int selectedIdx = 0;
        bool collapsed = false;

        final List<JustSidebarItem> items = <JustSidebarItem>[
          const JustSidebarItem(label: 'Home', icon: Icon(Icons.home)),
          const JustSidebarItem(
            label: 'Projects',
            icon: Icon(Icons.folder),
            children: <JustSidebarItem>[
              JustSidebarItem(label: 'Project 1', icon: Icon(Icons.file_copy)),
            ],
          ),
          const JustSidebarItem(label: 'Settings', icon: Icon(Icons.settings)),
        ];

        await tester.pumpWidget(
          _buildNavWrapper(
            child: JustSidebar(
              items: items,
              header: const Text('Sidebar Header'),
              footer: const Text('Sidebar Footer'),
              selectedIndex: selectedIdx,
              onItemSelected: (int idx) => selectedIdx = idx,
              isCollapsed: collapsed,
              onCollapsedChanged: (bool val) => collapsed = val,
            ),
          ),
        );

        expect(find.text('Sidebar Header'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Projects'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Sidebar Footer'), findsOneWidget);

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(selectedIdx, equals(2));

        // Expand sub-menu
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();
        expect(find.text('Project 1'), findsOneWidget);
      },
    );

    test('JustSidebarTheme copyWith and lerp', () {
      const JustSidebarTheme theme1 = JustSidebarTheme(
        defaultStyle: JustSidebarStyle(backgroundColor: Colors.white),
      );
      const JustSidebarTheme theme2 = JustSidebarTheme(
        defaultStyle: JustSidebarStyle(backgroundColor: Colors.black),
      );

      final JustSidebarTheme copied = theme1.copyWith(
        floatingStyle: const JustSidebarStyle(backgroundColor: Colors.grey),
      );
      expect(copied.defaultStyle?.backgroundColor, equals(Colors.white));
      expect(copied.floatingStyle?.backgroundColor, equals(Colors.grey));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustSidebarTheme.defaults.defaultStyle, isNull);
    });
  });

  // =========================================================================
  // --- 3. JustBottomNav Tests ---
  // =========================================================================
  group('JustBottomNav Widget & Theme Tests', () {
    testWidgets(
      'Renders bottom navigation destinations and handles selection',
      (WidgetTester tester) async {
        int selectedIdx = 0;
        const List<JustBottomNavItem> items = <JustBottomNavItem>[
          JustBottomNavItem(label: 'Home', icon: Icon(Icons.home)),
          JustBottomNavItem(label: 'Search', icon: Icon(Icons.search)),
          JustBottomNavItem(label: 'Profile', icon: Icon(Icons.person)),
        ];

        await tester.pumpWidget(
          _buildNavWrapper(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: JustBottomNav(
                items: items,
                selectedIndex: selectedIdx,
                onItemSelected: (int idx) => selectedIdx = idx,
                variant: JustBottomNavVariant.fixed,
              ),
            ),
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);

        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();
        expect(selectedIdx, equals(1));
      },
    );

    test('JustBottomNavTheme copyWith and lerp', () {
      const JustBottomNavTheme theme1 = JustBottomNavTheme(
        fixedStyle: JustBottomNavStyle(backgroundColor: Colors.white),
      );
      const JustBottomNavTheme theme2 = JustBottomNavTheme(
        fixedStyle: JustBottomNavStyle(backgroundColor: Colors.black),
      );

      final JustBottomNavTheme copied = theme1.copyWith(
        floatingStyle: const JustBottomNavStyle(backgroundColor: Colors.blue),
      );
      expect(copied.fixedStyle?.backgroundColor, equals(Colors.white));
      expect(copied.floatingStyle?.backgroundColor, equals(Colors.blue));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustBottomNavTheme.defaults.fixedStyle, isNull);
    });
  });

  // =========================================================================
  // --- 4. JustBreadcrumb Tests ---
  // =========================================================================
  group('JustBreadcrumb Widget & Theme Tests', () {
    testWidgets(
      'Renders breadcrumb trail and handles clicks and auto-collapsing',
      (WidgetTester tester) async {
        int tappedIndex = -1;
        final List<JustBreadcrumbItem> items = <JustBreadcrumbItem>[
          JustBreadcrumbItem(label: 'Home', onTap: () => tappedIndex = 0),
          JustBreadcrumbItem(label: 'Category', onTap: () => tappedIndex = 1),
          JustBreadcrumbItem(
            label: 'Subcategory',
            onTap: () => tappedIndex = 2,
          ),
          const JustBreadcrumbItem(label: 'Current Page'),
        ];

        await tester.pumpWidget(
          _buildNavWrapper(
            child: Column(
              children: <Widget>[
                const JustBreadcrumb(items: <JustBreadcrumbItem>[]),
                JustBreadcrumb(items: items),
                JustBreadcrumb(items: items, maxItems: 3),
              ],
            ),
          ),
        );

        expect(find.text('Home'), findsWidgets);
        expect(find.text('Current Page'), findsWidgets);

        await tester.tap(find.text('Home').first);
        await tester.pumpAndSettle();
        expect(tappedIndex, equals(0));

        expect(find.text('...'), findsOneWidget);
      },
    );

    testWidgets(
      'JustBreadcrumbTheme applies default style and instance style overrides it',
      (WidgetTester tester) async {
        const Color themeColor = Color(0xFF112233);
        const Color instanceColor = Color(0xFFAABBCC);

        await tester.pumpWidget(
          _buildNavWrapper(
            breadcrumbTheme: const JustBreadcrumbTheme(
              style: JustBreadcrumbStyle(color: themeColor),
            ),
            child: Column(
              children: <Widget>[
                JustBreadcrumb(
                  items: <JustBreadcrumbItem>[
                    JustBreadcrumbItem(label: 'Home', onTap: () {}),
                    const JustBreadcrumbItem(label: 'Current'),
                  ],
                ),
                JustBreadcrumb(
                  style: const JustBreadcrumbStyle(color: instanceColor),
                  items: <JustBreadcrumbItem>[
                    JustBreadcrumbItem(label: 'Docs', onTap: () {}),
                    const JustBreadcrumbItem(label: 'Override'),
                  ],
                ),
              ],
            ),
          ),
        );

        final Text homeText = tester.widget<Text>(find.text('Home'));
        expect(homeText.style?.color, equals(themeColor));

        final Text docsText = tester.widget<Text>(find.text('Docs'));
        expect(docsText.style?.color, equals(instanceColor));
      },
    );

    test('JustBreadcrumbTheme copyWith and lerp', () {
      const JustBreadcrumbTheme theme1 = JustBreadcrumbTheme(
        style: JustBreadcrumbStyle(activeColor: Colors.blue),
      );
      const JustBreadcrumbTheme theme2 = JustBreadcrumbTheme(
        style: JustBreadcrumbStyle(activeColor: Colors.red),
      );

      final JustBreadcrumbTheme copied = theme1.copyWith(
        style: const JustBreadcrumbStyle(activeColor: Colors.green),
      );
      expect(copied.style?.activeColor, equals(Colors.green));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustBreadcrumbTheme.defaults.style, isNull);
    });
  });

  // =========================================================================
  // --- 5. JustSheet Tests ---
  // =========================================================================
  group('JustSheet Widget & Theme Tests', () {
    testWidgets(
      'JustSheetScope and JustSheetController show and dismiss sheets',
      (WidgetTester tester) async {
        final JustSheetController sheetController = JustSheetController();

        await tester.pumpWidget(
          _buildNavWrapper(
            child: JustSheetScope(
              controller: sheetController,
              child: Builder(
                builder: (BuildContext context) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        sheetController.show<void>(
                          content: const Text('Sheet Content Body'),
                          direction: SheetDirection.bottom,
                          draggable: true,
                        );
                      },
                      child: const Text('Open Sheet'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(sheetController.isVisible, isFalse);
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Sheet Content Body'), findsOneWidget);
        expect(sheetController.isVisible, isTrue);

        sheetController.dismiss();
        await tester.pumpAndSettle();
        expect(sheetController.isVisible, isFalse);
      },
    );

    test('JustSheetTheme copyWith and lerp', () {
      const JustSheetTheme theme1 = JustSheetTheme(
        bottomStyle: JustSheetStyle(backgroundColor: Colors.white),
      );
      const JustSheetTheme theme2 = JustSheetTheme(
        bottomStyle: JustSheetStyle(backgroundColor: Colors.black),
      );

      final JustSheetTheme copied = theme1.copyWith(
        topStyle: const JustSheetStyle(backgroundColor: Colors.grey),
      );
      expect(copied.bottomStyle?.backgroundColor, equals(Colors.white));
      expect(copied.topStyle?.backgroundColor, equals(Colors.grey));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustSheetTheme.defaults.bottomStyle, isNull);
    });

    test('JustSheetStyle holds optional borderColor and borderWidth', () {
      const JustSheetStyle style = JustSheetStyle(
        borderColor: Color(0xFF112233),
        borderWidth: 2.5,
      );
      expect(style.borderColor, equals(const Color(0xFF112233)));
      expect(style.borderWidth, equals(2.5));
    });

    testWidgets(
      'JustSheetSurface renders inline with handle and directional border radius',
      (WidgetTester tester) async {
        final JustThemeData defaultTheme = .light;
        final Finder boxFinder = find
            .descendant(
              of: find.byType(JustSheetSurface),
              matching: find.byType(Container),
            )
            .first;
        final Finder handleFinder = find.byWidgetPredicate(
          (Widget w) =>
              w is Container &&
              w.constraints?.minWidth == 36.0 &&
              w.constraints?.minHeight == 4.0,
        );

        await tester.pumpWidget(
          _buildNavWrapper(
            theme: defaultTheme,
            child: const Center(
              child: JustSheetSurface(
                direction: .bottom,
                showHandle: true,
                child: Text('Inline Sheet'),
              ),
            ),
          ),
        );
        expect(find.text('Inline Sheet'), findsOneWidget);
        expect(find.byType(SafeArea), findsNothing);
        expect(handleFinder, findsOneWidget);

        final BoxDecoration bottomDeco =
            tester.widget<Container>(boxFinder).decoration! as BoxDecoration;
        expect(
          bottomDeco.borderRadius,
          equals(BorderRadius.vertical(top: defaultTheme.radius.lg)),
        );

        await tester.pumpWidget(
          _buildNavWrapper(
            theme: defaultTheme,
            child: const Center(
              child: JustSheetSurface(
                direction: .left,
                showHandle: true,
                child: Text('Left Sheet'),
              ),
            ),
          ),
        );
        expect(handleFinder, findsNothing);
        final BoxDecoration leftDeco =
            tester.widget<Container>(boxFinder).decoration! as BoxDecoration;
        expect(
          leftDeco.borderRadius,
          equals(BorderRadius.horizontal(right: defaultTheme.radius.lg)),
        );
      },
    );

    testWidgets(
      'JustSheetSurface applies theme, style overrides, neobrutalism preset, and SafeArea',
      (WidgetTester tester) async {
        final Finder boxFinder = find
            .descendant(
              of: find.byType(JustSheetSurface),
              matching: find.byType(Container),
            )
            .first;

        await tester.pumpWidget(
          _buildNavWrapper(
            sheetTheme: const JustSheetTheme(
              bottomStyle: JustSheetStyle(
                backgroundColor: Color(0xFF223344),
                borderColor: Color(0xFF556677),
                borderWidth: 2.0,
              ),
            ),
            child: const Center(
              child: JustSheetSurface(
                style: JustSheetStyle(borderWidth: 0.0, borderRadius: .zero),
                useSafeArea: true,
                child: Text('Borderless Sheet'),
              ),
            ),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(JustSheetSurface),
            matching: find.byType(SafeArea),
          ),
          findsOneWidget,
        );
        final BoxDecoration borderlessDeco =
            tester.widget<Container>(boxFinder).decoration! as BoxDecoration;
        expect(borderlessDeco.color, equals(const Color(0xFF223344)));
        expect(borderlessDeco.border, isNull);
      },
    );

    testWidgets('JustSheetSurface applies neobrutalism preset border', (
      WidgetTester tester,
    ) async {
      final Finder boxFinder = find
          .descendant(
            of: find.byType(JustSheetSurface),
            matching: find.byType(Container),
          )
          .first;
      final JustThemeData neoTheme = JustThemeData.neobrutalismLight;
      await tester.pumpWidget(
        _buildNavWrapper(
          theme: neoTheme,
          child: const Center(
            child: JustSheetSurface(child: Text('Neo Sheet')),
          ),
        ),
      );
      final BoxDecoration neoDeco =
          tester.widget<Container>(boxFinder).decoration! as BoxDecoration;
      expect(
        neoDeco.border,
        equals(
          Border.all(
            color: neoTheme.colors.textPrimary,
            width: neoTheme.presetTokens.borderWidth,
          ),
        ),
      );
    });

    testWidgets(
      'JustSheetSurface handles bounded inline sizing and unbounded parent axes',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildNavWrapper(
            child: Column(
              mainAxisSize: .min,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240.0),
                  child: const JustSheetSurface(
                    direction: .bottom,
                    showHandle: true,
                    child: Text('Bounded Bottom'),
                  ),
                ),
                const JustSheetSurface(
                  direction: .left,
                  child: Text('Unbounded Height Left'),
                ),
              ],
            ),
          ),
        );

        final Size boundedSize = tester.getSize(
          find.byType(JustSheetSurface).first,
        );
        expect(boundedSize.width, equals(240.0));
        expect(boundedSize.height, lessThan(120.0));
        expect(find.text('Unbounded Height Left'), findsOneWidget);
      },
    );

    testWidgets(
      'JustSheetSurface enforces maxSize when size is null for vertical and horizontal directions',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildNavWrapper(
            child: const MediaQuery(
              data: MediaQueryData(size: Size(800.0, 600.0)),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: .bottomCenter,
                    child: JustSheetSurface(
                      direction: .bottom,
                      maxSize: 0.25,
                      child: SizedBox(
                        height: 400.0,
                        child: Text('Tall Bottom'),
                      ),
                    ),
                  ),
                  Align(
                    alignment: .topCenter,
                    child: JustSheetSurface(
                      direction: .top,
                      maxSize: 0.25,
                      child: Text('Short Top'),
                    ),
                  ),
                  Align(
                    alignment: .centerLeft,
                    child: JustSheetSurface(
                      direction: .left,
                      maxSize: 0.25,
                      child: SizedBox(width: 400.0, child: Text('Wide Left')),
                    ),
                  ),
                  Align(
                    alignment: .centerRight,
                    child: JustSheetSurface(
                      direction: .right,
                      maxSize: 0.25,
                      child: Text('Hi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final Finder surfaces = find.byType(JustSheetSurface);
        final Size tallBottom = tester.getSize(surfaces.at(0));
        final Size shortTop = tester.getSize(surfaces.at(1));
        final Size wideLeft = tester.getSize(surfaces.at(2));
        final Size shortRight = tester.getSize(surfaces.at(3));

        expect(tallBottom.height, lessThanOrEqualTo(600.0 * 0.25 + 0.1));
        expect(shortTop.height, lessThan(100.0));
        expect(wideLeft.width, lessThanOrEqualTo(800.0 * 0.25 + 0.1));
        expect(shortRight.width, lessThan(150.0));
      },
    );

    testWidgets(
      'showJustBottomSheet fallback delegates to JustSheetSurface and applies JustSheetTheme',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildNavWrapper(
            sheetTheme: const JustSheetTheme(
              topStyle: JustSheetStyle(backgroundColor: Color(0xFF334455)),
            ),
            child: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    showJustBottomSheet<void>(
                      context: context,
                      direction: .top,
                      content: const Text('Fallback Top Sheet'),
                    );
                  },
                  child: const Text('Show Fallback'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show Fallback'));
        await tester.pumpAndSettle();

        expect(find.text('Fallback Top Sheet'), findsOneWidget);
        expect(find.byType(JustSheetSurface), findsOneWidget);

        final BoxDecoration deco =
            tester
                    .widget<Container>(
                      find
                          .descendant(
                            of: find.byType(JustSheetSurface),
                            matching: find.byType(Container),
                          )
                          .first,
                    )
                    .decoration!
                as BoxDecoration;
        expect(deco.color, equals(const Color(0xFF334455)));
        expect(
          deco.borderRadius,
          equals(BorderRadius.vertical(bottom: JustThemeData.light.radius.lg)),
        );

        await tester.tapAt(const Offset(10, 500));
        await tester.pumpAndSettle();
        expect(find.text('Fallback Top Sheet'), findsNothing);
      },
    );

    testWidgets(
      'JustSheetController and showJustBottomSheet use Duration.zero when disableAnimations is true',
      (WidgetTester tester) async {
        final JustSheetController sheetController = JustSheetController();
        await tester.pumpWidget(
          _buildNavWrapper(
            child: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: JustSheetScope(
                controller: sheetController,
                child: const Text('Sheet Host'),
              ),
            ),
          ),
        );

        unawaited(
          sheetController.show<void>(
            content: const Text('Scoped Reduced Sheet'),
          ),
        );
        await tester.pump();
        final SlideTransition scopedSlide = tester.widget<SlideTransition>(
          find.ancestor(
            of: find.byType(JustSheetSurface),
            matching: find.byType(SlideTransition),
          ),
        );
        expect(scopedSlide.position.value, equals(Offset.zero));
        sheetController.forceDismissAll();
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          _buildNavWrapper(
            child: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Builder(
                builder: (BuildContext context) => GestureDetector(
                  onTap: () => showJustBottomSheet<void>(
                    context: context,
                    content: const Text('Fallback Reduced Sheet'),
                  ),
                  child: const Text('Open Fallback'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Fallback'));
        await tester.pump();
        await tester.pump();
        final SlideTransition fallbackSlide = tester.widget<SlideTransition>(
          find.ancestor(
            of: find.byType(JustSheetSurface),
            matching: find.byType(SlideTransition),
          ),
        );
        expect(fallbackSlide.position.value, equals(Offset.zero));
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
      },
    );
  });

  // =========================================================================
  // --- 6. JustToast Tests ---
  // =========================================================================
  group('JustToast Widget & Theme Tests', () {
    testWidgets(
      'JustToastScope and JustToastController show and dismiss toasts',
      (WidgetTester tester) async {
        final JustToastController toastController = JustToastController();

        await tester.pumpWidget(
          _buildNavWrapper(
            child: JustToastScope(
              controller: toastController,
              child: Builder(
                builder: (BuildContext context) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        toastController.show(
                          message: 'Test Toast Message',
                          variant: ToastVariant.success,
                          duration: const Duration(seconds: 5),
                        );
                      },
                      child: const Text('Trigger Toast'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(toastController.isVisible, isFalse);
        await tester.tap(find.text('Trigger Toast'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Test Toast Message'), findsOneWidget);
        expect(toastController.isVisible, isTrue);

        toastController.dismiss();
        await tester.pumpAndSettle();
        expect(toastController.isVisible, isFalse);
      },
    );

    test('JustToastTheme copyWith and lerp', () {
      const JustToastTheme theme1 = JustToastTheme(
        infoStyle: JustToastStyle(backgroundColor: Colors.blue),
      );
      const JustToastTheme theme2 = JustToastTheme(
        infoStyle: JustToastStyle(backgroundColor: Colors.indigo),
      );

      final JustToastTheme copied = theme1.copyWith(
        successStyle: const JustToastStyle(backgroundColor: Colors.green),
      );
      expect(copied.infoStyle?.backgroundColor, equals(Colors.blue));
      expect(copied.successStyle?.backgroundColor, equals(Colors.green));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustToastTheme.defaults.infoStyle, isNull);
    });
  });

  // =========================================================================
  // --- 7. JustTooltip Tests ---
  // =========================================================================
  group('JustTooltip Widget & Theme Tests', () {
    testWidgets('JustTooltip renders child and responds to hover/tap overlay', (
      WidgetTester tester,
    ) async {
      final OverlayPortalController controller = OverlayPortalController();

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Center(
            child: JustTooltip(
              message: 'Helpful tooltip',
              controller: controller,
              child: const Text('Hover Target'),
            ),
          ),
        ),
      );

      expect(find.text('Hover Target'), findsOneWidget);
      controller.show();
      await tester.pumpAndSettle();
      expect(find.text('Helpful tooltip'), findsOneWidget);
      controller.hide();
      await tester.pumpAndSettle();
    });

    test('JustTooltipTheme copyWith and lerp', () {
      const JustTooltipTheme theme1 = JustTooltipTheme(
        style: JustTooltipStyle(backgroundColor: Colors.black87),
      );
      const JustTooltipTheme theme2 = JustTooltipTheme(
        style: JustTooltipStyle(backgroundColor: Colors.black),
      );

      final JustTooltipTheme copied = theme1.copyWith(
        style: const JustTooltipStyle(backgroundColor: Colors.blueGrey),
      );
      expect(copied.style?.backgroundColor, equals(Colors.blueGrey));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustTooltipTheme.defaults.style, isNull);
    });
  });

  // =========================================================================
  // --- 8. JustAccordion Tests ---
  // =========================================================================
  group('JustAccordion Widget & Theme Tests', () {
    testWidgets('Renders single and multi-expansion accordion items', (
      WidgetTester tester,
    ) async {
      Set<int> expanded = <int>{};
      final List<JustAccordionItem> items = <JustAccordionItem>[
        const JustAccordionItem(
          title: 'Section 1',
          content: Text('Section 1 Content Body'),
        ),
        const JustAccordionItem(
          title: 'Section 2',
          subtitle: Text('Subtitle 2'),
          content: Text('Section 2 Content Body'),
        ),
        const JustAccordionItem(
          title: 'Section 3 Disabled',
          content: Text('Section 3 Content Body'),
          enabled: false,
        ),
      ];

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: <Widget>[
              JustAccordion(
                items: items,
                initialExpanded: const <int>{0},
                onChanged: (Set<int> indices) => expanded = indices,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 1 Content Body'), findsOneWidget);

      await tester.tap(find.text('Section 2'));
      await tester.pumpAndSettle();
      expect(expanded.contains(1), isTrue);
      expect(find.text('Section 2 Content Body'), findsOneWidget);

      // Tapping disabled section 3 does not expand it
      await tester.tap(find.text('Section 3 Disabled'));
      await tester.pumpAndSettle();
      expect(expanded.contains(2), isFalse);
    });

    test('JustAccordionTheme copyWith and lerp', () {
      const JustAccordionTheme theme1 = JustAccordionTheme(
        style: JustAccordionStyle(borderColor: Colors.grey),
      );
      const JustAccordionTheme theme2 = JustAccordionTheme(
        style: JustAccordionStyle(borderColor: Colors.black),
      );

      final JustAccordionTheme copied = theme1.copyWith(
        style: const JustAccordionStyle(borderColor: Colors.blue),
      );
      expect(copied.style?.borderColor, equals(Colors.blue));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustAccordionTheme.defaults.style, isNull);
    });
  });

  // =========================================================================
  // --- 9. JustRadio & JustRadioGroup Tests ---
  // =========================================================================
  group('JustRadio & JustRadioGroup Tests', () {
    testWidgets('JustRadio renders all sizes and handles selection', (
      WidgetTester tester,
    ) async {
      String? selectedVal = 'A';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildNavWrapper(
              child: Column(
                children: <Widget>[
                  for (final JustRadioSize size in JustRadioSize.values)
                    JustRadio<String>(
                      value: size.name,
                      groupValue: selectedVal,
                      size: size,
                      label: Text('Radio ${size.name}'),
                      onChanged: (String val) =>
                          setState(() => selectedVal = val),
                    ),
                  const JustRadio<String>(
                    value: 'disabled',
                    groupValue: 'A',
                    onChanged: null,
                    isDisabled: true,
                    label: Text('Disabled Radio'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      expect(find.text('Radio sm'), findsOneWidget);
      expect(find.text('Radio md'), findsOneWidget);
      expect(find.text('Radio lg'), findsOneWidget);

      await tester.tap(find.text('Radio sm'));
      await tester.pumpAndSettle();
      expect(selectedVal, equals('sm'));
    });

    testWidgets('JustRadioGroup lays out options vertically and horizontally', (
      WidgetTester tester,
    ) async {
      int? selectedNum = 1;
      final List<JustRadioOption<int>> options = <JustRadioOption<int>>[
        const JustRadioOption<int>(value: 1, label: Text('Option 1')),
        const JustRadioOption<int>(value: 2, label: Text('Option 2')),
        const JustRadioOption<int>(
          value: 3,
          label: Text('Option 3'),
          isDisabled: true,
        ),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildNavWrapper(
              child: JustRadioGroup<int>(
                value: selectedNum,
                options: options,
                onChanged: (int val) => setState(() => selectedNum = val),
              ),
            );
          },
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);

      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();
      expect(selectedNum, equals(2));
    });

    test('JustRadioTheme copyWith and lerp', () {
      const JustRadioTheme theme1 = JustRadioTheme(
        style: JustRadioStyle(activeColor: Colors.blue),
        enableHaptic: false,
      );
      const JustRadioTheme theme2 = JustRadioTheme(
        style: JustRadioStyle(activeColor: Colors.green),
        enableHaptic: true,
      );

      final JustRadioTheme copied = theme1.copyWith(
        style: const JustRadioStyle(activeColor: Colors.purple),
        enableHaptic: true,
      );
      expect(copied.style?.activeColor, equals(Colors.purple));
      expect(copied.enableHaptic, isTrue);

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustRadioTheme.defaults.style, isNull);
    });
  });

  // =========================================================================
  // --- 10. JustTable Tests ---
  // =========================================================================
  group('JustTable Widget & Theme Tests', () {
    testWidgets(
      'Renders table columns, rows, sortable headers, and selectable rows',
      (WidgetTester tester) async {
        Set<int> selected = <int>{};
        int? sortedCol;

        final List<JustTableColumn<Map<String, String>>> columns =
            <JustTableColumn<Map<String, String>>>[
              JustTableColumn<Map<String, String>>(
                header: 'Name',
                sortable: true,
                cell: (Map<String, String> row) => Text(row['name']!),
              ),
              JustTableColumn<Map<String, String>>(
                header: 'Role',
                cell: (Map<String, String> row) => Text(row['role']!),
              ),
            ];

        final List<Map<String, String>> rows = <Map<String, String>>[
          <String, String>{'name': 'Alice', 'role': 'Admin'},
          <String, String>{'name': 'Bob', 'role': 'User'},
        ];

        await tester.pumpWidget(
          _buildNavWrapper(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 300,
                  child: JustTable<Map<String, String>>(
                    columns: columns,
                    rows: rows,
                    selectable: true,
                    selectedRows: selected,
                    onSelectionChanged: (Set<int> newSel) => selected = newSel,
                    onSort: (int colIdx) => sortedCol = colIdx,
                    variant: JustTableVariant.striped,
                  ),
                ),
                const SizedBox(
                  height: 100,
                  child: JustTable<Map<String, String>>(
                    columns: <JustTableColumn<Map<String, String>>>[],
                    rows: <Map<String, String>>[],
                    emptyState: Text('No Records Found'),
                  ),
                ),
              ],
            ),
          ),
        );

        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('No Records Found'), findsOneWidget);

        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        expect(sortedCol, equals(0));
      },
    );

    test('JustTableTheme copyWith and lerp', () {
      const JustTableTheme theme1 = JustTableTheme(
        style: JustTableStyle(headerBackgroundColor: Colors.grey),
      );
      const JustTableTheme theme2 = JustTableTheme(
        style: JustTableStyle(headerBackgroundColor: Colors.black),
      );

      final JustTableTheme copied = theme1.copyWith(
        style: const JustTableStyle(headerBackgroundColor: Colors.blue),
      );
      expect(copied.style?.headerBackgroundColor, equals(Colors.blue));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustTableTheme.defaults.style, isNull);
    });
  });

  // =========================================================================
  // --- 11. JustToggle & JustToggleGroup Tests ---
  // =========================================================================
  group('JustToggle & JustToggleGroup Tests', () {
    testWidgets(
      'JustToggle renders selected and unselected states across sizes',
      (WidgetTester tester) async {
        bool isSelected = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return _buildNavWrapper(
                child: Column(
                  children: <Widget>[
                    for (final JustToggleSize size in JustToggleSize.values)
                      JustToggle(
                        selected: isSelected,
                        size: size,
                        onPressed: () =>
                            setState(() => isSelected = !isSelected),
                        child: Text('Toggle ${size.name}'),
                      ),
                    const JustToggle(
                      selected: false,
                      enabled: false,
                      onPressed: null,
                      child: Text('Disabled Toggle'),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        expect(find.text('Toggle md'), findsOneWidget);
        await tester.tap(find.text('Toggle md'));
        await tester.pumpAndSettle();
        expect(isSelected, isTrue);
      },
    );

    testWidgets('JustToggleGroup single and multi select behavior', (
      WidgetTester tester,
    ) async {
      Set<int> selectedSet = <int>{0};
      final List<JustToggleGroupItem> items = <JustToggleGroupItem>[
        const JustToggleGroupItem(child: Text('Bold')),
        const JustToggleGroupItem(child: Text('Italic')),
        const JustToggleGroupItem(child: Text('Underline')),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildNavWrapper(
              child: JustToggleGroup(
                items: items,
                selectedIndices: selectedSet,
                allowMultiple: true,
                onChanged: (Set<int> newSel) =>
                    setState(() => selectedSet = newSel),
              ),
            );
          },
        ),
      );

      expect(find.text('Bold'), findsOneWidget);
      expect(find.text('Italic'), findsOneWidget);

      await tester.tap(find.text('Italic'));
      await tester.pumpAndSettle();
      expect(selectedSet, containsAll(<dynamic>[0, 1]));
    });

    test('JustToggleTheme copyWith and lerp', () {
      const JustToggleTheme theme1 = JustToggleTheme(
        style: JustToggleStyle(selectedBackgroundColor: Colors.blue),
      );
      const JustToggleTheme theme2 = JustToggleTheme(
        style: JustToggleStyle(selectedBackgroundColor: Colors.green),
      );

      final JustToggleTheme copied = theme1.copyWith(
        style: const JustToggleStyle(selectedBackgroundColor: Colors.amber),
      );
      expect(copied.style?.selectedBackgroundColor, equals(Colors.amber));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustToggleTheme.defaults.style, isNull);
    });
  });
}
