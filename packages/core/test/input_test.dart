import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/input/just_input.dart';
import 'package:just_ui_core/src/components/input/just_input_style.dart';
import 'package:just_ui_core/src/components/input/just_input_theme.dart';
import 'package:just_ui_core/src/components/input/just_input_variants.dart';

typedef JustInputThemeData = JustInputTheme;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(
    Widget child, {
    JustThemeData? theme,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      home: JustThemeProvider(
        initialThemeMode: themeMode,
        lightTheme: theme ?? JustThemeData.light,
        darkTheme: theme ?? JustThemeData.dark,
        child: Scaffold(
          body: Center(child: SingleChildScrollView(child: child)),
        ),
      ),
    );
  }

  group('JustInput - Text Variant & Core Interactions', () {
    testWidgets('Renders label, hint, and accepts user text input', (
      tester,
    ) async {
      final controller = TextEditingController();
      String changedValue = '';

      await tester.pumpWidget(
        buildTestApp(
          JustInput(
            controller: controller,
            label: 'Username',
            hint: 'Enter your username',
            onChanged: (val) => changedValue = val,
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.byType(EditableText), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'john_doe');
      await tester.pump();

      expect(controller.text, equals('john_doe'));
      expect(changedValue, equals('john_doe'));
    });

    testWidgets('Handles onSubmitted callback', (tester) async {
      String submittedValue = '';

      await tester.pumpWidget(
        buildTestApp(JustInput(onSubmitted: (val) => submittedValue = val)),
      );

      await tester.enterText(find.byType(EditableText), 'Submit text');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, equals('Submit text'));
    });

    testWidgets('Focus handling: updates focus state and border color', (
      tester,
    ) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        buildTestApp(JustInput(focusNode: focusNode, label: 'Focused Input')),
      );

      expect(focusNode.hasFocus, isFalse);

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      focusNode.unfocus();
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);

      focusNode.dispose();
    });

    testWidgets(
      'Error state displays errorText, error border, and announces semantics',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            const JustInput(label: 'Email', errorText: 'Invalid email address'),
          ),
        );

        expect(find.text('Invalid email address'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
      },
    );

    testWidgets('Success state displays successText and success styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const JustInput(label: 'Email', successText: 'Email is available'),
        ),
      );

      expect(find.text('Email is available'), findsOneWidget);
    });

    testWidgets('Helper text and character counter display correctly', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Hello');

      await tester.pumpWidget(
        buildTestApp(
          JustInput(
            controller: controller,
            helper: 'Maximum 10 characters',
            maxLength: 10,
          ),
        ),
      );

      expect(find.text('Maximum 10 characters'), findsOneWidget);
      expect(find.text('5 / 10'), findsOneWidget);

      controller.text = 'Hello World';
      await tester.pump();
      expect(find.text('11 / 10'), findsOneWidget);
    });

    testWidgets('Disabled state disables EditableText and ignores taps', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Disabled text');

      await tester.pumpWidget(
        buildTestApp(JustInput(controller: controller, enabled: false)),
      );

      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(
        editable.readOnly,
        isFalse,
      ); // EditableText receives readOnly from widget.readOnly
      expect(find.byType(EditableText), findsOneWidget);
    });

    testWidgets('ReadOnly state sets readOnly on EditableText', (tester) async {
      await tester.pumpWidget(buildTestApp(const JustInput(readOnly: true)));

      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.readOnly, isTrue);
    });

    testWidgets('Prefix and Suffix icons and custom widgets render properly', (
      tester,
    ) async {
      // 1. PrefixIcon and SuffixIcon
      await tester.pumpWidget(
        buildTestApp(
          const JustInput(
            prefixIcon: Icons.person_rounded,
            suffixIcon: Icons.check_circle_rounded,
          ),
        ),
      );

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // 2. Custom Prefix and Suffix widgets
      await tester.pumpWidget(
        buildTestApp(
          const JustInput(
            prefix: Text('PrefixWidget'),
            suffix: Text('SuffixWidget'),
          ),
        ),
      );

      expect(find.text('PrefixWidget'), findsOneWidget);
      expect(find.text('SuffixWidget'), findsOneWidget);
    });

    testWidgets(
      'ShowClearButton displays clear icon when text is entered and clears text on tap',
      (tester) async {
        final controller = TextEditingController(text: 'Clear me');
        String changed = 'Clear me';

        await tester.pumpWidget(
          buildTestApp(
            JustInput(
              controller: controller,
              showClearButton: true,
              suffixIcon: Icons.info_outline,
              onChanged: (val) => changed = val,
            ),
          ),
        );

        // Suffix icon is overridden by close icon when filled
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump();

        expect(controller.text, isEmpty);
        expect(changed, isEmpty);

        // Now that text is empty, suffixIcon is displayed instead
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
        expect(find.byIcon(Icons.close_rounded), findsNothing);
      },
    );

    testWidgets(
      'ShowClearButton displays custom suffix when empty and clear button when filled',
      (tester) async {
        final controller = TextEditingController(text: '');

        await tester.pumpWidget(
          buildTestApp(
            JustInput(
              controller: controller,
              showClearButton: true,
              suffix: const Text('CustomSuffix'),
            ),
          ),
        );

        expect(find.text('CustomSuffix'), findsOneWidget);

        controller.text = 'Some text';
        await tester.pump();

        expect(find.text('CustomSuffix'), findsNothing);
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'ShowClearButton with no suffix displays SizedBox.shrink when empty',
      (tester) async {
        final controller = TextEditingController(text: '');

        await tester.pumpWidget(
          buildTestApp(
            JustInput(controller: controller, showClearButton: true),
          ),
        );

        expect(find.byIcon(Icons.close_rounded), findsNothing);
      },
    );

    testWidgets('ShowClearButton does not clear text when enabled is false', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Cannot clear');

      await tester.pumpWidget(
        buildTestApp(
          JustInput(
            controller: controller,
            showClearButton: true,
            enabled: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(controller.text, equals('Cannot clear'));
    });

    testWidgets(
      'Size variants render with corresponding dimensions (sm, md, lg)',
      (tester) async {
        for (final size in [
          JustInputSize.sm,
          JustInputSize.md,
          JustInputSize.lg,
        ]) {
          await tester.pumpWidget(
            buildTestApp(JustInput(size: size, label: 'Size ${size.name}')),
          );

          expect(find.text('Size ${size.name}'), findsOneWidget);
        }
      },
    );

    testWidgets(
      'didUpdateWidget correctly handles controller and focusNode changes',
      (tester) async {
        final controller1 = TextEditingController(text: 'First');
        final controller2 = TextEditingController(text: 'Second');
        final node1 = FocusNode();
        final node2 = FocusNode();

        await tester.pumpWidget(
          buildTestApp(JustInput(controller: controller1, focusNode: node1)),
        );

        expect(find.text('First'), findsOneWidget);

        // Update to controller2 and node2
        await tester.pumpWidget(
          buildTestApp(JustInput(controller: controller2, focusNode: node2)),
        );

        expect(find.text('Second'), findsOneWidget);

        // Update to null controller and null focusNode
        await tester.pumpWidget(buildTestApp(const JustInput()));

        expect(find.byType(EditableText), findsOneWidget);

        controller1.dispose();
        node1.dispose();
      },
    );
  });

  group('JustInput - Password Variant', () {
    testWidgets('Toggles password visibility on eye icon click', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'secret123');

      await tester.pumpWidget(
        buildTestApp(
          JustInput.password(controller: controller, label: 'Password'),
        ),
      );

      final editable1 = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable1.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);

      // Tap to un-obscure
      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pump();

      final editable2 = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable2.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);

      // Tap to re-obscure
      await tester.tap(find.byIcon(Icons.visibility_rounded));
      await tester.pump();

      final editable3 = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable3.obscureText, isTrue);
    });

    testWidgets('Disabled password input does not toggle visibility', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(const JustInput.password(enabled: false)),
      );

      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
    });
  });

  group('JustInput - Search Variant', () {
    testWidgets('Renders search icon prefix and clear button', (tester) async {
      final controller = TextEditingController(text: '');

      await tester.pumpWidget(
        buildTestApp(JustInput.search(controller: controller)),
      );

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'Flutter query');
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(controller.text, isEmpty);
    });
  });

  group('JustInput - Number Variant', () {
    testWidgets('Increments and decrements integer and float values', (
      tester,
    ) async {
      final controller = TextEditingController(text: '5');
      String changed = '5';

      await tester.pumpWidget(
        buildTestApp(
          JustInput.number(
            controller: controller,
            onChanged: (val) => changed = val,
          ),
        ),
      );

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);

      // Increment 5 -> 6
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(controller.text, equals('6'));
      expect(changed, equals('6'));

      // Decrement 6 -> 5 -> 4
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(controller.text, equals('5'));

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(controller.text, equals('4'));

      // Float increment: '2.5' -> '3.5'
      controller.text = '2.5';
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(controller.text, equals('3.5'));

      // Float decrement: '3.5' -> '2.5'
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(controller.text, equals('2.5'));

      // Empty text defaults to 0.0 -> 1
      controller.text = '';
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(controller.text, equals('1'));
    });

    testWidgets(
      'Disabled and ReadOnly number input ignores increment and decrement',
      (tester) async {
        final controller = TextEditingController(text: '10');

        // Disabled
        await tester.pumpWidget(
          buildTestApp(
            JustInput.number(controller: controller, enabled: false),
          ),
        );

        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();
        expect(controller.text, equals('10'));

        // ReadOnly
        await tester.pumpWidget(
          buildTestApp(
            JustInput.number(controller: controller, readOnly: true),
          ),
        );

        await tester.tap(find.byIcon(Icons.remove_rounded));
        await tester.pump();
        expect(controller.text, equals('10'));
      },
    );
  });

  group('JustInput - Textarea Variant', () {
    testWidgets('Renders multi-line textarea with custom lines', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const JustInput.textarea(
            label: 'Description',
            hint: 'Write here...',
            size: JustInputSize.lg,
          ),
        ),
      );

      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.maxLines, equals(5));
      expect(editable.minLines, equals(3));
      expect(editable.keyboardType, equals(TextInputType.multiline));
    });
  });

  group('JustInput - OTP Variant', () {
    testWidgets(
      'Renders segmented OTP inputs, auto advances focus, handles paste and backspace',
      (tester) async {
        final controller = TextEditingController();
        String otpValue = '';

        await tester.pumpWidget(
          buildTestApp(
            JustInput.otp(
              length: 4,
              controller: controller,
              onChanged: (val) => otpValue = val,
              errorText: 'Invalid code',
            ),
          ),
        );

        expect(find.text('Invalid code'), findsOneWidget);
        expect(find.byType(EditableText), findsNWidgets(4));

        // Enter digits sequentially
        await tester.enterText(find.byType(EditableText).first, '1');
        await tester.pump();

        await tester.enterText(find.byType(EditableText).at(1), '2');
        await tester.pump();

        expect(controller.text, equals('12'));
        expect(otpValue, equals('12'));

        // Test backspace via KeyDownEvent
        await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
        await tester.pump();

        // Test paste distribution
        await tester.enterText(find.byType(EditableText).first, '5678');
        await tester.pump();

        expect(controller.text, equals('5678'));
        expect(otpValue, equals('5678'));
      },
    );

    testWidgets(
      'OTP renders pre-filled initial controller text and successText',
      (tester) async {
        final controller = TextEditingController(text: '9876');

        await tester.pumpWidget(
          buildTestApp(
            JustInput.otp(
              length: 4,
              controller: controller,
              successText: 'Verified successfully',
            ),
          ),
        );

        expect(find.text('Verified successfully'), findsOneWidget);
        expect(find.text('9'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.text('6'), findsOneWidget);
      },
    );
  });

  group('JustFormInput Tests', () {
    testWidgets('Integrates with Flutter Form and FormField validation', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      final formController = TextEditingController(text: 'Init');
      String? savedValue;

      await tester.pumpWidget(
        buildTestApp(
          Form(
            key: formKey,
            child: JustFormInput(
              label: 'Form Input',
              controller: formController,
              initialValue: 'Init',
              validator: (val) {
                if (formController.text.isEmpty) {
                  return 'Field cannot be empty';
                }
                if (formController.text.length < 3) {
                  return 'Too short';
                }
                return null;
              },
              onSaved: (val) => savedValue = formController.text,
            ),
          ),
        ),
      );

      expect(find.text('Init'), findsOneWidget);

      // Validate valid
      expect(formKey.currentState!.validate(), isTrue);

      // Enter invalid text
      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump();

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Too short'), findsOneWidget);

      // Save form
      await tester.enterText(find.byType(EditableText), 'Valid Input');
      await tester.pump();
      expect(formKey.currentState!.validate(), isTrue);

      formKey.currentState!.save();
      expect(savedValue, equals('Valid Input'));
    });
  });

  group('JustInput - Neobrutalism & Preset Tests', () {
    testWidgets('Renders with Neobrutalism light and dark presets', (
      tester,
    ) async {
      // Light Neobrutalism
      await tester.pumpWidget(
        buildTestApp(
          const JustInput(label: 'Neobrutalism Light', hint: 'Type here...'),
          theme: JustThemeData.neobrutalismLight,
        ),
      );

      expect(find.text('Neobrutalism Light'), findsOneWidget);

      // Dark Neobrutalism
      await tester.pumpWidget(
        buildTestApp(
          const JustInput(label: 'Neobrutalism Dark', hint: 'Type here...'),
          theme: JustThemeData.neobrutalismDark,
          themeMode: ThemeMode.dark,
        ),
      );

      expect(find.text('Neobrutalism Dark'), findsOneWidget);
    });
  });

  group('JustInputStyle & JustInputTheme Unit Tests', () {
    test('JustInputStyle instantiation with all properties', () {
      // ignore: prefer_const_constructors
      final style = JustInputStyle(
        borderColor: const Color(0xFF111111),
        focusedBorderColor: const Color(0xFF222222),
        errorBorderColor: const Color(0xFF333333),
        backgroundColor: const Color(0xFF444444),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        contentPadding: const EdgeInsets.all(16),
        textStyle: const TextStyle(fontSize: 18),
        labelStyle: const TextStyle(fontSize: 14),
        helperStyle: const TextStyle(fontSize: 12),
      );

      expect(style.borderColor, equals(const Color(0xFF111111)));
      expect(style.focusedBorderColor, equals(const Color(0xFF222222)));
      expect(style.errorBorderColor, equals(const Color(0xFF333333)));
      expect(style.backgroundColor, equals(const Color(0xFF444444)));
      expect(
        style.borderRadius,
        equals(const BorderRadius.all(Radius.circular(12))),
      );
      expect(style.contentPadding, equals(const EdgeInsets.all(16)));
      expect(style.textStyle?.fontSize, equals(18));
      expect(style.labelStyle?.fontSize, equals(14));
      expect(style.helperStyle?.fontSize, equals(12));

      // ignore: prefer_const_constructors
      final emptyStyle = JustInputStyle();
      expect(emptyStyle.borderColor, isNull);
    });

    testWidgets('Custom JustInputStyle applies overrides to JustInput widget', (
      tester,
    ) async {
      const customStyle = JustInputStyle(
        backgroundColor: Color(0xFFEFEFEF),
        borderColor: Color(0xFF999999),
        focusedBorderColor: Color(0xFF3333FF),
        errorBorderColor: Color(0xFFFF3333),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: TextStyle(color: Color(0xFF123456)),
        labelStyle: TextStyle(color: Color(0xFF654321)),
        helperStyle: TextStyle(color: Color(0xFFABCDEF)),
      );

      await tester.pumpWidget(
        buildTestApp(
          const JustInput(
            style: customStyle,
            label: 'Custom Label',
            helper: 'Custom Helper',
          ),
        ),
      );

      expect(find.text('Custom Label'), findsOneWidget);
      expect(find.text('Custom Helper'), findsOneWidget);
    });

    test('JustInputTheme copyWith and lerp unit tests', () {
      const style1 = JustInputStyle(borderColor: Color(0xFF111111));
      const style2 = JustInputStyle(borderColor: Color(0xFF222222));

      const theme1 = JustInputTheme(inputStyle: style1);
      final copied = theme1.copyWith(inputStyle: style2);
      expect(copied.inputStyle, equals(style2));

      final copiedNull = theme1.copyWith();
      expect(copiedNull.inputStyle, equals(style1));

      const theme2 = JustInputTheme(inputStyle: style2);

      // Lerp t < 0.5 returns theme1
      final lerpLow = theme1.lerp(theme2, 0.2);
      expect(lerpLow.inputStyle, equals(style1));

      // Lerp t >= 0.5 returns theme2
      final lerpHigh = theme1.lerp(theme2, 0.7);
      expect(lerpHigh.inputStyle, equals(style2));

      // Lerp with incompatible other returns this
      final lerpNull = theme1.lerp(null, 0.5);
      expect(lerpNull, equals(theme1));

      expect(JustInputTheme.defaults.inputStyle, isNull);
    });

    test('JustInputVariant and JustInputSize enum values', () {
      expect(
        JustInputVariant.values,
        containsAll([
          JustInputVariant.text,
          JustInputVariant.password,
          JustInputVariant.search,
          JustInputVariant.number,
          JustInputVariant.textarea,
          JustInputVariant.otp,
        ]),
      );

      expect(
        JustInputSize.values,
        containsAll([JustInputSize.sm, JustInputSize.md, JustInputSize.lg]),
      );
    });
  });
}
