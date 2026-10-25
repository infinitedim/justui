import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/bridge/view_config.dart';
import 'package:showcase/bridge/view_host.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

import 'scene_sizes.dart';

/// The four preset and mode combinations every scene is locked in.
const List<(JustThemePreset, InkPaperMode)> goldenCombos =
    <(JustThemePreset, InkPaperMode)>[
      (.default_, .light),
      (.default_, .dark),
      (.neobrutalism, .light),
      (.neobrutalism, .dark),
    ];

/// File name part for a combination, e.g. `neobrutalism_dark`.
String comboName(JustThemePreset preset, InkPaperMode mode) =>
    '${preset == .neobrutalism ? 'neobrutalism' : 'default'}_${mode.name}';

/// Pumps [scene] the way a docs host shows it: a [size] box on the mode's
/// canvas color, through the same [ViewHost] the web build uses.
Future<void> pumpScene(
  WidgetTester tester, {
  required String scene,
  required JustThemePreset preset,
  required InkPaperMode mode,
  Size size = const Size(320, 160),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ColoredBox(
      color: InkPaperTheme.roles(mode).canvas,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ViewHost(
          viewId: 0,
          fallbackConfig: ViewConfig(scene: scene, preset: preset, mode: mode),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps [scene] in the default preset, light mode, at its locked size
/// (keyboard and behavior tests).
Future<void> pumpDefault(WidgetTester tester, String scene) => pumpScene(
  tester,
  scene: scene,
  preset: .default_,
  mode: .light,
  size: sceneSizes[scene]!,
);
