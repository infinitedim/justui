// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/button/just_button_style.dart';
import 'package:just_ui_core/src/components/button/just_button_theme.dart';

import '../ink_paper_tokens.dart';

/// Button overrides for Ink and Paper.
///
/// The default preset needs none: core paints primary actions with
/// `borderFocus`, which the scheme maps to the ink fill. Neobrutalism in core
/// still uses the yellow primary (`colors.warning` with a black label), which
/// Ink and Paper Rule A removes (`prd/02-design-spec.md`, section 6): primary
/// is a surface fill with an ink border, secondary is transparent, and
/// destructive is an oxblood label on its tint.
///
/// Secondary paints the canvas instead of a transparent fill: Flutter draws
/// a `BoxShadow` under the whole box, so a transparent fill would show the
/// ink offset shadow through it (CSS clips a shadow to outside the border).
/// Its zero radius is for `JustIconButton`, which rounds every preset unless
/// a style says otherwise.
JustButtonTheme buttonInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset != .neobrutalism) return JustButtonTheme.defaults;
  return JustButtonTheme(
    primaryStyle: JustButtonStyle(
      backgroundColor: r.surface,
      foregroundColor: r.textPrimary,
      borderColor: r.textPrimary,
    ),
    secondaryStyle: JustButtonStyle(
      backgroundColor: r.canvas,
      foregroundColor: r.textPrimary,
      borderColor: r.textPrimary,
      borderRadius: .zero,
      // Elevation 1 resolves to the xs shadow: Rule A gives secondary
      // actions a 2 px ink shadow, and the icon button would cast 4 px.
      elevation: 1,
    ),
    destructiveStyle: JustButtonStyle(
      backgroundColor: r.errorTint,
      foregroundColor: r.error,
      borderColor: r.textPrimary,
    ),
  );
}
