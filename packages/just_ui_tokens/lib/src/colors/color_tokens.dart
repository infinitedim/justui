import 'package:flutter/painting.dart';
import 'color_palette.dart';
import 'color_semantic.dart';

/// Represents a resolved set of semantic color tokens for JustUI.
///
/// Contains functional colors like backgrounds, text colors, and state colors.
/// Standard implementations are provided for light and dark modes.
abstract final class JustColorScheme {
  /// Base constructor for custom schemes.
  const JustColorScheme();

  // --- Surface Colors ---
  /// Main background color for pages.
  Color get background;
  /// Card and container background color.
  Color get card;
  /// Elevated overlay/dialog surface color.
  Color get elevated;
  /// Modal overlay backdrop color.
  Color get overlay;

  // --- Text Colors ---
  /// Main high-contrast text color.
  Color get textPrimary;
  /// Secondary text color for captions and body.
  Color get textSecondary;
  /// Disabled text color.
  Color get textDisabled;
  /// Inverted text color.
  Color get textInverse;

  // --- Border Colors ---
  /// Default divider and input border color.
  Color get borderDefault;
  /// Focused element border color.
  Color get borderFocus;
  /// Error state border color.
  Color get borderError;

  // --- State Colors ---
  /// State color for success.
  Color get success;
  /// State color for warning.
  Color get warning;
  /// State color for error.
  Color get error;
  /// State color for info.
  Color get info;
}

final class _JustColorSchemeLight extends JustColorScheme {
  const _JustColorSchemeLight();

  @override
  Color get background => JustColorSemanticLight.background;
  @override
  Color get card => JustColorSemanticLight.card;
  @override
  Color get elevated => JustColorSemanticLight.elevated;
  @override
  Color get overlay => JustColorSemanticLight.overlay;

  @override
  Color get textPrimary => JustColorSemanticLight.textPrimary;
  @override
  Color get textSecondary => JustColorSemanticLight.textSecondary;
  @override
  Color get textDisabled => JustColorSemanticLight.textDisabled;
  @override
  Color get textInverse => JustColorSemanticLight.textInverse;

  @override
  Color get borderDefault => JustColorSemanticLight.borderDefault;
  @override
  Color get borderFocus => JustColorSemanticLight.borderFocus;
  @override
  Color get borderError => JustColorSemanticLight.borderError;

  @override
  Color get success => JustColorSemanticLight.success;
  @override
  Color get warning => JustColorSemanticLight.warning;
  @override
  Color get error => JustColorSemanticLight.error;
  @override
  Color get info => JustColorSemanticLight.info;
}

final class _JustColorSchemeDark extends JustColorScheme {
  const _JustColorSchemeDark();

  @override
  Color get background => JustColorSemanticDark.background;
  @override
  Color get card => JustColorSemanticDark.card;
  @override
  Color get elevated => JustColorSemanticDark.elevated;
  @override
  Color get overlay => JustColorSemanticDark.overlay;

  @override
  Color get textPrimary => JustColorSemanticDark.textPrimary;
  @override
  Color get textSecondary => JustColorSemanticDark.textSecondary;
  @override
  Color get textDisabled => JustColorSemanticDark.textDisabled;
  @override
  Color get textInverse => JustColorSemanticDark.textInverse;

  @override
  Color get borderDefault => JustColorSemanticDark.borderDefault;
  @override
  Color get borderFocus => JustColorSemanticDark.borderFocus;
  @override
  Color get borderError => JustColorSemanticDark.borderError;

  @override
  Color get success => JustColorSemanticDark.success;
  @override
  Color get warning => JustColorSemanticDark.warning;
  @override
  Color get error => JustColorSemanticDark.error;
  @override
  Color get info => JustColorSemanticDark.info;
}

/// Aggregated color tokens class exposing both raw palette and theme factories.
///
/// Use `JustColors.light()` and `JustColors.dark()` to retrieve semantic schemes,
/// or access raw colors directly.
abstract final class JustColors {
  // --- Static Theme Schemes ---
  /// The default light theme color scheme.
  static const JustColorScheme lightScheme = _JustColorSchemeLight();
  
  /// The default dark theme color scheme.
  static const JustColorScheme darkScheme = _JustColorSchemeDark();

  /// Returns the default light theme color scheme.
  static JustColorScheme light() => lightScheme;

  /// Returns the default dark theme color scheme.
  static JustColorScheme dark() => darkScheme;

  // --- Raw Palette Constants ---
  /// Pure white.
  static const Color white = JustColorPalette.white;
  /// Pure black.
  static const Color black = JustColorPalette.black;

  // --- Neutral Shades ---
  /// Neutral shade 50 (Slate-like)
  static const Color neutral50 = JustColorPalette.neutral50;
  /// Neutral shade 100
  static const Color neutral100 = JustColorPalette.neutral100;
  /// Neutral shade 200
  static const Color neutral200 = JustColorPalette.neutral200;
  /// Neutral shade 300
  static const Color neutral300 = JustColorPalette.neutral300;
  /// Neutral shade 400
  static const Color neutral400 = JustColorPalette.neutral400;
  /// Neutral shade 500
  static const Color neutral500 = JustColorPalette.neutral500;
  /// Neutral shade 600
  static const Color neutral600 = JustColorPalette.neutral600;
  /// Neutral shade 700
  static const Color neutral700 = JustColorPalette.neutral700;
  /// Neutral shade 800
  static const Color neutral800 = JustColorPalette.neutral800;
  /// Neutral shade 900
  static const Color neutral900 = JustColorPalette.neutral900;
  /// Neutral shade 955
  static const Color neutral950 = JustColorPalette.neutral950;

