import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for [JustToggle] and [JustToggleGroup].
class const JustToggleStyle({
  /// Custom background color of the toggle when selected.
  final Color? selectedBackgroundColor,

  /// Custom background color of the toggle when unselected.
  final Color? unselectedBackgroundColor,

  /// Custom border color of the toggle when selected.
  final Color? selectedBorderColor,

  /// Custom border color of the toggle when unselected.
  final Color? unselectedBorderColor,

  /// Custom text or icon color of the toggle when selected.
  final Color? selectedTextColor,

  /// Custom text or icon color of the toggle when unselected.
  final Color? unselectedTextColor,

  /// Custom border radius.
  final BorderRadius? borderRadius,

  /// Custom box shadow when selected. If null, follows preset defaults.
  final List<BoxShadow>? selectedShadows,

  /// Custom box shadow when unselected. If null, follows preset defaults.
  final List<BoxShadow>? unselectedShadows,
}) {
  /// Returns a copy with given fields replaced.
  JustToggleStyle copyWith({
    Color? selectedBackgroundColor,
    Color? unselectedBackgroundColor,
    Color? selectedBorderColor,
    Color? unselectedBorderColor,
    Color? selectedTextColor,
    Color? unselectedTextColor,
    BorderRadius? borderRadius,
    List<BoxShadow>? selectedShadows,
    List<BoxShadow>? unselectedShadows,
  }) {
    return JustToggleStyle(
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      unselectedBackgroundColor:
          unselectedBackgroundColor ?? this.unselectedBackgroundColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      unselectedBorderColor:
          unselectedBorderColor ?? this.unselectedBorderColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      unselectedTextColor: unselectedTextColor ?? this.unselectedTextColor,
      borderRadius: borderRadius ?? this.borderRadius,
      selectedShadows: selectedShadows ?? this.selectedShadows,
      unselectedShadows: unselectedShadows ?? this.unselectedShadows,
    );
  }

  /// Linearly interpolates between two [JustToggleStyle]s.
  static JustToggleStyle? lerp(
    JustToggleStyle? a,
    JustToggleStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return JustToggleStyle(
      selectedBackgroundColor: .lerp(
        a?.selectedBackgroundColor,
        b?.selectedBackgroundColor,
        t,
      ),
      unselectedBackgroundColor: .lerp(
        a?.unselectedBackgroundColor,
        b?.unselectedBackgroundColor,
        t,
      ),
      selectedBorderColor: .lerp(
        a?.selectedBorderColor,
        b?.selectedBorderColor,
        t,
      ),
      unselectedBorderColor: .lerp(
        a?.unselectedBorderColor,
        b?.unselectedBorderColor,
        t,
      ),
      selectedTextColor: .lerp(a?.selectedTextColor, b?.selectedTextColor, t),
      unselectedTextColor: .lerp(
        a?.unselectedTextColor,
        b?.unselectedTextColor,
        t,
      ),
      borderRadius: .lerp(a?.borderRadius, b?.borderRadius, t),
      selectedShadows: t < 0.5 ? a?.selectedShadows : b?.selectedShadows,
      unselectedShadows: t < 0.5 ? a?.unselectedShadows : b?.unselectedShadows,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustToggleStyle &&
          runtimeType == other.runtimeType &&
          selectedBackgroundColor == other.selectedBackgroundColor &&
          unselectedBackgroundColor == other.unselectedBackgroundColor &&
          selectedBorderColor == other.selectedBorderColor &&
          unselectedBorderColor == other.unselectedBorderColor &&
          selectedTextColor == other.selectedTextColor &&
          unselectedTextColor == other.unselectedTextColor &&
          borderRadius == other.borderRadius &&
          listEquals(selectedShadows, other.selectedShadows) &&
          listEquals(unselectedShadows, other.unselectedShadows);

  @override
  int get hashCode => Object.hash(
    selectedBackgroundColor,
    unselectedBackgroundColor,
    selectedBorderColor,
    unselectedBorderColor,
    selectedTextColor,
    unselectedTextColor,
    borderRadius,
    selectedShadows == null ? null : Object.hashAll(selectedShadows!),
    unselectedShadows == null ? null : Object.hashAll(unselectedShadows!),
  );
}
