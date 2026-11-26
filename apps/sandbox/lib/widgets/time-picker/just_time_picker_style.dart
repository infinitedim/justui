// justui-meta: registry=93c2ad3f2133cf88c143af6a337519227fd66494f878e2447634597377b8da12 local=322fa898df9ae8d69a7cdf9fc25d35f6f2ed8f02b6ba098dd68edb1c9d3724d6
import 'package:flutter/widgets.dart';

/// Customized per-instance visual styles for time picker components.
class JustTimePickerStyle {
  /// Background color of the time picker container.
  final Color? backgroundColor;

  /// Background color of the clock dial face.
  final Color? dialFaceColor;

  /// Color of the clock hand, center pin, and selection indicator.
  final Color? handColor;

  /// Color of the unselected hour/minute numbers on the dial.
  final Color? dialTextColor;

  /// Color of the selected hour/minute number text (on the thumb bubble).
  final Color? selectedTextColor;

  /// Color of the AM/PM toggle active state background.
  final Color? periodActiveColor;

  /// Container outer border color.
  final Color? borderColor;

  /// Container border radius override.
  final BorderRadius? borderRadius;

  /// Inner padding override.
  final EdgeInsets? padding;

  /// Clock dial diameter override (default resolved from presetTokens).
  final double? dialSize;

  /// Spinner row height override (default resolved from presetTokens).
  final double? spinnerRowHeight;

  /// Opacity applied to spinner wheel items above and below the center row.
  final double? overAndUnderCenterOpacity;

  /// Shadow elevation override.
  final double? elevation;

  const JustTimePickerStyle({
    this.backgroundColor,
    this.dialFaceColor,
    this.handColor,
    this.dialTextColor,
    this.selectedTextColor,
    this.periodActiveColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.dialSize,
    this.spinnerRowHeight,
    this.overAndUnderCenterOpacity,
    this.elevation,
  });
}
