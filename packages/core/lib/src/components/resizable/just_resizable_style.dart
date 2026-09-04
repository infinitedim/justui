import 'package:flutter/widgets.dart';

import 'just_resizable_variants.dart';

/// Customized per-instance visual styles for [JustResizable].
class const JustResizableStyle({
  /// Custom thickness for the splitter divider line.
  final double? dividerThickness,

  /// Custom color for the splitter divider line in its normal state.
  final Color? dividerColor,

  /// Custom color for the splitter divider line when hovered or dragged.
  final Color? activeDividerColor,

  /// Custom hit box size for splitter touch and mouse interactions. Defaults to 8.0.
  final double? handleHitSize,

  /// Visual variant of the handle (line, grip, none).
  final JustResizableHandleVariant? handleVariant,

  /// Custom size for the centered grip pill.
  final Size? gripSize,

  /// Custom background color of the centered grip pill.
  final Color? gripColor,

  /// Custom active background color of the centered grip pill when hovered or dragged.
  final Color? activeGripColor,

  /// Custom border color of the centered grip pill.
  final Color? gripBorderColor,

  /// Custom active border color of the centered grip pill.
  final Color? activeGripBorderColor,

  /// Custom icon / dots color inside the grip pill.
  final Color? gripDotColor,

  /// Custom border radius for the centered grip pill.
  final BorderRadius? gripRadius,

  /// Custom double-tap action for splitters.
  final JustResizableDoubleTapBehavior? doubleTapBehavior,

  /// Distance in pixels adjusted per standard arrow keypress.
  final double? keyboardStep,

  /// Distance in pixels adjusted when Shift is held with arrow keypress.
  final double? keyboardShiftStep,
}) {
  /// Returns a copy with given fields replaced.
  JustResizableStyle copyWith({
    double? dividerThickness,
    Color? dividerColor,
    Color? activeDividerColor,
    double? handleHitSize,
    JustResizableHandleVariant? handleVariant,
    Size? gripSize,
    Color? gripColor,
    Color? activeGripColor,
    Color? gripBorderColor,
    Color? activeGripBorderColor,
    Color? gripDotColor,
    BorderRadius? gripRadius,
    JustResizableDoubleTapBehavior? doubleTapBehavior,
    double? keyboardStep,
    double? keyboardShiftStep,
  }) {
    return JustResizableStyle(
      dividerThickness: dividerThickness ?? this.dividerThickness,
      dividerColor: dividerColor ?? this.dividerColor,
      activeDividerColor: activeDividerColor ?? this.activeDividerColor,
      handleHitSize: handleHitSize ?? this.handleHitSize,
      handleVariant: handleVariant ?? this.handleVariant,
      gripSize: gripSize ?? this.gripSize,
      gripColor: gripColor ?? this.gripColor,
      activeGripColor: activeGripColor ?? this.activeGripColor,
      gripBorderColor: gripBorderColor ?? this.gripBorderColor,
      activeGripBorderColor:
          activeGripBorderColor ?? this.activeGripBorderColor,
      gripDotColor: gripDotColor ?? this.gripDotColor,
      gripRadius: gripRadius ?? this.gripRadius,
      doubleTapBehavior: doubleTapBehavior ?? this.doubleTapBehavior,
      keyboardStep: keyboardStep ?? this.keyboardStep,
      keyboardShiftStep: keyboardShiftStep ?? this.keyboardShiftStep,
    );
  }

  /// Linearly interpolates between two [JustResizableStyle] instances.
  static JustResizableStyle? lerp(
    JustResizableStyle? a,
    JustResizableStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;

    final double? lerpedThickness;
    if (a?.dividerThickness != null && b?.dividerThickness != null) {
      lerpedThickness =
          a!.dividerThickness! +
          (b!.dividerThickness! - a.dividerThickness!) * t;
    } else {
      lerpedThickness = t < 0.5 ? a?.dividerThickness : b?.dividerThickness;
    }

    final double? lerpedHitSize;
    if (a?.handleHitSize != null && b?.handleHitSize != null) {
      lerpedHitSize =
          a!.handleHitSize! + (b!.handleHitSize! - a.handleHitSize!) * t;
    } else {
      lerpedHitSize = t < 0.5 ? a?.handleHitSize : b?.handleHitSize;
    }

    final double? lerpedKeyStep;
    if (a?.keyboardStep != null && b?.keyboardStep != null) {
      lerpedKeyStep =
          a!.keyboardStep! + (b!.keyboardStep! - a.keyboardStep!) * t;
    } else {
      lerpedKeyStep = t < 0.5 ? a?.keyboardStep : b?.keyboardStep;
    }

    final double? lerpedKeyShiftStep;
    if (a?.keyboardShiftStep != null && b?.keyboardShiftStep != null) {
      lerpedKeyShiftStep =
          a!.keyboardShiftStep! +
          (b!.keyboardShiftStep! - a.keyboardShiftStep!) * t;
    } else {
      lerpedKeyShiftStep = t < 0.5
          ? a?.keyboardShiftStep
          : b?.keyboardShiftStep;
    }

    return JustResizableStyle(
      dividerThickness: lerpedThickness,
      dividerColor: .lerp(a?.dividerColor, b?.dividerColor, t),
      activeDividerColor: .lerp(
        a?.activeDividerColor,
        b?.activeDividerColor,
        t,
      ),
      handleHitSize: lerpedHitSize,
      handleVariant: t < 0.5 ? a?.handleVariant : b?.handleVariant,
      gripSize: .lerp(a?.gripSize, b?.gripSize, t),
      gripColor: .lerp(a?.gripColor, b?.gripColor, t),
      activeGripColor: .lerp(a?.activeGripColor, b?.activeGripColor, t),
      gripBorderColor: .lerp(a?.gripBorderColor, b?.gripBorderColor, t),
      activeGripBorderColor: .lerp(
        a?.activeGripBorderColor,
        b?.activeGripBorderColor,
        t,
      ),
      gripDotColor: .lerp(a?.gripDotColor, b?.gripDotColor, t),
      gripRadius: .lerp(a?.gripRadius, b?.gripRadius, t),
      doubleTapBehavior: t < 0.5 ? a?.doubleTapBehavior : b?.doubleTapBehavior,
      keyboardStep: lerpedKeyStep,
      keyboardShiftStep: lerpedKeyShiftStep,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustResizableStyle &&
          runtimeType == other.runtimeType &&
          dividerThickness == other.dividerThickness &&
          dividerColor == other.dividerColor &&
          activeDividerColor == other.activeDividerColor &&
          handleHitSize == other.handleHitSize &&
          handleVariant == other.handleVariant &&
          gripSize == other.gripSize &&
          gripColor == other.gripColor &&
          activeGripColor == other.activeGripColor &&
          gripBorderColor == other.gripBorderColor &&
          activeGripBorderColor == other.activeGripBorderColor &&
          gripDotColor == other.gripDotColor &&
          gripRadius == other.gripRadius &&
          doubleTapBehavior == other.doubleTapBehavior &&
          keyboardStep == other.keyboardStep &&
          keyboardShiftStep == other.keyboardShiftStep;

  @override
  int get hashCode => Object.hash(
    dividerThickness,
    dividerColor,
    activeDividerColor,
    handleHitSize,
    handleVariant,
    gripSize,
    gripColor,
    activeGripColor,
    gripBorderColor,
    activeGripBorderColor,
    gripDotColor,
    gripRadius,
    doubleTapBehavior,
    keyboardStep,
    keyboardShiftStep,
  );
}
