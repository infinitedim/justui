import 'package:flutter/painting.dart';
import 'colors_accessibility.dart';

/// A dynamic 11-step color scale generated from a single seed color.
///
/// Maintains Hue and adjusts Lightness while dynamically curving Saturation
/// (boosting saturation for dark shades, and reducing it for light shades).
class JustColorScale {
  /// The shade 50 (lightest).
  final Color c50;

  /// The shade 100.
  final Color c100;

  /// The shade 200.
  final Color c200;

  /// The shade 300.
  final Color c300;

  /// The shade 400.
  final Color c400;

  /// The shade 500 (original seed midpoint).
  final Color c500;

  /// The shade 600.
  final Color c600;

  /// The shade 700.
  final Color c700;

  /// The shade 800.
  final Color c800;

  /// The shade 900.
  final Color c900;

  /// The shade 950 (darkest).
  final Color c950;

  /// Creates a [JustColorScale] with explicit shades.
  const JustColorScale({
    required this.c50,
    required this.c100,
    required this.c200,
    required this.c300,
    required this.c400,
    required this.c500,
    required this.c600,
    required this.c700,
    required this.c800,
    required this.c900,
    required this.c950,
  });

  /// Generates a complete 11-step HSL color scale using a dynamic saturation curve.
  factory JustColorScale.fromSeed(Color seed) {
    final HSLColor hsl = .fromColor(seed);
    final double seedH = hsl.hue;
    final double seedS = hsl.saturation;
    final double seedL = hsl.lightness;

    // Helper to interpolate and adjust saturation dynamically
    Color makeShade(double targetL) {
      double adjustedS = seedS;
      if (targetL > seedL) {
        // Light shades: scale saturation down (prevents neon glow)
        final double t = (targetL - seedL) / (0.96 - seedL + 1e-5);
        adjustedS = seedS * (1.0 - t * 0.6);
      } else if (targetL < seedL) {
        // Dark shades: scale saturation up (prevents dull/washed-out grey)
        final double t = (seedL - targetL) / (seedL - 0.06 + 1e-5);
        adjustedS = (seedS * (1.0 + t * 0.25)).clamp(0.0, 1.0);
      }
      return HSLColor.fromAHSL(1.0, seedH, adjustedS, targetL).toColor();
    }

    // We adjust target lightness levels dynamically based on seedL position
    double getLightnessForStep(double baseLightness, int step) {
      if (step == 500) return seedL;
      if (step < 500) {
        final double weight = (500 - step) / 500;
        return seedL + (0.96 - seedL) * weight;
      } else {
        final double weight = (step - 500) / 450;
        return seedL - (seedL - 0.06) * weight;
      }
    }

    return JustColorScale(
      c50: makeShade(getLightnessForStep(0.96, 50)),
      c100: makeShade(getLightnessForStep(0.90, 100)),
      c200: makeShade(getLightnessForStep(0.80, 200)),
      c300: makeShade(getLightnessForStep(0.70, 300)),
      c400: makeShade(getLightnessForStep(0.60, 400)),
      c500: seed,
      c600: makeShade(getLightnessForStep(0.40, 600)),
      c700: makeShade(getLightnessForStep(0.30, 700)),
      c800: makeShade(getLightnessForStep(0.20, 800)),
      c900: makeShade(getLightnessForStep(0.12, 900)),
      c950: makeShade(getLightnessForStep(0.06, 950)),
    );
  }
}

/// Extension methods on [Color] to dynamically enforce WCAG contrast compliance.
extension JustColorContrastCorrection on Color {
  /// Adjusts the lightness of this color so it meets the target contrast ratio
  /// against a given [background] color.
  ///
  /// Uses a binary search algorithm to shift lightness as minimally as possible
  /// to satisfy the accessibility constraints while preserving hue and saturation.
  Color adjustLightnessForContrast({
    required Color background,
    double targetRatio = 4.5,
  }) {
    final double currentRatio = contrastRatioWith(background);
    if (currentRatio >= targetRatio) return this;

    final double bgLuminance = background.computeLuminance();
    final HSLColor hsl = .fromColor(this);
    final bool makeLighter = bgLuminance < 0.5;

    double low = makeLighter ? hsl.lightness : 0.0;
    double high = makeLighter ? 1.0 : hsl.lightness;
    Color bestColor = this;

    for (int i = 0; i < 8; i++) {
      final double mid = (low + high) / 2;
      final Color testColor = hsl.withLightness(mid).toColor();
      final double ratio = testColor.contrastRatioWith(background);

      if (ratio >= targetRatio) {
        bestColor = testColor;
        if (makeLighter) {
          high = mid;
        } else {
          low = mid;
        }
      } else {
        if (makeLighter) {
          low = mid;
        } else {
          high = mid;
        }
      }
    }

    return bestColor;
  }
}

/// Utility class for dynamic surface color generation.
abstract final class JustDynamicSurfaces {
  /// Generates a brand-tinted dark surface color from a [seedColor].
  ///
  /// Blends the seed's hue with very low lightness and saturation for dark mode.
  static Color generateDarkSurface(
    Color seedColor, {
    required double lightness,
    double maxSaturation = 0.12,
    double saturationFactor = 0.20,
  }) {
    final HSLColor hsl = .fromColor(seedColor);
    final double s = (hsl.saturation * saturationFactor).clamp(0.0, maxSaturation);
    return HSLColor.fromAHSL(1.0, hsl.hue, s, lightness).toColor();
  }
}

