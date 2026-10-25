// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area_style.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area_theme.dart';

import '../ink_paper_tokens.dart';

/// Scroll area overrides for Ink and Paper.
///
/// The default preset needs none. In neobrutalism core paints the thumb as a
/// 30% grey, a tinted line the preset does not use; the thumb is ink, like
/// the docs demo.
JustScrollAreaTheme scrollAreaInkPaper(
  JustThemePreset preset,
  InkPaperRoles r,
) {
  if (preset != .neobrutalism) return JustScrollAreaTheme.defaults;
  return JustScrollAreaTheme(
    style: JustScrollAreaStyle(scrollbarThumbColor: r.textPrimary),
  );
}
