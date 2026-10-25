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

/// Size of [scene]'s own widget when its view is [width] wide.
Future<Size> measure(
  WidgetTester tester,
  String scene,
  JustThemePreset preset,
  double width,
) async {
  // The harness pads the view by 16 on each side; the scene sits in an
  // Align, so it takes its own size up to the width it is given.
  await pumpScene(
    tester,
    scene: scene,
    preset: preset,
    mode: InkPaperMode.light,
    size: Size(width + 32, 900),
  );
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
}
