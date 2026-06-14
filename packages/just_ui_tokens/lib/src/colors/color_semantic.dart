import 'package:flutter/painting.dart';
import 'color_palette.dart';

/// Semantic colors for JustUI in Light Mode.
///
/// Maps functional keys to colors defined in [JustColorPalette].
abstract final class JustColorSemanticLight {
  // --- Surface Colors ---
  /// Main background color for pages
  static const Color background = JustColorPalette.neutral50;
  /// Card and container background color
  static const Color card = JustColorPalette.white;
  /// Elevated overlay/dialog surface color
  static const Color elevated = JustColorPalette.white;
  /// Full screen modal backdrop / overlay color
  static const Color overlay = JustColorPalette.black;

  // --- Text Colors ---
  /// Main text color for headings and high contrast copy
  static const Color textPrimary = JustColorPalette.neutral900;
  /// Secondary text color for captions and body copy
  static const Color textSecondary = JustColorPalette.neutral600;
  /// Disabled text color
  static const Color textDisabled = JustColorPalette.neutral400;
  /// Inverse text color for dark backgrounds
  static const Color textInverse = JustColorPalette.neutral50;

  // --- Border Colors ---
  /// Default border color for inputs and dividers
  static const Color borderDefault = JustColorPalette.neutral200;
  /// Focused element border color
  static const Color borderFocus = JustColorPalette.primary500;
  /// Error state border color
  static const Color borderError = JustColorPalette.error500;

  // --- Semantic States ---
  /// Success base color (alerts, badges)
  static const Color success = JustColorPalette.success600;
  /// Warning base color
  static const Color warning = JustColorPalette.warning600;
  /// Error base color
  static const Color error = JustColorPalette.error600;
  /// Info base color
  static const Color info = JustColorPalette.info600;
}

/// Semantic colors for JustUI in Dark Mode.
///
/// Maps functional keys to colors defined in [JustColorPalette].
abstract final class JustColorSemanticDark {
  // --- Surface Colors ---
  /// Main background color for pages in dark mode
  static const Color background = JustColorPalette.neutral950;
  /// Card and container background color in dark mode
  static const Color card = JustColorPalette.neutral900;
  /// Elevated overlay/dialog surface color in dark mode
  static const Color elevated = JustColorPalette.neutral800;
  /// Full screen modal backdrop / overlay color in dark mode
  static const Color overlay = JustColorPalette.neutral950;

  // --- Text Colors ---
  /// Main text color for headings and high contrast copy in dark mode
  static const Color textPrimary = JustColorPalette.neutral50;
  /// Secondary text color for captions and body copy in dark mode
  static const Color textSecondary = JustColorPalette.neutral400;
  /// Disabled text color in dark mode
  static const Color textDisabled = JustColorPalette.neutral600;
  /// Inverse text color for light backgrounds in dark mode
  static const Color textInverse = JustColorPalette.neutral900;

  // --- Border Colors ---
  /// Default border color in dark mode
  static const Color borderDefault = JustColorPalette.neutral800;
  /// Focused element border color in dark mode
  static const Color borderFocus = JustColorPalette.primary400;
  /// Error state border color in dark mode
  static const Color borderError = JustColorPalette.error400;

  // --- Semantic States ---
  /// Success base color in dark mode
  static const Color success = JustColorPalette.success500;
  /// Warning base color in dark mode
  static const Color warning = JustColorPalette.warning500;
  /// Error base color in dark mode
  static const Color error = JustColorPalette.error500;
  /// Info base color in dark mode
  static const Color info = JustColorPalette.info500;
}
