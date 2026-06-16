import 'package:flutter/widgets.dart';

/// Visual fade edge modes for [JustScrollArea].
enum JustScrollFadeMode {
  /// Paints solid background colored overlay gradients to blend out content.
  /// Excellent performance as it avoids offscreen GPU layer compositing.
  overlay,

  /// Uses a [ShaderMask] to perform a true alpha transparency mask over the content.
  /// Necessary for scroll containers rendering over complex gradients/images.
  mask,
}

/// Customized per-instance styles for [JustScrollArea].
class JustScrollAreaStyle {
  /// The color used for the fade gradients. Defaults to context background color.
  final Color? fadeColor;

  /// The height/width of the fade gradients. Defaults to 24.0.
  final double? fadeHeight;

  /// Custom color of the scrollbar thumb.
  final Color? scrollbarThumbColor;

  /// Custom color of the scrollbar track.
  final Color? scrollbarTrackColor;

  /// Thickness of the scrollbar.
  final double? scrollbarThickness;

  /// Corner radius of the scrollbar thumb.
  final Radius? scrollbarRadius;

  /// Creates a [JustScrollAreaStyle] override.
  const JustScrollAreaStyle({
    this.fadeColor,
    this.fadeHeight,
    this.scrollbarThumbColor,
    this.scrollbarTrackColor,
    this.scrollbarThickness,
    this.scrollbarRadius,
  });
}
