import 'package:flutter/material.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

// ==========================================
// --- Spacing Scheme ---
// ==========================================

/// Defines the spacing values configuration.
abstract final class JustSpacingScheme {
  /// Base constructor.
  const JustSpacingScheme();

  /// Extra extra small spacing.
  double get xxs;

  /// Extra small spacing.
  double get xs;

  /// Small spacing.
  double get sm;

  /// Medium spacing.
  double get md;

  /// Large spacing.
  double get lg;

  /// Extra large spacing.
  double get xl;

  /// Double extra large spacing.
  double get xxl;

  /// Triple extra large spacing.
  double get xxxl;

  /// Huge spacing.
  double get huge;
}

final class _DefaultSpacingScheme extends JustSpacingScheme {
  const _DefaultSpacingScheme();

  @override
  double get xxs => JustSpacing.xxs;
  @override
  double get xs => JustSpacing.xs;
  @override
  double get sm => JustSpacing.sm;
  @override
  double get md => JustSpacing.md;
  @override
  double get lg => JustSpacing.lg;
  @override
  double get xl => JustSpacing.xl;
  @override
  double get xxl => JustSpacing.xxl;
  @override
  double get xxxl => JustSpacing.xxxl;
  @override
  double get huge => JustSpacing.huge;
}

// ==========================================
// --- Typography Scheme ---
// ==========================================

/// Defines the typography styles configuration.
abstract final class JustTypographyScheme {
  /// Base constructor.
  const JustTypographyScheme();

  /// Large display text.
  TextStyle get displayLg;

  /// Medium display text.
  TextStyle get displayMd;

  /// Small display text.
  TextStyle get displaySm;

  /// Large heading text.
  TextStyle get headingLg;

  /// Medium heading text.
  TextStyle get headingMd;

  /// Small heading text.
  TextStyle get headingSm;

  /// Large body text.
  TextStyle get bodyLg;

  /// Default body text.
  TextStyle get bodyMd;

  /// Small body text.
  TextStyle get bodySm;

  /// Caption text.
  TextStyle get caption;

  /// Overline text.
  TextStyle get overline;
}

final class _DefaultTypographyScheme extends JustTypographyScheme {
  const _DefaultTypographyScheme();

  @override
  TextStyle get displayLg => JustTypo.displayLg;
  @override
  TextStyle get displayMd => JustTypo.displayMd;
  @override
  TextStyle get displaySm => JustTypo.displaySm;
  @override
  TextStyle get headingLg => JustTypo.headingLg;
  @override
  TextStyle get headingMd => JustTypo.headingMd;
  @override
  TextStyle get headingSm => JustTypo.headingSm;
  @override
  TextStyle get bodyLg => JustTypo.bodyLg;
  @override
  TextStyle get bodyMd => JustTypo.bodyMd;
  @override
  TextStyle get bodySm => JustTypo.bodySm;
  @override
  TextStyle get caption => JustTypo.caption;
  @override
  TextStyle get overline => JustTypo.overline;
}

// ==========================================
// --- Radius Scheme ---
// ==========================================

/// Defines the corner rounding values configuration.
abstract final class JustRadiusScheme {
  /// Base constructor.
  const JustRadiusScheme();

  /// Sharp corners.
  Radius get none;

  /// Extra small corner rounding.
  Radius get xs;

  /// Small corner rounding.
  Radius get sm;

  /// Medium corner rounding.
  Radius get md;

  /// Large corner rounding.
  Radius get lg;

  /// Extra large corner rounding.
  Radius get xl;

  /// Double extra large corner rounding.
  Radius get xxl;

  /// Fully rounded pill shape.
  Radius get full;
}

final class _DefaultRadiusScheme extends JustRadiusScheme {
  const _DefaultRadiusScheme();

  @override
  Radius get none => JustRadius.none;
  @override
  Radius get xs => JustRadius.xs;
  @override
  Radius get sm => JustRadius.sm;
  @override
  Radius get md => JustRadius.md;
  @override
  Radius get lg => JustRadius.lg;
  @override
  Radius get xl => JustRadius.xl;
  @override
  Radius get xxl => JustRadius.xxl;
  @override
  Radius get full => JustRadius.full;
}

// ==========================================
// --- Shadow Scheme ---
// ==========================================

/// Defines the box shadows configurations.
abstract final class JustShadowScheme {
  /// Base constructor.
  const JustShadowScheme();

  /// Extra small shadow.
  List<BoxShadow> get xs;

  /// Small shadow.
  List<BoxShadow> get sm;

  /// Medium shadow.
  List<BoxShadow> get md;

  /// Large shadow.
  List<BoxShadow> get lg;

  /// Extra large shadow.
  List<BoxShadow> get xl;

  /// Double extra large shadow.
  List<BoxShadow> get xxl;
}

