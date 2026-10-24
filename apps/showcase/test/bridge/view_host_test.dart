// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show MaterialApp, Theme;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/button/just_button_theme.dart';
import 'package:showcase/bridge/bridge.dart';
import 'package:showcase/bridge/view_host.dart';

import '../support/fake_bridge.dart';

void main() {
  late FakeBridgePlatform page;

  setUp(() {
    page = FakeBridgePlatform(<int, Object?>{
      0: <String, Object?>{
        'scene': 'button',
        'preset': 'default',
        'theme': 'light',
        'locale': 'en',
        'strings': <String, Object?>{'saveChanges': 'Save changes'},
      },
    });
    debugBridgePlatform = page;
  });

  tearDown(() => debugBridgePlatform = null);

  testWidgets('renders the scene from initialData and announces once', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ViewHost(viewId: 0));
    await tester.pump();
    expect(find.text('Save changes'), findsOneWidget);
    expect(page.announceCount[0], 1);
    await tester.pump();
    expect(page.announceCount[0], 1);
  });

  // On the web WidgetsApp skips its Title widget when title is null, so the
  // host page keeps its document.title (the VM test binding always adds one).
  testWidgets('builds its app without a title', (WidgetTester tester) async {
    await tester.pumpWidget(const ViewHost(viewId: 0));
    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(app.title, isNull);
  });

  testWidgets('applies a patch from the page', (WidgetTester tester) async {
    await tester.pumpWidget(const ViewHost(viewId: 0));
    await tester.pump();
    final Future<void> done = page.controllers[0]!(<String, Object?>{
      'preset': 'neobrutalism',
      'theme': 'dark',
      'strings': <String, Object?>{'saveChanges': 'Simpan perubahan'},
    });
    await tester.pump();
    await done;
    expect(find.text('Simpan perubahan'), findsOneWidget);
    final BuildContext context = tester.element(find.text('Simpan perubahan'));
    expect(context.justPreset, JustThemePreset.neobrutalism);
    expect(context.justColors.background.computeLuminance(), lessThan(0.5));
    expect(
      Theme.of(context).extension<JustButtonTheme>()?.primaryStyle,
      isNotNull,
    );
  });

  testWidgets('an invalid patch keeps the current config', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ViewHost(viewId: 0));
    await tester.pump();
    final Future<void> done = page.controllers[0]!(<String, Object?>{
      'preset': 'material',
      'strings': <String, Object?>{'saveChanges': 'a\u202Eb'},
    });
    await tester.pump();
    await done;
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets('renders nothing for an unknown scene', (
    WidgetTester tester,
  ) async {
    page.configs[0] = <String, Object?>{'scene': 'nope'};
    await tester.pumpWidget(const ViewHost(viewId: 0));
    await tester.pump();
    expect(find.byType(Text), findsNothing);
    expect(page.announceCount[0], isNull);
  });
}
