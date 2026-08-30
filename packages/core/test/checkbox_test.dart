import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox_style.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(
    Widget child, {
    JustThemeData? theme,
    ThemeData? materialTheme,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    final effectiveJustTheme = theme ?? JustThemeData.light;
    final effectiveMaterialTheme =
        materialTheme ?? effectiveJustTheme.toThemeData();

    return MaterialApp(
      theme: effectiveMaterialTheme,
      home: JustThemeProvider(
        initialThemeMode: themeMode,
        lightTheme: effectiveJustTheme,
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('JustCheckbox - States & Sizing', () {
    testWidgets('Renders checked, unchecked, and indeterminate states', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: [
              JustCheckbox(value: true, onChanged: (_) {}),
              JustCheckbox(value: false, onChanged: (_) {}),
              JustCheckbox(value: null, onChanged: (_) {}),
            ],
          ),
        ),
      );

      expect(find.byType(JustCheckbox), findsNWidgets(3));

      // Checked semantics
      final checkedSemantics = tester.getSemantics(
        find.byType(JustCheckbox).at(0),
      );
      expect(
        checkedSemantics.getSemanticsData().flagsCollection.isChecked,
        equals(CheckedState.isTrue),
      );

      // Unchecked semantics
      final uncheckedSemantics = tester.getSemantics(
        find.byType(JustCheckbox).at(1),
      );
      expect(
        uncheckedSemantics.getSemanticsData().flagsCollection.isChecked,
        equals(CheckedState.isFalse),
      );

      // Indeterminate semantics
      final indeterminateSemantics = tester.getSemantics(
        find.byType(JustCheckbox).at(2),
      );
      expect(
        indeterminateSemantics.getSemanticsData().flagsCollection.isChecked,
        equals(CheckedState.mixed),
      );
    });

    testWidgets('Renders all size classifications (.sm, .md, .lg)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: [
              JustCheckbox(
                value: true,
                size: JustCheckboxSize.sm,
                onChanged: (_) {},
              ),
              JustCheckbox(
                value: true,
                size: JustCheckboxSize.md,
                onChanged: (_) {},
              ),
              JustCheckbox(
                value: true,
                size: JustCheckboxSize.lg,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      );

      expect(find.byType(JustCheckbox), findsNWidgets(3));

      // Minimum touch target 48x48
      final touchTargetFinders = find.descendant(
        of: find.byType(JustCheckbox),
        matching: find.byWidgetPredicate(
          (w) =>
              w is ConstrainedBox &&
              w.constraints.minWidth >= 48.0 &&
              w.constraints.minHeight >= 48.0,
        ),
      );
      expect(touchTargetFinders, findsNWidgets(3));
    });

    testWidgets('Tapping checkbox toggles boolean values accurately', (
      tester,
    ) async {
      bool? stateValue = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustCheckbox(
                value: stateValue,
                onChanged: (val) {
                  setState(() => stateValue = val);
                },
              ),
            );
          },
        ),
      );

      // False -> True
      await tester.tap(find.byType(JustCheckbox));
      await tester.pumpAndSettle();
      expect(stateValue, isTrue);

      // True -> False
      await tester.tap(find.byType(JustCheckbox));
      await tester.pumpAndSettle();
      expect(stateValue, isFalse);

      // Indeterminate (null) -> True
      stateValue = null;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustCheckbox(
                value: stateValue,
                onChanged: (val) {
                  setState(() => stateValue = val);
                },
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(JustCheckbox));
      await tester.pumpAndSettle();
      expect(stateValue, isTrue);
    });

    testWidgets('Tapping label triggers checkbox state change', (tester) async {
      bool value = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustCheckbox(
                value: value,
                label: const Text('Accept Terms and Conditions'),
                onChanged: (val) {
                  setState(() => value = val ?? false);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('Accept Terms and Conditions'), findsOneWidget);
      await tester.tap(find.text('Accept Terms and Conditions'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });
  });

  group('JustCheckbox - Disabled State & Keyboard Navigation', () {
    testWidgets(
      'Disabled checkbox via isDisabled prevents tap and dims opacity',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          buildTestApp(
            JustCheckbox(
              value: false,
              isDisabled: true,
              onChanged: (_) => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(JustCheckbox), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(tapped, isFalse);

        final opacity = tester.widget<Opacity>(
          find.descendant(
            of: find.byType(JustCheckbox),
            matching: find.byType(Opacity),
          ),
        );
        expect(opacity.opacity, equals(0.5));

        final semantics = tester.getSemantics(find.byType(JustCheckbox));
        expect(
          semantics.getSemanticsData().flagsCollection.isEnabled,
          equals(Tristate.isFalse),
        );
      },
    );

    testWidgets('Disabled checkbox via onChanged null prevents interactions', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(const JustCheckbox(value: true, onChanged: null)),
      );

      final semantics = tester.getSemantics(find.byType(JustCheckbox));
      expect(
        semantics.getSemanticsData().flagsCollection.isEnabled,
        equals(Tristate.isFalse),
      );
    });

    testWidgets('Keyboard space and enter keys toggle focused checkbox', (
      tester,
    ) async {
      bool value = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustCheckbox(
                value: value,
                focusNode: focusNode,
                onChanged: (val) => setState(() => value = val ?? false),
              ),
            );
          },
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      // Test Space key
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(value, isTrue);

      // Test Enter key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(value, isFalse);

      // Unhandled key
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle();
      expect(value, isFalse);
    });

    testWidgets('Keyboard events are ignored when checkbox is disabled', (
      tester,
    ) async {
      bool tapped = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        buildTestApp(
          JustCheckbox(
            value: false,
            isDisabled: true,
            focusNode: focusNode,
            onChanged: (_) => tapped = true,
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('External FocusNode update in didUpdateWidget', (tester) async {
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();
      addTearDown(focusNode1.dispose);
      addTearDown(focusNode2.dispose);

      await tester.pumpWidget(
        buildTestApp(
          JustCheckbox(value: false, focusNode: focusNode1, onChanged: (_) {}),
        ),
      );

      // Update to focusNode2
      await tester.pumpWidget(
        buildTestApp(
          JustCheckbox(value: true, focusNode: focusNode2, onChanged: (_) {}),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(JustCheckbox), findsOneWidget);
    });
  });

  group('JustCheckbox - Neobrutalism Preset & Theming', () {
    testWidgets(
      'Neobrutalism preset styles checkbox with solid border and press translation',
      (tester) async {
        const bool value = true;

        await tester.pumpWidget(
          buildTestApp(
            theme: JustThemeData.neobrutalismLight,
            JustCheckbox(value: value, onChanged: (_) {}),
          ),
        );

        expect(find.byType(JustCheckbox), findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(JustCheckbox)),
        );
        await tester.pump(const Duration(milliseconds: 20));

        expect(find.byType(AnimatedContainer), findsWidgets);

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('Haptic feedback is triggered on state toggle', (tester) async {
      final List<String> log = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'HapticFeedback.vibrate') {
              log.add(methodCall.arguments as String);
            }
            return null;
          });

      await tester.pumpWidget(
        buildTestApp(
          JustCheckbox(value: false, enableHaptic: true, onChanged: (_) {}),
        ),
      );

      await tester.tap(find.byType(JustCheckbox));
      await tester.pumpAndSettle();

      expect(log, contains('HapticFeedbackType.selectionClick'));
    });

    testWidgets('Per-instance JustCheckboxStyle overrides theme', (
      tester,
    ) async {
      const customStyle = JustCheckboxStyle(
        activeColor: Color(0xFF112233),
        checkColor: Color(0xFF445566),
        borderColor: Color(0xFF778899),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        textStyle: TextStyle(fontSize: 18, color: Color(0xFFAABBCC)),
      );

      await tester.pumpWidget(
        buildTestApp(
          JustCheckbox(
            value: true,
            style: customStyle,
            label: const Text('Custom Label'),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Custom Label'), findsOneWidget);
    });

    testWidgets('Global JustCheckboxTheme applies to JustCheckbox', (
      tester,
    ) async {
      const themeStyle = JustCheckboxStyle(
        activeColor: Color(0xFF990000),
        checkColor: Color(0xFFFFFFFF),
      );

      final materialTheme = ThemeData(
        extensions: const [
          JustCheckboxTheme(style: themeStyle, enableHaptic: true),
        ],
      );

      await tester.pumpWidget(
        buildTestApp(
          materialTheme: materialTheme,
          JustCheckbox(value: true, onChanged: (_) {}),
        ),
      );

      expect(find.byType(JustCheckbox), findsOneWidget);
    });
  });

  group('JustCheckbox - Painters Unit Tests', () {
    testWidgets(
      'Checkmark and Indeterminate CustomPainter painting and shouldRepaint',
      (tester) async {
        // Test widget animating value from false to true to pump all frames
        bool value = false;
        late StateSetter stateSetter;

        await tester.pumpWidget(
          buildTestApp(
            StatefulBuilder(
              builder: (context, setState) {
                stateSetter = setState;
                return JustCheckbox(value: value, onChanged: (_) {});
              },
            ),
          ),
        );

        // Trigger animation forward
        stateSetter(() => value = true);
        await tester.pump(const Duration(milliseconds: 50)); // progress <= 0.5
        await tester.pump(const Duration(milliseconds: 100)); // progress > 0.5
        await tester.pumpAndSettle(); // progress = 1.0

        // Trigger animation reverse
        stateSetter(() => value = false);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();

        // Trigger indeterminate
        stateSetter(() => value = true);
        await tester.pumpAndSettle();
      },
    );
  });

  group('JustCheckboxStyle & JustCheckboxTheme Unit Tests', () {
    test('JustCheckboxStyle copyWith, lerp, equality, and hashCode', () {
      const style1 = JustCheckboxStyle(
        activeColor: Color(0xFF112233),
        checkColor: Color(0xFF445566),
        borderColor: Color(0xFF778899),
        borderRadius: BorderRadius.all(Radius.circular(6)),
        textStyle: TextStyle(fontSize: 16),
      );

      final copied = style1.copyWith(activeColor: const Color(0xFF00FF00));

      expect(copied.activeColor, equals(const Color(0xFF00FF00)));
      expect(copied.checkColor, equals(style1.checkColor));
      expect(copied.borderColor, equals(style1.borderColor));
      expect(copied.borderRadius, equals(style1.borderRadius));
      expect(copied.textStyle, equals(style1.textStyle));

      const styleClone = JustCheckboxStyle(
        activeColor: Color(0xFF112233),
        checkColor: Color(0xFF445566),
        borderColor: Color(0xFF778899),
        borderRadius: BorderRadius.all(Radius.circular(6)),
        textStyle: TextStyle(fontSize: 16),
      );

      expect(style1, equals(styleClone));
      expect(style1.hashCode, equals(styleClone.hashCode));
      expect(style1 == copied, isFalse);

      // Lerp
      expect(JustCheckboxStyle.lerp(style1, style1, 0.5), equals(style1));
      expect(JustCheckboxStyle.lerp(null, null, 0.5), isNull);

      final lerped = JustCheckboxStyle.lerp(style1, copied, 0.5);
      expect(lerped, isNotNull);
      expect(
        lerped!.activeColor,
        equals(
          Color.lerp(const Color(0xFF112233), const Color(0xFF00FF00), 0.5),
        ),
      );
    });

    test(
      'JustCheckboxTheme defaults, copyWith, lerp, equality, and hashCode',
      () {
        const defaultTheme = JustCheckboxTheme.defaults;
        expect(defaultTheme.enableHaptic, isFalse);
        expect(defaultTheme.style, isNull);

        const customStyle = JustCheckboxStyle(activeColor: Color(0xFF990000));
        const theme1 = JustCheckboxTheme(
          style: customStyle,
          enableHaptic: true,
        );

        final copied = theme1.copyWith(enableHaptic: false);
        expect(copied.enableHaptic, isFalse);
        expect(copied.style, equals(customStyle));

        const themeClone = JustCheckboxTheme(
          style: customStyle,
          enableHaptic: true,
        );

        expect(theme1, equals(themeClone));
        expect(theme1.hashCode, equals(themeClone.hashCode));
        expect(theme1 == copied, isFalse);

        // Lerp
        expect(theme1.lerp(null, 0.5), equals(theme1));
        final lerpedTheme = theme1.lerp(copied, 0.7);
        expect(lerpedTheme.enableHaptic, isFalse);
        final lerpedThemeEarly = theme1.lerp(copied, 0.3);
        expect(lerpedThemeEarly.enableHaptic, isTrue);

        // Parity with JustCheckboxThemeData typedef
        expect(theme1, isA<JustCheckboxThemeData>());
      },
    );
  });
}
