// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/resizable/just_resizable_theme.dart';

import '../ink_paper_tokens.dart';

/// Resizable overrides for Ink and Paper.
///
/// Core means neobrutalism dividers to be 2.5 wide, but the theme's own
/// `dividerThickness` default (1.0) always wins over that fallback. The
/// override restores the 2.5 ink line in neobrutalism; colors stay core's.
JustResizableTheme resizableInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset != .neobrutalism) return JustResizableTheme.defaults;
  return const JustResizableTheme(dividerThickness: 2.5);
}
