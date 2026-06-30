// justui-meta: registry=63619e4d947f55eba60a33dea53c33349eac77fb2bc972d1022dadbbc9ba990e local=63619e4d947f55eba60a33dea53c33349eac77fb2bc972d1022dadbbc9ba990e
import 'package:flutter/widgets.dart';

/// The physical size classification for [JustSwitch].
enum JustSwitchSize {
  /// Small size (32x18 track)
  sm,

  /// Medium size (40x22 track)
  md,

  /// Large size (48x26 track)
  lg,
}

/// Customized per-instance visual styles for [JustSwitch].
class JustSwitchStyle {
  /// The track color when the switch is active (ON).
  final Color? activeTrackColor;

  /// The track color when the switch is inactive (OFF).
  final Color? inactiveTrackColor;

  /// The thumb color when the switch is active (ON).
  final Color? activeThumbColor;

  /// The thumb color when the switch is inactive (OFF).
  final Color? inactiveThumbColor;

  /// Text style of the switch label.
  final TextStyle? textStyle;

  /// Creates a [JustSwitchStyle] override.
  const JustSwitchStyle({
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.textStyle,
  });
}
