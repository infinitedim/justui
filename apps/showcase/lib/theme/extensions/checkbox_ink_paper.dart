// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox_style.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox_theme.dart';

import '../ink_paper_tokens.dart';

/// Checkbox overrides for Ink and Paper.
///
/// In Neobrutalism, Rule A requires that controls with an ink fill have no
/// ink offset shadow underneath.
JustCheckboxTheme checkboxInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset != .neobrutalism) return JustCheckboxTheme.defaults;
  return const JustCheckboxTheme(
    style: JustCheckboxStyle(activeShadows: <BoxShadow>[]),
  );
}