final class _DefaultShadowSchemeLight extends JustShadowScheme {
  const _DefaultShadowSchemeLight();

  @override
  List<BoxShadow> get xs => JustShadows.xs;
  @override
  List<BoxShadow> get sm => JustShadows.sm;
  @override
  List<BoxShadow> get md => JustShadows.md;
  @override
  List<BoxShadow> get lg => JustShadows.lg;
  @override
  List<BoxShadow> get xl => JustShadows.xl;
  @override
  List<BoxShadow> get xxl => JustShadows.xxl;
}

final class _DefaultShadowSchemeDark extends JustShadowScheme {
  const _DefaultShadowSchemeDark();

  @override
  List<BoxShadow> get xs => JustShadows.xsDark;
  @override
  List<BoxShadow> get sm => JustShadows.smDark;
  @override
  List<BoxShadow> get md => JustShadows.mdDark;
  @override
  List<BoxShadow> get lg => JustShadows.lgDark;
  @override
  List<BoxShadow> get xl => JustShadows.xlDark;
  @override
  List<BoxShadow> get xxl => JustShadows.xxlDark;
}

// ==========================================
// --- Animation Scheme ---
// ==========================================

/// Defines animation timings and curves.
abstract final class JustAnimationScheme {
  /// Base constructor.
  const JustAnimationScheme();

  /// Instant feedback duration.
  Duration get instant;

  /// Fast duration.
  Duration get fast;

  /// Normal duration.
  Duration get normal;

  /// Slow duration.
  Duration get slow;

  /// Slower duration.
  Duration get slower;

  /// Default easing curve.
  Curve get defaultCurve;

  /// Entrance easing curve.
  Curve get enter;

  /// Exit easing curve.
  Curve get exit;

  /// Springy easing curve.
  Curve get spring;
}

final class _DefaultAnimationScheme extends JustAnimationScheme {
  const _DefaultAnimationScheme();

  @override
  Duration get instant => JustDuration.instant;
  @override
  Duration get fast => JustDuration.fast;
  @override
  Duration get normal => JustDuration.normal;
  @override
  Duration get slow => JustDuration.slow;
  @override
  Duration get slower => JustDuration.slower;
  @override
  Curve get defaultCurve => JustCurves.default_;
  @override
  Curve get enter => JustCurves.enter;
  @override
  Curve get exit => JustCurves.exit;
  @override
  Curve get spring => JustCurves.spring;
}

// ==========================================
// --- JustThemeData ---
// ==========================================

/// Aggregated theme configuration class containing all sub-schemes.
///
/// Converts token values into Material [ThemeData]. Caches the created
/// [ThemeData] instance to prevent recalculation overhead.
class JustThemeData {
  /// Creates a theme configuration.
  JustThemeData({
    required this.colors,
    this.typography = const _DefaultTypographyScheme(),
    this.spacing = const _DefaultSpacingScheme(),
    this.radius = const _DefaultRadiusScheme(),
    required this.shadows,
    this.animations = const _DefaultAnimationScheme(),
  });

  /// The active color scheme.
  final JustColorScheme colors;

  /// The active typography scheme.
  final JustTypographyScheme typography;

  /// The active spacing scheme.
  final JustSpacingScheme spacing;

  /// The active radius scheme.
  final JustRadiusScheme radius;

  /// The active shadow scheme.
  final JustShadowScheme shadows;

  /// The active animation scheme.
  final JustAnimationScheme animations;

  // Cached material theme data.
  ThemeData? _cachedThemeData;

  /// Converts this [JustThemeData] configuration into Flutter [ThemeData].
  ///
  /// Caches the output value. Repeated calls return the same instance.
  ThemeData toThemeData() {
    return _cachedThemeData ??= _buildMaterialTheme();
  }

  /// Default pre-built light theme.
  static final JustThemeData light = JustThemeData(
    colors: JustColors.light(),
    shadows: const _DefaultShadowSchemeLight(),
  );

  /// Default pre-built dark theme.
  static final JustThemeData dark = JustThemeData(
    colors: JustColors.dark(),
    shadows: const _DefaultShadowSchemeDark(),
  );

