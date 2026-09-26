// justui-meta: registry=d40a11d74e8db83c3f8449732ab203157803409cc31e1c7b3fd6714c31155bc3 local=3a5a73b8fc1bfb7097b687b27a084cc7d45a954903a84d2749137a91ab2013a0
import 'package:flutter/material.dart' show ThemeExtension;

import 'just_resizable_style.dart';
import 'just_resizable_variants.dart';

/// Alias for [JustResizableTheme] for convention parity.
typedef JustResizableThemeData = JustResizableTheme;

/// Global theme configuration for resizable panel layouts, extending Flutter's [ThemeExtension].
class JustResizableTheme extends ThemeExtension<JustResizableTheme> {
  /// Global base style override for resizable panels.
  final JustResizableStyle? style;

  /// Default divider line thickness. Defaults to 1.0.
  final double dividerThickness;

  /// Default hit target area size for splitters. Defaults to 8.0.
  final double handleHitSize;

  /// Default visual variant for handles. Defaults to [JustResizableHandleVariant.line].
  final JustResizableHandleVariant handleVariant;

  /// Default action when double-tapping a splitter. Defaults to [JustResizableDoubleTapBehavior.toggle].
  final JustResizableDoubleTapBehavior doubleTapBehavior;

  /// Distance in pixels adjusted per standard arrow keypress. Defaults to 16.0.
  final double keyboardStep;

  /// Distance in pixels adjusted when Shift is held with arrow keypress. Defaults to 4.0.
  final double keyboardShiftStep;

  const JustResizableTheme({
    this.style,
    this.dividerThickness = 1.0,
    this.handleHitSize = 8.0,
    this.handleVariant = .line,
    this.doubleTapBehavior = .toggle,
    this.keyboardStep = 16.0,
    this.keyboardShiftStep = 4.0,
  });

  /// Default configuration for the theme.
  static const JustResizableTheme defaults = JustResizableTheme();

  @override
  JustResizableTheme copyWith({
    JustResizableStyle? style,
    double? dividerThickness,
    double? handleHitSize,
    JustResizableHandleVariant? handleVariant,
    JustResizableDoubleTapBehavior? doubleTapBehavior,
    double? keyboardStep,
    double? keyboardShiftStep,
  }) {
    return JustResizableTheme(
      style: style ?? this.style,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      handleHitSize: handleHitSize ?? this.handleHitSize,
      handleVariant: handleVariant ?? this.handleVariant,
      doubleTapBehavior: doubleTapBehavior ?? this.doubleTapBehavior,
      keyboardStep: keyboardStep ?? this.keyboardStep,
      keyboardShiftStep: keyboardShiftStep ?? this.keyboardShiftStep,
    );
  }

  @override
  JustResizableTheme lerp(ThemeExtension<JustResizableTheme>? other, double t) {
    if (other is! JustResizableTheme) return this;
    final double lerpedThickness =
        dividerThickness + (other.dividerThickness - dividerThickness) * t;
    final double lerpedHitSize =
        handleHitSize + (other.handleHitSize - handleHitSize) * t;
    final double lerpedKeyStep =
        keyboardStep + (other.keyboardStep - keyboardStep) * t;
    final double lerpedKeyShiftStep =
        keyboardShiftStep + (other.keyboardShiftStep - keyboardShiftStep) * t;

    return JustResizableTheme(
      style: .lerp(style, other.style, t),
      dividerThickness: lerpedThickness,
      handleHitSize: lerpedHitSize,
      handleVariant: t < 0.5 ? handleVariant : other.handleVariant,
      doubleTapBehavior: t < 0.5 ? doubleTapBehavior : other.doubleTapBehavior,
      keyboardStep: lerpedKeyStep,
      keyboardShiftStep: lerpedKeyShiftStep,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustResizableTheme &&
          runtimeType == other.runtimeType &&
          style == other.style &&
          dividerThickness == other.dividerThickness &&
          handleHitSize == other.handleHitSize &&
          handleVariant == other.handleVariant &&
          doubleTapBehavior == other.doubleTapBehavior &&
          keyboardStep == other.keyboardStep &&
          keyboardShiftStep == other.keyboardShiftStep;

  @override
  int get hashCode => Object.hash(
    style,
    dividerThickness,
    handleHitSize,
    handleVariant,
    doubleTapBehavior,
    keyboardStep,
    keyboardShiftStep,
  );
}
