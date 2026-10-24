import 'package:flutter/animation.dart' show Tween;
import 'package:flutter/painting.dart' show Color;

import 'hsluv_engine.dart';

/// A [Tween] that interpolates between two [Color]s in CIELUV perceptual
/// color space.
///
/// Unlike Flutter's default [ColorTween] which interpolates in gamma-compressed
/// sRGB (producing muddy gray transitions between distant hues), this produces
/// perceptually smooth transitions with consistent perceptual lightness and
/// chroma progression.
///
/// ```dart
/// final tween = HsluvColorTween(
///   begin: Colors.blue,
///   end: Colors.yellow,
/// );
/// final mid = tween.transform(0.5);
/// ```
class HsluvColorTween extends Tween<Color> {
  /// Creates an HSLuv/CIELUV color tween.
  HsluvColorTween({super.begin, super.end});

  @override
  Color lerp(double t) => HsluvEngine.lerp(begin!, end!, t);
}
