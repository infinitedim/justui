import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JustSpacingScheme &&
        other.xxs == xxs &&
        other.xs == xs &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl &&
        other.xxl == xxl &&
        other.xxxl == xxxl &&
        other.huge == huge;
  }

  @override
  int get hashCode {
    return Object.hashAll([xxs, xs, sm, md, lg, xl, xxl, xxxl, huge]);
  }

  /// Resolves the spacing scheme for a given screen width. Defaults to returning itself.
  JustSpacingScheme resolve(double width) => this;
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

  const FluidSpacingScheme({this.width = 1024.0});

  @override
  JustSpacingScheme resolve(double width) => FluidSpacingScheme(width: width);

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FluidSpacingScheme &&
          runtimeType == other.runtimeType &&
          width == other.width;

  @override
  int get hashCode => width.hashCode;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JustTypographyScheme &&
        other.displayLg == displayLg &&
        other.displayMd == displayMd &&
        other.displaySm == displaySm &&
        other.headingLg == headingLg &&
        other.headingMd == headingMd &&
        other.headingSm == headingSm &&
        other.bodyLg == bodyLg &&
        other.bodyMd == bodyMd &&
        other.bodySm == bodySm &&
        other.caption == caption &&
        other.overline == overline;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      displayLg,
      displayMd,
      displaySm,
      headingLg,
      headingMd,
      headingSm,
      bodyLg,
      bodyMd,
      bodySm,
      caption,
      overline,
    ]);
  }
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JustRadiusScheme &&
        other.none == none &&
        other.xs == xs &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl &&
        other.xxl == xxl &&
        other.full == full;
  }

  @override
  int get hashCode {
    return Object.hashAll([none, xs, sm, md, lg, xl, xxl, full]);
  }

  /// Resolves the radius scheme for a given screen width. Defaults to returning itself.
  JustRadiusScheme resolve(double width) => this;
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

  const FluidRadiusScheme({this.width = 1024.0});

  @override
  JustRadiusScheme resolve(double width) => FluidRadiusScheme(width: width);

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FluidRadiusScheme &&
          runtimeType == other.runtimeType &&
          width == other.width;

  @override
  int get hashCode => width.hashCode;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JustShadowScheme &&
        listEquals(other.xs, xs) &&
        listEquals(other.sm, sm) &&
        listEquals(other.md, md) &&
        listEquals(other.lg, lg) &&
        listEquals(other.xl, xl) &&
        listEquals(other.xxl, xxl);
  }

  @override
  int get hashCode {
    return Object.hash(
      .hashAll(xs),
      .hashAll(sm),
      .hashAll(md),
      .hashAll(lg),
      .hashAll(xl),
      .hashAll(xxl),
    );
  }
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _DefaultShadowSchemeLight;

  @override
  int get hashCode => const Symbol('_DefaultShadowSchemeLight').hashCode;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _DefaultShadowSchemeDark;

  @override
  int get hashCode => const Symbol('_DefaultShadowSchemeDark').hashCode;
}

final class TintedShadowScheme extends JustShadowScheme {
  final Color seedColor;
  final bool isDark;

  const TintedShadowScheme({required this.seedColor, required this.isDark});

  @override
  List<BoxShadow> get xs =>
      JustShadows.generate(seedColor: seedColor, elevation: 1, isDark: isDark);
  @override
  List<BoxShadow> get sm =>
      JustShadows.generate(seedColor: seedColor, elevation: 2, isDark: isDark);
  @override
  List<BoxShadow> get md =>
      JustShadows.generate(seedColor: seedColor, elevation: 4, isDark: isDark);
  @override
  List<BoxShadow> get lg =>
      JustShadows.generate(seedColor: seedColor, elevation: 8, isDark: isDark);
  @override
  List<BoxShadow> get xl =>
      JustShadows.generate(seedColor: seedColor, elevation: 16, isDark: isDark);
  @override
  List<BoxShadow> get xxl =>
      JustShadows.generate(seedColor: seedColor, elevation: 24, isDark: isDark);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TintedShadowScheme &&
          seedColor == other.seedColor &&
          isDark == other.isDark;

  @override
  int get hashCode => Object.hash(seedColor, isDark);
}

final class NeobrutalismShadowScheme extends JustShadowScheme {
  final Color shadowColor;
  const NeobrutalismShadowScheme({this.shadowColor = const Color(0xFF000000)});

