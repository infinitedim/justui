import 'package:flutter/material.dart'
    show Colors, Icons, MaterialApp, Scaffold, ThemeExtension;
import 'package:flutter/semantics.dart';
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
        final SemanticsNode node = tester.getSemantics(
          find.byType(JustToastSurface),
        );
        expect(node.getSemanticsData().flagsCollection.isLiveRegion, isFalse);

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

        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(tester.getSize(find.byType(JustToastSurface)).width, 240.0);
        final BoxDecoration borderless = _findBoxDecoration(
          tester,
          scope: find.byType(JustToastSurface),
        );
        expect(borderless.border, isNull);
        final SemanticsNode liveNode = tester.getSemantics(
          find.byType(JustToastSurface),
        );
        expect(
          liveNode.getSemanticsData().flagsCollection.isLiveRegion,
          isTrue,
        );

        await tester.tap(find.byIcon(Icons.close));
        expect(dismissCount, equals(1));
        semantics.dispose();
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

        final BoxDecoration bordered = _findBoxDecoration(
          tester,
          scope: find.byType(JustToastSurface),
        );
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
            final BoxDecoration box = _findBoxDecoration(
              tester,
              scope: find.byType(JustToastSurface),
            );
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
  });

  group('JustTooltipBubble & JustTooltip delegation', () {
    testWidgets(
      'JustTooltipBubble renders inline and applies maxWidth constraint',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const JustTooltipBubble(
              message: 'A long tooltip message that must wrap cleanly inside maxWidth',
              style: JustTooltipStyle(
                maxWidth: 120,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        );

        expect(
          find.text(
            'A long tooltip message that must wrap cleanly inside maxWidth',
          ),
          findsOneWidget,
        );
        expect(
          tester.getSize(find.byType(JustTooltipBubble)).width,
          lessThanOrEqualTo(120.0),
        );
        final BoxDecoration box = _findBoxDecoration(
          tester,
          scope: find.byType(JustTooltipBubble),
        );
        expect(box.color, equals(Colors.black));
        expect(box.border, isNull);
      },
    );

    testWidgets(
      'JustTooltipBubble uses JustTooltipTheme maxWidth and neobrutalism border',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const JustTooltipBubble(
              message: 'Theme constrained tooltip text that wraps at maxWidth',
            ),
            theme: JustThemeData.neobrutalismLight,
            tooltipTheme: const JustTooltipTheme(
              style: JustTooltipStyle(maxWidth: 100),
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(JustTooltipBubble)).width,
          lessThanOrEqualTo(100.0),
        );
        final BoxDecoration neoBox = _findBoxDecoration(
          tester,
          scope: find.byType(JustTooltipBubble),
        );
        expect(neoBox.border, isNotNull);
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
  });
}
