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
