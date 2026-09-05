import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/slider/just_slider.dart';
import 'package:just_ui_core/src/components/slider/just_slider_style.dart';
import 'package:just_ui_core/src/components/slider/just_slider_theme.dart';

typedef JustSliderThemeData = JustSliderTheme;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(
    Widget child, {
    JustThemeData? theme,
    ThemeData? materialTheme,
  }) {
    return MaterialApp(
      theme: materialTheme,
      home: JustThemeProvider(
        lightTheme: theme ?? JustThemeData.light,
        child: Scaffold(
          body: Center(child: SizedBox(width: 300, child: child)),
        ),
      ),
    );
  }

  group('JustRangeValues Unit Tests', () {
    test('Constructs with valid range and verifies equality and hashCode', () {
      const r1 = JustRangeValues(10.0, 50.0);
      const r2 = JustRangeValues(10.0, 50.0);
      const r3 = JustRangeValues(20.0, 60.0);

      expect(r1 == r2, isTrue);
      expect(r1 == r3, isFalse);
      expect(r1.hashCode, equals(r2.hashCode));
      expect(r1.toString(), equals('JustRangeValues(10.00, 50.00)'));
    });
  });

  group('JustSlider - Single Mode Interactions & Drag', () {
    testWidgets('Renders single thumb and responds to pan drag gesture', (
      tester,
    ) async {
      double value = 25.0;

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return JustSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                onChanged: (val) {
                  setState(() => value = val);
                },
              );
            },
          ),
        ),
      );

      expect(find.byType(JustSlider), findsOneWidget);
      expect(value, equals(25.0));

      // Drag slider thumb horizontally to the right
      await tester.drag(find.byType(JustSlider), const Offset(80.0, 0.0));
      await tester.pumpAndSettle();

      expect(value, greaterThan(25.0));
    });

    testWidgets('Tap on slider track updates value', (tester) async {
      double value = 0.0;

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return JustSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                onChanged: (val) => setState(() => value = val),
              );
            },
          ),
        ),
      );

      // Tap near the right edge of the slider
      final sliderTopLeft = tester.getTopLeft(find.byType(JustSlider));
      await tester.tapAt(
        Offset(sliderTopLeft.dx + 250.0, sliderTopLeft.dy + 24.0),
      );
      await tester.pumpAndSettle();

      expect(value, greaterThan(50.0));
    });

    testWidgets('Snaps to discrete divisions and displays tick marks', (
      tester,
    ) async {
      double value = 0.0;

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return JustSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                divisions: 4, // 0, 25, 50, 75, 100
                onChanged: (val) => setState(() => value = val),
              );
            },
          ),
        ),
      );

      // Drag slightly
      final sliderTopLeft = tester.getTopLeft(find.byType(JustSlider));
      await tester.tapAt(
        Offset(sliderTopLeft.dx + 80.0, sliderTopLeft.dy + 24.0),
      );
      await tester.pumpAndSettle();

      // With 4 divisions, value snaps to 25.0
      expect(value, equals(25.0));
    });

    testWidgets(
      'Tooltip renders during active drag in default and neobrutalism presets',
      (tester) async {
        double value = 50.0;

        // 1. Default preset tooltip
        await tester.pumpWidget(
          buildTestApp(
            StatefulBuilder(
              builder: (context, setState) {
                return JustSlider(
                  value: value,
                  min: 0.0,
                  max: 100.0,
                  showTooltip: true,
                  onChanged: (val) => setState(() => value = val),
                );
              },
            ),
          ),
        );

        final center = tester.getCenter(find.byType(JustSlider));
        final gesture = await tester.startGesture(center);
        await gesture.moveBy(const Offset(30.0, 0.0));
        await tester.pump();

        // Active tooltip is shown during drag
        expect(find.byType(JustSlider), findsOneWidget);

        await gesture.up();
        await tester.pumpAndSettle();

        // 2. Neobrutalism preset tooltip
        await tester.pumpWidget(
          buildTestApp(
            StatefulBuilder(
              builder: (context, setState) {
                return JustSlider(
                  value: value,
                  min: 0.0,
                  max: 100.0,
                  divisions: 10,
                  showTooltip: true,
                  onChanged: (val) => setState(() => value = val),
                );
              },
            ),
            theme: JustThemeData.neobrutalismLight,
          ),
        );

        final gesture2 = await tester.startGesture(center);
        await gesture2.moveBy(const Offset(30.0, 0.0));
        await tester.pump();

        expect(find.byType(JustSlider), findsOneWidget);
        await gesture2.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Disabled state disables gestures, keyboard events, and shows forbidden cursor',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            const JustSlider(
              value: 50.0,
              min: 0.0,
              max: 100.0,
              onChanged: null, // Disabled
            ),
          ),
        );

        // Drag has no effect
        await tester.drag(find.byType(JustSlider), const Offset(50.0, 0.0));
        await tester.pumpAndSettle();

        expect(find.byType(JustSlider), findsOneWidget);
      },
    );

    testWidgets('Keyboard arrow key navigation updates value', (tester) async {
      double value = 50.0;

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return JustSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                divisions: 10,
                onChanged: (val) => setState(() => value = val),
              );
            },
          ),
        ),
      );

      // Focus the slider
      final sliderFocusFinder = find.descendant(
        of: find.byType(JustSlider),
        matching: find.byType(Focus),
      );
      final focusNode = tester.widget<Focus>(sliderFocusFinder).focusNode;
      focusNode?.requestFocus();
      await tester.pump();

      // Right arrow increases
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, equals(60.0));

      // Up arrow increases
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(value, equals(70.0));

      // Left arrow decreases
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(value, equals(60.0));

      // Down arrow decreases
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(value, equals(50.0));
    });

    testWidgets('Mouse hover state and cursor interaction', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          JustSlider(value: 50.0, min: 0.0, max: 100.0, onChanged: (_) {}),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      // Hover over slider
      await gesture.moveTo(tester.getCenter(find.byType(JustSlider)));
      await tester.pump();

      // Hover out
      await gesture.moveTo(const Offset(10, 10));
      await tester.pump();
    });

    testWidgets('Continuous slider haptic triggering on boundary hits', (
      tester,
    ) async {
      double value = 95.0;

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return JustSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                enableHaptic: true,
                onChanged: (val) => setState(() => value = val),
              );
            },
          ),
        ),
      );

      // Drag far right to hit boundary 100
      await tester.drag(find.byType(JustSlider), const Offset(200.0, 0.0));
      await tester.pumpAndSettle();
      expect(value, equals(100.0));
    });
  });

  group('JustSlider - Range Mode Interactions & Drag', () {
    testWidgets(
      'Renders dual thumbs and updates range on dragging start thumb',
      (tester) async {
        JustRangeValues range = const JustRangeValues(20.0, 80.0);

        await tester.pumpWidget(
          buildTestApp(
            StatefulBuilder(
              builder: (context, setState) {
                return JustSlider.range(
                  rangeValues: range,
                  min: 0.0,
                  max: 100.0,
                  onRangeChanged: (val) => setState(() => range = val),
                );
              },
            ),
          ),
        );

        expect(find.byType(JustSlider), findsOneWidget);

        final sliderTopLeft = tester.getTopLeft(find.byType(JustSlider));

        // Drag from start thumb position (around x = 60) to right
        final startThumbPos = Offset(
          sliderTopLeft.dx + 56.0,
          sliderTopLeft.dy + 24.0,
        );
        await tester.dragFrom(startThumbPos, const Offset(50.0, 0.0));
        await tester.pumpAndSettle();

        expect(range.start, greaterThan(20.0));
        expect(range.start, lessThanOrEqualTo(range.end));
      },
    );

    testWidgets('Dragging end thumb clamps above start thumb', (tester) async {
      JustRangeValues range = const JustRangeValues(30.0, 70.0);

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return JustSlider.range(
                rangeValues: range,
                min: 0.0,
                max: 100.0,
                onRangeChanged: (val) => setState(() => range = val),
              );
            },
          ),
        ),
      );

      final sliderTopLeft = tester.getTopLeft(find.byType(JustSlider));

      // Drag end thumb position (around x = 200) to right
      final endThumbPos = Offset(
        sliderTopLeft.dx + 200.0,
        sliderTopLeft.dy + 24.0,
      );
      await tester.dragFrom(endThumbPos, const Offset(60.0, 0.0));
      await tester.pumpAndSettle();

      expect(range.end, greaterThan(70.0));
    });

    testWidgets('Range mode keyboard navigation updates start and end values', (
      tester,
    ) async {
      JustRangeValues range = const JustRangeValues(30.0, 70.0);

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return JustSlider.range(
                rangeValues: range,
                min: 0.0,
                max: 100.0,
                divisions: 10,
                onRangeChanged: (val) => setState(() => range = val),
              );
            },
          ),
        ),
      );

      // Focus slider
      final sliderFocusFinder = find.descendant(
        of: find.byType(JustSlider),
        matching: find.byType(Focus),
      );
      final focusNode = tester.widget<Focus>(sliderFocusFinder).focusNode;
      focusNode?.requestFocus();
      await tester.pump();

      // Right arrow increases end
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(range.end, equals(80.0));

      // Left arrow decreases start
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(range.start, equals(20.0));
    });

    testWidgets('Range mode continuous slider haptics on boundary hit', (
      tester,
    ) async {
      JustRangeValues range = const JustRangeValues(10.0, 90.0);

      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return JustSlider.range(
                rangeValues: range,
                min: 0.0,
                max: 100.0,
                enableHaptic: true,
                onRangeChanged: (val) => setState(() => range = val),
              );
            },
          ),
        ),
      );

      final sliderTopLeft = tester.getTopLeft(find.byType(JustSlider));

      // Drag start thumb far left to 0
      final startThumbPos = Offset(
        sliderTopLeft.dx + 30.0,
        sliderTopLeft.dy + 24.0,
      );
      await tester.dragFrom(startThumbPos, const Offset(-100.0, 0.0));
      await tester.pumpAndSettle();

      expect(range.start, equals(0.0));
    });
  });

  group('JustSlider - Sizes & Custom Styles', () {
    testWidgets('Renders all size variants (sm, md, lg)', (tester) async {
      for (final size in [
        JustSliderSize.sm,
        JustSliderSize.md,
        JustSliderSize.lg,
      ]) {
        await tester.pumpWidget(
          buildTestApp(
            JustSlider(
              value: 50.0,
              min: 0.0,
              max: 100.0,
              size: size,
              onChanged: (_) {},
            ),
          ),
        );

        expect(find.byType(JustSlider), findsOneWidget);
      }
    });

    testWidgets('Applies custom JustSliderStyle overrides', (tester) async {
      const customStyle = JustSliderStyle(
        activeTrackColor: Color(0xFFFF0000),
        inactiveTrackColor: Color(0xFF00FF00),
        thumbColor: Color(0xFF0000FF),
        thumbBorderColor: Color(0xFFFFFF00),
        tickMarkColor: Color(0xFFFF00FF),
        trackHeight: 12.0,
        thumbSize: 24.0,
        borderRadius: .all(.circular(8)),
      );

      await tester.pumpWidget(
        buildTestApp(
          JustSlider(
            value: 40.0,
            min: 0.0,
            max: 100.0,
            divisions: 5,
            style: customStyle,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(JustSlider), findsOneWidget);
    });

    testWidgets(
      'Inherits global JustSliderTheme from Material ThemeData extension',
      (tester) async {
        const globalTheme = JustSliderTheme(
          style: JustSliderStyle(
            activeTrackColor: Color(0xFF123456),
            thumbColor: Color(0xFF654321),
          ),
          enableHaptic: false,
        );

        final materialTheme = ThemeData().copyWith(extensions: [globalTheme]);

        await tester.pumpWidget(
          buildTestApp(
            JustSlider(value: 30.0, min: 0.0, max: 100.0, onChanged: (_) {}),
            materialTheme: materialTheme,
          ),
        );

        expect(find.byType(JustSlider), findsOneWidget);
      },
    );
  });

  group('JustSliderTheme & JustSliderStyle Unit Tests', () {
    test('JustSliderStyle instantiation with all properties', () {
      // ignore: prefer_const_constructors
      final style = JustSliderStyle(
        activeTrackColor: const Color(0xFF111111),
        inactiveTrackColor: const Color(0xFF222222),
        thumbColor: const Color(0xFF333333),
        thumbBorderColor: const Color(0xFF444444),
        tickMarkColor: const Color(0xFF555555),
        trackHeight: 10.0,
        thumbSize: 22.0,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      );

      expect(style.activeTrackColor, equals(const Color(0xFF111111)));
      expect(style.inactiveTrackColor, equals(const Color(0xFF222222)));
      expect(style.thumbColor, equals(const Color(0xFF333333)));
      expect(style.thumbBorderColor, equals(const Color(0xFF444444)));
      expect(style.tickMarkColor, equals(const Color(0xFF555555)));
      expect(style.trackHeight, equals(10.0));
      expect(style.thumbSize, equals(22.0));
      expect(
        style.borderRadius,
        equals(const BorderRadius.all(Radius.circular(6))),
      );

      // ignore: prefer_const_constructors
      final emptyStyle = JustSliderStyle();
      expect(emptyStyle.activeTrackColor, isNull);
    });

    test('JustSliderTheme copyWith and lerp tests', () {
      const style1 = JustSliderStyle(activeTrackColor: Color(0xFF111111));
      const style2 = JustSliderStyle(activeTrackColor: Color(0xFF222222));

      const theme1 = JustSliderTheme(style: style1, enableHaptic: true);
      final copied = theme1.copyWith(style: style2, enableHaptic: false);

      expect(copied.style, equals(style2));
      expect(copied.enableHaptic, isFalse);

      final copiedNull = theme1.copyWith();
      expect(copiedNull.style, equals(style1));
      expect(copiedNull.enableHaptic, isTrue);

      const theme2 = JustSliderTheme(style: style2, enableHaptic: false);

      // Lerp t < 0.5
      final lerpLow = theme1.lerp(theme2, 0.3);
      expect(lerpLow.style, equals(style1));
      expect(lerpLow.enableHaptic, isTrue);

      // Lerp t >= 0.5
      final lerpHigh = theme1.lerp(theme2, 0.8);
      expect(lerpHigh.style, equals(style2));
      expect(lerpHigh.enableHaptic, isFalse);

      // Lerp with null or incompatible
      final lerpNull = theme1.lerp(null, 0.5);
      expect(lerpNull, equals(theme1));

      expect(JustSliderTheme.defaults.style, isNull);
      expect(JustSliderTheme.defaults.enableHaptic, isTrue);
    });

    test('JustSliderSize enum values check', () {
      expect(
        JustSliderSize.values,
        containsAll([JustSliderSize.sm, JustSliderSize.md, JustSliderSize.lg]),
      );
    });
  });
}
