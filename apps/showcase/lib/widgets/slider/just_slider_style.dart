// justui-meta: registry=d6531b58b5b206cc86ed00e2a5c344dd3392e05c11e36dd9c8a955ab7d781927 local=2d83e4ff163d96d57196dd9dfddfbd788104e69b1d036366d35ba146c24b78f8
import 'package:flutter/widgets.dart';

export 'package:showcase/core/just_ui_core.dart' show JustSliderSize;

/// Customized per-instance visual styles for [JustSlider].
class const JustSliderStyle({
  /// Color of the active track (filled portion).
  final Color? activeTrackColor,

  /// Color of the inactive track (empty portion).
  final Color? inactiveTrackColor,

  /// Color of the thumb.
  final Color? thumbColor,

  /// Border color of the thumb.
  final Color? thumbBorderColor,

  /// Color of the tick marks.
  final Color? tickMarkColor,

  /// Custom height for the slider track.
  final double? trackHeight,

  /// Custom size (diameter or side length) for the thumb.
  final double? thumbSize,

  /// Border radius of the slider track.
  final BorderRadius? borderRadius,
});
