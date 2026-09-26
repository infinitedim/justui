// justui-meta: registry=471ce7a3e7427248fe1f19738933432cd3c62bface458a46e7ddd3f588a027a5 local=8b65fe6a85a0e94fb8f5a702ad2f1ea706437488953cbb8133fb8f32404a5b11
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

  const JustSwitchStyle({
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.textStyle,
  });

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
      activeTrackColor: .lerp(a?.activeTrackColor, b?.activeTrackColor, t),
      inactiveTrackColor: .lerp(
        a?.inactiveTrackColor,
        b?.inactiveTrackColor,
        t,
      ),
      activeThumbColor: .lerp(a?.activeThumbColor, b?.activeThumbColor, t),
      inactiveThumbColor: .lerp(
        a?.inactiveThumbColor,
        b?.inactiveThumbColor,
        t,
      ),
      textStyle: .lerp(a?.textStyle, b?.textStyle, t),
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
