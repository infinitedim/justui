import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/services.dart';
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

  group('JustButton Tests', () {
    testWidgets('Renders label and responds to tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustButton(label: 'Tap Me', onPressed: () => tapped = true),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('Does not trigger onTap when disabled', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustButton(
            label: 'Disabled',
            onPressed: () => tapped = true,
            isDisabled: true,
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      expect(tapped, isFalse);
    });

    testWidgets('Does not trigger onTap when loading', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          JustButton(
            label: 'Loading',
            onPressed: () => tapped = true,
            isLoading: true,
          ),
        ),
      );

      // Label is hidden when loading, check spinner presence instead
      expect(find.byType(JustProgressSpinner), findsOneWidget);
      expect(find.text('Loading'), findsNothing);

      await tester.tap(find.byType(JustProgressSpinner));
      expect(tapped, isFalse);
    });

    testWidgets('Renders leading and trailing widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustButton(
            label: 'With Icons',
            onPressed: null,
            leading: Text('L'),
            trailing: Text('T'),
          ),
        ),
      );

      expect(find.text('L'), findsOneWidget);
      expect(find.text('With Icons'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('Triggers haptic feedback when enabled and pressed', (
      WidgetTester tester,
    ) async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return null;
          });

      await tester.pumpWidget(
        buildTestableWidget(
          JustButton(
            label: 'Haptic Button',
            onPressed: () {},
            enableHaptic: true,
          ),
        ),
      );

      await tester.tap(find.text('Haptic Button'));
      await tester.pump();

      expect(
        log,
        contains(
          isA<MethodCall>()
              .having((c) => c.method, 'method', 'HapticFeedback.vibrate')
              .having(
                (c) => c.arguments,
                'arguments',
                'HapticFeedbackType.lightImpact',
              ),
        ),
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets(
      'Does not trigger haptic feedback when disabled or haptics disabled',
      (WidgetTester tester) async {
        final List<MethodCall> log = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (
              MethodCall methodCall,
            ) async {
              log.add(methodCall);
              return null;
            });

        // Scenario 1: Pressed, but haptics explicitly disabled
        await tester.pumpWidget(
          buildTestableWidget(
            JustButton(
              label: 'No Haptic Button',
              onPressed: () {},
              enableHaptic: false,
            ),
          ),
        );
        await tester.tap(find.text('No Haptic Button'));
        await tester.pump();

        // Scenario 2: Haptics enabled, but button is disabled (onPressed is null)
        await tester.pumpWidget(
          buildTestableWidget(
            const JustButton(
              label: 'Disabled Haptic Button',
              onPressed: null,
              enableHaptic: true,
            ),
          ),
        );
        await tester.tap(find.text('Disabled Haptic Button'));
        await tester.pump();

        final hasHapticCall = log.any(
          (c) =>
              c.method == 'HapticFeedback.vibrate' &&
              c.arguments == 'HapticFeedbackType.lightImpact',
        );
        expect(hasHapticCall, isFalse);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      },
    );

    testWidgets(
      'Theme and instance level enableHaptic overrides resolve correctly',
      (WidgetTester tester) async {
        final List<MethodCall> log = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (
              MethodCall methodCall,
            ) async {
              log.add(methodCall);
              return null;
            });

        // 1. Theme-level enabled (true), instance-level unset -> should trigger haptic
        await tester.pumpWidget(
          JustThemeProvider(
            child: Directionality(
              textDirection: .ltr,
              child: Theme(
                data: ThemeData(
                  extensions: const [JustButtonTheme(enableHaptic: true)],
                ),
                child: JustButton(
                  label: 'Theme Enabled Button',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Theme Enabled Button'));
        await tester.pump();

        expect(
          log.any(
            (c) =>
                c.method == 'HapticFeedback.vibrate' &&
                c.arguments == 'HapticFeedbackType.lightImpact',
          ),
          isTrue,
        );

        log.clear();

        // 2. Theme-level enabled (true), instance-level override to false -> should not trigger haptic
        await tester.pumpWidget(
          JustThemeProvider(
            child: Directionality(
              textDirection: .ltr,
              child: Theme(
                data: ThemeData(
                  extensions: const [JustButtonTheme(enableHaptic: true)],
                ),
                child: JustButton(
                  label: 'Theme Enabled Instance Overridden Button',
                  onPressed: () {},
                  enableHaptic: false,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Theme Enabled Instance Overridden Button'));
        await tester.pump();

        expect(
          log.any(
            (c) =>
                c.method == 'HapticFeedback.vibrate' &&
                c.arguments == 'HapticFeedbackType.lightImpact',
          ),
          isFalse,
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      },
    );
  });

  group('JustIconButton Tests', () {
    testWidgets('Renders and requires tooltip assertion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const JustIconButton(
            icon: SizedBox(width: 20, height: 20),
            onPressed: null,
            tooltip: 'Add Item',
          ),
        ),
      );

      expect(find.byType(JustIconButton), findsOneWidget);
    });

    test('Asserts tooltip is not null in debug mode', () {
      expect(
        () => JustIconButton(
          icon: const SizedBox(),
          onPressed: () {},
          tooltip: null,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('Triggers haptic feedback when enabled and pressed', (
      WidgetTester tester,
    ) async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            log.add(methodCall);
            return null;
          });

      await tester.pumpWidget(
        buildTestableWidget(
          JustIconButton(
            icon: const SizedBox(width: 20, height: 20),
            onPressed: () {},
            tooltip: 'Haptic Icon Button',
            enableHaptic: true,
          ),
        ),
      );

      await tester.tap(find.byType(JustIconButton));
      await tester.pump();

      expect(
        log,
        contains(
          isA<MethodCall>()
              .having((c) => c.method, 'method', 'HapticFeedback.vibrate')
              .having(
                (c) => c.arguments,
                'arguments',
                'HapticFeedbackType.lightImpact',
              ),
        ),
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
  });

  group('JustButtonGroup Tests', () {
    testWidgets('Renders children in attached layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          JustButtonGroup(
            attached: true,
            children: [
              JustButton(label: 'Btn 1', onPressed: () {}),
              JustButton(label: 'Btn 2', onPressed: () {}),
            ],
          ),
        ),
      );

      expect(find.text('Btn 1'), findsOneWidget);
      expect(find.text('Btn 2'), findsOneWidget);
    });
  });

  group('Golden Tests for JustButton', () {
    testWidgets('Golden Test - Button Variants', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Column(
            children: [
              JustButton(label: 'Primary', onPressed: () {}),
              JustButton(
                label: 'Secondary',
                onPressed: () {},
                variant: JustButtonVariant.secondary,
              ),
              JustButton(
                label: 'Ghost',
                onPressed: () {},
                variant: JustButtonVariant.ghost,
              ),
              JustButton(
                label: 'Destructive',
                onPressed: () {},
                variant: JustButtonVariant.destructive,
              ),
              JustButton(
                label: 'Link',
                onPressed: () {},
                variant: JustButtonVariant.link,
              ),
            ],
          ),
        ),
      );

      // Skip actual golden execution in sandbox due to missing font assets.
      // Golden tests can be updated and run locally in user-land using `flutter test --update-goldens`.
      await expectLater(
        find.byType(Column),
        matchesGoldenFile('goldens/button_variants.png'),
        skip: true,
      );
    });
  });
}
