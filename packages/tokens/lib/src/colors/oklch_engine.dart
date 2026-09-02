import 'dart:math' as math;

import 'package:flutter/material.dart' show Color;

/// Represents color coordinates in the OKLCH color space.
///
/// - [l]: Lightness (0.0 = black, 1.0 = white)
/// - [c]: Chroma (0.0 = monochrome/gray, ~0.37+ = vivid color)
/// - [h]: Hue angle in degrees (0.0 to 360.0)
final class OklchColor {
  final double l;
  final double c;
  final double h;

  const OklchColor(this.l, this.c, this.h);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OklchColor &&
        (other.l - l).abs() < 1e-6 &&
        (other.c - c).abs() < 1e-6 &&
        (other.h - h).abs() < 1e-6;
  }

  @override
  int get hashCode => Object.hash(l, c, h);

  @override
  String toString() =>
      'OklchColor(L: ${l.toStringAsFixed(4)}, C: ${c.toStringAsFixed(4)}, H: ${h.toStringAsFixed(1)}°)';
}

/// Pure-Dart OKLCH conversion engine, CSS-4 gamut mapping, and interpolation utilities.
abstract final class OklchEngine {
  /// Converts a Flutter [Color] (sRGB) to [OklchColor].
  static OklchColor fromColor(Color color) {
    final double r = color.r;
    final double g = color.g;
    final double b = color.b;

    // 1. sRGB to Linear RGB (gamma expansion)
    final double rL = _sRgbToLinear(r);
    final double gL = _sRgbToLinear(g);
    final double bL = _sRgbToLinear(b);

    // 2. Linear RGB to LMS cone responses (M1 matrix)
    final double l = 0.4122214708 * rL + 0.5363325363 * gL + 0.0514459529 * bL;
    final double m = 0.2119034982 * rL + 0.6806995451 * gL + 0.1073969566 * bL;
    final double s = 0.0883024619 * rL + 0.2817188376 * gL + 0.6299787005 * bL;

    // 3. Perceptual non-linear compression (safe cube root)
    final double lCap = _cbrt(l);
    final double mCap = _cbrt(m);
    final double sCap = _cbrt(s);

    // 4. LMS' to OKLab (M2 matrix)
    final double L =
        0.2104542553 * lCap + 0.7936177850 * mCap - 0.0040720468 * sCap;
    final double labA =
        1.9779984951 * lCap - 2.4285922050 * mCap + 0.4505937099 * sCap;
    final double labB =
        0.0259040371 * lCap + 0.7827717662 * mCap - 0.8086757973 * sCap;

    // 5. OKLab to OKLCH (Cartesian to Polar)
    final double C = math.sqrt(labA * labA + labB * labB);
    double H = 0.0;
    if (C >= 1e-6) {
      H = math.atan2(labB, labA) * (180.0 / math.pi);
      if (H < 0) H += 360.0;
    }

    return OklchColor(L.clamp(0.0, 1.0), C < 1e-6 ? 0.0 : C, H);
  }

  /// Converts an [OklchColor] back to a Flutter [Color] (sRGB) using
  /// CSS Color Level 4 §12 gamut mapping.
  ///
  /// Reduces chroma while preserving lightness and hue until the color
  /// fits within the sRGB gamut. For the raw clamping-based conversion
  /// without gamut mapping, see [toRawColor].
  static Color toColor(OklchColor oklch, {double alpha = 1.0}) {
    return gamutMap(oklch, alpha: alpha);
  }

  /// Converts an [OklchColor] to a Flutter [Color] using raw per-channel
  /// clamping without gamut mapping.
  ///
  /// Faster than [toColor] but may cause hue shifts for out-of-gamut colors.
  /// Use when performance is critical and the input is known to be in-gamut.
  static Color toRawColor(OklchColor oklch, {double alpha = 1.0}) {
    final (rL, gL, bL) = _oklchToLinearRgb(oklch.l, oklch.c, oklch.h);
    return _linearRgbToColor(rL, gL, bL, alpha);
  }

  /// CSS Color Level 4 §12 gamut mapping: reduces chroma while preserving
  /// lightness and hue until the color fits within the sRGB gamut.
  ///
  /// Uses a 16-iteration binary search on chroma to find the maximum
  /// in-gamut chroma, achieving ~0.001% precision.
  static Color gamutMap(OklchColor oklch, {double alpha = 1.0}) {
    // Fast path: achromatic colors are always in gamut
    if (oklch.c < 1e-6) {
      return toRawColor(oklch, alpha: alpha);
    }

    // Check if already in gamut (skip binary search)
    final (rL, gL, bL) = _oklchToLinearRgb(oklch.l, oklch.c, oklch.h);
    if (_isLinearRgbInGamut(rL, gL, bL)) {
      return _linearRgbToColor(rL, gL, bL, alpha);
    }

    // Binary search: reduce chroma preserving L and H
    double low = 0.0;
    double high = oklch.c;

    for (int i = 0; i < 16; i++) {
      final double mid = (low + high) / 2;
      final (rM, gM, bM) = _oklchToLinearRgb(oklch.l, mid, oklch.h);
      if (_isLinearRgbInGamut(rM, gM, bM)) {
        low = mid;
      } else {
        high = mid;
      }
    }

    // Converged: use the highest in-gamut chroma
    final (rF, gF, bF) = _oklchToLinearRgb(oklch.l, low, oklch.h);
    return _linearRgbToColor(rF, gF, bF, alpha);
  }

