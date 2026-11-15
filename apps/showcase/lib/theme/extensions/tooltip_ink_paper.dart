// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip_style.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip_theme.dart';

import '../ink_paper_tokens.dart';

/// Tooltip overrides for Ink and Paper.
///
/// Uses the inverse ink fill (`r.inverse` / `r.onInverse`) and matches the
/// 6 px default / sharp neobrutalism corners of `KitTooltip`.
JustTooltipTheme tooltipInkPaper(JustThemePreset preset, InkPaperRoles r) {
  return JustTooltipTheme(
    style: JustTooltipStyle(
      backgroundColor: r.inverse,
      foregroundColor: r.onInverse,
      borderRadius: preset == .neobrutalism ? .zero : const .all(.circular(6)),
      padding: const .symmetric(horizontal: 10, vertical: 6),
    ),
  );
}
