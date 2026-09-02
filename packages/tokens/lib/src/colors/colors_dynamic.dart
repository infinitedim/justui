import 'package:flutter/painting.dart';

import 'color_space.dart';
import 'colors_accessibility.dart';

/// A dynamic 11-step color scale generated from a single seed color.
///
/// Supports multi-engine color space manipulation ([JustColorSpaceEngine.hsl],
/// [JustColorSpaceEngine.oklch], [JustColorSpaceEngine.hsluv]).
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

  /// Generates a complete 11-step color scale using the specified color space [engine].
  ///
  /// The [engine] determines the color model used for lightness and chroma manipulation:
  /// - [JustColorSpaceEngine.hsl]: Legacy HSL (default, backward compatible)
  /// - [JustColorSpaceEngine.oklch]: OKLCH perceptually uniform color space
  /// - [JustColorSpaceEngine.hsluv]: HSLuv gamut-safe human-friendly space
  factory JustColorScale.fromSeed(
    Color seed, {
    JustColorSpaceEngine engine = .hsl,
  }) {
    final pc = ColorSpaceOps.toPerceptual(seed, engine);
    final double seedL = pc.l;

    Color makeShade(double targetL) {
      if (targetL == seedL) {
        return seed; // c500: direct assignment bypass, zero drift
      }

      if (engine == JustColorSpaceEngine.hsl) {
        final bool isLighter = targetL > seedL;
        final double range = isLighter ? (0.96 - seedL) : (seedL - 0.06);
        final double delta = (targetL - seedL).abs();
        final double progress = delta / (range + 1e-5);

        final double adjustedC = isLighter
            ? pc.c * (1.0 - progress * 0.6)
            : (pc.c * (1.0 + progress * 0.25)).clamp(0.0, 1.0);

        return ColorSpaceOps.fromPerceptual(
          PerceptualColor(targetL, adjustedC, pc.h),
          engine,
        );
      }

      final double dampedC = ColorSpaceOps.dampChroma(pc.c, targetL, engine, hue: pc.h);
      return ColorSpaceOps.fromPerceptual(
        PerceptualColor(targetL, dampedC, pc.h),
        engine,
      );
    }

    double getLightnessForStep(double baseLightness, int step) {
      if (step == 500) return seedL;

      if (step < 500) {
        final double weight = (500 - step) / 500;
        return seedL + (0.96 - seedL) * weight;
      }

      final double weight = (step - 500) / 450;
      return seedL - (seedL - 0.06) * weight;
    }

    return JustColorScale(
      c50: makeShade(getLightnessForStep(0.96, 50)),
      c100: makeShade(getLightnessForStep(0.90, 100)),
      c200: makeShade(getLightnessForStep(0.80, 200)),
      c300: makeShade(getLightnessForStep(0.70, 300)),
      c400: makeShade(getLightnessForStep(0.60, 400)),
      c500: seed, // Direct assignment, zero drift guarantee
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
  /// against a given [background] color using the specified [engine].
  ///
  /// Uses a binary search algorithm in the target perceptual color space while
  /// validating compliance using exact sRGB relative luminance (`contrastRatioWith`).
  Color adjustLightnessForContrast({
    required Color background,
    double targetRatio = 4.5,
    JustColorSpaceEngine engine = .hsl,
  }) {
    final double currentRatio = contrastRatioWith(background);
    if (currentRatio >= targetRatio) return this;

    final double bgLuminance = background.computeLuminance();
    final pc = ColorSpaceOps.toPerceptual(this, engine);
    final bool makeLighter = bgLuminance < 0.5;

    double low = makeLighter ? pc.l : 0.0;
    double high = makeLighter ? 1.0 : pc.l;
    Color bestColor = this;

    for (int i = 0; i < 12; i++) {
      final double mid = (low + high) / 2;
      final Color testColor = ColorSpaceOps.fromPerceptual(
        PerceptualColor(mid, pc.c, pc.h),
        engine,
      );
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
  /// Generates a brand-tinted dark surface color from a [seedColor] using [engine].
  ///
  /// Blends the seed's hue with low lightness and saturation for dark mode.
  static Color generateDarkSurface(
    Color seedColor, {
    required double lightness,
    double maxSaturation = 0.12,
    double saturationFactor = 0.20,
    JustColorSpaceEngine engine = .hsl,
  }) {
    final pc = ColorSpaceOps.toPerceptual(seedColor, engine);
    final double dampedC = (pc.c * saturationFactor).clamp(0.0, maxSaturation);
    return ColorSpaceOps.fromPerceptual(
      PerceptualColor(lightness, dampedC, pc.h),
      engine,
    );
  }
}
