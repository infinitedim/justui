// justui-meta: registry=3b5a31beb11e71c15d2b06ad26403bf938653ca29b15aac1726999fbff28220e local=c5ec9b5cb4185fc8ceae5aad3162f5f7d35daa23fc3cfcd2b2773a67c958246a
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a dialog.
class JustDialogStyle {
  /// Custom background color of the dialog surface.
  final Color? backgroundColor;

  /// Custom background color of the backdrop/barrier.
  final Color? barrierColor;

  /// Custom border color of the dialog surface.
  final Color? borderColor;

  /// Custom border width of the dialog surface.
  final double? borderWidth;

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

  const JustDialogStyle({
    this.backgroundColor,
    this.barrierColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.maxWidth,
    this.maxHeight,
    this.shadows,
  });
}