  /// Calculates the maximum sRGB-safe chroma for a given [lightness] and [hue].
  ///
  /// Uses a 16-iteration binary search for fast convergence (~0.001% precision).
  /// Returns 0.0 at extreme lightness values (pure black/white).
  static double maxChromaForLH(double lightness, double hue) {
    if (lightness <= 1e-6 || lightness >= 1.0 - 1e-6) return 0.0;

    double low = 0.0;
    double high = 0.5; // Practical upper bound for OKLCH chroma in sRGB

    for (int i = 0; i < 16; i++) {
      final double mid = (low + high) / 2;
      final (rL, gL, bL) = _oklchToLinearRgb(lightness, mid, hue);
      if (_isLinearRgbInGamut(rL, gL, bL)) {
        low = mid;
      } else {
        high = mid;
      }
    }

    return low;
  }

  /// Calculates a pre-damped chroma value for a target lightness [targetL]
  /// to ensure shades near L=0 and L=1 stay within sRGB gamut.
  ///
  /// This is the legacy hue-unaware heuristic. Prefer [dampChromaHueAware]
  /// for more accurate results that respect the actual gamut boundary per hue.
  static double dampChroma(double seedChroma, double targetL) {
    if (seedChroma <= 1e-6) return 0.0;
    // Edge factor drops to 0 at L=0 and L=1, preserving full chroma near L=0.5
    final double edgeFactor = 1.0 - math.pow((2.0 * targetL - 1.0).abs(), 2.5);
    return (seedChroma * edgeFactor.clamp(0.0, 1.0));
  }

  /// Improved chroma damping that respects the actual sRGB gamut boundary
  /// at each hue angle, preventing unnecessary desaturation.
  ///
  /// Clamps [seedChroma] to the maximum in-gamut chroma for the given
  /// [targetL] and [hue], computed via [maxChromaForLH].
  static double dampChromaHueAware(
    double seedChroma,
    double targetL,
    double hue,
  ) {
    if (seedChroma <= 1e-6) return 0.0;
    final double maxC = maxChromaForLH(targetL, hue);
    return seedChroma.clamp(0.0, maxC);
  }

  /// Interpolates between two colors in OKLCH space at parameter [t] (0.0 to 1.0).
  ///
  /// Unlike Flutter's [Color.lerp] which interpolates in sRGB (producing muddy
  /// gray transitions between distant hues), this produces perceptually smooth
  /// transitions with consistent chroma and shortest-arc hue interpolation.
  static Color lerp(Color a, Color b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;

    final oklchA = fromColor(a);
    final oklchB = fromColor(b);

    // Interpolate lightness and chroma linearly
    final double l = oklchA.l + (oklchB.l - oklchA.l) * t;
    final double c = oklchA.c + (oklchB.c - oklchA.c) * t;

    // Shortest-arc hue interpolation
    double dH = oklchB.h - oklchA.h;
    if (dH > 180.0) dH -= 360.0;
    if (dH < -180.0) dH += 360.0;
    double h = oklchA.h + dH * t;
    if (h < 0.0) h += 360.0;
    if (h >= 360.0) h -= 360.0;

    // Interpolate alpha
    final double alpha = a.a + (b.a - a.a) * t;

    return gamutMap(OklchColor(l, c, h), alpha: alpha);
  }

  // --- Internal conversion helpers ---

  /// Converts OKLCH coordinates to Linear RGB without clamping or gamma compression.
  static (double, double, double) _oklchToLinearRgb(
    double L,
    double C,
    double H,
  ) {
    // 1. OKLCH to OKLab (Polar to Cartesian)
    final double hRad = H * (math.pi / 180.0);
    final double labA = C * math.cos(hRad);
    final double labB = C * math.sin(hRad);

    // 2. OKLab to LMS' (M2 inverse matrix)
    final double lCap = L + 0.3963377774 * labA + 0.2158037573 * labB;
    final double mCap = L - 0.1055613458 * labA - 0.0638541728 * labB;
    final double sCap = L - 0.0894841775 * labA - 1.2914855480 * labB;

    // 3. LMS' to LMS (cubing)
    final double l = lCap * lCap * lCap;
    final double m = mCap * mCap * mCap;
    final double s = sCap * sCap * sCap;

    // 4. LMS to Linear RGB (M1 inverse matrix)
    return (
      4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
      -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
      -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
    );
  }

  /// Checks if linear RGB values are within the sRGB gamut (with small epsilon tolerance).
  static bool _isLinearRgbInGamut(double rL, double gL, double bL) {
    const double e = 1e-4;
    return rL >= -e &&
        rL <= 1.0 + e &&
        gL >= -e &&
        gL <= 1.0 + e &&
        bL >= -e &&
        bL <= 1.0 + e;
  }

  /// Converts linear RGB to a Flutter [Color] with gamma compression and clamping.
  static Color _linearRgbToColor(
    double rL,
    double gL,
    double bL,
    double alpha,
  ) {
    return .from(
      alpha: alpha.clamp(0.0, 1.0),
      red: _linearToSRgb(rL).clamp(0.0, 1.0),
      green: _linearToSRgb(gL).clamp(0.0, 1.0),
      blue: _linearToSRgb(bL).clamp(0.0, 1.0),
    );
  }

  // --- Helper math functions ---

  static double _sRgbToLinear(double c) {
    return c <= 0.04045
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _linearToSRgb(double c) {
    return c <= 0.0031308
        ? 12.92 * c
        : 1.055 * math.pow(c, 1.0 / 2.4).toDouble() - 0.055;
  }

  static double _cbrt(double x) {
    return x < 0
        ? -math.pow(-x, 1.0 / 3.0).toDouble()
        : math.pow(x, 1.0 / 3.0).toDouble();
  }
}

/// Extension methods on [Color] for OKLCH-aware color interpolation.
extension OklchColorLerp on Color {
  /// Interpolates between this color and [other] in OKLCH space at [t].
  ///
  /// See [OklchEngine.lerp] for details.
  Color lerpToOklch(Color other, double t) => OklchEngine.lerp(this, other, t);
}
