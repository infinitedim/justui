import 'dart:math' as math;

import 'package:flutter/material.dart' show Color;

/// Represents color coordinates in the HSLuv color space.
///
/// - [h]: Hue angle in degrees (0.0 to 360.0)
/// - [s]: Saturation percentage (0.0 to 100.0)
/// - [l]: Lightness percentage (0.0 to 100.0)
final class HsluvColor {
  final double h;
  final double s;
  final double l;

  const HsluvColor(this.h, this.s, this.l);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HsluvColor &&
        (other.h - h).abs() < 1e-6 &&
        (other.s - s).abs() < 1e-6 &&
        (other.l - l).abs() < 1e-6;
  }

  @override
  int get hashCode => Object.hash(h, s, l);

  @override
  String toString() =>
      'HsluvColor(H: ${h.toStringAsFixed(1)}°, S: ${s.toStringAsFixed(1)}%, L: ${l.toStringAsFixed(1)}%)';
}

/// Pure-Dart HSLuv conversion engine, gamut boundary calculations, and
/// CIELUV perceptual color interpolation.
///
/// ## Color Science & High Precision
///
/// Uses high-precision CIE ASTM E308 reference white constants (D65 illuminant
/// derived from chromaticity $x=0.3127, y=0.3290$) and exact rational fractions
/// for CIE L* constants ($\kappa = 24389/27, \epsilon = 216/24389$).
///
/// ## Interpolation — Premultiplied CIELUV
///
/// Color interpolation ([lerp]) is performed in Cartesian CIELUV ($L^*, u^*, v^*$)
/// space using premultiplied alpha (Porter-Duff compositing). This avoids the
/// non-linear chroma jumps ("wibbly-wobbly" artifacts) of interpolating in polar
/// HSLuv $(H, S, L)$ coordinates, producing smooth, perceptually uniform transitions.
///
/// References:
/// - Alexei Boronine, "HSLuv: A human-friendly alternative to HSL" (2012)
/// - CIE Publication 15: Colorimetry (3rd Edition, 2004)
/// - ASTM E308-01: Standard Practice for Computing the Colors of Objects
abstract final class HsluvEngine {
  // High-precision D65 white point derived from sRGB chromaticities:
  // xw = 0.3127, yw = 0.3290 -> Xn = xw/yw, Yn = 1.0, Zn = (1 - xw - yw)/yw
  static const double _refX = 0.9504559270516717;
  static const double _refY = 1.0000000000000000;
  static const double _refZ = 1.0890577507598784;

  static const double _refU =
      (4.0 * _refX) / (_refX + 15.0 * _refY + 3.0 * _refZ);
  static const double _refV =
      (9.0 * _refY) / (_refX + 15.0 * _refY + 3.0 * _refZ);

  // Exact CIE L* constants (Bruce Lindbloom / CIE 15:2004)
  static const double _kappa = 903.2962962962963; // 24389 / 27
  static const double _epsilon = 0.0088564516790356308; // 216 / 24389

  // Matrix M_RGB_XYZ
  static const double _mR0 = 0.41239079926595934;
  static const double _mR1 = 0.35758433938387796;
  static const double _mR2 = 0.18048078840183429;
  static const double _mG0 = 0.21263900587151036;
  static const double _mG1 = 0.71516867876775593;
  static const double _mG2 = 0.07219231536073371;
  static const double _mB0 = 0.01933081871559185;
  static const double _mB1 = 0.11919477979462598;
  static const double _mB2 = 0.95053215224966058;

  // Matrix M_XYZ_RGB
  static const double _mX0 = 3.240969941904521;
  static const double _mX1 = -1.537383177570093;
  static const double _mX2 = -0.498610760293003;
  static const double _mY0 = -0.969243636280870;
  static const double _mY1 = 1.875967501507720;
  static const double _mY2 = 0.041555057407175;
  static const double _mZ0 = 0.055630080164829;
  static const double _mZ1 = -0.204007460932413;
  static const double _mZ2 = 1.057225216773290;

  /// Converts a Flutter [Color] (sRGB) to [HsluvColor].
  static HsluvColor fromColor(Color color) {
    final (l, u, v) = _colorToLuv(color);

    if (l <= 1e-6) {
      return const HsluvColor(0.0, 0.0, 0.0);
    }
    if (l >= 99.999999) {
      return const HsluvColor(0.0, 0.0, 100.0);
    }

    // Luv -> Lch
    final double c = math.sqrt(u * u + v * v);
    double h = 0.0;
    if (c >= 1e-6) {
      h = math.atan2(v, u) * (180.0 / math.pi);
      if (h < 0) h += 360.0;
    }

    // Lch -> HSLuv
    final double maxC = maxChromaForLH(l, h);
    final double s = maxC < 1e-6 ? 0.0 : (c / maxC) * 100.0;

    return HsluvColor(h, s.clamp(0.0, 100.0), l.clamp(0.0, 100.0));
  }

