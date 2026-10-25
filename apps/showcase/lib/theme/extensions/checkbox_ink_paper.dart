// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox_style.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox_theme.dart';

import '../ink_paper_tokens.dart';

/// Checkbox overrides for Ink and Paper.
///
/// The default preset needs none: a checked box is `borderFocus` (ink) with
/// a `textInverse` check. Neobrutalism in core fills it with the cognac
/// `warning` role, which Rule A replaces with the selected/active treatment:
/// an ink fill with an on-inverse check (`prd/02-design-spec.md`, section 6).
JustCheckboxTheme checkboxInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset != .neobrutalism) return JustCheckboxTheme.defaults;
  return JustCheckboxTheme(
    style: JustCheckboxStyle(activeColor: r.inverse, checkColor: r.onInverse),
  );
}
