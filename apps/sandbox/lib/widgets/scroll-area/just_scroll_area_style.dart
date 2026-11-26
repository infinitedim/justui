// justui-meta: registry=966cc88155cc9431db201f5967685ec8077bce757faa13e1e87e7aa10003028b local=fe70013fb814d3f06877733956e238627683dfdf09a5aeea31e01fd5d8d4844a
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

  /// Optional padding inset for the scrollbar track. Defaults to [EdgeInsets.zero].
  final EdgeInsets? scrollbarPadding;

  /// Optional main axis margin for the scrollbar track. Defaults to 0.0.
  final double? scrollbarMargin;

  /// Whether the scrollbar thumb should always remain visible.
  final bool? thumbVisibility;

  /// Whether the scrollbar track should always remain visible.
  final bool? trackVisibility;

  /// Corner radius of the scrollbar track.
  final Radius? scrollbarTrackRadius;

  /// Optional cross axis margin for the scrollbar track. Defaults to 0.0.
  final double? scrollbarCrossAxisMargin;

  /// Corner radius for the keyboard focus indicator around the scroll area.
  final BorderRadius? focusBorderRadius;

  /// When `null`, defaults to `true` on desktop/web and `false` on mobile.
  final bool? smoothScroll;

  /// Defaults to 0.10 (Lenis signature).
  final double? lerpFactor;

  /// Defaults to 1.0.
  final double? wheelMultiplier;

  /// Defaults to 1.0.
  final double? touchMultiplier;

  const JustScrollAreaStyle({
    this.fadeColor,
    this.fadeHeight,
    this.scrollbarThumbColor,
    this.scrollbarTrackColor,
    this.scrollbarThickness,
    this.scrollbarRadius,
    this.scrollbarPadding,
    this.scrollbarMargin,
    this.thumbVisibility,
    this.trackVisibility,
    this.scrollbarTrackRadius,
    this.scrollbarCrossAxisMargin,
    this.focusBorderRadius,
    this.smoothScroll,
    this.lerpFactor,
    this.wheelMultiplier,
    this.touchMultiplier,
  });
}
