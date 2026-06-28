import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar.dart';
import 'package:just_ui_core/src/components/shared/_shared_tooltip_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child, {double width = 800.0}) {
    return JustThemeProvider(
      child: Directionality(
        textDirection: .ltr,
        child: MediaQuery(
          data: MediaQueryData(size: Size(width, 600.0)),
          child: Overlay(
            initialEntries: [OverlayEntry(builder: (context) => child)],
          ),
        ),
      ),
    );
  }

  group('JustSidebar Tests', () {
    testWidgets('Renders header, footer, and menu items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSidebar(
            header: Text('MyLogo'),
            footer: Text('MyUser'),
            items: [
              JustSidebarItem(label: 'Home', icon: Text('HomeIcon')),
              JustSidebarItem(label: 'Settings', icon: Text('SettingsIcon')),
            ],
          ),
        ),
      );

      expect(find.text('MyLogo'), findsOneWidget);
      expect(find.text('MyUser'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Tapping on a submenu folder expands child items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSidebar(
            items: [
              JustSidebarItem(
                label: 'Folder',
                icon: Text('FolderIcon'),
                children: [
                  JustSidebarItem(label: 'SubItemA', icon: Text('IconA')),
                  JustSidebarItem(label: 'SubItemB', icon: Text('IconB')),
                ],
              ),
            ],
          ),
        ),
      );

      // Initially, SubItemA is hidden
      expect(find.text('SubItemA'), findsNothing);

      // Tap on Folder to expand
      await tester.tap(find.text('Folder'));
      await tester.pumpAndSettle();

      // Now children should be visible
      expect(find.text('SubItemA'), findsOneWidget);
      expect(find.text('SubItemB'), findsOneWidget);
    });

    testWidgets('Auto-collapses below md breakpoint (768px)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSidebar(
            width: 260.0,
            collapsedWidth: 68.0,
            items: [JustSidebarItem(label: 'Home', icon: Text('HomeIcon'))],
          ),
          width: 500.0, // Below md breakpoint
        ),
      );

      await tester.pumpAndSettle();

      // In collapsed mode, item labels are hidden from screen
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('Hovering over item in collapsed mode shows tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustSidebar(
            isCollapsed: true,
            items: [JustSidebarItem(label: 'HoverMe', icon: Text('Icon'))],
          ),
        ),
      );

      // Initially, tooltip is not shown
      expect(find.text('HoverMe'), findsNothing);

      // Simulate mouse enter to trigger hover
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      // Hover over the icon widget
      await gesture.moveTo(tester.getCenter(find.byType(JustTooltipOverlay)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tooltip label should show up
      expect(find.text('HoverMe'), findsOneWidget);
    });

    testWidgets('Applies Neobrutalism preset correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          lightTheme: JustThemeData.neobrutalismLight,
          child: const Directionality(
            textDirection: .ltr,
            child: JustSidebar(
              items: [JustSidebarItem(label: 'Home', icon: Text('HomeIcon'))],
            ),
          ),
        ),
      );

      bool foundThickBorder = false;
      for (final element in tester.allElements) {
        if (element.widget is Container) {
          final container = element.widget as Container;
          if (container.decoration is BoxDecoration) {
            final dec = container.decoration as BoxDecoration;
            if (dec.border is Border &&
                (dec.border as Border).right.width == 2.5) {
              foundThickBorder = true;
            }
          }
        }
      }
      expect(foundThickBorder, isTrue);
    });
  });
}
