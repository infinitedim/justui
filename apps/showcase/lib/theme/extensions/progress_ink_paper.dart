// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart' show BorderRadius;
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/progress/just_progress_style.dart';
import 'package:just_ui_core/src/components/progress/just_progress_theme.dart';

import '../ink_paper_tokens.dart';

/// Progress overrides for Ink and Paper.
///
/// Core paints the default track at 30% of the control border and leaves
/// the neobrutalism track transparent. The docs part uses one recipe in both
/// presets: an ink indicator on a control-colored track with square ends.
JustProgressTheme progressInkPaper(JustThemePreset preset, InkPaperRoles r) {
  return JustProgressTheme(
    style: JustProgressStyle(
      trackColor: r.borderControl,
      fillColor: r.inverse,
      labelColor: r.textPrimary,
      borderRadius: BorderRadius.zero,
    ),
  );
}
