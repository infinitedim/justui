import 'package:flutter/widgets.dart';

export '../../theme/preset_tokens.dart' show JustSliderSize;

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
