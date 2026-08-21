import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog.dart';
import 'package:just_ui_core/src/components/input/just_input.dart';
import 'package:just_ui_core/src/components/select/just_select.dart';
import 'package:just_ui_core/src/components/shared/_shared_pressable.dart';
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

  group('JustInput Widget Tests', () {
    testWidgets('Renders input text and handles user typing', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildTestApp(JustInput(controller: controller)));

      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Hello JustUI');
      expect(controller.text, equals('Hello JustUI'));
    });

    testWidgets('Triggers clear button tap to reset text', (tester) async {
      final controller = TextEditingController(text: 'Initial Text');
      await tester.pumpWidget(
        buildTestApp(JustInput(controller: controller, showClearButton: true)),
      );

      expect(controller.text, equals('Initial Text'));
      await tester.tap(find.byType(JustPressable));
      await tester.pumpAndSettle();
      expect(controller.text, isEmpty);
    });

    testWidgets('Applies disabled state and guards interaction', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Disabled');
      await tester.pumpWidget(
        buildTestApp(JustInput(controller: controller, enabled: false)),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });

  group('JustSwitch & JustCheckbox Widget Tests', () {
    testWidgets('JustSwitch toggles value on tap', (tester) async {
      bool value = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustSwitch(
                value: value,
                onChanged: (v) => setState(() => value = v),
              ),
            );
          },
        ),
      );

      expect(value, isFalse);
      await tester.tap(find.byType(JustSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });

    testWidgets(
      'JustCheckbox toggles value on tap and meets minimum touch target',
      (tester) async {
        bool value = false;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildTestApp(
                JustCheckbox(
                  value: value,
                  onChanged: (v) => setState(() => value = v ?? false),
                ),
              );
            },
          ),
        );

        expect(value, isFalse);
        final size = tester.getSize(find.byType(JustCheckbox));
        expect(size.width, greaterThanOrEqualTo(44.0));
        expect(size.height, greaterThanOrEqualTo(44.0));

        await tester.tap(find.byType(JustCheckbox));
        await tester.pumpAndSettle();
        expect(value, isTrue);
      },
    );
  });

  group('JustSlider Widget Tests', () {
    testWidgets('JustSlider clamps value and responds to drag', (tester) async {
      double value = 50.0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                onChanged: (v) => setState(() => value = v),
              ),
            );
          },
        ),
      );

      expect(value, equals(50.0));
      await tester.drag(find.byType(JustSlider), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(value, greaterThan(50.0));
    });

    testWidgets('JustSlider responds to keyboard arrow key events', (
      tester,
    ) async {
      double value = 50.0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                onChanged: (v) => setState(() => value = v),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(JustSlider));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, greaterThan(50.0));
    });
  });

  group('JustSelect & JustDialogScope Widget Tests', () {
    testWidgets('JustSelect opens dropdown overlay and selects option', (
      tester,
    ) async {
      String selected = 'Option A';
      final options = [
        const JustSelectOption(value: 'Option A', label: 'Option A'),
        const JustSelectOption(value: 'Option B', label: 'Option B'),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestApp(
              JustSelect<String>(
                value: selected,
                options: options,
                onChanged: (v) {
                  setState(() => selected = v);
                },
              ),
            );
          },
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      await tester.tap(find.byType(JustSelect<String>));
      await tester.pumpAndSettle();

      // Dropdown overlay items
      expect(find.text('Option B'), findsOneWidget);
      await tester.tap(find.text('Option B').last);
      await tester.pumpAndSettle();
      expect(selected, equals('Option B'));
    });

    testWidgets('JustDialogController shows and dismisses dialog', (
      tester,
    ) async {
      final dialogController = JustDialogController();

      await tester.pumpWidget(
        MaterialApp(
          home: JustThemeProvider(
            lightTheme: JustThemeData.light,
            child: JustDialogScope(
              controller: dialogController,
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        context.justDialog.show<void>(
                          content: const Text('Dialog Body'),
                        );
                      },
                      child: const Text('Open Dialog'),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Body'), findsOneWidget);
      expect(dialogController.isVisible, isTrue);

      dialogController.forceDismissAll();
      await tester.pumpAndSettle();
      expect(dialogController.isVisible, isFalse);
    });
  });
}