  /// Generates a complete [JustThemeData] configuration dynamically from a single [seedColor].
  static JustThemeData fromSeed(
    Color seedColor, {
    bool isDark = false,
    JustTypographyScheme typography = const _DefaultTypographyScheme(),
    JustSpacingScheme spacing = const _DefaultSpacingScheme(),
    JustRadiusScheme radius = const _DefaultRadiusScheme(),
    JustAnimationScheme animations = const _DefaultAnimationScheme(),
  }) {
    final bg = isDark
        ? JustColorSemanticDark.background
        : JustColorSemanticLight.background;

    // Generate an HSL-based primary color variant.
    // In light mode, default borderFocus is primary500 (lightness ~0.5).
    // In dark mode, default borderFocus is primary400 (lightness ~0.6).
    final hsl = HSLColor.fromColor(seedColor);
    final targetLightness = isDark ? 0.6 : 0.5;
    final primary = hsl.withLightness(targetLightness).toColor();

    // Adjust lightness dynamically to guarantee at least 3.0:1 contrast (WCAG AA for large text/components).
    final borderFocusColor = _makeAccessible(primary, bg, minRatio: 3.0);

    final colors = CustomColorScheme(
      background: bg,
      card: isDark ? JustColorSemanticDark.card : JustColorSemanticLight.card,
      elevated: isDark
          ? JustColorSemanticDark.elevated
          : JustColorSemanticLight.elevated,
      overlay: isDark
          ? JustColorSemanticDark.overlay
          : JustColorSemanticLight.overlay,
      textPrimary: isDark
          ? JustColorSemanticDark.textPrimary
          : JustColorSemanticLight.textPrimary,
      textSecondary: isDark
          ? JustColorSemanticDark.textSecondary
          : JustColorSemanticLight.textSecondary,
      textDisabled: isDark
          ? JustColorSemanticDark.textDisabled
          : JustColorSemanticLight.textDisabled,
      textInverse: isDark
          ? JustColorSemanticDark.textInverse
          : JustColorSemanticLight.textInverse,
      borderDefault: isDark
          ? JustColorSemanticDark.borderDefault
          : JustColorSemanticLight.borderDefault,
      borderFocus: borderFocusColor,
      borderError: isDark
          ? JustColorSemanticDark.borderError
          : JustColorSemanticLight.borderError,
      success: isDark
          ? JustColorSemanticDark.success
          : JustColorSemanticLight.success,
      warning: isDark
          ? JustColorSemanticDark.warning
          : JustColorSemanticLight.warning,
      error: isDark
          ? JustColorSemanticDark.error
          : JustColorSemanticLight.error,
      info: isDark ? JustColorSemanticDark.info : JustColorSemanticLight.info,
    );

    return JustThemeData(
      colors: colors,
      typography: typography,
      spacing: spacing,
      radius: radius,
      shadows: isDark
          ? const _DefaultShadowSchemeDark()
          : const _DefaultShadowSchemeLight(),
      animations: animations,
    );
  }

  static Color _makeAccessible(
    Color color,
    Color background, {
    double minRatio = 3.0,
  }) {
    if (color.contrastRatioWith(background) >= minRatio) {
      return color;
    }
    final hsl = HSLColor.fromColor(color);
    final isBgDark = background.computeLuminance() < 0.5;
    double currentLightness = hsl.lightness;
    const double step = 0.02;

    while (currentLightness >= 0.0 && currentLightness <= 1.0) {
      if (isBgDark) {
        currentLightness += step;
        if (currentLightness > 1.0) break;
      } else {
        currentLightness -= step;
        if (currentLightness < 0.0) break;
      }
      final adjusted = hsl.withLightness(currentLightness).toColor();
      if (adjusted.contrastRatioWith(background) >= minRatio) {
        return adjusted;
      }
    }
    return isBgDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  ThemeData _buildMaterialTheme() {
    final isDark = colors.background.computeLuminance() < 0.5;
    final Brightness brightness = isDark ? .dark : .light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.card,
      dividerColor: colors.borderDefault,
      dialogTheme: DialogThemeData(backgroundColor: colors.elevated),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.borderFocus,
        onPrimary: colors.textInverse,
        secondary: colors.borderFocus,
        onSecondary: colors.textInverse,
        error: colors.error,
        onError: colors.textInverse,
        surface: colors.card,
        onSurface: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0.0,
        titleTextStyle: typography.headingLg.copyWith(
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
        actionsIconTheme: IconThemeData(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: .all(radius.lg)),
        elevation: 0.0,
        color: colors.card,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderFocus, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderError, width: 2.0),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1.0,
        space: 1.0,
        color: colors.borderDefault,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: .all(radius.md)),
        padding: .symmetric(horizontal: spacing.md, vertical: spacing.sm),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: .all(radius.md)),
          padding: .symmetric(horizontal: spacing.md, vertical: spacing.sm),
          textStyle: typography.bodyMd,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: .all(radius.md)),
          padding: .symmetric(horizontal: spacing.md, vertical: spacing.sm),
          textStyle: typography.bodyMd,
        ),
      ),
    );
  }

  /// Creates a copy of this theme with the given fields replaced by new values.
  JustThemeData copyWith({
    JustColorScheme? colors,
    JustTypographyScheme? typography,
    JustSpacingScheme? spacing,
    JustRadiusScheme? radius,
    JustShadowScheme? shadows,
    JustAnimationScheme? animations,
  }) {
    return JustThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      animations: animations ?? this.animations,
    );
  }
}
