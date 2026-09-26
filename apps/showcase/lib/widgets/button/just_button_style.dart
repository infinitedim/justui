// justui-meta: registry=e9fe823ad5feae84397215b10e2ab5d4b31365520b371c5f295fd7f9b54694fc local=bb91de19e0d2c74f2ab6905bef224860d703432aec0fb8cd5e931d1b2dd70b7e
import 'package:flutter/widgets.dart';

import 'package:showcase/core/just_ui_core.dart';

import 'just_button_variants.dart';

/// Customized per-instance visual styles for [JustButton] and [JustIconButton].
class JustButtonStyle {
  /// Custom background color of the button.
  final Color? backgroundColor;

  /// Custom text or icon color of the button.
  final Color? foregroundColor;

  /// Custom border color of the button.
  final Color? borderColor;

  /// Custom border radius of the button.
  final BorderRadius? borderRadius;

  /// Custom inner padding of the button.
  final EdgeInsets? padding;

  /// Custom text style overrides.
  final TextStyle? textStyle;

  /// Custom elevation (shadow).
  final double? elevation;

  const JustButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.elevation,
  });

  /// Returns a copy with given fields replaced.
  JustButtonStyle copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    double? elevation,
  }) {
    return JustButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      elevation: elevation ?? this.elevation,
    );
  }

  /// Linearly interpolates between two [JustButtonStyle]s.
  static JustButtonStyle? lerp(
    JustButtonStyle? a,
    JustButtonStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    final double? lerpedElevation;
    if (a?.elevation != null && b?.elevation != null) {
      lerpedElevation = a!.elevation! + (b!.elevation! - a.elevation!) * t;
    } else {
      lerpedElevation = t < 0.5 ? a?.elevation : b?.elevation;
    }
    return JustButtonStyle(
      backgroundColor: .lerp(a?.backgroundColor, b?.backgroundColor, t),
      foregroundColor: .lerp(a?.foregroundColor, b?.foregroundColor, t),
      borderColor: .lerp(a?.borderColor, b?.borderColor, t),
      borderRadius: .lerp(a?.borderRadius, b?.borderRadius, t),
      padding: .lerp(a?.padding, b?.padding, t),
      textStyle: .lerp(a?.textStyle, b?.textStyle, t),
      elevation: lerpedElevation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustButtonStyle &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          foregroundColor == other.foregroundColor &&
          borderColor == other.borderColor &&
          borderRadius == other.borderRadius &&
          padding == other.padding &&
          textStyle == other.textStyle &&
          elevation == other.elevation;

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    foregroundColor,
    borderColor,
    borderRadius,
    padding,
    textStyle,
    elevation,
  );
}

/// Background, foreground and border colors of a button in one state.
typedef JustButtonColors = ({Color bg, Color text, Color border});

/// Resolves the background, foreground and border colors for a
/// [JustButton] or [JustIconButton] of [variant] in its current interaction
/// state. Pure function of its inputs, shared by both buttons.
JustButtonColors resolveJustButtonColors({
  required JustButtonVariant variant,
  required JustColorScheme colors,
  required JustPresetTokens presetTokens,
  required bool isInteractive,
  required bool isPressed,
  required bool isHovered,
}) {
  Color bg;
  Color text;
  Color border;

  // Fallback colors matching semantic rules
  final Color primaryBg = presetTokens.showsDefaultBorder
      ? colors.warning
      : colors.borderFocus;
  final Color primaryFg = presetTokens.showsDefaultBorder
      ? const Color(0xFF000000)
      : colors.textInverse;
  final Color errorBg = colors.error;

  switch (variant) {
    case .primary:
      bg = primaryBg;
      text = primaryFg;
      border = presetTokens.showsDefaultBorder
          ? colors.textPrimary
          : const Color(0x00000000);

      if (!isInteractive) {
        bg = bg.withValues(alpha: 0.5);
        text = text.withValues(alpha: 0.7);
      } else if (isPressed) {
        bg = bg.withValues(alpha: 0.8);
      } else if (isHovered) {
        bg = bg.withValues(alpha: 0.9);
      }
      break;

    case .secondary:
      bg = presetTokens.showsDefaultBorder
          ? colors.card
          : const Color(0x00000000);
      text = colors.textPrimary;
      border = presetTokens.showsDefaultBorder
          ? colors.textPrimary
          : colors.borderDefault;

      if (!isInteractive) {
        text = text.withValues(alpha: 0.4);
        border = border.withValues(alpha: 0.4);
      } else if (isPressed) {
        bg = presetTokens.showsDefaultBorder
            ? colors.card
            : primaryBg.withValues(alpha: 0.15);
        border = presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : primaryBg;
        text = presetTokens.showsDefaultBorder ? colors.textPrimary : primaryBg;
      } else if (isHovered) {
        bg = presetTokens.showsDefaultBorder
            ? colors.card
            : primaryBg.withValues(alpha: 0.08);
        border = presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : primaryBg;
        text = presetTokens.showsDefaultBorder ? colors.textPrimary : primaryBg;
      }
      break;

    case .ghost:
      bg = const Color(0x00000000);
      text = colors.textPrimary;
      border = const Color(0x00000000);

      if (!isInteractive) {
        text = text.withValues(alpha: 0.4);
      } else if (isPressed) {
        bg = colors.textPrimary.withValues(alpha: 0.15);
      } else if (isHovered) {
        bg = colors.textPrimary.withValues(alpha: 0.08);
      }
      break;

    case .destructive:
      bg = errorBg;
      text = presetTokens.showsDefaultBorder
          ? const Color(0xFF000000)
          : colors.textInverse;
      border = presetTokens.showsDefaultBorder
          ? colors.textPrimary
          : const Color(0x00000000);

      if (!isInteractive) {
        bg = bg.withValues(alpha: 0.5);
        text = text.withValues(alpha: 0.7);
      } else if (isPressed) {
        bg = bg.withValues(alpha: 0.8);
      } else if (isHovered) {
        bg = bg.withValues(alpha: 0.9);
      }
      break;

    case .link:
      bg = const Color(0x00000000);
      text = presetTokens.showsDefaultBorder
          ? ((colors.background.computeLuminance() < 0.5)
                ? colors.textPrimary
                : colors.info)
          : primaryBg;
      border = const Color(0x00000000);

      if (!isInteractive) {
        text = text.withValues(alpha: 0.4);
      } else if (isPressed) {
        text = text.withValues(alpha: 0.7);
      } else if (isHovered) {
        text = text.withValues(alpha: 0.8);
      }
      break;
  }

  return (bg: bg, text: text, border: border);
}
