import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a sheet.
class const JustSheetStyle({
  /// Custom background color of the sheet surface.
  final Color? backgroundColor,

  /// Custom background color of the backdrop/barrier.
  final Color? barrierColor,

  /// Custom color of the drag handle bar (if visible).
  final Color? handleColor,

  /// Custom border radius of the sheet surface.
  final BorderRadius? borderRadius,

  /// Custom inner padding of the sheet surface.
  final EdgeInsets? padding,

  /// Custom shadows/elevation.
  final List<BoxShadow>? shadows,
});
