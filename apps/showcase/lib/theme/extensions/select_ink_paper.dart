// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/select/just_select_style.dart';
import 'package:just_ui_core/src/components/select/just_select_theme.dart';

import '../ink_paper_tokens.dart';

/// Select overrides for Ink and Paper.
///
/// Mirrors `KitSelect` and the Ink and Paper role tokens: surface trigger,
/// raised dropdown menu, hover and selection fills, control vs ink border,
/// and control border radius (8 px default, sharp in neobrutalism).
JustSelectTheme selectInkPaper(JustThemePreset preset, InkPaperRoles r) {
  final bool neo = preset == .neobrutalism;
  return JustSelectTheme(
    style: JustSelectStyle(
      triggerBackgroundColor: r.surface,
      dropdownBackgroundColor: r.raised,
      optionHoverColor: r.hover,
      selectedOptionColor: neo ? r.inverse : r.selection,
      textColor: r.textPrimary,
      placeholderColor: r.textSecondary,
      triggerBorderColor: neo ? r.textPrimary : r.borderControl,
      borderRadius: neo ? .zero : const .all(.circular(8)),
    ),
  );
}
