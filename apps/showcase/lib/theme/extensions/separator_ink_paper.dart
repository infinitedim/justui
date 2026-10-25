// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/separator/just_separator_style.dart';
import 'package:just_ui_core/src/components/separator/just_separator_theme.dart';

import '../ink_paper_tokens.dart';

/// Separator overrides for Ink and Paper.
///
/// Core draws separators with `borderDefault`, which the Ink and Paper scheme
/// maps to the control border. A separator is a hairline between containers
/// (`borderSubtle`); in neobrutalism every rule is ink (`textPrimary`).
/// Thickness stays core's (1, or 2 in neobrutalism).
JustSeparatorTheme separatorInkPaper(JustThemePreset preset, InkPaperRoles r) {
  return JustSeparatorTheme(
    style: JustSeparatorStyle(
      color: preset == .neobrutalism ? r.textPrimary : r.borderSubtle,
    ),
  );
}
