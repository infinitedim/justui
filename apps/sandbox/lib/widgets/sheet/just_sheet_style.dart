// justui-meta: registry=a0ff6c6ba2ca0a75f9bbe6bc871036a25a19a257b12e84309f26500aad27b1f3 local=ad285371832ccca176066c5b9e00f0a11d22cc043ffe7da5bff164ab5025a89d
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for a sheet.
class JustSheetStyle {
  /// Custom background color of the sheet surface.
  final Color? backgroundColor;

  /// Custom background color of the backdrop/barrier.
  final Color? barrierColor;

  /// Custom color of the drag handle bar (if visible).
  final Color? handleColor;

  /// Custom border color of the sheet surface.
  final Color? borderColor;

  /// Custom border width of the sheet surface.
  final double? borderWidth;

  /// Custom border radius of the sheet surface.
  final BorderRadius? borderRadius;

  /// Custom inner padding of the sheet surface.
  final EdgeInsets? padding;

  /// Custom shadows/elevation.
  final List<BoxShadow>? shadows;

  const JustSheetStyle({
    this.backgroundColor,
    this.barrierColor,
    this.handleColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.shadows,
  });
}
