// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/resizable/just_resizable_style.dart';
import 'package:just_ui_core/src/components/resizable/just_resizable_theme.dart';

import '../ink_paper_tokens.dart';

/// Resizable overrides for Ink and Paper.
///
/// Default uses the surface role on the centered grip pill so its control
/// border keeps >= 3.9:1 contrast in both light and dark modes (matching
/// `KitResizable`). Neobrutalism restores the 2.5 px ink divider line.
JustResizableTheme resizableInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset == .neobrutalism) {
    return JustResizableTheme(
      dividerThickness: 2.5,
      style: JustResizableStyle(gripColor: r.surface),
    );
  }
  return JustResizableTheme(
    style: JustResizableStyle(
      gripColor: r.surface,
      gripRadius: const .all(.circular(4.0)),
    ),
  );
}
