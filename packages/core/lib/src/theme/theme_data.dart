import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import 'preset_tokens.dart';
import 'schemes/radius_scheme.dart';
import 'schemes/shadow_scheme.dart';
import 'schemes/spacing_scheme.dart';
import 'schemes/typography_scheme.dart';

export 'schemes/radius_scheme.dart';
export 'schemes/shadow_scheme.dart';
export 'schemes/spacing_scheme.dart';
export 'schemes/typography_scheme.dart';

// ==========================================
// --- JustThemeData ---
// ==========================================

/// Aggregated theme configuration class containing all sub-schemes.
///
/// Converts token values into Material [ThemeData]. Caches the created
/// [ThemeData] instance to prevent recalculation overhead.
class const JustThemeData({
  required final JustColorScheme colors,
  final JustTypographyScheme typography = const DefaultTypographyScheme(),
  final JustSpacingScheme spacing = const DefaultSpacingScheme(),
  final JustRadiusScheme radius = const DefaultRadiusScheme(),
  required final JustShadowScheme shadows,
  final JustMotionProfile animations = .standard,
  final JustThemePreset preset = .default_,
  final JustColorSpaceEngine colorSpace = .hsl,
}) {
  /// Resolved preset-specific visual token implementation.
  /// Convenience accessor equivalent to `preset.tokens`.
  JustPresetTokens get presetTokens => preset.tokens;

  /// Default pre-built light theme.
  static final JustThemeData light = JustThemeData(
    colors: JustColors.light(),
    shadows: const DefaultShadowSchemeLight(),
  );

  /// Default pre-built dark theme.
  static final JustThemeData dark = JustThemeData(
    colors: JustColors.dark(),
    shadows: const DefaultShadowSchemeDark(),
  );

  /// Pre-built neobrutalism light theme.
  static final JustThemeData neobrutalismLight = JustThemeData(
    colors: JustColors.neobrutalismLight(),
    shadows: const NeobrutalismShadowScheme(),
    animations: JustMotionProfile.neobrutalism,
    preset: .neobrutalism,
  );

  /// Pre-built neobrutalism dark theme.
  static final JustThemeData neobrutalismDark = JustThemeData(
    colors: JustColors.neobrutalismDark(),
    shadows: const NeobrutalismShadowScheme(shadowColor: Color(0xFFFFFFFF)),
    animations: .neobrutalism,
    preset: .neobrutalism,
  );

  /// Resolves the shadow offset based on the preset.
  Offset get shadowOffset =>
      preset == .neobrutalism ? const Offset(4.0, 4.0) : .zero;

  /// Resolves the shadow list for the current preset and press state.
  ///
  /// Under neobrutalism, if the component is pressed, all solid shadows collapse
  /// to [.zero] (i.e. disappear behind the element).
  List<BoxShadow> resolveShadows(
    List<BoxShadow> baseShadows, {
    required bool isPressed,
  }) {
    if (preset == .neobrutalism && isPressed) {
      return baseShadows.map((s) => s.copyWith(offset: .zero)).toList();
    }
    return baseShadows;
  }

  /// Builds the interactive press effect wrapper widget matching the active preset.
  ///
  /// In default mode, applies a smooth scale animation.
  /// In neobrutalism mode, translates the widget down/right by [shadowOffset]
  /// to align with the collapsed shadow.
  Widget buildPressEffect({
    required Widget child,
    required bool isPressed,
    double scaleFactor = 0.97,
    Offset? translationOffset,
  }) {
    if (preset == .neobrutalism) {
      final offset = translationOffset ?? shadowOffset;
      return AnimatedContainer(
        duration: animations.instant,
        curve: animations.defaultCurve,
        transform: .translationValues(
          isPressed ? offset.dx : 0.0,
          isPressed ? offset.dy : 0.0,
          0.0,
        ),
        child: child,
      );
    } else {
      return AnimatedScale(
        scale: isPressed ? scaleFactor : 1.0,
        duration: animations.instant,
        curve: animations.defaultCurve,
        child: child,
      );
    }
  }

  /// Generates a complete [JustThemeData] configuration dynamically from a single [seedColor].
  static JustThemeData fromSeed(
    Color seedColor, {
    bool isDark = false,
    JustTypographyScheme typography = const DefaultTypographyScheme(),
    JustSpacingScheme spacing = const DefaultSpacingScheme(),
    JustRadiusScheme radius = const DefaultRadiusScheme(),
    JustMotionProfile animations = .standard,
    JustThemePreset preset = .default_,
    JustColorSpaceEngine colorSpace = .hsl,
  }) {
    assert(seedColor.a == 1.0, 'Seed color must be fully opaque');

    final Color bg;
    final Color card;
    final Color elevated;
    final Color muted;
    final Color overlay;

    if (isDark) {
      bg = JustDynamicSurfaces.generateDarkSurface(
        seedColor,
        lightness: 0.03,
        engine: colorSpace,
      );
      card = JustDynamicSurfaces.generateDarkSurface(
        seedColor,
        lightness: 0.07,
        engine: colorSpace,
      );
      elevated = JustDynamicSurfaces.generateDarkSurface(
        seedColor,
        lightness: 0.12,
        engine: colorSpace,
      );
      muted = JustDynamicSurfaces.generateDarkSurface(
        seedColor,
        lightness: 0.10,
        engine: colorSpace,
      );
      overlay = JustDynamicSurfaces.generateDarkSurface(
        seedColor,
        lightness: 0.02,
        engine: colorSpace,
      );
    } else {
      bg = preset == .neobrutalism
          ? const Color(0xFFFFFDF5)
          : JustColorSemanticLight.background;
      card = JustColorSemanticLight.card;
      elevated = JustColorSemanticLight.elevated;
      muted = JustColorSemanticLight.muted;
      overlay = JustColorSemanticLight.overlay;
    }

    // Generate a primary color variant using the configured colorSpace engine.
    final pc = ColorSpaceOps.toPerceptual(seedColor, colorSpace);
    final targetLightness = isDark ? 0.6 : 0.5;
    final primary = ColorSpaceOps.fromPerceptual(
      PerceptualColor(targetLightness, pc.c, pc.h),
      colorSpace,
    );

    // Adjust lightness dynamically to guarantee at least 3.0:1 contrast.
    final Color borderFocusColor;
    if (preset == .neobrutalism) {
      borderFocusColor = isDark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000);
    } else {
      borderFocusColor = _makeAccessible(
        primary,
        bg,
        minRatio: 3.0,
        engine: colorSpace,
      );
    }

    // Dynamic contrast enforcement for semantic state colors against generated background
    final successBase = isDark
        ? JustColorSemanticDark.success
        : JustColorSemanticLight.success;
    final warningBase = isDark
        ? JustColorSemanticDark.warning
        : JustColorSemanticLight.warning;
    final errorBase = isDark
        ? JustColorSemanticDark.error
        : JustColorSemanticLight.error;
    final infoBase = isDark
        ? JustColorSemanticDark.info
        : JustColorSemanticLight.info;

    final successColor = _makeAccessible(
      successBase,
      bg,
      minRatio: 4.5,
      engine: colorSpace,
    );
    final warningColor = _makeAccessible(
      warningBase,
      bg,
      minRatio: 3.0,
      engine: colorSpace,
    );
    final errorColor = _makeAccessible(
      errorBase,
      bg,
      minRatio: 4.5,
      engine: colorSpace,
    );
    final infoColor = _makeAccessible(
      infoBase,
      bg,
      minRatio: 4.5,
      engine: colorSpace,
    );

    final colors = CustomColorScheme.resolveSemantic(
      background: bg,
      card: card,
      elevated: elevated,
      muted: muted,
      overlay: overlay,
      borderFocus: borderFocusColor,
      success: successColor,
      warning: warningColor,
      error: errorColor,
      info: infoColor,
      isDark: isDark,
      preset: preset,
    );

    final JustShadowScheme resolvedShadows;
    if (preset == .neobrutalism) {
      resolvedShadows = NeobrutalismShadowScheme(
        shadowColor: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
      );
    } else {
      resolvedShadows = TintedShadowScheme(
        seedColor: seedColor,
        isDark: isDark,
      );
    }

    return JustThemeData(
      colors: colors,
      typography: typography,
      spacing: spacing,
      radius: radius,
      shadows: resolvedShadows,
      animations: (animations == .standard && preset == .neobrutalism)
          ? JustMotionProfile.neobrutalism
          : animations,
      preset: preset,
      colorSpace: colorSpace,
    );
  }

  static Color _makeAccessible(
    Color color,
    Color background, {
    double minRatio = 3.0,
    JustColorSpaceEngine engine = .hsl,
  }) {
    final adjusted = color.adjustLightnessForContrast(
      background: background,
      targetRatio: minRatio,
      engine: engine,
    );
    if (adjusted.contrastRatioWith(background) >= minRatio) {
      return adjusted;
    }
    final isBgDark = background.computeLuminance() < 0.5;
    return isBgDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  /// Returns a copy of this theme with high-contrast color overrides applied.
  ///
  /// Increases visual accessibility by enforcing high contrast text, borders,
  /// and WCAG contrast ratios against the active background surface.
  JustThemeData applyHighContrastOverrides() {
    final isBgDark = colors.background.computeLuminance() < 0.5;
    final highContrastText = isBgDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
    final highContrastBorder = highContrastText;

    final updatedColors = CustomColorScheme(
      background: colors.background,
      card: colors.card,
      elevated: colors.elevated,
      muted: colors.muted,
      overlay: colors.overlay,
      textPrimary: highContrastText,
      textSecondary: isBgDark
          ? const Color(0xFFE0E0E0)
          : const Color(0xFF1A1A1A),
      textDisabled: isBgDark
          ? const Color(0xFF9E9E9E)
          : const Color(0xFF616161),
      textInverse: colors.textInverse,
      borderDefault: highContrastBorder,
      borderFocus: _makeAccessible(
        colors.borderFocus,
        colors.background,
        minRatio: 4.5,
        engine: colorSpace,
      ),
      borderError: _makeAccessible(
        colors.borderError,
        colors.background,
        minRatio: 4.5,
        engine: colorSpace,
      ),
      success: _makeAccessible(
        colors.success,
        colors.background,
        minRatio: 4.5,
        engine: colorSpace,
      ),
      warning: _makeAccessible(
        colors.warning,
        colors.background,
        minRatio: 4.5,
        engine: colorSpace,
      ),
      error: _makeAccessible(
        colors.error,
        colors.background,
        minRatio: 4.5,
        engine: colorSpace,
      ),
      info: _makeAccessible(
        colors.info,
        colors.background,
        minRatio: 4.5,
        engine: colorSpace,
      ),
    );

    return copyWith(colors: updatedColors);
  }

  /// Creates a copy of this theme with the given fields replaced by new values.
  JustThemeData copyWith({
    JustColorScheme? colors,
    JustTypographyScheme? typography,
    JustSpacingScheme? spacing,
    JustRadiusScheme? radius,
    JustShadowScheme? shadows,
    JustMotionProfile? animations,
    JustThemePreset? preset,
    JustColorSpaceEngine? colorSpace,
  }) {
    return JustThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      animations: animations ?? this.animations,
      preset: preset ?? this.preset,
      colorSpace: colorSpace ?? this.colorSpace,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustThemeData &&
          runtimeType == other.runtimeType &&
          colors == other.colors &&
          typography == other.typography &&
          spacing == other.spacing &&
          radius == other.radius &&
          shadows == other.shadows &&
          animations == other.animations &&
          preset == other.preset &&
          colorSpace == other.colorSpace;

  @override
  int get hashCode => Object.hash(
    colors,
    typography,
    spacing,
    radius,
    shadows,
    animations,
    preset,
    colorSpace,
  );
}