  /// Converts an [HsluvColor] back to a Flutter [Color] (sRGB).
  static Color toColor(HsluvColor hsluv, {double alpha = 1.0}) {
    final double h = hsluv.h;
    final double s = hsluv.s;
    final double l = hsluv.l;

    if (l > 99.999999) {
      return .from(
        alpha: alpha.clamp(0.0, 1.0),
        red: 1.0,
        green: 1.0,
        blue: 1.0,
      );
    }
    if (l < 1e-6) {
      return .from(
        alpha: alpha.clamp(0.0, 1.0),
        red: 0.0,
        green: 0.0,
        blue: 0.0,
      );
    }

    // HSLuv -> Lch
    final double maxC = maxChromaForLH(l, h);
    final double c = (maxC / 100.0) * s;

    // Lch -> Luv
    final double hRad = h * (math.pi / 180.0);
    final double u = c * math.cos(hRad);
    final double v = c * math.sin(hRad);

    return _luvToColor(l, u, v, alpha: alpha);
  }

  /// Calculates the maximum allowed Chroma at lightness [l] and hue [h] (in degrees)
  /// before exiting the sRGB gamut.
  ///
  /// Returns 0.0 strictly at extreme lightness boundaries ($L \le 10^{-6}$ or $L \ge 100 - 10^{-6}$)
  /// to eliminate floating-point roundoff drift.
  static double maxChromaForLH(double l, double h) {
    if (l <= 1e-6 || l >= 100.0 - 1e-6) {
      return 0.0;
    }
    final double hRad = h * (math.pi / 180.0);
    return _intersectBoundingLines(l, hRad);
  }

  /// Interpolates between two colors in CIELUV Cartesian ($L^*, u^*, v^*$) space
  /// at parameter [t] (0.0 to 1.0) using **premultiplied alpha**.
  ///
  /// Interpolating in Cartesian CIELUV guarantees a straight perceptual path
  /// through uniform color space, completely avoiding the non-linear chroma
  /// jumps ("wibbly-wobbly" artifacts) that occur when interpolating directly
  /// in polar HSLuv $(H, S, L)$ coordinates.
  ///
  /// Premultiplied alpha eliminates dark halo artifacts on transparent borders.
  static Color lerp(Color a, Color b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;

    final (lA, uA, vA) = _colorToLuv(a);
    final (lB, uB, vB) = _colorToLuv(b);
    final double alphaA = a.a;
    final double alphaB = b.a;

    // Premultiplied alpha encoding in Cartesian CIELUV space
    final double lPreA = lA * alphaA;
    final double uPreA = uA * alphaA;
    final double vPreA = vA * alphaA;

    final double lPreB = lB * alphaB;
    final double uPreB = uB * alphaB;
    final double vPreB = vB * alphaB;

    // Linear interpolation
    final double lPre = lPreA + (lPreB - lPreA) * t;
    final double uPre = uPreA + (uPreB - uPreA) * t;
    final double vPre = vPreA + (vPreB - vPreA) * t;
    final double alpha = alphaA + (alphaB - alphaA) * t;

    if (alpha < 1e-6) {
      return const Color(0x00000000);
    }

    // Decode premultiplied -> straight
    final double l = (lPre / alpha).clamp(0.0, 100.0);
    final double u = uPre / alpha;
    final double v = vPre / alpha;

    return _luvToColor(l, u, v, alpha: alpha);
  }

  // --- Internal CIELUV helpers ---

  static (double, double, double) _colorToLuv(Color color) {
    final double rL = _sRgbToLinear(color.r);
    final double gL = _sRgbToLinear(color.g);
    final double bL = _sRgbToLinear(color.b);

    // RGB -> XYZ
    final double x = _mR0 * rL + _mR1 * gL + _mR2 * bL;
    final double y = _mG0 * rL + _mG1 * gL + _mG2 * bL;
    final double z = _mB0 * rL + _mB1 * gL + _mB2 * bL;

    // XYZ -> Luv
    final double l = _yToL(y);
    if (l <= 1e-6) {
      return (0.0, 0.0, 0.0);
    }

    final double denominator = x + 15.0 * y + 3.0 * z;
    final double uPrime = denominator < 1e-12 ? _refU : (4.0 * x) / denominator;
    final double vPrime = denominator < 1e-12 ? _refV : (9.0 * y) / denominator;

    final double u = 13.0 * l * (uPrime - _refU);
    final double v = 13.0 * l * (vPrime - _refV);

    return (l, u, v);
  }

