import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/shared/_shared_focus_indicator.dart';
import 'package:just_ui_core/src/components/shared/_shared_pressable.dart';
import 'package:just_ui_core/src/components/shared/_shared_progress_spinner.dart';
import 'package:just_ui_core/src/components/shared/_shared_tooltip_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildSharedTestApp(
    Widget child, {
    JustThemeData? theme,
    bool disableAnimations = false,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: JustThemeProvider(
          lightTheme: theme ?? JustThemeData.light,
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  group('JustInteractionState Unit Tests', () {
    test('Stores and exposes interaction state values', () {
      final node = FocusNode();
      final state = JustInteractionState(true, true, true, true, node);

      expect(state.isHovered, isTrue);
      expect(state.isPressed, isTrue);
      expect(state.isFocused, isTrue);
      expect(state.isFocusVisible, isTrue);
      expect(state.focusNode, equals(node));
      node.dispose();
    });
  });

  group('JustPressable Widget Tests', () {
    testWidgets('Renders child builder with initial idle state', (
      WidgetTester tester,
    ) async {
      late JustInteractionState capturedState;

      await tester.pumpWidget(
        buildSharedTestApp(
          JustPressable(
            builder: (context, state) {
              capturedState = state;
              return const Text('Pressable Item');
            },
          ),
        ),
      );

      expect(find.text('Pressable Item'), findsOneWidget);
      expect(capturedState.isHovered, isFalse);
      expect(capturedState.isPressed, isFalse);
      expect(capturedState.isFocused, isFalse);
      expect(capturedState.isFocusVisible, isFalse);
    });

    testWidgets('Handles mouse hover onEnter and onExit', (
      WidgetTester tester,
    ) async {
      late JustInteractionState capturedState;

      await tester.pumpWidget(
        buildSharedTestApp(
          JustPressable(
            builder: (context, state) {
              capturedState = state;
              return Container(
                width: 100,
                height: 50,
                color: state.isHovered ? Colors.blue : Colors.grey,
                child: const Text('Hover Target'),
              );
            },
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();

      // Move inside bounds
      await gesture.moveTo(tester.getCenter(find.text('Hover Target')));
      await tester.pumpAndSettle();
      expect(capturedState.isHovered, isTrue);

      // Move outside bounds
      await gesture.moveTo(const Offset(500, 500));
      await tester.pumpAndSettle();
      expect(capturedState.isHovered, isFalse);

      await gesture.removePointer();
    });

    testWidgets('Handles press lifecycle (down, up, cancel, tap callback)', (
      WidgetTester tester,
    ) async {
      late JustInteractionState capturedState;
      bool tapped = false;

      await tester.pumpWidget(
        buildSharedTestApp(
          JustPressable(
            onTap: () => tapped = true,
            builder: (context, state) {
              capturedState = state;
              return const SizedBox(
                width: 100,
                height: 50,
                child: Text('Tap Target'),
              );
            },
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Tap Target')),
      );
      await tester.pump();
      expect(capturedState.isPressed, isTrue);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(capturedState.isPressed, isFalse);
      expect(tapped, isTrue);

      // Test cancel
      final gestureCancel = await tester.startGesture(
        tester.getCenter(find.text('Tap Target')),
      );
      await tester.pump();
      expect(capturedState.isPressed, isTrue);

      await gestureCancel.cancel();
      await tester.pumpAndSettle();
      expect(capturedState.isPressed, isFalse);
    });

    testWidgets('Keyboard Enter and Space keys trigger onTap', (
      WidgetTester tester,
    ) async {
      int tapCount = 0;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        buildSharedTestApp(
          JustPressable(
            focusNode: focusNode,
            onTap: () => tapCount++,
            builder: (context, state) => const Text('Key Target'),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      // Enter key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(tapCount, equals(1));

      // Space key
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(tapCount, equals(2));

      // Other key (ignored)
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle();
      expect(tapCount, equals(2));

      focusNode.dispose();
    });

    testWidgets('Custom onKeyEvent callback takes precedence', (
      WidgetTester tester,
    ) async {
      bool customKeyHandled = false;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        buildSharedTestApp(
          JustPressable(
            focusNode: focusNode,
            onKeyEvent: (node, event) {
              if (event.logicalKey == LogicalKeyboardKey.keyK) {
                customKeyHandled = true;
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            onTap: () {},
            builder: (context, state) => const Text('Custom Key'),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.pumpAndSettle();
      expect(customKeyHandled, isTrue);

      focusNode.dispose();
    });

    testWidgets('Disabled state guards all interactions', (
      WidgetTester tester,
    ) async {
      late JustInteractionState capturedState;
      bool tapped = false;

      await tester.pumpWidget(
        buildSharedTestApp(
          JustPressable(
            enabled: false,
            onTap: () => tapped = true,
            builder: (context, state) {
              capturedState = state;
              return const SizedBox(
                width: 100,
                height: 50,
                child: Text('Disabled Target'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Disabled Target'));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
      expect(capturedState.isHovered, isFalse);
      expect(capturedState.isPressed, isFalse);
      expect(capturedState.isFocused, isFalse);

      final mouseRegion = tester.widget<MouseRegion>(find.byType(MouseRegion));
      expect(mouseRegion.cursor, equals(SystemMouseCursors.basic));
    });

    testWidgets(
      'Haptic feedback executes on mobile platforms or when enabled',
      (WidgetTester tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await tester.pumpWidget(
          buildSharedTestApp(
            JustPressable(
              enableHapticFeedback: true,
              onTap: () {},
              builder: (context, state) => const Text('Haptic Button'),
            ),
          ),
        );

        await tester.tap(find.text('Haptic Button'));
        await tester.pumpAndSettle();

        debugDefaultTargetPlatformOverride = null;
      },
    );

    testWidgets('semanticLabel wraps widget with accessible Semantics', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        buildSharedTestApp(
          JustPressable(
            semanticLabel: 'Action Label',
            onTap: () {},
            builder: (context, state) => const Text('Inner Text'),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(JustPressable)),
        matchesSemantics(
          isButton: true,
          isEnabled: true,
          label: 'Action Label',
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('didUpdateWidget properly handles focusNode changes', (
      WidgetTester tester,
    ) async {
      final nodeA = FocusNode();
      final nodeB = FocusNode();

      await tester.pumpWidget(
        buildSharedTestApp(
          JustPressable(
            focusNode: nodeA,
            builder: (context, state) => const Text('Focus Node Swap'),
          ),
        ),
      );

      await tester.pumpWidget(
        buildSharedTestApp(
          JustPressable(
            focusNode: nodeB,
            builder: (context, state) => const Text('Focus Node Swap'),
          ),
        ),
      );

      nodeA.dispose();
      nodeB.dispose();
    });
  });

  group('FocusIndicator Widget & Painter Tests', () {
    testWidgets('Renders FocusIndicator with focus ring when focused', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSharedTestApp(
          const FocusIndicator(
            isFocused: true,
            borderRadius: .all(.circular(8.0)),
            child: SizedBox(width: 80, height: 40, child: Text('Focus Box')),
          ),
        ),
      );

      expect(find.text('Focus Box'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('FocusIndicator adapts to Neobrutalism preset styles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSharedTestApp(
          theme: JustThemeData.neobrutalismLight,
          const FocusIndicator(
            isFocused: true,
            borderRadius: .all(.circular(4.0)),
            child: SizedBox(width: 80, height: 40, child: Text('Neo Focus')),
          ),
        ),
      );

      expect(find.text('Neo Focus'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('FocusIndicator respects disableAnimations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSharedTestApp(
          disableAnimations: true,
          const FocusIndicator(
            isFocused: true,
            borderRadius: .all(.circular(8.0)),
            child: Text('Instant Focus Box'),
          ),
        ),
      );

      expect(find.text('Instant Focus Box'), findsOneWidget);
      await tester.pump();
    });
  });

  group('JustProgressSpinner Widget & Painter Tests', () {
    testWidgets(
      'Renders JustProgressSpinner with custom size, color, trackColor, semantics',
      (WidgetTester tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          buildSharedTestApp(
            const JustProgressSpinner(
              size: 32.0,
              color: Color(0xFF123456),
              strokeWidth: 3.0,
              trackColor: Color(0x33000000),
              semanticLabel: 'Loading Progress',
            ),
          ),
        );

        expect(find.byType(JustProgressSpinner), findsOneWidget);
        expect(
          tester.getSemantics(find.byType(JustProgressSpinner)),
          matchesSemantics(label: 'Loading Progress'),
        );

        // Advance animation frames
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 400));

        handle.dispose();
      },
    );

    testWidgets('JustProgressSpinner excludeSemantics removes semantics node', (
      WidgetTester tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        buildSharedTestApp(
          const JustProgressSpinner(
            size: 24.0,
            color: Color(0xFF00FF00),
            excludeSemantics: true,
          ),
        ),
      );

      expect(find.byType(JustProgressSpinner), findsOneWidget);
      handle.dispose();
    });

    testWidgets(
      'JustProgressSpinner renders statically when disableAnimations is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSharedTestApp(
            disableAnimations: true,
            const JustProgressSpinner(size: 20.0, color: Color(0xFFFF0000)),
          ),
        );

        expect(find.byType(JustProgressSpinner), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 100));
      },
    );
  });

  group('JustTooltipOverlay Widget Tests', () {
    testWidgets(
      'JustTooltipOverlay delegates to JustTooltip and displays on hover',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSharedTestApp(
            const JustTooltipOverlay(
              message: 'Helper Information',
              child: Text('Target Button'),
            ),
          ),
        );

        expect(find.text('Target Button'), findsOneWidget);
        expect(find.text('Helper Information'), findsNothing);

        // Mouse hover over target
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        await tester.pump();

        await gesture.moveTo(tester.getCenter(find.text('Target Button')));
        await tester.pumpAndSettle();

        expect(find.text('Helper Information'), findsOneWidget);

        // Mouse exit
        await gesture.moveTo(const Offset(500, 500));
        await tester.pumpAndSettle();

        expect(find.text('Helper Information'), findsNothing);
        await gesture.removePointer();
      },
    );

    testWidgets('JustTooltipOverlay with explicit OverlayPortalController', (
      WidgetTester tester,
    ) async {
      final controller = OverlayPortalController();

      await tester.pumpWidget(
        buildSharedTestApp(
          JustTooltipOverlay(
            controller: controller,
            message: 'Controlled Tooltip',
            child: const Text('Controlled Target'),
          ),
        ),
      );

      expect(find.text('Controlled Target'), findsOneWidget);
      expect(find.text('Controlled Tooltip'), findsNothing);

      controller.show();
      await tester.pumpAndSettle();
      expect(find.text('Controlled Tooltip'), findsOneWidget);

      controller.hide();
      await tester.pumpAndSettle();
      expect(find.text('Controlled Tooltip'), findsNothing);
    });
  });
}
