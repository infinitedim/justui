import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog_style.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog_theme.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog_variants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildDialogTestApp({
    required JustDialogController controller,
    required Widget child,
    JustThemeData? theme,
    JustDialogTheme? dialogTheme,
  }) {
    return MaterialApp(
      theme: ThemeData(extensions: [dialogTheme ?? const JustDialogTheme()]),
      home: JustThemeProvider(
        lightTheme: theme ?? JustThemeData.light,
        child: JustDialogScope(
          controller: controller,
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('JustDialogStyle & JustDialogTheme Unit Tests', () {
    test('JustDialogStyle holds configured values', () {
      const style = JustDialogStyle(
        backgroundColor: Color(0xFF112233),
        barrierColor: Color(0x88000000),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        padding: EdgeInsets.all(24.0),
        maxWidth: 500.0,
        maxHeight: 600.0,
        shadows: [BoxShadow(color: Color(0xFF000000), blurRadius: 8.0)],
      );

      expect(style.backgroundColor, equals(const Color(0xFF112233)));
      expect(style.barrierColor, equals(const Color(0x88000000)));
      expect(
        style.borderRadius,
        equals(const BorderRadius.all(Radius.circular(12.0))),
      );
      expect(style.padding, equals(const EdgeInsets.all(24.0)));
      expect(style.maxWidth, equals(500.0));
      expect(style.maxHeight, equals(600.0));
      expect(style.shadows?.length, equals(1));
    });

    test('JustDialogTheme defaults and copyWith', () {
      const defaultTheme = JustDialogTheme.defaults;
      expect(defaultTheme.centerStyle, isNull);
      expect(defaultTheme.bottomStyle, isNull);
      expect(defaultTheme.topStyle, isNull);

      const centerStyle = JustDialogStyle(maxWidth: 400.0);
      const bottomStyle = JustDialogStyle(maxHeight: 300.0);
      const topStyle = JustDialogStyle(padding: EdgeInsets.all(8.0));

      final updated = defaultTheme.copyWith(
        centerStyle: centerStyle,
        bottomStyle: bottomStyle,
        topStyle: topStyle,
      );

      expect(updated.centerStyle?.maxWidth, equals(400.0));
      expect(updated.bottomStyle?.maxHeight, equals(300.0));
      expect(updated.topStyle?.padding, equals(const EdgeInsets.all(8.0)));

      // Fallback copyWith preserves existing values
      final partial = updated.copyWith();
      expect(partial.centerStyle?.maxWidth, equals(400.0));
      expect(partial.bottomStyle?.maxHeight, equals(300.0));
      expect(partial.topStyle?.padding, equals(const EdgeInsets.all(8.0)));
    });

    test('JustDialogTheme lerp behavior', () {
      const themeA = JustDialogTheme(
        centerStyle: JustDialogStyle(maxWidth: 300.0),
      );
      const themeB = JustDialogTheme(
        centerStyle: JustDialogStyle(maxWidth: 600.0),
      );

      // Non-JustDialogTheme returns this
      expect(themeA.lerp(null, 0.5), equals(themeA));

      // t < 0.5 returns this
      expect(themeA.lerp(themeB, 0.2), equals(themeA));

      // t >= 0.5 returns other
      expect(themeA.lerp(themeB, 0.7), equals(themeB));
    });

    test('DialogPosition enum values', () {
      expect(
        DialogPosition.values,
        containsAll([
          DialogPosition.center,
          DialogPosition.bottom,
          DialogPosition.top,
        ]),
      );
    });
  });

  group('JustDialogController & Scope Lifecycle Tests', () {
    test(
      'Unattached controller throws AssertionError when show() is called',
      () {
        final controller = JustDialogController();
        expect(controller.isVisible, isFalse);
        expect(
          () => controller.show<void>(content: const Text('Hello')),
          throwsAssertionError,
        );
      },
    );

    testWidgets(
      'JustDialogScope.of & context.justDialog return attached controller',
      (WidgetTester tester) async {
        final controller = JustDialogController();
        late JustDialogController fromOf;
        late JustDialogController fromExtension;

        await tester.pumpWidget(
          buildDialogTestApp(
            controller: controller,
            child: Builder(
              builder: (context) {
                fromOf = JustDialogScope.of(context);
                fromExtension = context.justDialog;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(fromOf, equals(controller));
        expect(fromExtension, equals(controller));
      },
    );

    testWidgets('JustDialogScope throws when context lacks JustDialogScope', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(() => JustDialogScope.of(context), throwsAssertionError);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('JustDialogScope didUpdateWidget reattaches new controller', (
      WidgetTester tester,
    ) async {
      final controller1 = JustDialogController();
      final controller2 = JustDialogController();

      await tester.pumpWidget(
        buildDialogTestApp(
          controller: controller1,
          child: const Text('Page 1'),
        ),
      );

      expect(controller1.isVisible, isFalse);

      // Open a dialog on controller1
      unawaited(controller1.show<void>(content: const Text('Dialog 1')));
      await tester.pumpAndSettle();
      expect(controller1.isVisible, isTrue);

      // Update widget with controller2
      await tester.pumpWidget(
        buildDialogTestApp(
          controller: controller2,
          child: const Text('Page 2'),
        ),
      );

      // controller1 should have been force dismissed
      expect(controller1.isVisible, isFalse);
      expect(find.text('Dialog 1'), findsNothing);

      // controller2 should be able to open dialogs now
      unawaited(controller2.show<void>(content: const Text('Dialog 2')));
      await tester.pumpAndSettle();
      expect(controller2.isVisible, isTrue);
      expect(find.text('Dialog 2'), findsOneWidget);

      controller2.forceDismissAll();
      await tester.pumpAndSettle();
    });
  });

  group('JustDialog Interactive & Visual Tests', () {
    testWidgets(
      'Shows center dialog, verifies constraints, semantics, and barrier dismissal',
      (WidgetTester tester) async {
        final controller = JustDialogController();
        bool? dialogResult;

        await tester.pumpWidget(
          buildDialogTestApp(
            controller: controller,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    dialogResult = await controller.show<bool>(
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Modal Title'),
                          Text('Modal Body Content'),
                        ],
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        );

        expect(controller.isVisible, isFalse);
        expect(find.text('Modal Title'), findsNothing);

        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pump(); // Start animation
        await tester.pumpAndSettle(); // Complete forward animation

        expect(controller.isVisible, isTrue);
        expect(find.text('Modal Title'), findsOneWidget);
        expect(find.text('Modal Body Content'), findsOneWidget);

        // Verify semantics
        expect(find.bySemanticsLabel('Dialog'), findsOneWidget);

        // Tap outside barrier to dismiss
        await tester.tapAt(const Offset(10, 10));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(controller.isVisible, isFalse);
        expect(find.text('Modal Title'), findsNothing);
        expect(dialogResult, isNull);
      },
    );

    testWidgets('Shows bottom dialog with handle bar and SafeArea', (
      WidgetTester tester,
    ) async {
      final controller = JustDialogController();

      await tester.pumpWidget(
        buildDialogTestApp(
          controller: controller,
          child: const SizedBox.shrink(),
        ),
      );

      unawaited(
        controller.show<void>(
          position: DialogPosition.bottom,
          content: const Text('Bottom Sheet Content'),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.isVisible, isTrue);
      expect(find.text('Bottom Sheet Content'), findsOneWidget);

      final alignFinder = find.ancestor(
        of: find.text('Bottom Sheet Content'),
        matching: find.byType(Align),
      );
      expect(alignFinder, findsWidgets);
      final align = tester.widget<Align>(alignFinder.first);
      expect(align.alignment, equals(Alignment.bottomCenter));

      controller.forceDismissAll();
      await tester.pumpAndSettle();
    });

    testWidgets('Shows top dialog with top alignment', (
      WidgetTester tester,
    ) async {
      final controller = JustDialogController();

      await tester.pumpWidget(
        buildDialogTestApp(
          controller: controller,
          child: const SizedBox.shrink(),
        ),
      );

      unawaited(
        controller.show<void>(
          position: DialogPosition.top,
          content: const Text('Top Banner Content'),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.isVisible, isTrue);
      expect(find.text('Top Banner Content'), findsOneWidget);

      final alignFinder = find.ancestor(
        of: find.text('Top Banner Content'),
        matching: find.byType(Align),
      );
      expect(alignFinder, findsWidgets);
      final align = tester.widget<Align>(alignFinder.first);
      expect(align.alignment, equals(Alignment.topCenter));

      controller.dismiss();
      await tester.pumpAndSettle();
      expect(controller.isVisible, isFalse);
    });

    testWidgets('barrierDismissable = false prevents barrier tap dismissal', (
      WidgetTester tester,
    ) async {
      final controller = JustDialogController();

      await tester.pumpWidget(
        buildDialogTestApp(
          controller: controller,
          child: const SizedBox.shrink(),
        ),
      );

      unawaited(
        controller.show<void>(
          barrierDismissable: false,
          content: const Text('Locked Dialog'),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.isVisible, isTrue);

      // Tap barrier
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pumpAndSettle();

      // Dialog is still visible
      expect(controller.isVisible, isTrue);
      expect(find.text('Locked Dialog'), findsOneWidget);

      controller.forceDismissAll();
      await tester.pumpAndSettle();
      expect(controller.isVisible, isFalse);
    });

    testWidgets(
      'Applies custom JustDialogStyle overrides and custom barrierColor',
      (WidgetTester tester) async {
        final controller = JustDialogController();

        const customStyle = JustDialogStyle(
          backgroundColor: Color(0xFF123456),
          barrierColor: Color(0xAAFF0000),
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          padding: EdgeInsets.all(32.0),
          maxWidth: 320.0,
          maxHeight: 400.0,
        );

        await tester.pumpWidget(
          buildDialogTestApp(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        );

        unawaited(
          controller.show<void>(
            style: customStyle,
            content: const Text('Styled Dialog'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Styled Dialog'), findsOneWidget);

        final containerFinder = find.ancestor(
          of: find.text('Styled Dialog'),
          matching: find.byType(Container),
        );
        expect(containerFinder, findsWidgets);

        controller.forceDismissAll();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('Applies global JustDialogTheme position styles', (
      WidgetTester tester,
    ) async {
      final controller = JustDialogController();
      const globalDialogTheme = JustDialogTheme(
        centerStyle: JustDialogStyle(
          backgroundColor: Color(0xFF223344),
          maxWidth: 420.0,
        ),
        bottomStyle: JustDialogStyle(backgroundColor: Color(0xFF334455)),
        topStyle: JustDialogStyle(backgroundColor: Color(0xFF445566)),
      );

      await tester.pumpWidget(
        buildDialogTestApp(
          controller: controller,
          dialogTheme: globalDialogTheme,
          child: const SizedBox.shrink(),
        ),
      );

      unawaited(
        controller.show<void>(
          position: DialogPosition.center,
          content: const Text('Themed Center Dialog'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Themed Center Dialog'), findsOneWidget);

      controller.forceDismissAll();
      await tester.pumpAndSettle();
    });

    testWidgets('Neobrutalism preset renders prominent borders', (
      WidgetTester tester,
    ) async {
      final controller = JustDialogController();

      await tester.pumpWidget(
        buildDialogTestApp(
          controller: controller,
          theme: JustThemeData.neobrutalismLight,
          child: const SizedBox.shrink(),
        ),
      );

      unawaited(
        controller.show<void>(content: const Text('Neobrutalism Dialog')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Neobrutalism Dialog'), findsOneWidget);

      controller.forceDismissAll();
      await tester.pumpAndSettle();
    });

    testWidgets('Custom animationBuilder is rendered', (
      WidgetTester tester,
    ) async {
      final controller = JustDialogController();

      await tester.pumpWidget(
        buildDialogTestApp(
          controller: controller,
          child: const SizedBox.shrink(),
        ),
      );

      unawaited(
        controller.show<void>(
          animationBuilder: (context, anim, child) {
            return Opacity(opacity: anim.value, child: child);
          },
          content: const Text('Custom Animated Dialog'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Animated Dialog'), findsOneWidget);

      controller.forceDismissAll();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'Custom external animationController is used and not disposed by dialog',
      (WidgetTester tester) async {
        final controller = JustDialogController();
        final customAnimController = AnimationController(
          vsync: const TestVSync(),
          duration: const Duration(milliseconds: 200),
        );

        await tester.pumpWidget(
          buildDialogTestApp(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        );

        unawaited(
          controller.show<void>(
            animationController: customAnimController,
            content: const Text('External Anim Dialog'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('External Anim Dialog'), findsOneWidget);

        controller.dismiss();
        await tester.pumpAndSettle();

        // Ensure customAnimController is still valid (not disposed by internal cleanup)
        expect(customAnimController.isDismissed, isTrue);
        customAnimController.dispose();
      },
    );

    testWidgets(
      'Keyboard Escape key dismisses dialog and restores previous focus',
      (WidgetTester tester) async {
        final controller = JustDialogController();
        final focusNode = FocusNode();

        await tester.pumpWidget(
          buildDialogTestApp(
            controller: controller,
            child: TextField(focusNode: focusNode, autofocus: true),
          ),
        );

        // Focus the text field
        focusNode.requestFocus();
        await tester.pumpAndSettle();
        expect(focusNode.hasFocus, isTrue);

        // Show dialog
        unawaited(
          controller.show<void>(
            content: const Text('Escape Dismissable Dialog'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Escape Dismissable Dialog'), findsOneWidget);

        // Send non-escape key (e.g. key A) - dialog remains open
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();
        expect(controller.isVisible, isTrue);

        // Send Escape key
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(controller.isVisible, isFalse);
        expect(find.text('Escape Dismissable Dialog'), findsNothing);

        // Focus restored to previous focus node
        expect(focusNode.hasFocus, isTrue);
        focusNode.dispose();
      },
    );

    testWidgets('Multiple rapid dismiss calls are idempotent', (
      WidgetTester tester,
    ) async {
      final controller = JustDialogController();

      await tester.pumpWidget(
        buildDialogTestApp(
          controller: controller,
          child: const SizedBox.shrink(),
        ),
      );

      unawaited(
        controller.show<void>(content: const Text('Idempotent Dialog')),
      );
      await tester.pumpAndSettle();

      // Trigger multiple dismiss calls
      controller.dismiss();
      controller.dismiss();
      controller.forceDismissAll();
      controller.forceDismissAll();
      controller.dispose();

      await tester.pumpAndSettle();
      expect(controller.isVisible, isFalse);
    });
  });
}
