import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_group.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_style.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(Widget child, {JustThemeData? theme}) {
    final JustThemeData effectiveTheme = theme ?? JustThemeData.light;
    return MaterialApp(
      theme: effectiveTheme.toThemeData(),
      home: JustThemeProvider(
        initialThemeMode: ThemeMode.light,
        lightTheme: effectiveTheme,
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('JustToggle - Basic Rendering & Interaction', () {
    testWidgets('Renders toggle and handles selection tap', (
      WidgetTester tester,
    ) async {
      bool selected = false;
      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return JustToggle(
                selected: selected,
                onPressed: () => setState(() => selected = !selected),
                child: const Text('Toggle'),
              );
            },
          ),
        ),
      );

      expect(find.text('Toggle'), findsOneWidget);
      await tester.tap(find.byType(JustToggle));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
    });

    testWidgets('Neobrutalism preset with selectedShadows override', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: JustThemeData.neobrutalismLight,
          JustToggle(
            selected: true,
            onPressed: () {},
            style: const JustToggleStyle(selectedShadows: <BoxShadow>[]),
            child: const Text('No Shadow'),
          ),
        ),
      );

      expect(find.text('No Shadow'), findsOneWidget);
      // Containers inside JustToggle: should not have any BoxShadow
      final Iterable<Container> containers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(JustToggle),
              matching: find.byType(Container),
            ),
          )
          .where((Container c) => c.decoration is BoxDecoration);
      for (final Container c in containers) {
        final BoxDecoration d = c.decoration! as BoxDecoration;
        expect(d.boxShadow, isNull);
      }
    });
  });

  group('JustToggleGroup - Single and Multiple Selection', () {
    testWidgets('Selects single item in single selection mode', (
      WidgetTester tester,
    ) async {
      Set<int> selected = const <int>{0};
      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return JustToggleGroup(
                items: const <JustToggleGroupItem>[
                  JustToggleGroupItem(child: Text('Option 1')),
                  JustToggleGroupItem(child: Text('Option 2')),
                ],
                selectedIndices: selected,
                onChanged: (Set<int> value) {
                  setState(() => selected = value);
                },
              );
            },
          ),
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);

      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();
      expect(selected, equals(const <int>{1}));
    });
  });

  group('JustToggleStyle & JustToggleTheme Unit Tests', () {
    test('JustToggleStyle copyWith, lerp, equality, and hashCode', () {
      const JustToggleStyle styleA = JustToggleStyle(
        selectedBackgroundColor: Color(0xFF000000),
        selectedShadows: <BoxShadow>[BoxShadow(offset: Offset(2, 2))],
      );
      final JustToggleStyle styleB = styleA.copyWith(
        unselectedBackgroundColor: const Color(0xFFFFFFFF),
      );

      expect(styleB.selectedBackgroundColor, equals(const Color(0xFF000000)));
      expect(styleB.unselectedBackgroundColor, equals(const Color(0xFFFFFFFF)));
      expect(styleB.selectedShadows, hasLength(1));

      final JustToggleStyle? lerped = JustToggleStyle.lerp(styleA, styleB, 0.5);
      expect(lerped?.selectedBackgroundColor, equals(const Color(0xFF000000)));

      expect(styleA == styleA.copyWith(), isTrue);
      expect(styleA.hashCode, equals(styleA.copyWith().hashCode));
    });

    test('JustToggleTheme defaults, copyWith, lerp', () {
      const JustToggleTheme themeA = JustToggleTheme.defaults;
      final JustToggleTheme themeB = themeA.copyWith(
        style: const JustToggleStyle(
          selectedBackgroundColor: Color(0xFF111111),
        ),
      );

      expect(
        themeB.style?.selectedBackgroundColor,
        equals(const Color(0xFF111111)),
      );
      final JustToggleTheme lerped = themeA.lerp(themeB, 0.6);
      expect(
        lerped.style?.selectedBackgroundColor,
        equals(const Color(0xFF111111)),
      );
    });
  });
}
