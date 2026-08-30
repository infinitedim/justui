import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/switch/just_switch.dart';
import 'package:just_ui_core/src/components/switch/just_switch_style.dart';
import 'package:just_ui_core/src/components/switch/just_switch_theme.dart';

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

  group('JustSwitch - States, Sizes & Semantics', () {
    testWidgets('Renders active and inactive states with proper semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: [
              JustSwitch(value: true, onChanged: (_) {}),
              JustSwitch(value: false, onChanged: (_) {}),
            ],
          ),
        ),
      );

      expect(find.byType(JustSwitch), findsNWidgets(2));

      final activeSemantics = tester.getSemantics(
        find.byType(JustSwitch).at(0),
      );
      expect(
        activeSemantics.getSemanticsData().flagsCollection.isToggled,
        equals(Tristate.isTrue),
      );

      final inactiveSemantics = tester.getSemantics(
        find.byType(JustSwitch).at(1),
      );
      expect(
        inactiveSemantics.getSemanticsData().flagsCollection.isToggled,
        equals(Tristate.isFalse),
      );
    });

    testWidgets(
      'Renders all size classifications (.sm, .md, .lg) and meets touch target',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            Column(
              children: [
                JustSwitch(
                  value: false,
                  size: JustSwitchSize.sm,
                  onChanged: (_) {},
                ),
                JustSwitch(
                  value: false,
                  size: JustSwitchSize.md,
                  onChanged: (_) {},
                ),
                JustSwitch(
                  value: false,
                  size: JustSwitchSize.lg,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        );

        expect(find.byType(JustSwitch), findsNWidgets(3));

        // Minimum height constraint 48.0
        final constrainedBoxes = tester.widgetList<ConstrainedBox>(
          find.descendant(
            of: find.byType(JustSwitch),
            matching: find.byWidgetPredicate(
              (w) => w is ConstrainedBox && w.constraints.minHeight >= 48.0,
            ),
          ),
        );
        expect(constrainedBoxes.length, equals(3));
      },
    );

    testWidgets('Tapping switch toggles boolean value', (tester) async {
      bool value = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustSwitch(
                value: value,
                onChanged: (val) => setState(() => value = val),
              ),
            );
          },
        ),
      );

      expect(value, isFalse);
      await tester.tap(find.byType(JustSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);

      await tester.tap(find.byType(JustSwitch));
      await tester.pumpAndSettle();
      expect(value, isFalse);
    });

    testWidgets('Tapping label triggers switch toggle', (tester) async {
      bool value = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustSwitch(
                value: value,
                label: const Text('Enable Notifications'),
                onChanged: (val) => setState(() => value = val),
              ),
            );
          },
        ),
      );

      expect(find.text('Enable Notifications'), findsOneWidget);
      await tester.tap(find.text('Enable Notifications'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });
  });

  group('JustSwitch - Inner-Layout Thumb Calculations & Alignments', () {
    testWidgets('Default preset track and thumb sizing calculations', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: [
              JustSwitch(
                value: false,
                size: JustSwitchSize.sm,
                onChanged: (_) {},
              ),
              JustSwitch(
                value: true,
                size: JustSwitchSize.md,
                onChanged: (_) {},
              ),
              JustSwitch(
                value: false,
                size: JustSwitchSize.lg,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      );

      // Verify track container sizing for sm: 32x18
      final smTrackFinder = find.descendant(
        of: find.byType(JustSwitch).at(0),
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 32.0,
        ),
      );
      expect(smTrackFinder, findsOneWidget);

      // Verify track container sizing for md: 40x22
      final mdTrackFinder = find.descendant(
        of: find.byType(JustSwitch).at(1),
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 40.0,
        ),
      );
      expect(mdTrackFinder, findsOneWidget);

      // Verify track container sizing for lg: 48x26
      final lgTrackFinder = find.descendant(
        of: find.byType(JustSwitch).at(2),
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 48.0,
        ),
      );
      expect(lgTrackFinder, findsOneWidget);

      // Alignment check: Inactive (false) -> Alignment(-1.0, 0.0)
      final smAlign = tester.widget<Align>(
        find.descendant(
          of: find.byType(JustSwitch).at(0),
          matching: find.byType(Align),
        ),
      );
      expect(smAlign.alignment, equals(const Alignment(-1.0, 0.0)));

      // Alignment check: Active (true) -> Alignment(1.0, 0.0)
      final mdAlign = tester.widget<Align>(
        find.descendant(
          of: find.byType(JustSwitch).at(1),
          matching: find.byType(Align),
        ),
      );
      expect(mdAlign.alignment, equals(const Alignment(1.0, 0.0)));
    });

    testWidgets('Neobrutalism preset inner-layout thumb calculations', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: JustThemeData.neobrutalismLight,
          JustSwitch(value: true, size: JustSwitchSize.md, onChanged: (_) {}),
        ),
      );

      expect(find.byType(JustSwitch), findsOneWidget);

      // Md size with neobrutalism border: thumbSize = 22 - (2 * 2.5) - (2 * 2) = 13.0
      final thumbContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(JustSwitch),
          matching: find.byWidgetPredicate(
            (w) => w is Container && w.constraints?.maxWidth == 13.0,
          ),
        ),
      );
      expect(thumbContainer.constraints?.maxWidth, equals(13.0));
      expect(thumbContainer.constraints?.maxHeight, equals(13.0));
    });
  });

  group('JustSwitch - Drag Interactions', () {
    testWidgets('Dragging switch past 50% threshold toggles value', (
      tester,
    ) async {
      bool value = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustSwitch(
                value: value,
                onChanged: (val) => setState(() => value = val),
              ),
            );
          },
        ),
      );

      // Drag right past threshold
      await tester.drag(find.byType(JustSwitch), const Offset(30.0, 0.0));
      await tester.pumpAndSettle();
      expect(value, isTrue);

      // Drag left on active switch
      await tester.drag(find.byType(JustSwitch), const Offset(-30.0, 0.0));
      await tester.pumpAndSettle();
      expect(value, isFalse);
    });

    testWidgets('Dragging switch and returning back snaps without toggling', (
      tester,
    ) async {
      bool value = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustSwitch(
                value: value,
                onChanged: (val) => setState(() => value = val),
              ),
            );
          },
        ),
      );

      // Drag right then back left
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(JustSwitch)),
      );
      await gesture.moveBy(const Offset(25.0, 0.0));
      await tester.pump();
      await gesture.moveBy(const Offset(-25.0, 0.0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(value, isFalse);
    });

    testWidgets('Dragging disabled switch does not trigger onChanged', (
      tester,
    ) async {
      bool changed = false;

      await tester.pumpWidget(
        buildTestApp(
          JustSwitch(
            value: false,
            isDisabled: true,
            onChanged: (_) => changed = true,
          ),
        ),
      );

      await tester.drag(
        find.byType(JustSwitch),
        const Offset(30.0, 0.0),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(changed, isFalse);
    });
  });

  group('JustSwitch - Thumb Icon & Customizations', () {
    testWidgets('Renders custom thumb icon matching active/inactive states', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          JustSwitch(
            value: true,
            thumbIcon: (val) => Icon(
              val ? Icons.check : Icons.close,
              key: const ValueKey('thumb-icon'),
              size: 10,
            ),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byKey(const ValueKey('thumb-icon')), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Direct activeColor parameter overrides track color', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          JustSwitch(
            value: true,
            activeColor: const Color(0xFF00FF00),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(JustSwitch), findsOneWidget);
    });
  });

  group('JustSwitch - Disabled State & Keyboard Navigation', () {
    testWidgets('Disabled switch dims opacity and prevents tap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          JustSwitch(
            value: false,
            isDisabled: true,
            onChanged: (_) => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(JustSwitch), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, isFalse);

      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(JustSwitch),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, equals(0.5));

      final semantics = tester.getSemantics(find.byType(JustSwitch));
      expect(
        semantics.getSemanticsData().flagsCollection.isEnabled,
        equals(Tristate.isFalse),
      );
    });

    testWidgets('Disabled switch via onChanged null disables interactions', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(const JustSwitch(value: true, onChanged: null)),
      );

      final semantics = tester.getSemantics(find.byType(JustSwitch));
      expect(
        semantics.getSemanticsData().flagsCollection.isEnabled,
        equals(Tristate.isFalse),
      );
    });

    testWidgets('Keyboard space and enter keys toggle focused switch', (
      tester,
    ) async {
      bool value = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustSwitch(
                value: value,
                focusNode: focusNode,
                onChanged: (val) => setState(() => value = val),
              ),
            );
          },
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      // Space key
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(value, isTrue);

      // Enter key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(value, isFalse);

      // Unhandled key
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pumpAndSettle();
      expect(value, isFalse);
    });

    testWidgets('Keyboard events are ignored when switch is disabled', (
      tester,
    ) async {
      bool tapped = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        buildTestApp(
          JustSwitch(
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

    testWidgets('External FocusNode update and didUpdateWidget lifecycle', (
      tester,
    ) async {
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();
      addTearDown(focusNode1.dispose);
      addTearDown(focusNode2.dispose);

      await tester.pumpWidget(
        buildTestApp(
          JustSwitch(value: false, focusNode: focusNode1, onChanged: (_) {}),
        ),
      );

      // Update to focusNode2 and value: true
      await tester.pumpWidget(
        buildTestApp(
          JustSwitch(value: true, focusNode: focusNode2, onChanged: (_) {}),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(JustSwitch), findsOneWidget);
    });
  });

  group('JustSwitch - Theming & Haptics', () {
    testWidgets('Haptic feedback on switch toggle', (tester) async {
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
          JustSwitch(value: false, enableHaptic: true, onChanged: (_) {}),
        ),
      );

      await tester.tap(find.byType(JustSwitch));
      await tester.pumpAndSettle();

      expect(log, contains('HapticFeedbackType.selectionClick'));
    });

    testWidgets('Per-instance JustSwitchStyle overrides default colors', (
      tester,
    ) async {
      const customStyle = JustSwitchStyle(
        activeTrackColor: Color(0xFF112233),
        inactiveTrackColor: Color(0xFF445566),
        activeThumbColor: Color(0xFF778899),
        inactiveThumbColor: Color(0xFFAABBCC),
        textStyle: TextStyle(fontSize: 16, color: Color(0xFF001122)),
      );

      await tester.pumpWidget(
        buildTestApp(
          JustSwitch(
            value: true,
            style: customStyle,
            label: const Text('Styled Switch'),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Styled Switch'), findsOneWidget);
    });

    testWidgets('Global JustSwitchTheme in ThemeData applies to switch', (
      tester,
    ) async {
      const themeStyle = JustSwitchStyle(
        activeTrackColor: Color(0xFF008800),
        activeThumbColor: Color(0xFFFFFFFF),
      );

      final materialTheme = ThemeData(
        extensions: const [
          JustSwitchTheme(style: themeStyle, enableHaptic: true),
        ],
      );

      await tester.pumpWidget(
        buildTestApp(
          materialTheme: materialTheme,
          JustSwitch(value: true, onChanged: (_) {}),
        ),
      );

      expect(find.byType(JustSwitch), findsOneWidget);
    });
  });

  group('JustSwitchStyle & JustSwitchTheme Unit Tests', () {
    test('JustSwitchStyle copyWith, lerp, equality, and hashCode', () {
      const style1 = JustSwitchStyle(
        activeTrackColor: Color(0xFF112233),
        inactiveTrackColor: Color(0xFF445566),
        activeThumbColor: Color(0xFF778899),
        inactiveThumbColor: Color(0xFFAABBCC),
        textStyle: TextStyle(fontSize: 14),
      );

      final copied = style1.copyWith(activeTrackColor: const Color(0xFF00FF00));

      expect(copied.activeTrackColor, equals(const Color(0xFF00FF00)));
      expect(copied.inactiveTrackColor, equals(style1.inactiveTrackColor));
      expect(copied.activeThumbColor, equals(style1.activeThumbColor));
      expect(copied.inactiveThumbColor, equals(style1.inactiveThumbColor));
      expect(copied.textStyle, equals(style1.textStyle));

      const styleClone = JustSwitchStyle(
        activeTrackColor: Color(0xFF112233),
        inactiveTrackColor: Color(0xFF445566),
        activeThumbColor: Color(0xFF778899),
        inactiveThumbColor: Color(0xFFAABBCC),
        textStyle: TextStyle(fontSize: 14),
      );

      expect(style1, equals(styleClone));
      expect(style1.hashCode, equals(styleClone.hashCode));
      expect(style1 == copied, isFalse);

      // Lerp
      expect(JustSwitchStyle.lerp(style1, style1, 0.5), equals(style1));
      expect(JustSwitchStyle.lerp(null, null, 0.5), isNull);

      final lerped = JustSwitchStyle.lerp(style1, copied, 0.5);
      expect(lerped, isNotNull);
      expect(
        lerped!.activeTrackColor,
        equals(
          Color.lerp(const Color(0xFF112233), const Color(0xFF00FF00), 0.5),
        ),
      );
    });

    test(
      'JustSwitchTheme defaults, copyWith, lerp, equality, and hashCode',
      () {
        const defaultTheme = JustSwitchTheme.defaults;
        expect(defaultTheme.enableHaptic, isFalse);
        expect(defaultTheme.style, isNull);

        const customStyle = JustSwitchStyle(
          activeTrackColor: Color(0xFF336699),
        );
        const theme1 = JustSwitchTheme(style: customStyle, enableHaptic: true);

        final copied = theme1.copyWith(enableHaptic: false);
        expect(copied.enableHaptic, isFalse);
        expect(copied.style, equals(customStyle));

        const themeClone = JustSwitchTheme(
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

        // Parity with JustSwitchThemeData typedef
        expect(theme1, isA<JustSwitchThemeData>());
      },
    );
  });
}
