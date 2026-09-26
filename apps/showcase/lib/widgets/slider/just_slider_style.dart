// justui-meta: registry=d6531b58b5b206cc86ed00e2a5c344dd3392e05c11e36dd9c8a955ab7d781927 local=bfff310906a10be894c7813f199659e242d050437cb2c11a29270f9bb8e5fc86
import 'package:flutter/widgets.dart';

export 'package:showcase/core/just_ui_core.dart' show JustSliderSize;

/// Customized per-instance visual styles for [JustSlider].
class JustSliderStyle {
  /// Color of the active track (filled portion).
  final Color? activeTrackColor;

  /// Color of the inactive track (empty portion).
  final Color? inactiveTrackColor;

  /// Color of the thumb.
  final Color? thumbColor;

  /// Border color of the thumb.
  final Color? thumbBorderColor;

  /// Color of the tick marks.
  final Color? tickMarkColor;

  /// Custom height for the slider track.
  final double? trackHeight;

  /// Custom size (diameter or side length) for the thumb.
  final double? thumbSize;

  /// Border radius of the slider track.
  final BorderRadius? borderRadius;

  const JustSliderStyle({
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.thumbBorderColor,
    this.tickMarkColor,
    this.trackHeight,
    this.thumbSize,
    this.borderRadius,
  });
}
