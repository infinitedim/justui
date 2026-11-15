import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart'
    show Colors, Icons, MaterialApp, Scaffold, ThemeExtension;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/toast/just_toast.dart';
import 'package:just_ui_core/src/components/toast/just_toast_style.dart';
import 'package:just_ui_core/src/components/toast/just_toast_theme.dart';
import 'package:just_ui_core/src/components/toast/just_toast_variants.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip_style.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip_theme.dart';

Widget _buildTestApp(
  Widget child, {
  JustThemeData? theme,
  JustToastTheme? toastTheme,
  JustTooltipTheme? tooltipTheme,
}) {
  final JustThemeData resolvedTheme = theme ?? JustThemeData.light;
  final List<ThemeExtension<dynamic>> extensions = <ThemeExtension<dynamic>>[
    ?toastTheme,
    ?tooltipTheme,
  ];
  return JustThemeProvider(
    lightTheme: resolvedTheme,
    darkTheme: resolvedTheme,
    initialThemeMode: .light,
    child: MaterialApp(
      theme: resolvedTheme.toThemeData(additionalExtensions: extensions),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

BoxDecoration _findBoxDecoration(WidgetTester tester, {required Finder scope}) {
  final Finder containers = find.descendant(
    of: scope,
    matching: find.byWidgetPredicate(
      (Widget w) => w is Container && w.decoration is BoxDecoration,
    ),
  );
  final Container container = tester.widget<Container>(containers.first);
  return container.decoration! as BoxDecoration;
}

SemanticsData _semanticsOf(WidgetTester tester, Finder finder) =>
    tester.getSemantics(finder).getSemanticsData();

BoxDecoration _toastBox(WidgetTester tester) =>
    _findBoxDecoration(tester, scope: find.byType(JustToastSurface));

BoxDecoration _closeRingDecoration(WidgetTester tester) {
  final Finder finder = find.ancestor(
    of: find.byIcon(Icons.close),
    matching: find.byType(DecoratedBox),
  );
  return tester.widget<DecoratedBox>(finder.first).decoration as BoxDecoration;
}

void main() {
  group('JustToastSurface & JustToastController description', () {
    testWidgets(
      'JustToastSurface renders message, description, variants, and optional close button inline',
      (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          _buildTestApp(
            const JustToastSurface(
              message: 'Saved',
              description: 'Project settings updated.',
              variant: .success,
              showCloseButton: false,
            ),
          ),
        );

        expect(find.text('Saved'), findsOneWidget);
        expect(find.text('Project settings updated.'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.close), findsNothing);
        expect(
          _semanticsOf(
            tester,
            find.byType(JustToastSurface),
          ).flagsCollection.isLiveRegion,
          isFalse,
        );

        final Row row = tester.widget<Row>(
          find.descendant(
            of: find.byType(JustToastSurface),
            matching: find.byType(Row),
          ),
        );
        expect(row.crossAxisAlignment, equals(CrossAxisAlignment.start));
        semantics.dispose();
      },
    );

    testWidgets(
      'JustToastSurface respects close button, action, liveRegion, and borderWidth',
      (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        try {
          int dismissCount = 0;
          await tester.pumpWidget(
            _buildTestApp(
              JustToastSurface(
                message: 'Single line',
                liveRegion: true,
                onDismiss: () => dismissCount++,
                style: const JustToastStyle(
                  minWidth: 0,
                  maxWidth: 240,
                  borderWidth: 0.0,
                ),
              ),
            ),
          );

          final Finder closeIcon = find.byIcon(Icons.close);
          expect(closeIcon, findsOneWidget);
          expect(tester.getSize(find.byType(JustToastSurface)).width, 240.0);
          final Size closeSize = tester.getSize(closeIcon);
          expect(closeSize.width >= 24.0 && closeSize.height >= 24.0, isTrue);
          expect(
            _semanticsOf(tester, closeIcon).flagsCollection.isButton,
            isTrue,
          );
          final BoxDecoration borderless = _toastBox(tester);
          expect(borderless.border, isNull);
          expect(
            _semanticsOf(
              tester,
              find.byType(JustToastSurface),
            ).flagsCollection.isLiveRegion,
            isTrue,
          );

          await tester.tap(closeIcon);
          expect(dismissCount, equals(1));
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(FocusManager.instance.primaryFocus, isNotNull);
          expect(
            FocusManager.instance.primaryFocus,
            isNot(isA<FocusScopeNode>()),
          );
          expect(_closeRingDecoration(tester).border, isNotNull);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          expect(dismissCount, equals(3));
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'JustToastSurface renders action instead of close button and applies custom styles',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const JustToastSurface(
              message: 'Deleted',
              description: 'Moved to trash.',
              variant: .error,
              descriptionTextStyle: TextStyle(fontSize: 13, color: Colors.red),
              action: Text('Undo'),
              style: JustToastStyle(
                borderWidth: 2.5,
                borderColor: Colors.black,
              ),
            ),
            theme: JustThemeData.neobrutalismLight,
          ),
        );

        expect(find.text('Undo'), findsOneWidget);
        expect(find.byIcon(Icons.close), findsNothing);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        final Text desc = tester.widget<Text>(find.text('Moved to trash.'));
        expect(desc.style?.color, equals(Colors.red));

        final BoxDecoration bordered = _toastBox(tester);
        expect(bordered.border, isNotNull);
      },
    );

    testWidgets(
      'JustToastSurface renders all variants and applies JustToastTheme overrides',
      (WidgetTester tester) async {
        final Map<ToastVariant, IconData> expectedIcons =
            <ToastVariant, IconData>{
              .info: Icons.info_outline,
              .success: Icons.check_circle_outline,
              .warning: Icons.warning_amber_outlined,
              .error: Icons.error_outline,
            };
        for (final MapEntry<ToastVariant, IconData> pair
            in expectedIcons.entries) {
          await tester.pumpWidget(
            _buildTestApp(
              JustToastSurface(message: pair.key.name, variant: pair.key),
              toastTheme: const JustToastTheme(
                warningStyle: JustToastStyle(backgroundColor: Colors.amber),
              ),
            ),
          );
          expect(find.byIcon(pair.value), findsOneWidget);
          if (pair.key == .warning) {
            final BoxDecoration box = _toastBox(tester);
            expect(box.color, equals(Colors.amber));
          }
        }
      },
    );

    testWidgets(
      'JustToastController.show passes description to overlay JustToastSurface',
      (WidgetTester tester) async {
        final JustToastController controller = JustToastController();
        await tester.pumpWidget(
          _buildTestApp(
            JustToastScope(
              controller: controller,
              child: const SizedBox.shrink(),
            ),
          ),
        );

        controller.show(
          message: 'Saved',
          description: 'All changes synced.',
          variant: .success,
          duration: const Duration(seconds: 5),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(JustToastSurface), findsOneWidget);
        expect(find.text('Saved'), findsOneWidget);
        expect(find.text('All changes synced.'), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);

        final JustToastSurface surface = tester.widget<JustToastSurface>(
          find.byType(JustToastSurface),
        );
        expect(surface.showCloseButton, isTrue);
        expect(surface.liveRegion, isTrue);

        controller.dismiss();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'JustToastSurface resolves body and description from justTypo',
      (WidgetTester tester) async {
        const JustTypographyScheme typo = JustTypographyScheme.fromFontFamily(
          fontFamily: 'ToastFont',
        );
        final JustThemeData theme = JustThemeData.light.copyWith(
          typography: typo,
        );
        const Widget surface = JustToastSurface(message: 'T', description: 'D');
        await tester.pumpWidget(_buildTestApp(surface, theme: theme));
        String? fontOf(String s) =>
            tester.widget<Text>(find.text(s)).style?.fontFamily;
        expect(fontOf('T'), 'ToastFont');
        expect(fontOf('D'), 'ToastFont');
      },
    );
  });

  group('JustTooltipBubble & JustTooltip delegation', () {
    testWidgets(
      'JustTooltipBubble renders inline and applies maxWidth constraint',
      (WidgetTester tester) async {
        const String msg = 'A long tooltip message that wraps at maxWidth';
        await tester.pumpWidget(
          _buildTestApp(
            const JustTooltipBubble(
              message: msg,
              style: JustTooltipStyle(
                maxWidth: 120,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        );

        final Finder bubble = find.byType(JustTooltipBubble);
        expect(find.text(msg), findsOneWidget);
        expect(tester.getSize(bubble).width, lessThanOrEqualTo(120.0));
        final BoxDecoration box = _findBoxDecoration(tester, scope: bubble);
        expect(box.color, equals(Colors.black));
        expect(box.border, isNull);
      },
    );

    testWidgets(
      'JustTooltipBubble uses JustTooltipTheme maxWidth and neobrutalism border',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const JustTooltipBubble(message: 'Wrapped tooltip text'),
            theme: JustThemeData.neobrutalismLight,
            tooltipTheme: const JustTooltipTheme(
              style: JustTooltipStyle(maxWidth: 100),
            ),
          ),
        );
        final Finder bubble = find.byType(JustTooltipBubble);
        expect(tester.getSize(bubble).width, lessThanOrEqualTo(100.0));
        expect(_findBoxDecoration(tester, scope: bubble).border, isNotNull);
      },
    );

    testWidgets(
      'JustTooltip delegates its overlay bubble to JustTooltipBubble',
      (WidgetTester tester) async {
        final OverlayPortalController controller = OverlayPortalController();
        await tester.pumpWidget(
          _buildTestApp(
            JustTooltip(
              message: 'Copy',
              controller: controller,
              style: const JustTooltipStyle(maxWidth: 140),
              child: const Text('Target'),
            ),
          ),
        );
        expect(find.byType(JustTooltipBubble), findsNothing);
        controller.show();
        await tester.pumpAndSettle();
        expect(find.byType(JustTooltipBubble), findsOneWidget);
        expect(find.text('Copy'), findsOneWidget);
        controller.hide();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'JustTooltipBubble honors style overrides and neo inverse shadow',
      (WidgetTester tester) async {
        final JustThemeData neo = JustThemeData.neobrutalismLight;
        const Key kA = ValueKey<String>('a');
        const Key kB = ValueKey<String>('b');
        final JustTooltipStyle override = JustTooltipStyle(
          backgroundColor: neo.colors.textPrimary,
          foregroundColor: neo.colors.textInverse,
          borderWidth: 0.0,
          borderRadius: .zero,
          shadows: const <BoxShadow>[],
          textStyle: const TextStyle(
            fontFamily: 'Mono',
            fontSize: 12,
            fontWeight: .w600,
          ),
        );
        final Widget pair = Column(
          mainAxisSize: .min,
          children: <Widget>[
            JustTooltipBubble(key: kA, message: 'A', style: override),
            JustTooltipBubble(
              key: kB,
              message: 'B',
              style: JustTooltipStyle(backgroundColor: neo.colors.textPrimary),
            ),
          ],
        );
        await tester.pumpWidget(_buildTestApp(pair, theme: neo));

        BoxDecoration deco(Key k) =>
            _findBoxDecoration(tester, scope: find.byKey(k));
        final BoxDecoration boxA = deco(kA);
        expect(boxA.border, isNull);
        expect(boxA.boxShadow, isEmpty);
        final Text textA = tester.widget<Text>(find.text('A'));
        expect(textA.style?.fontFamily, 'Mono');
        expect(textA.style?.color, neo.colors.textInverse);

        final BoxDecoration boxB = deco(kB);
        final bool same = boxB.boxShadow!.any(
          (BoxShadow s) => s.color == boxB.color,
        );
        expect(same, isFalse);
      },
    );

    testWidgets(
      'JustTooltip and JustToastController honor disableAnimations with Duration.zero',
      (WidgetTester tester) async {
        final JustToastController toastController = JustToastController();
        await tester.pumpWidget(
          _buildTestApp(
            MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: JustToastScope(
                controller: toastController,
                child: const JustTooltip(
                  message: 'Quick Tip',
                  showDelay: Duration.zero,
                  child: SizedBox(width: 48, height: 48, child: Text('Target')),
                ),
              ),
            ),
          ),
        );

        final TestGesture mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer();
        await mouse.moveTo(tester.getCenter(find.text('Target')));
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump();

        final Opacity tipOpacity = tester.widget<Opacity>(
          find.ancestor(
            of: find.byType(JustTooltipBubble),
            matching: find.byType(Opacity),
          ),
        );
        expect(tipOpacity.opacity, equals(1.0));
        await mouse.moveTo(Offset.zero);
        await mouse.removePointer();
        await tester.pumpAndSettle();

        toastController.show(message: 'Instant Toast');
        await tester.pump();
        final FadeTransition toastFade = tester.widget<FadeTransition>(
          find.ancestor(
            of: find.byType(JustToastSurface),
            matching: find.byType(FadeTransition),
          ),
        );
        expect(toastFade.opacity.value, equals(1.0));
        toastController.forceDismissAll();
        await tester.pumpAndSettle();
      },
    );
  });
}