  // --- Primary Shades ---
  /// Primary shade 50
  static const Color primary50 = JustColorPalette.primary50;
  /// Primary shade 100
  static const Color primary100 = JustColorPalette.primary100;
  /// Primary shade 200
  static const Color primary200 = JustColorPalette.primary200;
  /// Primary shade 300
  static const Color primary300 = JustColorPalette.primary300;
  /// Primary shade 400
  static const Color primary400 = JustColorPalette.primary400;
  /// Primary shade 500
  static const Color primary500 = JustColorPalette.primary500;
  /// Primary shade 600
  static const Color primary600 = JustColorPalette.primary600;
  /// Primary shade 700
  static const Color primary700 = JustColorPalette.primary700;
  /// Primary shade 800
  static const Color primary800 = JustColorPalette.primary800;
  /// Primary shade 900
  static const Color primary900 = JustColorPalette.primary900;
  /// Primary shade 950
  static const Color primary950 = JustColorPalette.primary950;

  // --- Success Shades ---
  /// Success shade 50
  static const Color success50 = JustColorPalette.success50;
  /// Success shade 100
  static const Color success100 = JustColorPalette.success100;
  /// Success shade 200
  static const Color success200 = JustColorPalette.success200;
  /// Success shade 300
  static const Color success300 = JustColorPalette.success300;
  /// Success shade 400
  static const Color success400 = JustColorPalette.success400;
  /// Success shade 500
  static const Color success500 = JustColorPalette.success500;
  /// Success shade 600
  static const Color success600 = JustColorPalette.success600;
  /// Success shade 700
  static const Color success700 = JustColorPalette.success700;
  /// Success shade 800
  static const Color success800 = JustColorPalette.success800;
  /// Success shade 900
  static const Color success900 = JustColorPalette.success900;
  /// Success shade 950
  static const Color success950 = JustColorPalette.success950;

  // --- Warning Shades ---
  /// Warning shade 50
  static const Color warning50 = JustColorPalette.warning50;
  /// Warning shade 100
  static const Color warning100 = JustColorPalette.warning100;
  /// Warning shade 200
  static const Color warning200 = JustColorPalette.warning200;
  /// Warning shade 300
  static const Color warning300 = JustColorPalette.warning300;
  /// Warning shade 400
  static const Color warning400 = JustColorPalette.warning400;
  /// Warning shade 500
  static const Color warning500 = JustColorPalette.warning500;
  /// Warning shade 600
  static const Color warning600 = JustColorPalette.warning600;
  /// Warning shade 700
  static const Color warning700 = JustColorPalette.warning700;
  /// Warning shade 800
  static const Color warning800 = JustColorPalette.warning800;
  /// Warning shade 900
  static const Color warning900 = JustColorPalette.warning900;
  /// Warning shade 950
  static const Color warning950 = JustColorPalette.warning950;

  // --- Error Shades ---
  /// Error shade 50
  static const Color error50 = JustColorPalette.error50;
  /// Error shade 100
  static const Color error100 = JustColorPalette.error100;
  /// Error shade 200
  static const Color error200 = JustColorPalette.error200;
  /// Error shade 300
  static const Color error300 = JustColorPalette.error300;
  /// Error shade 400
  static const Color error400 = JustColorPalette.error400;
  /// Error shade 500
  static const Color error500 = JustColorPalette.error500;
  /// Error shade 600
  static const Color error600 = JustColorPalette.error600;
  /// Error shade 700
  static const Color error700 = JustColorPalette.error700;
  /// Error shade 800
  static const Color error800 = JustColorPalette.error800;
  /// Error shade 900
  static const Color error900 = JustColorPalette.error900;
  /// Error shade 950
  static const Color error950 = JustColorPalette.error950;

  // --- Info Shades ---
  /// Info shade 50
  static const Color info50 = JustColorPalette.info50;
  /// Info shade 100
  static const Color info100 = JustColorPalette.info100;
  /// Info shade 200
  static const Color info200 = JustColorPalette.info200;
  /// Info shade 300
  static const Color info300 = JustColorPalette.info300;
  /// Info shade 400
  static const Color info400 = JustColorPalette.info400;
  /// Info shade 500
  static const Color info500 = JustColorPalette.info500;
  /// Info shade 600
  static const Color info600 = JustColorPalette.info600;
  /// Info shade 700
  static const Color info700 = JustColorPalette.info700;
  /// Info shade 800
  static const Color info800 = JustColorPalette.info800;
  /// Info shade 900
  static const Color info900 = JustColorPalette.info900;
  /// Info shade 950
  static const Color info950 = JustColorPalette.info950;
}
