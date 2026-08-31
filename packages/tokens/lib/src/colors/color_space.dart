import 'package:flutter/material.dart' show Color, HSLColor;

import 'oklch_engine.dart';
import 'hsluv_engine.dart';

/// Available color space engines for dynamic color palette generation and contrast adjustment.
enum JustColorSpaceEngine {
  /// Legacy HSL color space (default, backward compatible).
  hsl,

  /// OKLCH perceptually uniform color space.
  /// Solves the yellow/blue lightness paradox and delivers smooth shade distribution.
  oklch,

  /// HSLuv human-friendly color space.
  /// Guarantees sRGB gamut safety at all saturation levels across all hues.
  hsluv,
}

/// Unified, engine-agnostic perceptual color coordinates.
///
/// - [l]: Normalized Lightness (0.0 to 1.0)
/// - [c]: Engine-specific Chroma or Saturation
/// - [h]: Hue angle in degrees (0.0 to 360.0)
final class PerceptualColor {
  final double l;
  final double c;
  final double h;

  const PerceptualColor(this.l, this.c, this.h);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerceptualColor &&
        (other.l - l).abs() < 1e-6 &&
        (other.c - c).abs() < 1e-6 &&
        (other.h - h).abs() < 1e-6;
  }

  @override
  int get hashCode => Object.hash(l, c, h);

  @override
  String toString() =>
      'PerceptualColor(L: ${l.toStringAsFixed(4)}, C: ${c.toStringAsFixed(4)}, H: ${h.toStringAsFixed(1)}°)';
}

/// Operational dispatcher delegating color transformations to the active [JustColorSpaceEngine].
abstract final class ColorSpaceOps {
  /// Converts a Flutter [Color] (sRGB) to normalized [PerceptualColor] coordinates
  /// using the specified [engine].
  static PerceptualColor toPerceptual(
    Color color,
    JustColorSpaceEngine engine,
  ) {
    switch (engine) {
      case .hsl:
        final HSLColor hsl = .fromColor(color);
        return PerceptualColor(hsl.lightness, hsl.saturation, hsl.hue);

      case .oklch:
        final oklch = OklchEngine.fromColor(color);
        return PerceptualColor(oklch.l, oklch.c, oklch.h);

      case .hsluv:
        final hsluv = HsluvEngine.fromColor(color);
        return PerceptualColor(hsluv.l / 100.0, hsluv.s / 100.0, hsluv.h);
    }
  }

  /// Converts normalized [PerceptualColor] coordinates back to a Flutter [Color] (sRGB)
  /// using the specified [engine].
  static Color fromPerceptual(PerceptualColor pc, JustColorSpaceEngine engine) {
    switch (engine) {
      case .hsl:
        return HSLColor.fromAHSL(
          1.0,
          pc.h.clamp(0.0, 360.0),
          pc.c.clamp(0.0, 1.0),
          pc.l.clamp(0.0, 1.0),
        ).toColor();

      case .oklch:
        return OklchEngine.toColor(
          OklchColor(pc.l.clamp(0.0, 1.0), pc.c.clamp(0.0, 1.0), pc.h),
        );

      case .hsluv:
        return HsluvEngine.toColor(
          HsluvColor(
            pc.h,
            (pc.c * 100.0).clamp(0.0, 100.0),
            (pc.l * 100.0).clamp(0.0, 100.0),
          ),
        );
    }
  }

  /// Calculates a pre-damped chroma value for [targetL] to prevent out-of-gamut clipping.
  static double dampChroma(
    double seedChroma,
    double targetL,
    JustColorSpaceEngine engine,
  ) {
    switch (engine) {
      case .hsl:
        return seedChroma; // HSL handles saturation within [0, 1] natively

      case .oklch:
        return OklchEngine.dampChroma(seedChroma, targetL);

      case .hsluv:
        return seedChroma; // HSLuv normalizes chroma to gamut boundary automatically
    }
  }
}
