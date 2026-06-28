import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_variants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(textDirection: .ltr, child: child),
    );
  }

  group('JustBottomNav Tests', () {
    testWidgets('Renders correct labels and default icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          JustBottomNav(
            items: [
              const JustBottomNavItem(label: 'Home', icon: Text('IconA')),
              const JustBottomNavItem(label: 'Search', icon: Text('IconB')),
              const JustBottomNavItem(label: 'Profile', icon: Text('IconC')),
            ],
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('IconA'), findsOneWidget);
    });

    testWidgets('Tapping an item triggers onItemSelected', (
      WidgetTester tester,
    ) async {
      int? selectedIndex;

      await tester.pumpWidget(
        buildTestableWidget(
          JustBottomNav(
            selectedIndex: 0,
            onItemSelected: (idx) => selectedIndex = idx,
            items: [
              const JustBottomNavItem(label: 'Home', icon: Text('IconA')),
              const JustBottomNavItem(label: 'Search', icon: Text('IconB')),
              const JustBottomNavItem(label: 'Profile', icon: Text('IconC')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(selectedIndex, equals(1));
    });

    testWidgets('Assertion triggers when items count is less than 3', (
      WidgetTester tester,
    ) async {
      expect(
        () => JustBottomNav(
          items: [
            const JustBottomNavItem(label: 'Home', icon: Text('IconA')),
            const JustBottomNavItem(label: 'Search', icon: Text('IconB')),
          ],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('Assertion triggers when items count is more than 5', (
      WidgetTester tester,
    ) async {
      expect(
        () => JustBottomNav(
          items: [
            const JustBottomNavItem(label: '1', icon: Text('I')),
            const JustBottomNavItem(label: '2', icon: Text('I')),
            const JustBottomNavItem(label: '3', icon: Text('I')),
            const JustBottomNavItem(label: '4', icon: Text('I')),
            const JustBottomNavItem(label: '5', icon: Text('I')),
            const JustBottomNavItem(label: '6', icon: Text('I')),
          ],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('Transitions icons when activeIcon is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          JustBottomNav(
            selectedIndex: 0,
            items: [
              const JustBottomNavItem(
                label: 'Home',
                icon: Text('InactiveHome'),
                activeIcon: Text('ActiveHome'),
              ),
              const JustBottomNavItem(label: 'Search', icon: Text('I')),
              const JustBottomNavItem(label: 'Profile', icon: Text('I')),
            ],
          ),
        ),
      );

      // Verify both icons are present in the stack, but ActiveHome is selected (opacity should set up correctly)
      expect(find.text('InactiveHome'), findsOneWidget);
      expect(find.text('ActiveHome'), findsOneWidget);
    });

    testWidgets('Applies Neobrutalism preset correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          lightTheme: JustThemeData.neobrutalismLight,
          child: Directionality(
            textDirection: .ltr,
            child: JustBottomNav(
              variant: JustBottomNavVariant.floating,
              items: [
                const JustBottomNavItem(label: 'Home', icon: Text('IconA')),
                const JustBottomNavItem(label: 'Search', icon: Text('IconB')),
                const JustBottomNavItem(label: 'Profile', icon: Text('IconC')),
              ],
            ),
          ),
        ),
      );

      final containerFinder = find.byKey(
        const Key('just_bottom_nav_bar_surface'),
      );
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.width, equals(2.5));
    });
  });
}
