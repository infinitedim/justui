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

final class FluidSpacingScheme extends JustSpacingScheme {
  final double width;

  const FluidSpacingScheme({required this.width});

  double _fluid(double minSize, double maxSize) {
    const double minWidth = 640.0;
    const double maxWidth = 1024.0;
    final clampedWidth = width.clamp(minWidth, maxWidth);
    final slope = (maxSize - minSize) / (maxWidth - minWidth);
    return minSize + slope * (clampedWidth - minWidth);
  }

  @override
  double get xxs => _fluid(1.5, 2.0);
  @override
  double get xs => _fluid(3.0, 4.0);
  @override
  double get sm => _fluid(6.0, 8.0);
  @override
  double get md => _fluid(9.0, 12.0);
  @override
  double get lg => _fluid(12.0, 16.0);
  @override
  double get xl => _fluid(18.0, 24.0);
  @override
  double get xxl => _fluid(24.0, 32.0);
  @override
  double get xxxl => _fluid(36.0, 48.0);
  @override
  double get huge => _fluid(48.0, 64.0);
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

final class FluidRadiusScheme extends JustRadiusScheme {
  final double width;

  const FluidRadiusScheme({required this.width});

  Radius _fluid(double minSize, double maxSize) {
    const double minWidth = 640.0;
    const double maxWidth = 1024.0;
    final clampedWidth = width.clamp(minWidth, maxWidth);
    final slope = (maxSize - minSize) / (maxWidth - minWidth);
    final calculatedSize = minSize + slope * (clampedWidth - minWidth);
    return .circular(calculatedSize);
  }

  @override
  Radius get none => .zero;
  @override
  Radius get xs => _fluid(1.5, 2.0);
  @override
  Radius get sm => _fluid(3.0, 4.0);
  @override
  Radius get md => _fluid(6.0, 8.0);
  @override
  Radius get lg => _fluid(8.0, 12.0);
  @override
  Radius get xl => _fluid(12.0, 16.0);
  @override
  Radius get xxl => _fluid(16.0, 24.0);
  @override
  Radius get full => const Radius.circular(9999.0);
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

final class TintedShadowScheme extends JustShadowScheme {
  final Color seedColor;
  final bool isDark;

  const TintedShadowScheme({
    required this.seedColor,
    required this.isDark,
  });

  @override
  List<BoxShadow> get xs => JustShadows.generate(seedColor: seedColor, elevation: 1, isDark: isDark);
  @override
  List<BoxShadow> get sm => JustShadows.generate(seedColor: seedColor, elevation: 2, isDark: isDark);
  @override
  List<BoxShadow> get md => JustShadows.generate(seedColor: seedColor, elevation: 4, isDark: isDark);
  @override
  List<BoxShadow> get lg => JustShadows.generate(seedColor: seedColor, elevation: 8, isDark: isDark);
  @override
  List<BoxShadow> get xl => JustShadows.generate(seedColor: seedColor, elevation: 16, isDark: isDark);
  @override
  List<BoxShadow> get xxl => JustShadows.generate(seedColor: seedColor, elevation: 24, isDark: isDark);
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
    this.animations = JustMotionProfile.standard,
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
  final JustMotionProfile animations;

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
    JustMotionProfile animations = JustMotionProfile.standard,
  }) {
    final Color bg;
    final Color card;
    final Color elevated;
    final Color overlay;

    if (isDark) {
      bg = JustDynamicSurfaces.generateDarkSurface(seedColor, lightness: 0.03);
      card = JustDynamicSurfaces.generateDarkSurface(seedColor, lightness: 0.07);
      elevated = JustDynamicSurfaces.generateDarkSurface(seedColor, lightness: 0.12);
      overlay = JustDynamicSurfaces.generateDarkSurface(seedColor, lightness: 0.02);
    } else {
      bg = JustColorSemanticLight.background;
      card = JustColorSemanticLight.card;
      elevated = JustColorSemanticLight.elevated;
      overlay = JustColorSemanticLight.overlay;
    }

    // Generate an HSL-based primary color variant.
    // In light mode, default borderFocus is primary500 (lightness ~0.5).
    // In dark mode, default borderFocus is primary400 (lightness ~0.6).
    final HSLColor hsl = .fromColor(seedColor);
    final targetLightness = isDark ? 0.6 : 0.5;
    final primary = hsl.withLightness(targetLightness).toColor();

    // Adjust lightness dynamically to guarantee at least 3.0:1 contrast (WCAG AA for large text/components).
    final borderFocusColor = _makeAccessible(primary, bg, minRatio: 3.0);

    // Dynamic contrast enforcement for semantic state colors against generated background
    final successBase = isDark ? JustColorSemanticDark.success : JustColorSemanticLight.success;
    final warningBase = isDark ? JustColorSemanticDark.warning : JustColorSemanticLight.warning;
    final errorBase = isDark ? JustColorSemanticDark.error : JustColorSemanticLight.error;
    final infoBase = isDark ? JustColorSemanticDark.info : JustColorSemanticLight.info;

    final successColor = _makeAccessible(successBase, bg, minRatio: 4.5);
    final warningColor = _makeAccessible(warningBase, bg, minRatio: 3.0);
    final errorColor = _makeAccessible(errorBase, bg, minRatio: 4.5);
    final infoColor = _makeAccessible(infoBase, bg, minRatio: 4.5);

    final colors = CustomColorScheme(
      background: bg,
      card: card,
      elevated: elevated,
      overlay: overlay,
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
      success: successColor,
      warning: warningColor,
      error: errorColor,
      info: infoColor,
    );

    return JustThemeData(
      colors: colors,
      typography: typography,
      spacing: spacing,
      radius: radius,
      shadows: TintedShadowScheme(seedColor: seedColor, isDark: isDark),
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
    final HSLColor hsl = .fromColor(color);
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
    JustMotionProfile? animations,
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
