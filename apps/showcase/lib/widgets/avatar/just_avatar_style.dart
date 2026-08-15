// justui-meta: registry=fdf9159cb5d738d1b3b511f7bcca9314f764738beb458a9c8071872151592dbd local=fdf9159cb5d738d1b3b511f7bcca9314f764738beb458a9c8071872151592dbd
import 'package:flutter/widgets.dart';

/// Customized per-instance overrides for [JustAvatar] styling.
class JustAvatarStyle {
  /// Custom background color of the avatar placeholder/initials box.
  final Color? backgroundColor;

  /// Custom text or icon color of the avatar initials/fallback icon.
  final Color? foregroundColor;

  /// Custom border color of the avatar outline.
  final Color? borderColor;

  /// Custom border width of the avatar outline.
  final double? borderWidth;

  /// Creates a [JustAvatarStyle] override.
  const JustAvatarStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
  });
}
