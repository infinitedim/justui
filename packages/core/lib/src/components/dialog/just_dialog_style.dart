import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a dialog.
class JustDialogStyle {
  /// Custom background color of the dialog surface.
  final Color? backgroundColor;

  /// Custom background color of the backdrop/barrier.
  final Color? barrierColor;

  /// Custom border radius of the dialog surface.
  final BorderRadius? borderRadius;

  /// Custom inner padding of the dialog surface.
  final EdgeInsets? padding;

  /// Custom maximum width constraint.
  final double? maxWidth;

  /// Custom maximum height constraint.
  final double? maxHeight;

  /// Custom shadows/elevation.
  final List<BoxShadow>? shadows;

  /// Creates a [JustDialogStyle] override.
  const JustDialogStyle({
    this.backgroundColor,
    this.barrierColor,
    this.borderRadius,
    this.padding,
    this.maxWidth,
    this.maxHeight,
    this.shadows,
  });
}