  static Color _luvToColor(double l, double u, double v, {double alpha = 1.0}) {
    if (l > 99.999999) {
      return .from(
        alpha: alpha.clamp(0.0, 1.0),
        red: 1.0,
        green: 1.0,
        blue: 1.0,
      );
    }
    if (l < 1e-6) {
      return .from(
        alpha: alpha.clamp(0.0, 1.0),
        red: 0.0,
        green: 0.0,
        blue: 0.0,
      );
    }

    // Luv -> XYZ
    final double uPrime = u / (13.0 * l) + _refU;
    final double vPrime = v / (13.0 * l) + _refV;

    final double y = _lToY(l);
    final double x = vPrime < 1e-12 ? 0.0 : y * (9.0 * uPrime) / (4.0 * vPrime);
    final double z = vPrime < 1e-12
        ? 0.0
        : y * (12.0 - 3.0 * uPrime - 20.0 * vPrime) / (4.0 * vPrime);

    // XYZ -> RGB
    final double rL = _mX0 * x + _mX1 * y + _mX2 * z;
    final double gL = _mY0 * x + _mY1 * y + _mY2 * z;
    final double bL = _mZ0 * x + _mZ1 * y + _mZ2 * z;

    final double r = _linearToSRgb(rL).clamp(0.0, 1.0);
    final double g = _linearToSRgb(gL).clamp(0.0, 1.0);
    final double b = _linearToSRgb(bL).clamp(0.0, 1.0);

    return .from(alpha: alpha.clamp(0.0, 1.0), red: r, green: g, blue: b);
  }

  static double _intersectBoundingLines(double l, double hRad) {
    final double sinH = math.sin(hRad);
    final double cosH = math.cos(hRad);

    // Micro-optimization: avoid math.pow(l + 16.0, 3.0) via direct cubic multiplication
    final double l16 = l + 16.0;
    final double sub1 = (l16 * l16 * l16) / 1560896.0;
    final double sub2 = sub1 > _epsilon ? sub1 : l / _kappa;

    double minLength = .infinity;

    for (int c = 0; c < 3; c++) {
      final double m1 = c == 0 ? _mX0 : (c == 1 ? _mY0 : _mZ0);
      final double m2 = c == 0 ? _mX1 : (c == 1 ? _mY1 : _mZ1);
      final double m3 = c == 0 ? _mX2 : (c == 1 ? _mY2 : _mZ2);

      for (int boundary = 0; boundary < 2; boundary++) {
        final double bound = boundary.toDouble();

        final double top1 = (284517.0 * m1 - 94839.0 * m3) * sub2;
        final double top2 =
            (838422.0 * m3 + 769860.0 * m2 + 731718.0 * m1) * l * sub2 -
            769860.0 * bound * l;
        final double bottom =
            (632260.0 * m3 - 126452.0 * m2) * sub2 + 126452.0 * bound;

        // Numerical guard: prevent division by zero or NaN on parallel rays
        final double denom = bottom * sinH - top1 * cosH;
        if (denom.abs() < 1e-12) continue;

        final double length = top2 / denom;
        if (length >= 0.0 && length < minLength) {
          minLength = length;
        }
      }
    }

    return minLength.isFinite ? minLength : 0.0;
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

  static double _yToL(double y) {
    return y <= _epsilon
        ? y * _kappa
        : 116.0 * math.pow(y, 1.0 / 3.0).toDouble() - 16.0;
  }

  static double _lToY(double l) {
    if (l <= 8.0) return l / _kappa;
    // Micro-optimization: avoid math.pow via direct cubic multiplication
    final double lNorm = (l + 16.0) / 116.0;
    return lNorm * lNorm * lNorm;
  }
}

/// Extension methods on [Color] for HSLuv-aware color interpolation.
extension HsluvColorLerp on Color {
  /// Interpolates between this color and [other] in CIELUV space at [t].
  ///
  /// See [HsluvEngine.lerp] for details.
  Color lerpToHsluv(Color other, double t) => HsluvEngine.lerp(this, other, t);
}
