// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart' show FontWeight, TextStyle;
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/table/just_table_style.dart';
import 'package:just_ui_core/src/components/table/just_table_theme.dart';

import '../ink_paper_tokens.dart';

/// Table overrides for Ink and Paper.
///
/// Core fills the neobrutalism header with ink (the selected-item look) and
/// draws the default grid in the control border. Ink and Paper keeps the
/// header a sunken row with secondary text in both presets and draws the
/// grid in the container border: subtle in default, ink in neobrutalism.
JustTableTheme tableInkPaper(JustThemePreset preset, InkPaperRoles r) {
  return JustTableTheme(
    style: JustTableStyle(
      headerBackgroundColor: r.sunken,
      headerTextColor: r.textSecondary,
      borderColor: preset == .neobrutalism ? r.textPrimary : r.borderSubtle,
      rowBackgroundColor: r.canvas,
      hoverColor: r.hover,
      headerTextStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: r.textSecondary,
      ),
    ),
  );
}
