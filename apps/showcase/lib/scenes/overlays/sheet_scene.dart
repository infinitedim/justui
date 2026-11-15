// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/sheet/just_sheet.dart';

import '../../theme/ink_paper_theme.dart';
import '../scene.dart';

/// Part 30, sheet: an inline bottom panel with a grabber and title,
/// matching `KitPart` `sheet` (`KitSheet`, `max-w-60`).
///
/// Contains no interactive controls so keyboard Tab skips past the static
/// preview just like its React counterpart.
Widget sheetScene(BuildContext context, SceneContext scene) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 240),
    child: JustSheetSurface(
      direction: .bottom,
      showHandle: true,
      child: Text(
        scene.strings.text('share'),
        style: const TextStyle(
          fontFamily: InkPaperTheme.fontFamily,
          fontSize: 15,
          fontWeight: .w700,
        ),
      ),
    ),
  );
}
