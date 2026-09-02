import 'package:flutter/animation.dart' show Tween;
import 'package:flutter/painting.dart' show Color;

import 'oklch_engine.dart';

/// A [Tween] that interpolates between two [Color]s in OKLCH perceptual
/// color space.
///
/// Unlike Flutter's default [ColorTween] which interpolates in sRGB
/// (producing muddy gray transitions between distant hues), this produces
/// perceptually smooth transitions with consistent chroma and natural
/// hue progression.
///
/// ```dart
/// final tween = OklchColorTween(
///   begin: Colors.blue,
///   end: Colors.yellow,
/// );
/// // At t=0.5, produces a vibrant green instead of gray
/// final mid = tween.transform(0.5);
/// ```
class OklchColorTween extends Tween<Color> {
  /// Creates an OKLCH color tween.
  OklchColorTween({super.begin, super.end});

  @override
  Color lerp(double t) => OklchEngine.lerp(begin!, end!, t);
}