  @override
  List<BoxShadow> get xs => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(1.0, 1.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get sm => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(2.0, 2.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get md => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(3.0, 3.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get lg => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(4.0, 4.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get xl => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(6.0, 6.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get xxl => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(8.0, 8.0),
      blurRadius: 0.0,
    ),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NeobrutalismShadowScheme && shadowColor == other.shadowColor;

  @override
  int get hashCode => shadowColor.hashCode;
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
    this.animations = .standard,
    this.preset = .default_,
  });

  /// The visual style preset.
  final JustThemePreset preset;

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

  /// Pre-built neobrutalism light theme.
  static final JustThemeData neobrutalismLight = JustThemeData(
    colors: JustColors.neobrutalismLight(),
    shadows: const NeobrutalismShadowScheme(),
    preset: .neobrutalism,
  );

  /// Pre-built neobrutalism dark theme.
  static final JustThemeData neobrutalismDark = JustThemeData(
    colors: JustColors.neobrutalismDark(),
    shadows: const NeobrutalismShadowScheme(shadowColor: Color(0xFFFFFFFF)),
    preset: .neobrutalism,
  );

  /// Resolves the shadow offset based on the preset.
  Offset get shadowOffset =>
      preset == .neobrutalism ? const Offset(3.0, 3.0) : Offset.zero;

  /// Resolves the shadow list for the current preset and press state.
  ///
  /// Under neobrutalism, if the component is pressed, all solid shadows collapse
  /// to [Offset.zero] (i.e. disappear behind the element).
  List<BoxShadow> resolveShadows(
    List<BoxShadow> baseShadows, {
    required bool isPressed,
  }) {
    if (preset == .neobrutalism && isPressed) {
      return baseShadows.map((s) => s.copyWith(offset: Offset.zero)).toList();
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
        transform: Matrix4.translationValues(
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
    JustTypographyScheme typography = const _DefaultTypographyScheme(),
    JustSpacingScheme spacing = const _DefaultSpacingScheme(),
    JustRadiusScheme radius = const _DefaultRadiusScheme(),
    JustMotionProfile animations = .standard,
    JustThemePreset preset = .default_,
  }) {
    final Color bg;
    final Color card;
    final Color elevated;
    final Color overlay;

    if (isDark) {
      bg = JustDynamicSurfaces.generateDarkSurface(seedColor, lightness: 0.03);
      card = JustDynamicSurfaces.generateDarkSurface(
        seedColor,
        lightness: 0.07,
      );
      elevated = JustDynamicSurfaces.generateDarkSurface(
        seedColor,
        lightness: 0.12,
      );
      overlay = JustDynamicSurfaces.generateDarkSurface(
        seedColor,
        lightness: 0.02,
      );
    } else {
      bg = preset == .neobrutalism
          ? const Color(0xFFFFFDF5)
          : JustColorSemanticLight.background;
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
    final Color borderFocusColor;
    if (preset == .neobrutalism) {
      borderFocusColor = isDark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000);
    } else {
      borderFocusColor = _makeAccessible(primary, bg, minRatio: 3.0);
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

    final successColor = _makeAccessible(successBase, bg, minRatio: 4.5);
    final warningColor = _makeAccessible(warningBase, bg, minRatio: 3.0);
    final errorColor = _makeAccessible(errorBase, bg, minRatio: 4.5);
    final infoColor = _makeAccessible(infoBase, bg, minRatio: 4.5);

    final Color textPrimaryResolved;
    final Color textSecondaryResolved;
    final Color textDisabledResolved;
    final Color textInverseResolved;
    final Color borderDefaultResolved;
    final Color borderErrorResolved;

    if (preset == .neobrutalism) {
      textPrimaryResolved = isDark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000);
      textSecondaryResolved = isDark
          ? const Color(0xFFCCCCCC)
          : const Color(0xFF222222);
      textDisabledResolved = isDark
          ? const Color(0xFF666666)
          : const Color(0xFF777777);
      textInverseResolved = isDark
          ? const Color(0xFF000000)
          : const Color(0xFFFFFFFF);
      borderDefaultResolved = isDark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000);
      borderErrorResolved = isDark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000);
    } else {
      textPrimaryResolved = isDark
          ? JustColorSemanticDark.textPrimary
          : JustColorSemanticLight.textPrimary;
      textSecondaryResolved = isDark
          ? JustColorSemanticDark.textSecondary
          : JustColorSemanticLight.textSecondary;
      textDisabledResolved = isDark
          ? JustColorSemanticDark.textDisabled
          : JustColorSemanticLight.textDisabled;
      textInverseResolved = isDark
          ? JustColorSemanticDark.textInverse
          : JustColorSemanticLight.textInverse;
      borderDefaultResolved = isDark
          ? JustColorSemanticDark.borderDefault
          : JustColorSemanticLight.borderDefault;
      borderErrorResolved = isDark
          ? JustColorSemanticDark.borderError
          : JustColorSemanticLight.borderError;
    }

    final colors = CustomColorScheme(
      background: bg,
      card: card,
      elevated: elevated,
      overlay: overlay,
      textPrimary: textPrimaryResolved,
      textSecondary: textSecondaryResolved,
      textDisabled: textDisabledResolved,
      textInverse: textInverseResolved,
      borderDefault: borderDefaultResolved,
      borderFocus: borderFocusColor,
      borderError: borderErrorResolved,
      success: successColor,
      warning: warningColor,
      error: errorColor,
      info: infoColor,
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
      animations: animations,
      preset: preset,
    );
  }

  static Color _makeAccessible(
    Color color,
    Color background, {
    double minRatio = 3.0,
  }) {
    final adjusted = color.adjustLightnessForContrast(
      background: background,
      targetRatio: minRatio,
    );
    if (adjusted.contrastRatioWith(background) >= minRatio) {
      return adjusted;
    }
    final isBgDark = background.computeLuminance() < 0.5;
    return isBgDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
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
  }) {
    return JustThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      animations: animations ?? this.animations,
      preset: preset ?? this.preset,
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
          preset == other.preset;

  @override
  int get hashCode => Object.hash(
    colors,
    typography,
    spacing,
    radius,
    shadows,
    animations,
    preset,
  );
}
