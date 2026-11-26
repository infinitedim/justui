// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area_style.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area_theme.dart';

import '../ink_paper_tokens.dart';

/// Scroll area overrides for Ink and Paper.
///
/// Mirrors `KitScrollArea`: always-visible 6 px thumb on a sunken track,
/// pill ends in default and sharp corners in neobrutalism.
JustScrollAreaTheme scrollAreaInkPaper(
  JustThemePreset preset,
  InkPaperRoles r,
) {
  final bool neo = preset == .neobrutalism;
  return JustScrollAreaTheme(
    style: JustScrollAreaStyle(
      scrollbarThumbColor: neo ? r.textPrimary : r.borderControl,
      scrollbarTrackColor: r.sunken,
      scrollbarThickness: 6.0,
      scrollbarRadius: neo ? .zero : const .circular(999.0),
      scrollbarTrackRadius: neo ? .zero : const .circular(999.0),
      scrollbarMargin: 6.0,
      scrollbarCrossAxisMargin: 6.0,
      thumbVisibility: true,
      trackVisibility: true,
      focusBorderRadius: neo ? .zero : const .all(.circular(8.0)),
    ),
  );
}
