import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(textDirection: .ltr, child: child),
    );
  }

  group('JustInput Tests', () {
    testWidgets('Renders label and hint', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustInput(label: 'Username', hint: 'Enter your username'),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('Toggles password visibility on eye icon click', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: 'secret123');
      await tester.pumpWidget(
        buildTestableWidget(
          JustInput.password(label: 'Password', controller: controller),
        ),
      );

      // Check initially obscured
      final editableTextFinder = find.byType(EditableText);
      expect(editableTextFinder, findsOneWidget);
      EditableText editable = tester.widget<EditableText>(editableTextFinder);
      expect(editable.obscureText, isTrue);

      // Tap the suffix eye icon
      // Suffix is an Icon inside a GestureDetector
      final eyeIconFinder = find.byType(GestureDetector);
      expect(eyeIconFinder, findsOneWidget);
      await tester.tap(eyeIconFinder);
      await tester.pump();

      // Check now visible
      editable = tester.widget<EditableText>(editableTextFinder);
      expect(editable.obscureText, isFalse);
    });

    testWidgets('Clears search input value', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'flutter');
      bool changedCalled = false;
      String changedValue = '';

      await tester.pumpWidget(
        buildTestableWidget(
          JustInput.search(
            controller: controller,
            onChanged: (val) {
              changedCalled = true;
              changedValue = val;
            },
          ),
        ),
      );

      expect(controller.text, equals('flutter'));

      // Suffix is a GestureDetector containing the close icon
      final clearButtonFinder = find.byType(GestureDetector);
      expect(clearButtonFinder, findsOneWidget);
      await tester.tap(clearButtonFinder);
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(changedCalled, isTrue);
      expect(changedValue, isEmpty);
    });

    testWidgets('Number stepper increments and decrements value', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '5');
      await tester.pumpWidget(
        buildTestableWidget(JustInput.number(controller: controller)),
      );

      // Suffix is a Row containing two GestureDetectors: decrement (minus) and increment (plus)
      final buttons = find.descendant(
        of: find.byType(Row),
        matching: find.byType(GestureDetector),
      );

      expect(buttons, findsNWidgets(2));

      // Click decrement (first button)
      await tester.tap(buttons.at(0));
      await tester.pump();
      expect(controller.text, equals('4'));

      // Click increment (second button)
      await tester.tap(buttons.at(1));
      await tester.pump();
      expect(controller.text, equals('5'));
    });

    testWidgets('Renders textarea variant', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const JustInput.textarea(label: 'Bio')),
      );

      expect(find.text('Bio'), findsOneWidget);
      final editableTextFinder = find.byType(EditableText);
      final EditableText editable = tester.widget<EditableText>(
        editableTextFinder,
      );
      expect(editable.maxLines, equals(5));
      expect(editable.minLines, equals(3));
    });

    testWidgets('Renders OTP input row with correct segments', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestableWidget(JustInput.otp(length: 4, controller: controller)),
      );

      // OTP has 4 segmented input fields (each is a JustInput)
      final otpFields = find.byType(EditableText);
      expect(otpFields, findsNWidgets(4));
    });

    testWidgets('JustFormInput validates and shows error state', (
      WidgetTester tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        buildTestableWidget(
          Form(
            key: formKey,
            child: JustFormInput(
              label: 'Email',
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
          ),
        ),
      );

      formKey.currentState?.validate();
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('Shows character limit counter and updates dynamically', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestableWidget(JustInput(controller: controller, maxLength: 10)),
      );

      // Verify initial state
      expect(find.text('0 / 10'), findsOneWidget);

      // Enter some text
      controller.text = 'hello';
      await tester.pump();

      // Verify updated character count
      expect(find.text('5 / 10'), findsOneWidget);
      expect(find.text('0 / 10'), findsNothing);
    });

    testWidgets('Shows clear button when filled and clears input on tap', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        buildTestableWidget(
          JustInput(controller: controller, showClearButton: true),
        ),
      );

      // Initially clear button should not be shown
      expect(find.byType(GestureDetector), findsNothing);

      // Add text
      controller.text = 'some text';
      await tester.pump();

      // Clear button should be visible (as a GestureDetector)
      final clearFinder = find.byType(GestureDetector);
      expect(clearFinder, findsOneWidget);

      // Tap clear button
      await tester.tap(clearFinder);
      await tester.pump();

      // Verify text is cleared and clear button is hidden again
      expect(controller.text, isEmpty);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('Renders correctly under neobrutalism preset', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        JustThemeProvider(
          lightTheme: JustThemeData.neobrutalismLight,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: JustInput(label: 'Neobrutalist Username'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(JustInput), findsOneWidget);
    });
  });
}
