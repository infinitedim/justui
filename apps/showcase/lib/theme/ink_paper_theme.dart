import 'package:just_ui_core/just_ui_core.dart';

import 'ink_paper_tokens.dart';

/// Light or dark Ink and Paper mode.
enum InkPaperMode {
  /// Paper: ink text on a warm off-white canvas.
  light,

  /// Ink: paper text on a warm near-black canvas.
  dark,
}

/// Builds the Ink and Paper [JustThemeData] for one preset and mode.
///
/// Core still ships the pre-rebrand defaults (Inter, seed colors); this
/// theme lives in showcase until PRD P1-P4 move core to Ink and Paper. Only
/// the role values come from [InkPaperTokens]; layout, motion and preset
/// behavior stay the core ones.
abstract final class InkPaperTheme {
  /// Family declared in the showcase pubspec for all text.
  static const String fontFamily = 'PlusJakartaSans';

  /// Family declared in the showcase pubspec for code and keys.
  static const String monoFontFamily = 'IBMPlexMono';

  /// The roles of [mode].
  static InkPaperRoles roles(InkPaperMode mode) => InkPaperRoles(
    mode == .light ? InkPaperTokens.light : InkPaperTokens.dark,
  );

  /// Maps the Ink and Paper roles onto the 16 core color roles.
  static CustomColorScheme colorScheme(InkPaperMode mode) {
    final InkPaperRoles r = roles(mode);
    return CustomColorScheme(
      background: r.canvas,
      card: r.surface,
      elevated: r.raised,
      muted: r.sunken,
      // Modal backdrop: ink at 40%, the same in both modes.
      overlay: InkPaperTokens.light['--ip-text-primary']!.withValues(
        alpha: 0.4,
      ),
      textPrimary: r.textPrimary,
      textSecondary: r.textSecondary,
      textDisabled: r.textDisabled,
      textInverse: r.onInverse,
      // Core uses borderDefault for control outlines too, so it takes the
      // control border (3:1 against the canvas), not the hairline.
      borderDefault: r.borderControl,
      // borderFocus is what core paints primary actions and focus rings
      // with: the ink fill of Ink and Paper.
      borderFocus: r.inverse,
      borderError: r.error,
      success: r.success,
      warning: r.warning,
      error: r.error,
      info: r.textPrimary,
    );
  }

  /// The complete theme for [preset] in [mode].
  static JustThemeData build(JustThemePreset preset, InkPaperMode mode) {
    final bool neo = preset == .neobrutalism;
    final InkPaperRoles r = roles(mode);
    return JustThemeData(
      colors: colorScheme(mode),
      typography: const JustTypographyScheme.fromFontFamily(
        fontFamily: fontFamily,
        monoFontFamily: monoFontFamily,
      ),
      shadows: neo
          ? NeobrutalismShadowScheme(shadowColor: r.textPrimary)
          : (mode == .light
                ? const DefaultShadowSchemeLight()
                : const DefaultShadowSchemeDark()),
      animations: neo ? .neobrutalism : .standard,
      preset: preset,
    );
  }
}
