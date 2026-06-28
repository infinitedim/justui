import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/breadcrumb/just_breadcrumb.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(
        textDirection: .ltr,
        child: Overlay(
          initialEntries: [OverlayEntry(builder: (context) => child)],
        ),
      ),
    );
  }

  group('JustBreadcrumb Tests', () {
    testWidgets('Renders all items and separators when maxItems is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustBreadcrumb(
            items: [
              JustBreadcrumbItem(label: 'Home'),
              JustBreadcrumbItem(label: 'Settings'),
              JustBreadcrumbItem(label: 'Profile'),
            ],
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('/'), findsNWidgets(2));
    });

    testWidgets('Interactive items trigger onTap', (WidgetTester tester) async {
      bool homeTapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustBreadcrumb(
            items: [
              JustBreadcrumbItem(label: 'Home', onTap: () => homeTapped = true),
              const JustBreadcrumbItem(label: 'Profile'),
            ],
          ),
        ),
      );

      final homeFinder = find.text('Home');
      expect(homeFinder, findsOneWidget);
      await tester.tap(homeFinder);
      await tester.pump();

      expect(homeTapped, isTrue);
    });

    testWidgets('Middle items collapse when count exceeds maxItems', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustBreadcrumb(
            maxItems: 3,
            items: [
              JustBreadcrumbItem(label: 'Home'),
              JustBreadcrumbItem(label: 'Category'),
              JustBreadcrumbItem(label: 'Subcategory'),
              JustBreadcrumbItem(label: 'Item Details'),
            ],
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Item Details'), findsOneWidget);
      expect(find.text('Category'), findsNothing);
      expect(find.text('Subcategory'), findsNothing);
      expect(find.text('...'), findsOneWidget);
    });

    testWidgets('Tapping collapsed indicator shows dropdown list', (
      WidgetTester tester,
    ) async {
      bool categoryTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          JustBreadcrumb(
            maxItems: 3,
            items: [
              const JustBreadcrumbItem(label: 'Home'),
              JustBreadcrumbItem(
                label: 'Category',
                onTap: () => categoryTapped = true,
              ),
              const JustBreadcrumbItem(label: 'Subcategory'),
              const JustBreadcrumbItem(label: 'Item Details'),
            ],
          ),
        ),
      );

      final collapsedFinder = find.text('...');
      expect(collapsedFinder, findsOneWidget);

      // Verify dropdown is initially hidden
      expect(find.text('Category'), findsNothing);

      // Tap collapsed indicator to toggle dropdown overlay
      await tester.tap(collapsedFinder);
      // Pump twice to trigger build and layout builder overlays
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Now "Category" should be visible in the dropdown
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Subcategory'), findsOneWidget);

      // Tap on Category inside dropdown
      await tester.tap(find.text('Category'));
      await tester.pump();

      expect(categoryTapped, isTrue);

      // Dropdown should hide after selection
      await tester.pump();
      expect(find.text('Category'), findsNothing);
    });

    testWidgets('Applies Neobrutalism preset correctly to collapsed overlay', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          lightTheme: JustThemeData.neobrutalismLight,
          child: Directionality(
            textDirection: .ltr,
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => const JustBreadcrumb(
                    maxItems: 3,
                    items: [
                      JustBreadcrumbItem(label: 'Home'),
                      JustBreadcrumbItem(label: 'Category'),
                      JustBreadcrumbItem(label: 'Subcategory'),
                      JustBreadcrumbItem(label: 'Item Details'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final collapsedFinder = find.text('...');
      expect(collapsedFinder, findsOneWidget);

      await tester.tap(collapsedFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      bool foundThickBorder = false;
      for (final element in tester.allElements) {
        if (element.widget is Container) {
          final container = element.widget as Container;
          if (container.decoration is BoxDecoration) {
            final dec = container.decoration as BoxDecoration;
            if (dec.border != null && dec.border!.top.width == 2.5) {
              foundThickBorder = true;
            }
          }
        }
      }
      expect(foundThickBorder, isTrue);
    });
  });
}
