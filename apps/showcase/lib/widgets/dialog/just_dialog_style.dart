// justui-meta: registry=7cf69d86827bf7ac2a2141bf68461b71cfd12bff3409ee05ac3a2532dceee9ee local=de33deb9628249cfa79c5ad28dfaf92ba52616f46c650c3c863ff41ec3046306
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
