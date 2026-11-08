// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_style.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_theme.dart';

import '../ink_paper_tokens.dart';

/// Toggle overrides for Ink and Paper.
///
/// In Neobrutalism, Rule A requires that controls with an ink fill have no
/// ink offset shadow underneath.
JustToggleTheme toggleInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset != .neobrutalism) return JustToggleTheme.defaults;
  return const JustToggleTheme(
    style: JustToggleStyle(selectedShadows: <BoxShadow>[]),
  );
}
