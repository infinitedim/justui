// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker_style.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker_theme.dart';

import '../ink_paper_tokens.dart';

/// Time picker overrides for Ink and Paper.
///
/// Uses Ink and Paper surface, sunken and inverse roles, keeps off-center
/// spinner numbers at 0.82 opacity for >= 4.5:1 contrast, and sets a 34 px
/// row height so the inline spinner fits inside the components-page stage.
JustTimePickerTheme timePickerInkPaper(
  JustThemePreset preset,
  InkPaperRoles r,
) {
  final bool neo = preset == .neobrutalism;
  return JustTimePickerTheme(
    inlineStyle: JustTimePickerStyle(
      backgroundColor: r.surface,
      dialFaceColor: r.sunken,
      handColor: r.inverse,
      dialTextColor: r.textPrimary,
      periodActiveColor: r.inverse,
      borderColor: neo ? r.textPrimary : r.borderSubtle,
      borderRadius: neo ? .zero : const .all(.circular(12.0)),
      spinnerRowHeight: 34.0,
      overAndUnderCenterOpacity: 0.82,
    ),
  );
}
