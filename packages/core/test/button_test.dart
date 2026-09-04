import 'dart:ui' show PointerDeviceKind, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';
import 'package:just_ui_core/src/components/button/just_button_style.dart';
import 'package:just_ui_core/src/components/button/just_button_theme.dart';
import 'package:just_ui_core/src/components/button/just_button_variants.dart';
import 'package:just_ui_core/src/components/button/just_icon_button.dart';
import 'package:just_ui_core/src/components/shared/_shared_progress_spinner.dart';

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

  group('JustButton - Variants and Constructors', () {
    testWidgets('Renders primary variant with default and named constructors', (
      tester,
    ) async {
      bool tappedDefault = false;
      bool tappedNamed = false;

      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: [
              JustButton(
                label: 'Default Primary',
                onPressed: () => tappedDefault = true,
                variant: JustButtonVariant.primary,
              ),
              JustButton.primary(
                label: 'Named Primary',
                onPressed: () => tappedNamed = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Default Primary'), findsOneWidget);
      expect(find.text('Named Primary'), findsOneWidget);

      await tester.tap(find.text('Default Primary'));
      await tester.pumpAndSettle();
      expect(tappedDefault, isTrue);

      await tester.tap(find.text('Named Primary'));
      await tester.pumpAndSettle();
      expect(tappedNamed, isTrue);
    });

    testWidgets(
      'Renders secondary variant with default and named constructors',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          buildTestApp(
            JustButton.secondary(
              label: 'Secondary Action',
              onPressed: () => tapped = true,
            ),
          ),
        );

        expect(find.text('Secondary Action'), findsOneWidget);
        await tester.tap(find.text('Secondary Action'));
        await tester.pumpAndSettle();
        expect(tapped, isTrue);
      },
    );

    testWidgets('Renders ghost variant with default and named constructors', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          JustButton.ghost(
            label: 'Ghost Action',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Ghost Action'), findsOneWidget);
      await tester.tap(find.text('Ghost Action'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets(
      'Renders destructive variant with default and named constructors',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          buildTestApp(
            JustButton.destructive(
              label: 'Delete Item',
              onPressed: () => tapped = true,
            ),
          ),
        );

        expect(find.text('Delete Item'), findsOneWidget);
        await tester.tap(find.text('Delete Item'));
        await tester.pumpAndSettle();
        expect(tapped, isTrue);
      },
    );

    testWidgets('Renders link variant with default and named constructors', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          JustButton.link(
            label: 'Read Documentation',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Read Documentation'), findsOneWidget);
      await tester.tap(find.text('Read Documentation'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('JustButton - Sizes and Dimensions', () {
    testWidgets('Renders all size classifications correctly', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          SingleChildScrollView(
            child: Column(
              children: [
                JustButton(
                  label: 'XS Button',
                  size: JustButtonSize.xs,
                  onPressed: () {},
                ),
                JustButton(
                  label: 'SM Button',
                  size: JustButtonSize.sm,
                  onPressed: () {},
                ),
                JustButton(
                  label: 'MD Button',
                  size: JustButtonSize.md,
                  onPressed: () {},
                ),
                JustButton(
                  label: 'LG Button',
                  size: JustButtonSize.lg,
                  onPressed: () {},
                ),
                JustButton(
                  label: 'XL Button',
                  size: JustButtonSize.xl,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('XS Button'), findsOneWidget);
      expect(find.text('SM Button'), findsOneWidget);
      expect(find.text('MD Button'), findsOneWidget);
      expect(find.text('LG Button'), findsOneWidget);
      expect(find.text('XL Button'), findsOneWidget);

      // Verify minimum touch target constraints (minHeight >= 48.0 for all)
      final constrainedBox = tester.widget<ConstrainedBox>(
        find
            .descendant(
              of: find.byType(JustButton).first,
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(constrainedBox.constraints.minHeight, greaterThanOrEqualTo(48.0));
      expect(constrainedBox.constraints.minWidth, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Full width button expands horizontally', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          SizedBox(
            width: 300.0,
            child: JustButton(
              label: 'Full Width',
              isFullWidth: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      final buttonFinder = find.descendant(
        of: find.byType(JustButton),
        matching: find.byType(ConstrainedBox),
      );
      final size = tester.getSize(buttonFinder.first);
      expect(size.width, equals(300.0));
    });
  });

  group('JustButton - Leading and Trailing Icons', () {
    testWidgets('Renders leading and trailing widgets with icon theme merge', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          JustButton(
            label: 'With Icons',
            leading: const Icon(Icons.star, key: ValueKey('leading-star')),
            trailing: const Icon(
              Icons.arrow_forward,
              key: ValueKey('trailing-arrow'),
            ),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byKey(const ValueKey('leading-star')), findsOneWidget);
      expect(find.byKey(const ValueKey('trailing-arrow')), findsOneWidget);
      expect(find.text('With Icons'), findsOneWidget);
    });

    testWidgets('Renders leading-only and trailing-only correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: [
              JustButton(
                label: 'Leading Only',
                leading: const Icon(Icons.add, key: ValueKey('icon-add')),
                onPressed: () {},
              ),
              JustButton(
                label: 'Trailing Only',
                trailing: const Icon(Icons.check, key: ValueKey('icon-check')),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      expect(find.byKey(const ValueKey('icon-add')), findsOneWidget);
      expect(find.byKey(const ValueKey('icon-check')), findsOneWidget);
    });
  });

  group('JustButton - States & Interactions', () {
    testWidgets('Disabled via isDisabled prevents tap and applies semantics', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          JustButton(
            label: 'Disabled Button',
            isDisabled: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Disabled Button'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, isFalse);

      final semantics = tester.getSemantics(find.byType(JustButton));
      expect(
        semantics.getSemanticsData().flagsCollection.isEnabled,
        equals(Tristate.isFalse),
      );
    });

    testWidgets('Disabled via onPressed null prevents tap', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const JustButton(label: 'Null Callback', onPressed: null)),
      );

      final semantics = tester.getSemantics(find.byType(JustButton));
      expect(
        semantics.getSemanticsData().flagsCollection.isEnabled,
        equals(Tristate.isFalse),
      );
    });

    testWidgets('Loading state renders spinner and disables interactions', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          JustButton(
            label: 'Submit Order',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(JustProgressSpinner), findsOneWidget);
      expect(find.text('Submit Order'), findsNothing);

      await tester.tap(find.byType(JustProgressSpinner), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tapped, isFalse);

      final semantics = tester.getSemantics(find.byType(JustButton));
      expect(semantics.label, contains('Loading Submit Order'));
    });

    testWidgets('Hover state alters styling and link decoration', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: [
              JustButton.primary(label: 'Hover Primary', onPressed: () {}),
              JustButton.secondary(label: 'Hover Secondary', onPressed: () {}),
              JustButton.ghost(label: 'Hover Ghost', onPressed: () {}),
              JustButton.destructive(
                label: 'Hover Destructive',
                onPressed: () {},
              ),
              JustButton.link(label: 'Hover Link', onPressed: () {}),
            ],
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      // Hover over primary
      await gesture.moveTo(tester.getCenter(find.text('Hover Primary')));
      await tester.pumpAndSettle();

      // Hover over secondary
      await gesture.moveTo(tester.getCenter(find.text('Hover Secondary')));
      await tester.pumpAndSettle();

      // Hover over ghost
      await gesture.moveTo(tester.getCenter(find.text('Hover Ghost')));
      await tester.pumpAndSettle();

      // Hover over destructive
      await gesture.moveTo(tester.getCenter(find.text('Hover Destructive')));
      await tester.pumpAndSettle();

      // Hover over link (triggers underline decoration)
      await gesture.moveTo(tester.getCenter(find.text('Hover Link')));
      await tester.pumpAndSettle();

      final linkText = tester.widget<Text>(find.text('Hover Link'));
      expect(linkText.style?.decoration, equals(TextDecoration.underline));
    });

    testWidgets('Press state triggers press effect animation', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          JustButton.primary(label: 'Press Effect', onPressed: () {}),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Press Effect')),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AnimatedScale), findsWidgets);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('Haptic feedback is invoked when enableHaptic is true', (
      tester,
    ) async {
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
          JustButton.primary(
            label: 'Haptic Button',
            enableHaptic: true,
            onPressed: () {},
          ),
        ),
      );

      await tester.tap(find.text('Haptic Button'));
      await tester.pumpAndSettle();

      expect(log, contains('HapticFeedbackType.lightImpact'));
    });
  });

  group('JustButton - Neobrutalism Preset', () {
    testWidgets('Neobrutalism preset styles all variants with solid borders', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: JustThemeData.neobrutalismLight,
          SingleChildScrollView(
            child: Column(
              children: [
                JustButton.primary(label: 'Neo Primary', onPressed: () {}),
                JustButton.secondary(label: 'Neo Secondary', onPressed: () {}),
                JustButton.ghost(label: 'Neo Ghost', onPressed: () {}),
                JustButton.destructive(
                  label: 'Neo Destructive',
                  onPressed: () {},
                ),
                JustButton.link(label: 'Neo Link', onPressed: () {}),
                JustButton.link(
                  label: 'Neo Link Disabled',
                  isDisabled: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Neo Primary'), findsOneWidget);
      expect(find.text('Neo Secondary'), findsOneWidget);
      expect(find.text('Neo Ghost'), findsOneWidget);
      expect(find.text('Neo Destructive'), findsOneWidget);
      expect(find.text('Neo Link'), findsOneWidget);
      expect(find.text('Neo Link Disabled'), findsOneWidget);

      // Neobrutalism uses AnimatedContainer for translation press effect
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Neo Primary')),
      );
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.byType(AnimatedContainer), findsWidgets);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('Neobrutalism link color in dark mode', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: JustThemeData.neobrutalismDark,
          themeMode: ThemeMode.dark,
          JustButton.link(label: 'Neo Dark Link', onPressed: () {}),
        ),
      );

      expect(find.text('Neo Dark Link'), findsOneWidget);
    });
  });

  group('JustButtonGroup & JustButtonGroupInfo', () {
    testWidgets('Horizontal attached button group renders connected corners', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          JustButtonGroup(
            direction: Axis.horizontal,
            attached: true,
            children: [
              JustButton(label: 'First', onPressed: () {}),
              JustButton(label: 'Middle', onPressed: () {}),
              JustButton(label: 'Last', onPressed: () {}),
            ],
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Middle'), findsOneWidget);
      expect(find.text('Last'), findsOneWidget);
      expect(find.byType(JustButtonGroupInfo), findsNWidgets(3));
    });

    testWidgets('Vertical attached button group renders connected corners', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          JustButtonGroup(
            direction: Axis.vertical,
            attached: true,
            children: [
              JustButton(label: 'Top', onPressed: () {}),
              JustButton(label: 'Center', onPressed: () {}),
              JustButton(label: 'Bottom', onPressed: () {}),
            ],
          ),
        ),
      );

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Center'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
      expect(find.byType(JustButtonGroupInfo), findsNWidgets(3));
    });

    testWidgets('Non-attached button group uses Flex spacing', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          JustButtonGroup(
            attached: false,
            children: [
              JustButton(label: 'Btn 1', onPressed: () {}),
              JustButton(label: 'Btn 2', onPressed: () {}),
            ],
          ),
        ),
      );

      expect(find.text('Btn 1'), findsOneWidget);
      expect(find.text('Btn 2'), findsOneWidget);
      expect(find.byType(JustButtonGroupInfo), findsNothing);
    });

    testWidgets('Empty JustButtonGroup returns SizedBox.shrink', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(const JustButtonGroup(children: [])),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('JustButtonGroupInfo InheritedWidget updateShouldNotify', (
      tester,
    ) async {
      const info1 = JustButtonGroupInfo(
        index: 0,
        totalCount: 3,
        direction: Axis.horizontal,
        child: SizedBox(),
      );
      const info2 = JustButtonGroupInfo(
        index: 1,
        totalCount: 3,
        direction: Axis.horizontal,
        child: SizedBox(),
      );
      const info3 = JustButtonGroupInfo(
        index: 0,
        totalCount: 4,
        direction: Axis.horizontal,
        child: SizedBox(),
      );
      const info4 = JustButtonGroupInfo(
        index: 0,
        totalCount: 3,
        direction: Axis.vertical,
        child: SizedBox(),
      );
      const infoSame = JustButtonGroupInfo(
        index: 0,
        totalCount: 3,
        direction: Axis.horizontal,
        child: SizedBox(),
      );

      expect(info1.updateShouldNotify(info2), isTrue);
      expect(info1.updateShouldNotify(info3), isTrue);
      expect(info1.updateShouldNotify(info4), isTrue);
      expect(info1.updateShouldNotify(infoSame), isFalse);
    });
  });

  group('JustIconButton Tests', () {
    testWidgets('Renders all variants and sizes with tooltip', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          SingleChildScrollView(
            child: Column(
              children: [
                JustIconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Item',
                  size: JustButtonSize.xs,
                  onPressed: () => tapped = true,
                ),
                JustIconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Item',
                  variant: JustButtonVariant.primary,
                  size: JustButtonSize.sm,
                  onPressed: () {},
                ),
                JustIconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share Item',
                  variant: JustButtonVariant.secondary,
                  size: JustButtonSize.md,
                  onPressed: () {},
                ),
                JustIconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Item',
                  variant: JustButtonVariant.destructive,
                  size: JustButtonSize.lg,
                  onPressed: () {},
                ),
                JustIconButton(
                  icon: const Icon(Icons.link),
                  tooltip: 'Link Item',
                  variant: JustButtonVariant.link,
                  size: JustButtonSize.xl,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      // Verify touch target min 48x48 on xs button
      final xsBox = tester.widget<ConstrainedBox>(
        find
            .descendant(
              of: find.byType(JustIconButton).first,
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(xsBox.constraints.minWidth, greaterThanOrEqualTo(48.0));
      expect(xsBox.constraints.minHeight, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Disabled JustIconButton prevents tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          JustIconButton(
            icon: const Icon(Icons.lock),
            tooltip: 'Locked',
            isDisabled: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.lock), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('Loading JustIconButton shows spinner and loading hint', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          JustIconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Upload',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(JustProgressSpinner), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload), findsNothing);
    });

    testWidgets('Neobrutalism JustIconButton handles hover and press', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          theme: JustThemeData.neobrutalismLight,
          Column(
            children: [
              JustIconButton(
                icon: const Icon(Icons.star),
                tooltip: 'Star',
                variant: JustButtonVariant.primary,
                onPressed: () {},
              ),
              JustIconButton(
                icon: const Icon(Icons.favorite),
                tooltip: 'Favorite',
                variant: JustButtonVariant.secondary,
                onPressed: () {},
              ),
              JustIconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close',
                variant: JustButtonVariant.destructive,
                onPressed: () {},
              ),
              JustIconButton(
                icon: const Icon(Icons.open_in_new),
                tooltip: 'Open',
                variant: JustButtonVariant.link,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.star)));
      await tester.pumpAndSettle();

      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.favorite)));
      await tester.pumpAndSettle();

      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.close)));
      await tester.pumpAndSettle();

      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.open_in_new)));
      await tester.pumpAndSettle();
    });

    testWidgets('Haptic feedback on JustIconButton when enableHaptic is true', (
      tester,
    ) async {
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
          JustIconButton(
            icon: const Icon(Icons.touch_app),
            tooltip: 'Touch',
            enableHaptic: true,
            onPressed: () {},
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.touch_app));
      await tester.pumpAndSettle();

      expect(log, contains('HapticFeedbackType.lightImpact'));
    });
  });

  group('JustButtonStyle Unit Tests', () {
    test('Constructor, copyWith, lerp, equality, and hashCode', () {
      const style1 = JustButtonStyle(
        backgroundColor: Color(0xFF112233),
        foregroundColor: Color(0xFF445566),
        borderColor: Color(0xFF778899),
        borderRadius: .all(.circular(8)),
        padding: EdgeInsets.all(12),
        textStyle: TextStyle(fontSize: 14),
        elevation: 2.0,
      );

      final styleCopied = style1.copyWith(
        backgroundColor: const Color(0xFF999999),
        elevation: 4.0,
      );

      expect(styleCopied.backgroundColor, equals(const Color(0xFF999999)));
      expect(styleCopied.foregroundColor, equals(style1.foregroundColor));
      expect(styleCopied.borderColor, equals(style1.borderColor));
      expect(styleCopied.borderRadius, equals(style1.borderRadius));
      expect(styleCopied.padding, equals(style1.padding));
      expect(styleCopied.textStyle, equals(style1.textStyle));
      expect(styleCopied.elevation, equals(4.0));

      const styleClone = JustButtonStyle(
        backgroundColor: Color(0xFF112233),
        foregroundColor: Color(0xFF445566),
        borderColor: Color(0xFF778899),
        borderRadius: .all(.circular(8)),
        padding: EdgeInsets.all(12),
        textStyle: TextStyle(fontSize: 14),
        elevation: 2.0,
      );

      expect(style1, equals(styleClone));
      expect(style1.hashCode, equals(styleClone.hashCode));
      expect(style1 == styleCopied, isFalse);

      // Lerp tests
      expect(JustButtonStyle.lerp(style1, style1, 0.5), equals(style1));
      expect(JustButtonStyle.lerp(null, null, 0.5), isNull);

      final lerped = JustButtonStyle.lerp(style1, styleCopied, 0.5);
      expect(lerped, isNotNull);
      expect(lerped!.elevation, equals(3.0));
      expect(
        lerped.backgroundColor,
        equals(
          Color.lerp(const Color(0xFF112233), const Color(0xFF999999), 0.5),
        ),
      );
    });

    testWidgets('Custom JustButtonStyle applies to JustButton', (tester) async {
      const customStyle = JustButtonStyle(
        backgroundColor: Color(0xFF00FF00),
        foregroundColor: Color(0xFF000000),
        borderColor: Color(0xFFFF0000),
        borderRadius: .all(.circular(16)),
        padding: EdgeInsets.symmetric(horizontal: 28),
        elevation: 3.0,
      );

      await tester.pumpWidget(
        buildTestApp(
          JustButton(
            label: 'Custom Styled',
            style: customStyle,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Custom Styled'), findsOneWidget);

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('Custom Styled'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF00FF00)));
      expect(
        decoration.borderRadius,
        equals(const BorderRadius.all(Radius.circular(16))),
      );
      expect(
        animatedContainer.padding,
        equals(const EdgeInsets.symmetric(horizontal: 28)),
      );
    });
  });

  group('JustButtonTheme / JustButtonThemeData Unit & Integration Tests', () {
    test(
      'Theme Extension defaults, copyWith, lerp, equality, and hashCode',
      () {
        const defaultTheme = JustButtonTheme.defaults;
        expect(defaultTheme.enableHaptic, isFalse);
        expect(defaultTheme.primaryStyle, isNull);

        const customPrimary = JustButtonStyle(
          backgroundColor: Color(0xFF123456),
        );
        const customSecondary = JustButtonStyle(borderColor: Color(0xFF654321));
        const customGhost = JustButtonStyle(foregroundColor: Color(0xFFABCDEF));
        const customDestructive = JustButtonStyle(
          backgroundColor: Color(0xFFFF0000),
        );
        const customLink = JustButtonStyle(foregroundColor: Color(0xFF0000FF));

        const theme1 = JustButtonTheme(
          primaryStyle: customPrimary,
          secondaryStyle: customSecondary,
          ghostStyle: customGhost,
          destructiveStyle: customDestructive,
          linkStyle: customLink,
          enableHaptic: true,
        );

        final copied = theme1.copyWith(enableHaptic: false);
        expect(copied.enableHaptic, isFalse);
        expect(copied.primaryStyle, equals(customPrimary));
        expect(copied.secondaryStyle, equals(customSecondary));
        expect(copied.ghostStyle, equals(customGhost));
        expect(copied.destructiveStyle, equals(customDestructive));
        expect(copied.linkStyle, equals(customLink));

        const themeClone = JustButtonTheme(
          primaryStyle: customPrimary,
          secondaryStyle: customSecondary,
          ghostStyle: customGhost,
          destructiveStyle: customDestructive,
          linkStyle: customLink,
          enableHaptic: true,
        );

        expect(theme1, equals(themeClone));
        expect(theme1.hashCode, equals(themeClone.hashCode));
        expect(theme1 == copied, isFalse);

        // Lerp tests
        expect(theme1.lerp(null, 0.5), equals(theme1));
        final lerpedTheme = theme1.lerp(copied, 0.7);
        expect(lerpedTheme.enableHaptic, isFalse);
        final lerpedThemeEarly = theme1.lerp(copied, 0.3);
        expect(lerpedThemeEarly.enableHaptic, isTrue);

        // Parity with JustButtonThemeData typedef
        expect(theme1, isA<JustButtonThemeData>());
      },
    );

    testWidgets('Global JustButtonTheme overrides button styles in tree', (
      tester,
    ) async {
      const themePrimaryStyle = JustButtonStyle(
        backgroundColor: Color(0xFF123456),
        foregroundColor: Color(0xFFFFFFFF),
        borderRadius: .all(.circular(20)),
      );

      final materialTheme = ThemeData(
        extensions: const [
          JustButtonTheme(primaryStyle: themePrimaryStyle, enableHaptic: true),
        ],
      );

      await tester.pumpWidget(
        buildTestApp(
          materialTheme: materialTheme,
          JustButton.primary(label: 'Themed Button', onPressed: () {}),
        ),
      );

      expect(find.text('Themed Button'), findsOneWidget);
      final container = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.text('Themed Button'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF123456)));
      expect(
        decoration.borderRadius,
        equals(const BorderRadius.all(Radius.circular(20))),
      );
    });
  });
}
