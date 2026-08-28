import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for time picker components.
class const JustTimePickerStyle({
  /// Background color of the time picker container.
  final Color? backgroundColor,

  /// Background color of the clock dial face.
  final Color? dialFaceColor,

  /// Color of the clock hand, center pin, and selection indicator.
  final Color? handColor,

  /// Color of the unselected hour/minute numbers on the dial.
  final Color? dialTextColor,

  /// Color of the selected hour/minute number text (on the thumb bubble).
  final Color? selectedTextColor,

  /// Color of the AM/PM toggle active state background.
  final Color? periodActiveColor,

  /// Container outer border color.
  final Color? borderColor,

  /// Container border radius override.
  final BorderRadius? borderRadius,

  /// Inner padding override.
  final EdgeInsets? padding,

  /// Clock dial diameter override (default resolved from presetTokens).
  final double? dialSize,

  /// Spinner row height override (default resolved from presetTokens).
  final double? spinnerRowHeight,

  /// Shadow elevation override.
  final double? elevation,
});
