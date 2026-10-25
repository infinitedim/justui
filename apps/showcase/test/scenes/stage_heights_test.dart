import 'dart:io';

import 'package:flutter/material.dart' show Material;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/scenes/scene_registry.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

import '../support/golden_harness.dart';

const String _docs = '../docs/src';

/// `min-h-[Npx]` entries of the docs stage map, by slug, and its default.
(Map<String, double>, double) stageHeights() {
  final String source = File(
    '$_docs/components/organisms/parts-index/stage-heights.ts',
  ).readAsStringSync();
  final RegExp entry = RegExp(
    r"^\s*'?([a-z-]+)'?: 'min-h-\[(\d+)px\]',$",
    multiLine: true,
  );
  final RegExp fallback = RegExp(r"DEFAULT_STAGE = 'min-h-\[(\d+)px\]'");
  return (
    <String, double>{
      for (final RegExpMatch m in entry.allMatches(source))
        m[1]!: double.parse(m[2]!),
    },
    double.parse(fallback.firstMatch(source)![1]!),
  );
}

/// Slugs of `WIDE_PARTS` in the docs part groups.
Set<String> wideParts() {
  final String source = File('$_docs/lib/part-groups.ts').readAsStringSync();
  final String set = source.substring(
    source.indexOf('const WIDE_PARTS'),
    source.indexOf(']);', source.indexOf('const WIDE_PARTS')),
  );
  return RegExp(r"'([a-z-]+)'")
      .allMatches(set)
      .map((RegExpMatch m) => m[1]!)
      .toSet();
}

/// The [lang] block of the docs `kitTranslations`, one `key: value,` per
/// line (the same parse as `strings_drift_test.dart`).
Map<String, Object> kitCopy(String lang) {
  final String source = File('$_docs/lib/kit-translations.ts')
      .readAsStringSync();
  final int start = source.indexOf('  $lang: {');
  final int end = lang == 'en' ? source.indexOf('  id: {') : source.length;
  final RegExp entry = RegExp(r"^    (\w+): (\[.*\]|'.*'),$", multiLine: true);
  final RegExp quoted = RegExp(r"'([^']*)'");
  return <String, Object>{
    for (final RegExpMatch m in entry.allMatches(source.substring(start, end)))
      m[1]!: m[2]!.startsWith('[')
          ? quoted.allMatches(m[2]!).map((RegExpMatch q) => q[1]!).toList()
          : m[2]!.substring(1, m[2]!.length - 1),
  };
}

/// Size of the scene's own widget in the view as it is now.
Size sceneSize(WidgetTester tester) {
  final RenderBox align = tester.renderObject<RenderBox>(
    find
        .descendant(of: find.byType(Material), matching: find.byType(Align))
        .first,
  );
  Size size = Size.zero;
  align.visitChildren((RenderObject child) {
    size = (child as RenderBox).size;
  });
  return size;
}

/// Size of [scene]'s own widget when its view is [width] wide.
Future<Size> measure(
  WidgetTester tester,
  String scene,
  JustThemePreset preset,
  double width, {
  Map<String, Object> strings = const <String, Object>{},
}) async {
  // The harness pads the view by 16 on each side; the scene sits in an
  // Align, so it takes its own size up to the width it is given.
  await pumpScene(
    tester,
    scene: scene,
    preset: preset,
    mode: InkPaperMode.light,
    size: Size(width + 32, 900),
    strings: strings,
  );
  return sceneSize(tester);
}

/// Every live scene fits the stage the components page gives it, in both
/// presets. Views are 320 x 344 on every page (LivePart: the engine shares
/// one surface between views), so a scene gets 320 px and must stay inside
/// the narrowest cell that shows it: 240 px for a narrow cell, 280 px for a
/// wide one (a phone), and 8 px under its stage for the top padding.
/// Growth on use (open accordion, input error) is budgeted by hand.
void main() {
  final (Map<String, double> heights, double fallback) = stageHeights();
  final Set<String> wide = wideParts();

  test('the docs files parse', () {
    expect(heights, isNotEmpty);
    expect(wide, contains('date-picker'));
  });

  for (final String scene in sceneRegistry.keys) {
    final double stage = heights[scene] ?? fallback;
    final double maxWidth = wide.contains(scene) ? 280 : 240;
    for (final JustThemePreset preset in JustThemePreset.values) {
      testWidgets('$scene fits its stage (${preset.name})', (
        WidgetTester tester,
      ) async {
        final Size size = await measure(tester, scene, preset, 320);
        expect(size.width, lessThanOrEqualTo(maxWidth));
        expect(size.height + 8, lessThanOrEqualTo(stage));
        expect(stage - 8, lessThanOrEqualTo(328), reason: 'view is 344 tall');
      });
    }
  }

  // Growth a visitor can trigger, with the copy each locale sends.
  for (final String lang in <String>['en', 'id']) {
    for (final JustThemePreset preset in JustThemePreset.values) {
      testWidgets('input with its error fits ($lang, ${preset.name})', (
        WidgetTester tester,
      ) async {
        await measure(tester, 'input', preset, 320, strings: kitCopy(lang));
        await tester.enterText(find.byType(EditableText), 'Just UI');
        await tester.pumpAndSettle();
        final double stage = heights['input'] ?? fallback;
        expect(sceneSize(tester).height + 8, lessThanOrEqualTo(stage));
      });

      testWidgets('open accordion fits ($lang, ${preset.name})', (
        WidgetTester tester,
      ) async {
        final Map<String, Object> copy = kitCopy(lang);
        await measure(tester, 'accordion', preset, 320, strings: copy);
        await tester.tap(find.text(copy['accordionQuestion']! as String));
        await tester.pumpAndSettle();
        final double stage = heights['accordion'] ?? fallback;
        expect(sceneSize(tester).height + 8, lessThanOrEqualTo(stage));
      });
    }
  }
}
