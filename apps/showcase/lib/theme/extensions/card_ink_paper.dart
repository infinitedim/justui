// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart' show BorderRadius, Radius;
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/card/just_card_style.dart';
import 'package:just_ui_core/src/components/card/just_card_theme.dart';

import '../ink_paper_tokens.dart';

/// Card overrides for Ink and Paper.
///
/// Default: core keeps its soft shadow and no border; only the corner takes
/// the Ink and Paper card radius (`--ip-radius-card`, 12 px). Neobrutalism:
/// core outlines cards with the grey control border, which reads as a
/// disabled edge next to the flat ink shadow; Ink and Paper outlines every
/// container in ink.
JustCardTheme cardInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset == .neobrutalism) {
    return JustCardTheme(style: JustCardStyle(borderColor: r.textPrimary));
  }
  return const JustCardTheme(
    style: JustCardStyle(borderRadius: BorderRadius.all(Radius.circular(12))),
  );
}
