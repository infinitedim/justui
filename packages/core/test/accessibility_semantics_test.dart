import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';
import 'package:just_ui_core/src/components/slider/just_slider.dart';
import 'package:just_ui_core/src/components/switch/just_switch.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(Widget child, {JustThemeData? theme}) {
    return MaterialApp(
      home: JustThemeProvider(
        lightTheme: theme ?? JustThemeData.light,
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('Accessibility & Semantics Tree Audits', () {
    testWidgets('JustButton exposes button semantics and tap actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      bool tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          JustButton(label: 'Submit Action', onPressed: () => tapped = true),
        ),
      );

      expect(
        tester.getSemantics(find.byType(JustButton)),
        matchesSemantics(
          isButton: true,
          isEnabled: true,
          label: 'Submit Action',
          hasTapAction: true,
        ),
      );

      await tester.tap(find.byType(JustButton));
      expect(tapped, isTrue);

      handle.dispose();
    });

    testWidgets(
      'JustSwitch exposes toggled semantics and screen reader actions',
      (tester) async {
        final handle = tester.ensureSemantics();
        bool toggled = true;

        await tester.pumpWidget(
          buildTestApp(
            JustSwitch(value: toggled, onChanged: (v) => toggled = v),
          ),
        );

        expect(
          tester.getSemantics(find.byType(JustSwitch)),
          matchesSemantics(
            isToggled: true,
            isEnabled: true,
            hasTapAction: true,
          ),
        );

        handle.dispose();
      },
    );

    testWidgets('JustCheckbox exposes checked semantics and tap actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      bool checked = false;

      await tester.pumpWidget(
        buildTestApp(
          JustCheckbox(value: checked, onChanged: (v) => checked = v ?? false),
        ),
      );

      expect(
        tester.getSemantics(find.byType(JustCheckbox)),
        matchesSemantics(isChecked: false, isEnabled: true, hasTapAction: true),
      );

      handle.dispose();
    });

    testWidgets(
      'JustSlider exposes slider semantics with value and increase/decrease actions',
      (tester) async {
        final handle = tester.ensureSemantics();
        double sliderVal = 30.0;

        await tester.pumpWidget(
          buildTestApp(
            JustSlider(
              value: sliderVal,
              min: 0.0,
              max: 100.0,
              onChanged: (v) => sliderVal = v,
            ),
          ),
        );

        expect(
          tester.getSemantics(find.byType(JustSlider)),
          matchesSemantics(
            isEnabled: true,
            value: '30%',
            hasIncreaseAction: true,
            hasDecreaseAction: true,
          ),
        );

        handle.dispose();
      },
    );
  });

  group('WCAG 2.2 AA Contrast Audits', () {
    test('Default Light and Dark theme colors meet WCAG AA contrast ratio (>= 4.5)', () {
      final lightColors = JustColors.light();
      final darkColors = JustColors.dark();

      final lightBodyContrast = lightColors.textPrimary.contrastRatioWith(
        lightColors.background,
      );
      final darkBodyContrast = darkColors.textPrimary.contrastRatioWith(
        darkColors.background,
      );

      expect(lightBodyContrast, greaterThanOrEqualTo(4.5));
      expect(darkBodyContrast, greaterThanOrEqualTo(4.5));
    });

    test('High contrast mode overrides force minimum contrast and accessible borders', () {
      final baseTheme = JustThemeData.light;
      final highContrastTheme = baseTheme.applyHighContrastOverrides();

      expect(
        highContrastTheme.colors.background,
        equals(const Color(0xFFFFFFFF)),
      );
      expect(
        highContrastTheme.colors.textPrimary,
        equals(const Color(0xFF000000)),
      );

      final contrast = highContrastTheme.colors.textPrimary.contrastRatioWith(
        highContrastTheme.colors.background,
      );
      expect(contrast, greaterThanOrEqualTo(7.0)); // WCAG AAA requirement
    });
  });
}
