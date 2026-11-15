// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart' show Color, TextStyle;
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/toast/just_toast_style.dart';
import 'package:just_ui_core/src/components/toast/just_toast_theme.dart';

import '../ink_paper_theme.dart';
import '../ink_paper_tokens.dart';

JustToastStyle _toastStyle(
  JustThemePreset preset,
  InkPaperRoles r,
  Color foreground,
) {
  final bool neo = preset == .neobrutalism;
  return JustToastStyle(
    backgroundColor: r.raised,
    borderColor: neo ? r.textPrimary : null,
    borderWidth: neo ? 2.5 : 0.0,
    borderRadius: neo ? .zero : const .all(.circular(12)),
    padding: const .symmetric(horizontal: 16, vertical: 14),
    minWidth: 0,
    maxWidth: 240,
    textStyle: TextStyle(
      fontFamily: InkPaperTheme.fontFamily,
      fontSize: 14,
      fontWeight: neo ? .w700 : .w600,
      color: foreground,
    ),
  );
}

/// Toast overrides for Ink and Paper.
///
/// Default keeps the borderless raised card with 12 px corners and soft
/// shadow; neobrutalism draws the 2.5 px ink border with sharp corners.
/// Width is capped to `maxWidth: 240` (`minWidth: 0`) so the toast scene fits
/// a narrow cell in the components grid.
JustToastTheme toastInkPaper(JustThemePreset preset, InkPaperRoles r) {
  return JustToastTheme(
    infoStyle: _toastStyle(preset, r, r.textPrimary),
    successStyle: _toastStyle(preset, r, r.success),
    warningStyle: _toastStyle(preset, r, r.warning),
    errorStyle: _toastStyle(preset, r, r.error),
  );
}
