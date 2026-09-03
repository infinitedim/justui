import 'package:flutter/material.dart' show ThemeExtension;

import 'just_resizable_style.dart';
import 'just_resizable_variants.dart';

/// Alias for [JustResizableTheme] for convention parity.
typedef JustResizableThemeData = JustResizableTheme;

/// Global theme configuration for resizable panel layouts, extending Flutter's [ThemeExtension].
class const JustResizableTheme({
  /// Global base style override for resizable panels.
  final JustResizableStyle? style,

  /// Default divider line thickness. Defaults to 1.0.
  final double dividerThickness = 1.0,

  /// Default hit target area size for splitters. Defaults to 8.0.
  final double handleHitSize = 8.0,

  /// Default visual variant for handles. Defaults to [JustResizableHandleVariant.line].
  final JustResizableHandleVariant handleVariant = .line,
}) extends ThemeExtension<JustResizableTheme> {
  /// Default configuration for the theme.
  static const defaults = JustResizableTheme();

  @override
  JustResizableTheme copyWith({
    JustResizableStyle? style,
    double? dividerThickness,
    double? handleHitSize,
    JustResizableHandleVariant? handleVariant,
  }) {
    return JustResizableTheme(
      style: style ?? this.style,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      handleHitSize: handleHitSize ?? this.handleHitSize,
      handleVariant: handleVariant ?? this.handleVariant,
    );
  }

  @override
  JustResizableTheme lerp(ThemeExtension<JustResizableTheme>? other, double t) {
    if (other is! JustResizableTheme) return this;
    final lerpedThickness =
        dividerThickness + (other.dividerThickness - dividerThickness) * t;
    final lerpedHitSize =
        handleHitSize + (other.handleHitSize - handleHitSize) * t;

    return JustResizableTheme(
      style: JustResizableStyle.lerp(style, other.style, t),
      dividerThickness: lerpedThickness,
      handleHitSize: lerpedHitSize,
      handleVariant: t < 0.5 ? handleVariant : other.handleVariant,
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
          handleVariant == other.handleVariant;

  @override
  int get hashCode => Object.hash(
    style,
    dividerThickness,
    handleHitSize,
    handleVariant,
  );
}
