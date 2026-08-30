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
class const JustSwitchStyle({
  /// The track color when the switch is active (ON).
  final Color? activeTrackColor,

  /// The track color when the switch is inactive (OFF).
  final Color? inactiveTrackColor,

  /// The thumb color when the switch is active (ON).
  final Color? activeThumbColor,

  /// The thumb color when the switch is inactive (OFF).
  final Color? inactiveThumbColor,

  /// Text style of the switch label.
  final TextStyle? textStyle,
}) {
  /// Returns a copy with given fields replaced.
  JustSwitchStyle copyWith({
    Color? activeTrackColor,
    Color? inactiveTrackColor,
    Color? activeThumbColor,
    Color? inactiveThumbColor,
    TextStyle? textStyle,
  }) {
    return JustSwitchStyle(
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      inactiveTrackColor: inactiveTrackColor ?? this.inactiveTrackColor,
      activeThumbColor: activeThumbColor ?? this.activeThumbColor,
      inactiveThumbColor: inactiveThumbColor ?? this.inactiveThumbColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Linearly interpolates between two [JustSwitchStyle]s.
  static JustSwitchStyle? lerp(
    JustSwitchStyle? a,
    JustSwitchStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return JustSwitchStyle(
      activeTrackColor: Color.lerp(a?.activeTrackColor, b?.activeTrackColor, t),
      inactiveTrackColor: Color.lerp(
        a?.inactiveTrackColor,
        b?.inactiveTrackColor,
        t,
      ),
      activeThumbColor: Color.lerp(a?.activeThumbColor, b?.activeThumbColor, t),
      inactiveThumbColor: Color.lerp(
        a?.inactiveThumbColor,
        b?.inactiveThumbColor,
        t,
      ),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustSwitchStyle &&
          runtimeType == other.runtimeType &&
          activeTrackColor == other.activeTrackColor &&
          inactiveTrackColor == other.inactiveTrackColor &&
          activeThumbColor == other.activeThumbColor &&
          inactiveThumbColor == other.inactiveThumbColor &&
          textStyle == other.textStyle;

  @override
  int get hashCode => Object.hash(
    activeTrackColor,
    inactiveTrackColor,
    activeThumbColor,
    inactiveThumbColor,
    textStyle,
  );
}
