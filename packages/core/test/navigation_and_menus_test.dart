import 'package:flutter/material.dart'
    show Colors, Icons, MaterialApp, Scaffold, ThemeData;
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
  final activeTheme = theme ?? JustThemeData.light;
  return JustThemeProvider(
    lightTheme: activeTheme,
    child: MaterialApp(
      theme: ThemeData(
        extensions: [
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
      final controller = JustTabController(length: 3, initialIndex: 1);
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

      final emptyController = JustTabController(length: 0);
      expect(emptyController.index, equals(0));
      emptyController.index = 0;
      emptyController.animateTo(0);
      emptyController.updateAnimationValue(0);
    });

    testWidgets('Renders tabs variants and handles tab switching', (
      tester,
    ) async {
      int activeIndex = 0;
      final tabs = [
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
            children: [
              Expanded(
                child: JustTabs(
                  tabs: tabs,
                  onChanged: (idx) => activeIndex = idx,
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

    testWidgets('Renders all tab constructor variants', (tester) async {
      final tabs = [
        const JustTab(label: 'A', content: Text('Page A')),
        const JustTab(label: 'B', content: Text('Page B')),
      ];

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: [Expanded(child: JustTabs.line(tabs: tabs))],
          ),
        ),
      );

      expect(find.text('Page A'), findsOneWidget);

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: [Expanded(child: JustTabs.enclosed(tabs: tabs))],
          ),
        ),
      );

      expect(find.text('Page A'), findsOneWidget);

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: [Expanded(child: JustTabs.pill(tabs: tabs))],
          ),
        ),
      );

      expect(find.text('Page A'), findsOneWidget);

      await tester.pumpWidget(
        _buildNavWrapper(
          child: Column(
            children: [Expanded(child: JustTabs.vertical(tabs: tabs))],
          ),
        ),
      );

      expect(find.text('Page A'), findsOneWidget);
    });

    test('JustTabsTheme copyWith and lerp', () {
      const theme1 = JustTabsTheme(
        lineStyle: JustTabsStyle(activeColor: Colors.blue),
      );
      const theme2 = JustTabsTheme(
        lineStyle: JustTabsStyle(activeColor: Colors.red),
      );

      final copied = theme1.copyWith(
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
      (tester) async {
        int selectedIdx = 0;
        bool collapsed = false;

        final items = [
          const JustSidebarItem(label: 'Home', icon: Icon(Icons.home)),
          const JustSidebarItem(
            label: 'Projects',
            icon: Icon(Icons.folder),
            children: [
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
              onItemSelected: (idx) => selectedIdx = idx,
              isCollapsed: collapsed,
              onCollapsedChanged: (val) => collapsed = val,
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
      const theme1 = JustSidebarTheme(
        defaultStyle: JustSidebarStyle(backgroundColor: Colors.white),
      );
      const theme2 = JustSidebarTheme(
        defaultStyle: JustSidebarStyle(backgroundColor: Colors.black),
      );

      final copied = theme1.copyWith(
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
      (tester) async {
        int selectedIdx = 0;
        const items = [
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
                onItemSelected: (idx) => selectedIdx = idx,
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
      const theme1 = JustBottomNavTheme(
        fixedStyle: JustBottomNavStyle(backgroundColor: Colors.white),
      );
      const theme2 = JustBottomNavTheme(
        fixedStyle: JustBottomNavStyle(backgroundColor: Colors.black),
      );

      final copied = theme1.copyWith(
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
      (tester) async {
        int tappedIndex = -1;
        final items = [
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
              children: [
                const JustBreadcrumb(items: []),
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

    test('JustBreadcrumbTheme copyWith and lerp', () {
      const theme1 = JustBreadcrumbTheme(
        style: JustBreadcrumbStyle(activeColor: Colors.blue),
      );
      const theme2 = JustBreadcrumbTheme(
        style: JustBreadcrumbStyle(activeColor: Colors.red),
      );

      final copied = theme1.copyWith(
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
      (tester) async {
        final sheetController = JustSheetController();

        await tester.pumpWidget(
          _buildNavWrapper(
            child: JustSheetScope(
              controller: sheetController,
              child: Builder(
                builder: (context) {
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
      const theme1 = JustSheetTheme(
        bottomStyle: JustSheetStyle(backgroundColor: Colors.white),
      );
      const theme2 = JustSheetTheme(
        bottomStyle: JustSheetStyle(backgroundColor: Colors.black),
      );

      final copied = theme1.copyWith(
        topStyle: const JustSheetStyle(backgroundColor: Colors.grey),
      );
      expect(copied.bottomStyle?.backgroundColor, equals(Colors.white));
      expect(copied.topStyle?.backgroundColor, equals(Colors.grey));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustSheetTheme.defaults.bottomStyle, isNull);
    });
  });

  // =========================================================================
  // --- 6. JustToast Tests ---
  // =========================================================================
  group('JustToast Widget & Theme Tests', () {
    testWidgets(
      'JustToastScope and JustToastController show and dismiss toasts',
      (tester) async {
        final toastController = JustToastController();

        await tester.pumpWidget(
          _buildNavWrapper(
            child: JustToastScope(
              controller: toastController,
              child: Builder(
                builder: (context) {
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
      const theme1 = JustToastTheme(
        infoStyle: JustToastStyle(backgroundColor: Colors.blue),
      );
      const theme2 = JustToastTheme(
        infoStyle: JustToastStyle(backgroundColor: Colors.indigo),
      );

      final copied = theme1.copyWith(
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
      tester,
    ) async {
      final controller = OverlayPortalController();

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
      const theme1 = JustTooltipTheme(
        style: JustTooltipStyle(backgroundColor: Colors.black87),
      );
      const theme2 = JustTooltipTheme(
        style: JustTooltipStyle(backgroundColor: Colors.black),
      );

      final copied = theme1.copyWith(
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
      tester,
    ) async {
      Set<int> expanded = {};
      final items = [
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
            children: [
              JustAccordion(
                items: items,
                initialExpanded: const {0},
                onChanged: (indices) => expanded = indices,
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
      const theme1 = JustAccordionTheme(
        style: JustAccordionStyle(borderColor: Colors.grey),
      );
      const theme2 = JustAccordionTheme(
        style: JustAccordionStyle(borderColor: Colors.black),
      );

      final copied = theme1.copyWith(
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
      tester,
    ) async {
      String? selectedVal = 'A';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _buildNavWrapper(
              child: Column(
                children: [
                  for (final size in JustRadioSize.values)
                    JustRadio<String>(
                      value: size.name,
                      groupValue: selectedVal,
                      size: size,
                      label: Text('Radio ${size.name}'),
                      onChanged: (val) => setState(() => selectedVal = val),
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
      tester,
    ) async {
      int? selectedNum = 1;
      final options = [
        const JustRadioOption(value: 1, label: Text('Option 1')),
        const JustRadioOption(value: 2, label: Text('Option 2')),
        const JustRadioOption(
          value: 3,
          label: Text('Option 3'),
          isDisabled: true,
        ),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _buildNavWrapper(
              child: JustRadioGroup<int>(
                value: selectedNum,
                options: options,
                onChanged: (val) => setState(() => selectedNum = val),
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
      const theme1 = JustRadioTheme(
        style: JustRadioStyle(activeColor: Colors.blue),
        enableHaptic: false,
      );
      const theme2 = JustRadioTheme(
        style: JustRadioStyle(activeColor: Colors.green),
        enableHaptic: true,
      );

      final copied = theme1.copyWith(
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
      (tester) async {
        Set<int> selected = {};
        int? sortedCol;

        final columns = [
          JustTableColumn<Map<String, String>>(
            header: 'Name',
            sortable: true,
            cell: (row) => Text(row['name']!),
          ),
          JustTableColumn<Map<String, String>>(
            header: 'Role',
            cell: (row) => Text(row['role']!),
          ),
        ];

        final rows = [
          {'name': 'Alice', 'role': 'Admin'},
          {'name': 'Bob', 'role': 'User'},
        ];

        await tester.pumpWidget(
          _buildNavWrapper(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: JustTable<Map<String, String>>(
                    columns: columns,
                    rows: rows,
                    selectable: true,
                    selectedRows: selected,
                    onSelectionChanged: (newSel) => selected = newSel,
                    onSort: (colIdx) => sortedCol = colIdx,
                    variant: JustTableVariant.striped,
                  ),
                ),
                const SizedBox(
                  height: 100,
                  child: JustTable<Map<String, String>>(
                    columns: [],
                    rows: [],
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
      const theme1 = JustTableTheme(
        style: JustTableStyle(headerBackgroundColor: Colors.grey),
      );
      const theme2 = JustTableTheme(
        style: JustTableStyle(headerBackgroundColor: Colors.black),
      );

      final copied = theme1.copyWith(
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
      (tester) async {
        bool isSelected = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return _buildNavWrapper(
                child: Column(
                  children: [
                    for (final size in JustToggleSize.values)
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
      tester,
    ) async {
      Set<int> selectedSet = {0};
      final items = [
        const JustToggleGroupItem(child: Text('Bold')),
        const JustToggleGroupItem(child: Text('Italic')),
        const JustToggleGroupItem(child: Text('Underline')),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _buildNavWrapper(
              child: JustToggleGroup(
                items: items,
                selectedIndices: selectedSet,
                allowMultiple: true,
                onChanged: (newSel) => setState(() => selectedSet = newSel),
              ),
            );
          },
        ),
      );

      expect(find.text('Bold'), findsOneWidget);
      expect(find.text('Italic'), findsOneWidget);

      await tester.tap(find.text('Italic'));
      await tester.pumpAndSettle();
      expect(selectedSet, containsAll([0, 1]));
    });

    test('JustToggleTheme copyWith and lerp', () {
      const theme1 = JustToggleTheme(
        style: JustToggleStyle(selectedBackgroundColor: Colors.blue),
      );
      const theme2 = JustToggleTheme(
        style: JustToggleStyle(selectedBackgroundColor: Colors.green),
      );

      final copied = theme1.copyWith(
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
