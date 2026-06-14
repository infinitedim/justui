import 'package:flutter/painting.dart';

/// Typography tokens for JustUI.
///
/// Defines font families, weights, sizes, line heights, and letter spacings.
/// All text styles are defined as compile-time constants.
abstract final class JustTypo {
  /// The default font family used by JustUI.
  static const String fontFamily = 'Inter';

  /// The monospace font family used for code or numbers.
  static const String monoFontFamily = 'JetBrains Mono';

  // --- Display Scale ---
  /// Large display text for hero headlines (48px / line-height: 1.2)
  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.96, // -0.02 * 48
  );

  /// Medium display text for section headlines (36px / line-height: 1.2)
  static const TextStyle displayMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.72, // -0.02 * 36
  );

  /// Small display text for sub-headlines (30px / line-height: 1.3)
  static const TextStyle displaySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.6, // -0.02 * 30
  );

  // --- Heading Scale ---
  /// Large heading text for page titles (24px / line-height: 1.3)
  static const TextStyle headingLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.24, // -0.01 * 24
  );

  /// Medium heading text for cards (20px / line-height: 1.4)
  static const TextStyle headingMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2, // -0.01 * 20
  );

  /// Small heading text for subsections (16px / line-height: 1.4)
  static const TextStyle headingSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.16, // -0.01 * 16
  );

  // --- Body Scale ---
  /// Large body text for prominent paragraphs (18px / line-height: 1.6)
  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.0,
  );

  /// Default body copy text (16px / line-height: 1.6)
  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.0,
  );

  /// Small body copy text for details (14px / line-height: 1.5)
  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.0,
  );

  // --- Support Scale ---
  /// Caption text for secondary annotations (12px / line-height: 1.4)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.0,
  );

  /// Overline text for small header labels (11px / line-height: 1.5)
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.55, // 0.05 * 11
  );
}
