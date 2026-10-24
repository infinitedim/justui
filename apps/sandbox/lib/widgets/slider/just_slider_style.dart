// justui-meta: registry=d6531b58b5b206cc86ed00e2a5c344dd3392e05c11e36dd9c8a955ab7d781927 local=0e497312fd2d7248689d3168cc6629ff954557f8df5a311d33a008c63a60f171
import 'package:flutter/widgets.dart';

export 'package:sandbox/core/just_ui_core.dart' show JustSliderSize;

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
