import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/select/just_select.dart';
import 'package:just_ui_core/src/components/select/just_select_style.dart';
import 'package:just_ui_core/src/components/select/just_select_theme.dart';
import 'package:just_ui_core/src/components/select/just_select_variants.dart';

typedef JustSelectThemeData = JustSelectTheme;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(
    Widget child, {
    JustThemeData? theme,
    ThemeData? materialTheme,
    Alignment alignment = Alignment.center,
  }) {
    return MaterialApp(
      theme: materialTheme,
      home: JustThemeProvider(
        lightTheme: theme ?? JustThemeData.light,
        darkTheme: theme ?? JustThemeData.dark,
        child: Scaffold(
          body: Align(
            alignment: alignment,
            child: SizedBox(width: 320, child: child),
          ),
        ),
      ),
    );
  }

  group('JustSelectOption Unit Tests', () {
    test('Standard option and divider option constructor properties', () {
      const JustSelectOption<String> option = JustSelectOption<String>(
        value: 'val1',
        label: 'Option 1',
        icon: Icon(Icons.star),
        enabled: true,
        isDivider: false,
      );

      expect(option.value, equals('val1'));
      expect(option.label, equals('Option 1'));
      expect(option.icon, isNotNull);
      expect(option.enabled, isTrue);
      expect(option.isDivider, isFalse);

      const JustSelectOption<String> divider =
          JustSelectOption<String>.divider();
      expect(divider.value, isNull);
      expect(divider.label, isEmpty);
      expect(divider.icon, isNull);
      expect(divider.enabled, isFalse);
      expect(divider.isDivider, isTrue);
    });
  });

  group('JustSelect - Dropdown Open, Close & Item Selection', () {
    testWidgets('Opens dropdown overlay on tap and selects option', (
      WidgetTester tester,
    ) async {
      String? selectedValue = 'opt1';
      final List<JustSelectOption<String>> options = <JustSelectOption<String>>[
        const JustSelectOption<String>(value: 'opt1', label: 'Option 1'),
        const JustSelectOption<String>(value: 'opt2', label: 'Option 2'),
        const JustSelectOption<String>(value: 'opt3', label: 'Option 3'),
      ];

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return JustSelect<String>(
                value: selectedValue,
                options: options,
                onChanged: (String val) => setState(() => selectedValue = val),
              );
            },
          ),
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);

      // Tap trigger to open dropdown
      await tester.tap(find.byType(JustSelect<String>));
      await tester.pumpAndSettle();

      // Dropdown menu is now open with all options visible
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);

      // Tap Option 2
      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();

      expect(selectedValue, equals('opt2'));
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsNothing); // Overlay is closed
    });

    testWidgets(
      'Tapping outside overlay barrier closes dropdown without changing value',
      (WidgetTester tester) async {
        String? selectedValue = 'apple';
        final List<JustSelectOption<String>> options =
            <JustSelectOption<String>>[
              const JustSelectOption<String>(value: 'apple', label: 'Apple'),
              const JustSelectOption<String>(value: 'banana', label: 'Banana'),
            ];

        await tester.pumpWidget(
          buildTestApp(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return JustSelect<String>(
                  value: selectedValue,
                  options: options,
                  onChanged: (String val) =>
                      setState(() => selectedValue = val),
                );
              },
            ),
          ),
        );

        await tester.tap(find.byType(JustSelect<String>));
        await tester.pumpAndSettle();

        expect(find.text('Banana'), findsOneWidget);

        // Tap outside top-left corner
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(selectedValue, equals('apple'));
        expect(find.text('Banana'), findsNothing);
      },
    );

    testWidgets(
      'Tapping disabled option does not select and keeps dropdown open',
      (WidgetTester tester) async {
        String? selectedValue = 'opt1';
        final List<JustSelectOption<String>> options =
            <JustSelectOption<String>>[
              const JustSelectOption<String>(value: 'opt1', label: 'Option 1'),
              const JustSelectOption<String>(
                value: 'opt2',
                label: 'Option 2 (Disabled)',
                enabled: false,
              ),
            ];

        await tester.pumpWidget(
          buildTestApp(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return JustSelect<String>(
                  value: selectedValue,
                  options: options,
                  onChanged: (String val) =>
                      setState(() => selectedValue = val),
                );
              },
            ),
          ),
        );

        await tester.tap(find.byType(JustSelect<String>));
        await tester.pumpAndSettle();

        // Tap disabled option
        await tester.tap(find.text('Option 2 (Disabled)'));
        await tester.pumpAndSettle();

        // Value remains unchanged and dropdown stays open
        expect(selectedValue, equals('opt1'));
        expect(find.text('Option 2 (Disabled)'), findsOneWidget);
      },
    );

    testWidgets('Renders divider option separators in dropdown list', (
      WidgetTester tester,
    ) async {
      final List<JustSelectOption<String>> options = <JustSelectOption<String>>[
        const JustSelectOption<String>(value: 'item1', label: 'Item 1'),
        const JustSelectOption<String>.divider(),
        const JustSelectOption<String>(value: 'item2', label: 'Item 2'),
      ];

      await tester.pumpWidget(
        buildTestApp(
          JustSelect<String>(
            value: 'item1',
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(JustSelect<String>));
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsWidgets);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('Placeholder renders when value is null', (
      WidgetTester tester,
    ) async {
      final List<JustSelectOption<String>> options = <JustSelectOption<String>>[
        const JustSelectOption<String>(value: 'a', label: 'Alpha'),
      ];

      await tester.pumpWidget(
        buildTestApp(
          JustSelect<String>(
            value: null,
            placeholder: 'Choose an item...',
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Choose an item...'), findsOneWidget);
    });

    testWidgets('Disabled JustSelect ignores tap and does not open dropdown', (
      WidgetTester tester,
    ) async {
      final List<JustSelectOption<String>> options = <JustSelectOption<String>>[
        const JustSelectOption<String>(value: 'a', label: 'Option A'),
      ];

      await tester.pumpWidget(
        buildTestApp(
          JustSelect<String>(
            value: 'a',
            enabled: false,
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(JustSelect<String>));
      await tester.pumpAndSettle();

      // Overlay was not opened
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Renders label, prefixIcon, and errorText', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          JustSelect<String>(
            value: '1',
            label: 'Select Country',
            errorText: 'Please make a selection',
            prefixIcon: const Icon(Icons.language),
            options: const <JustSelectOption<String>>[
              JustSelectOption<String>(
                value: '1',
                label: 'United States',
                icon: Icon(Icons.flag),
              ),
            ],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Select Country'), findsOneWidget);
      expect(find.text('Please make a selection'), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
    });
  });

  group('JustSelect - Searchable Dropdown', () {
    testWidgets('Filters options when user types in search input', (
      WidgetTester tester,
    ) async {
      final List<JustSelectOption<String>> options = <JustSelectOption<String>>[
        const JustSelectOption<String>(value: 'apple', label: 'Apple'),
        const JustSelectOption<String>(value: 'banana', label: 'Banana'),
        const JustSelectOption<String>(value: 'avocado', label: 'Avocado'),
      ];

      await tester.pumpWidget(
        buildTestApp(
          JustSelect<String>(
            value: null,
            searchable: true,
            options: options,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(JustSelect<String>));
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Avocado'), findsOneWidget);

      // Enter query 'av'
      await tester.enterText(find.byType(EditableText), 'av');
      await tester.pumpAndSettle();

      expect(find.text('Avocado'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Banana'), findsNothing);

      // Enter unmatched query
      await tester.enterText(find.byType(EditableText), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('No options found'), findsOneWidget);
    });
  });

  group('JustSelect - Keyboard Navigation', () {
    testWidgets('Opens with Enter key and navigates with Arrow keys', (
      WidgetTester tester,
    ) async {
      String? selectedValue;
      final List<JustSelectOption<String>> options = <JustSelectOption<String>>[
        const JustSelectOption<String>(value: 'item1', label: 'Item 1'),
        const JustSelectOption<String>(value: 'item2', label: 'Item 2'),
        const JustSelectOption<String>(value: 'item3', label: 'Item 3'),
      ];

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return JustSelect<String>(
                value: selectedValue,
                options: options,
                onChanged: (String val) => setState(() => selectedValue = val),
              );
            },
          ),
        ),
      );

      // Focus the trigger the way a keyboard user does.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Press Enter to open dropdown
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Item 2'), findsOneWidget);

      // Press ArrowDown to navigate to first option (Item 1)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Press ArrowDown to navigate to second option (Item 2)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Press Enter to select Item 2
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selectedValue, equals('item2'));
      expect(find.text('Item 3'), findsNothing);
    });

    testWidgets('Closes open dropdown with Escape key', (
      WidgetTester tester,
    ) async {
      final List<JustSelectOption<String>> options = <JustSelectOption<String>>[
        const JustSelectOption<String>(value: '1', label: 'Option 1'),
      ];

      await tester.pumpWidget(
        buildTestApp(
          JustSelect<String>(value: '1', options: options, onChanged: (_) {}),
        ),
      );

      await tester.tap(find.byType(JustSelect<String>));
      await tester.pumpAndSettle();

      expect(find.text('Option 1'), findsWidgets);

      // Press Escape
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsNothing);
    });
  });

  group('JustSelect - Flip Positioning Logic', () {
    testWidgets(
      'Positions dropdown above trigger when placed near bottom edge',
      (WidgetTester tester) async {
        final List<JustSelectOption<String>> options =
            <JustSelectOption<String>>[
              const JustSelectOption<String>(value: '1', label: 'Option 1'),
            ];

        await tester.pumpWidget(
          buildTestApp(
            JustSelect<String>(value: '1', options: options, onChanged: (_) {}),
            alignment: Alignment.bottomCenter,
          ),
        );

        await tester.tap(find.byType(JustSelect<String>));
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
      },
    );
  });

  group('JustSelect - Presets & Sizes', () {
    testWidgets('Renders all size variants (sm, md, lg)', (
      WidgetTester tester,
    ) async {
      for (final JustSelectSize size in <JustSelectSize>[
        JustSelectSize.sm,
        JustSelectSize.md,
        JustSelectSize.lg,
      ]) {
        await tester.pumpWidget(
          buildTestApp(
            JustSelect<String>(
              size: size,
              value: '1',
              options: const <JustSelectOption<String>>[
                JustSelectOption<String>(value: '1', label: 'Size Test'),
              ],
              onChanged: (_) {},
            ),
          ),
        );

        expect(find.text('Size Test'), findsOneWidget);
      }
    });

    testWidgets('Renders with Neobrutalism preset and applies preset styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          JustSelect<String>(
            value: 'neo',
            options: const <JustSelectOption<String>>[
              JustSelectOption<String>(value: 'neo', label: 'Neo Option'),
            ],
            onChanged: (_) {},
          ),
          theme: JustThemeData.neobrutalismLight,
        ),
      );

      expect(find.text('Neo Option'), findsOneWidget);

      await tester.tap(find.byType(JustSelect<String>));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets(
      'dropdown height wraps option count when smaller than maxDropdownHeight',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            JustSelect<String>(
              value: 'weekly',
              options: const <JustSelectOption<String>>[
                JustSelectOption<String>(value: 'weekly', label: 'Weekly'),
                JustSelectOption<String>(value: 'monthly', label: 'Monthly'),
              ],
              onChanged: (_) {},
            ),
          ),
        );

        await tester.tap(find.byType(JustSelect<String>));
        await tester.pumpAndSettle();

        final Finder menuBox = find
            .ancestor(
              of: find.byType(ListView),
              matching: find.byType(Container),
            )
            .first;
        final Size menuSize = tester.getSize(menuBox);
        expect(menuSize.height, lessThan(120.0));
        expect(menuSize.height, equals(82.0));

        // Neobrutalism borderWidth (2.5 * 2 = 5.0) + 2 options (80.0) = 85.0
        await tester.pumpWidget(
          buildTestApp(
            JustSelect<String>(
              key: const ValueKey<String>('neo-select'),
              value: 'weekly',
              options: const <JustSelectOption<String>>[
                JustSelectOption<String>(value: 'weekly', label: 'Weekly'),
                JustSelectOption<String>(value: 'monthly', label: 'Monthly'),
              ],
              onChanged: (_) {},
            ),
            theme: JustThemeData.neobrutalismLight,
          ),
        );

        await tester.tap(find.byType(JustSelect<String>));
        await tester.pumpAndSettle();

        final Finder neoMenuBox = find
            .ancestor(
              of: find.byType(ListView),
              matching: find.byType(Container),
            )
            .first;
        expect(tester.getSize(neoMenuBox).height, equals(85.0));
      },
    );

    testWidgets('dropdown height caps at maxDropdownHeight for long lists', (
      WidgetTester tester,
    ) async {
      final List<JustSelectOption<int>> manyOptions =
          List<JustSelectOption<int>>.generate(
            15,
            (int index) =>
                JustSelectOption<int>(value: index, label: 'Option $index'),
          );

      await tester.pumpWidget(
        buildTestApp(
          JustSelect<int>(
            value: 0,
            maxDropdownHeight: 150,
            options: manyOptions,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(JustSelect<int>));
      await tester.pumpAndSettle();

      final Finder menuBox = find
          .ancestor(of: find.byType(ListView), matching: find.byType(Container))
          .first;
      expect(tester.getSize(menuBox).height, equals(150.0));
    });

    testWidgets(
      'inlineDropdown expands in-flow and supports keyboard selection + selected semantics',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          String selectedValue = 'weekly';
          const List<JustSelectOption<String>> options =
              <JustSelectOption<String>>[
                JustSelectOption<String>(value: 'weekly', label: 'Weekly'),
                JustSelectOption<String>(value: 'monthly', label: 'Monthly'),
              ];

          await tester.pumpWidget(
            buildTestApp(
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return JustSelect<String>(
                    label: 'Frequency',
                    value: selectedValue,
                    inlineDropdown: true,
                    options: options,
                    onChanged: (String val) =>
                        setState(() => selectedValue = val),
                  );
                },
              ),
            ),
          );

          final double closedHeight = tester
              .getSize(find.byType(JustSelect<String>))
              .height;
          expect(find.byType(OverlayPortal), findsNothing);
          expect(find.text('Monthly'), findsNothing);

          // Open with Tab + Enter
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          final FocusNode? triggerFocus = FocusManager.instance.primaryFocus;
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          expect(find.byType(OverlayPortal), findsNothing);
          expect(find.text('Monthly'), findsOneWidget);
          final double openHeight = tester
              .getSize(find.byType(JustSelect<String>))
              .height;
          expect(openHeight, greaterThan(closedHeight + 70.0));

          // Tab does not step into inline option tiles (single Tab stop)
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(FocusManager.instance.primaryFocus, same(triggerFocus));

          // Verify Semantics(selected: isSelected, button: true) on option tiles
          final SemanticsData weeklyData = tester
              .getSemantics(find.text('Weekly').last)
              .getSemanticsData();
          expect(weeklyData.flagsCollection.isButton, isTrue);
          expect(
            weeklyData.flagsCollection.isSelected,
            equals(Tristate.isTrue),
          );

          final SemanticsData monthlyData = tester
              .getSemantics(find.text('Monthly'))
              .getSemanticsData();
          expect(monthlyData.flagsCollection.isButton, isTrue);
          expect(
            monthlyData.flagsCollection.isSelected,
            equals(Tristate.isFalse),
          );

          // ArrowDown moves focus from selected Weekly to Monthly, Enter selects it
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          expect(selectedValue, equals('monthly'));
          expect(
            tester.getSize(find.byType(JustSelect<String>)).height,
            equals(closedHeight),
          );
          expect(find.text('Weekly'), findsNothing);

          // Re-open with Enter and dismiss with Escape
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(find.text('Weekly'), findsOneWidget);

          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(find.text('Weekly'), findsNothing);
          expect(
            tester.getSize(find.byType(JustSelect<String>)).height,
            equals(closedHeight),
          );
        } finally {
          handle.dispose();
        }
      },
    );

    testWidgets(
      'inlineDropdown supports searchable filtering and empty state height',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestApp(
            JustSelect<String>(
              value: 'weekly',
              searchable: true,
              inlineDropdown: true,
              options: const <JustSelectOption<String>>[
                JustSelectOption<String>(value: 'weekly', label: 'Weekly'),
                JustSelectOption<String>(value: 'monthly', label: 'Monthly'),
              ],
              onChanged: (_) {},
            ),
          ),
        );

        await tester.tap(find.byType(JustSelect<String>));
        await tester.pumpAndSettle();

        expect(find.byType(EditableText), findsOneWidget);
        await tester.enterText(find.byType(EditableText), 'zzz');
        await tester.pumpAndSettle();

        expect(find.text('No options found'), findsOneWidget);
      },
    );

    testWidgets(
      'switching inlineDropdown from false to true while overlay is open hides safely',
      (WidgetTester tester) async {
        const List<JustSelectOption<String>> options =
            <JustSelectOption<String>>[
              JustSelectOption<String>(value: 'weekly', label: 'Weekly'),
              JustSelectOption<String>(value: 'monthly', label: 'Monthly'),
            ];

        await tester.pumpWidget(
          buildTestApp(
            JustSelect<String>(
              inlineDropdown: false,
              value: 'weekly',
              options: options,
              onChanged: (_) {},
            ),
          ),
        );

        await tester.tap(find.byType(JustSelect<String>));
        await tester.pumpAndSettle();
        expect(find.text('Monthly'), findsOneWidget);

        await tester.pumpWidget(
          buildTestApp(
            JustSelect<String>(
              inlineDropdown: true,
              value: 'weekly',
              options: options,
              onChanged: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Monthly'), findsNothing);

        // Switching back to overlay mode remains closed rather than reopening.
        await tester.pumpWidget(
          buildTestApp(
            JustSelect<String>(
              inlineDropdown: false,
              value: 'weekly',
              options: options,
              onChanged: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Monthly'), findsNothing);
      },
    );

    testWidgets(
      'searchable select navigates and selects single filtered option via ArrowDown and Enter',
      (WidgetTester tester) async {
        String? selected;
        const List<JustSelectOption<String>> options =
            <JustSelectOption<String>>[
              JustSelectOption<String>(value: 'apple', label: 'Apple'),
              JustSelectOption<String>(value: 'banana', label: 'Banana'),
              JustSelectOption<String>(value: 'cherry', label: 'Cherry'),
            ];

        await tester.pumpWidget(
          buildTestApp(
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return JustSelect<String>(
                  inlineDropdown: true,
                  searchable: true,
                  placeholder: 'Pick fruit',
                  value: selected,
                  options: options,
                  onChanged: (String value) => setState(() => selected = value),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Pick fruit'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), 'ban');
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(selected, equals('banana'));
        expect(find.byType(EditableText), findsNothing);
      },
    );
  });

  group('JustSelectTheme & JustSelectStyle Unit Tests', () {
    test('JustSelectStyle instantiation with all properties', () {
      // ignore: prefer_const_constructors
      final JustSelectStyle style = JustSelectStyle(
        triggerBackgroundColor: const Color(0xFF111111),
        triggerBorderColor: const Color(0xFF222222),
        dropdownBackgroundColor: const Color(0xFF333333),
        optionHoverColor: const Color(0xFF444444),
        selectedOptionColor: const Color(0xFF555555),
        textColor: const Color(0xFF666666),
        placeholderColor: const Color(0xFF777777),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        dropdownElevation: 4.0,
      );

      expect(style.triggerBackgroundColor, equals(const Color(0xFF111111)));
      expect(style.triggerBorderColor, equals(const Color(0xFF222222)));
      expect(style.dropdownBackgroundColor, equals(const Color(0xFF333333)));
      expect(style.optionHoverColor, equals(const Color(0xFF444444)));
      expect(style.selectedOptionColor, equals(const Color(0xFF555555)));
      expect(style.textColor, equals(const Color(0xFF666666)));
      expect(style.placeholderColor, equals(const Color(0xFF777777)));
      expect(
        style.borderRadius,
        equals(const BorderRadius.all(Radius.circular(8))),
      );
      expect(style.dropdownElevation, equals(4.0));

      // ignore: prefer_const_constructors
      final JustSelectStyle emptyStyle = JustSelectStyle();
      expect(emptyStyle.triggerBackgroundColor, isNull);
    });

    test('JustSelectTheme copyWith and lerp unit tests', () {
      const JustSelectStyle style1 = JustSelectStyle(
        triggerBackgroundColor: Color(0xFF111111),
      );
      const JustSelectStyle style2 = JustSelectStyle(
        triggerBackgroundColor: Color(0xFF222222),
      );

      const JustSelectTheme theme1 = JustSelectTheme(style: style1);
      final JustSelectTheme copied = theme1.copyWith(style: style2);
      expect(copied.style, equals(style2));

      final JustSelectTheme copiedNull = theme1.copyWith();
      expect(copiedNull.style, equals(style1));

      const JustSelectTheme theme2 = JustSelectTheme(style: style2);

      // Lerp t < 0.5
      final JustSelectTheme lerpLow = theme1.lerp(theme2, 0.2);
      expect(lerpLow.style, equals(style1));

      // Lerp t >= 0.5
      final JustSelectTheme lerpHigh = theme1.lerp(theme2, 0.7);
      expect(lerpHigh.style, equals(style2));

      // Lerp with null / incompatible
      final JustSelectTheme lerpNull = theme1.lerp(null, 0.5);
      expect(lerpNull, equals(theme1));

      expect(JustSelectTheme.defaults.style, isNull);
    });

    test('JustSelectSize enum values', () {
      expect(
        JustSelectSize.values,
        containsAll(<dynamic>[
          JustSelectSize.sm,
          JustSelectSize.md,
          JustSelectSize.lg,
        ]),
      );
    });
  });
}
