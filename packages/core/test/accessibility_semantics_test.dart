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
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
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
          hasEnabledState: true,
          isFocusable: true,
          hasFocusAction: true,
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
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        bool toggled = true;

        await tester.pumpWidget(
          buildTestApp(
            JustSwitch(value: toggled, onChanged: (bool v) => toggled = v),
          ),
        );

        expect(
          tester.getSemantics(find.byType(JustSwitch)),
          matchesSemantics(
            isToggled: true,
            hasToggledState: true,
            isEnabled: true,
            hasEnabledState: true,
            isFocusable: true,
            hasFocusAction: true,
            label: 'Switch',
            hasTapAction: true,
          ),
        );

        handle.dispose();
      },
    );

    testWidgets('JustCheckbox exposes checked semantics and tap actions', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      bool checked = false;

      await tester.pumpWidget(
        buildTestApp(
          JustCheckbox(
            value: checked,
            onChanged: (bool? v) => checked = v ?? false,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(JustCheckbox)),
        matchesSemantics(
          isChecked: false,
          hasCheckedState: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasFocusAction: true,
          label: 'Checkbox',
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets(
      'JustSlider exposes slider semantics with value and increase/decrease actions',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        double sliderVal = 30.0;

        await tester.pumpWidget(
          buildTestApp(
            JustSlider(
              value: sliderVal,
              min: 0.0,
              max: 100.0,
              onChanged: (double v) => sliderVal = v,
            ),
          ),
        );

        expect(
          tester.getSemantics(find.byType(JustSlider)),
          matchesSemantics(
            isSlider: true,
            isEnabled: true,
            hasEnabledState: true,
            isFocusable: true,
            hasFocusAction: true,
            hasTapAction: true,
            value: '30.0',
            increasedValue: '35.0',
            decreasedValue: '25.0',
            hasIncreaseAction: true,
            hasDecreaseAction: true,
            hasScrollDownAction: true,
            hasScrollLeftAction: true,
            hasScrollRightAction: true,
            hasScrollUpAction: true,
          ),
        );

        handle.dispose();
      },
    );
  });

  group('WCAG 2.2 AA Contrast Audits', () {
    test('Default Light and Dark theme colors meet WCAG AA contrast ratio (>= 4.5)', () {
      final JustColorScheme lightColors = JustColors.light();
      final JustColorScheme darkColors = JustColors.dark();

      final double lightBodyContrast = lightColors.textPrimary
          .contrastRatioWith(lightColors.background);
      final double darkBodyContrast = darkColors.textPrimary.contrastRatioWith(
        darkColors.background,
      );

      expect(lightBodyContrast, greaterThanOrEqualTo(4.5));
      expect(darkBodyContrast, greaterThanOrEqualTo(4.5));
    });

    test('High contrast mode overrides force minimum contrast and accessible borders', () {
      final JustThemeData baseTheme = JustThemeData.light;
      final JustThemeData highContrastTheme = baseTheme
          .applyHighContrastOverrides();

      expect(
        highContrastTheme.colors.background,
        equals(const Color(0xFFFFFFFF)),
      );
      expect(
        highContrastTheme.colors.textPrimary,
        equals(const Color(0xFF000000)),
      );

      final double contrast = highContrastTheme.colors.textPrimary
          .contrastRatioWith(highContrastTheme.colors.background);
      expect(contrast, greaterThanOrEqualTo(7.0)); // WCAG AAA requirement
    });
  });
}
