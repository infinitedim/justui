// justui-meta: registry=57856af3fbf6ef20cdd3c4c470dc793f843d4fa00ea62abb941cb83c15ffcc1d local=d62b514915d1feef40c9243dd63af012e634cd09e095fca8f33c0dfb3c6b327a
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';
import 'package:showcase/core/just_ui_core.dart';

import '../shared/just_focus_indicator.dart';
import '../shared/just_pressable.dart';
import '../shared/just_progress_spinner.dart';
import 'just_button_style.dart';
import 'just_button_variants.dart';
import 'just_button_theme.dart';

/// An icon-only button component following JustUI tokens and strict accessibility rules.
class JustIconButton extends StatelessWidget {
  /// The icon widget to display inside the button.
  final Widget icon;

  /// Callback executed when the button is tapped. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// The visual style variant. Defaults to [.ghost].
  final JustButtonVariant variant;

  /// The physical size classification.
  final JustButtonSize size;

  /// An accessibility label/tooltip description. Mandatory in debug mode.
  final String? tooltip;

  /// Whether the button is currently in a loading state.
  final bool isLoading;

  /// Whether the button is explicitly disabled.
  final bool isDisabled;

  /// Per-instance style overrides.
  final JustButtonStyle? style;

  /// Whether to enable haptic feedback on button presses.
  /// If null, falls back to the theme setting.
  final bool? enableHaptic;

  /// Creates a [JustIconButton].
  const JustIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = .ghost,
    this.size = .md,
    required this.tooltip,
    this.isLoading = false,
    this.isDisabled = false,
    this.style,
    this.enableHaptic,
  }) : assert(
         tooltip != null,
         'A tooltip must be provided for JustIconButton for accessibility.',
       );

  @override
  Widget build(BuildContext context) {
    final JustPresetTokens presetTokens = context.justPresetTokens;
    final JustButtonTheme? buttonTheme = Theme.of(context)
        .extension<JustButtonTheme>();
    final JustButtonStyle? themeStyle = buttonTheme?.styleFor(variant);
    final bool finalEnableHaptic =
        enableHaptic ??
        buttonTheme?.enableHaptic ??
        presetTokens.selectionHapticDefault;

    final JustColorScheme colors = context.justColors;
    final JustRadiusScheme radius = context.justRadius;
    final JustShadowScheme shadows = context.justShadows;
    final JustMotionProfile animations = context.justAnimations;

    final bool isInteractive = onPressed != null && !isDisabled && !isLoading;

    // Square button: width == height == sizeDimension.
    final (
      double sizeDimension,
      double iconSize,
      Radius cornerRadius,
    ) = switch (size) {
      .xs => (28.0, 14.0, radius.sm),
      .sm => (32.0, 16.0, radius.md),
      .md => (40.0, 18.0, radius.md),
      .lg => (48.0, 20.0, radius.md),
      .xl => (56.0, 22.0, radius.lg),
    };
    final BorderRadius defaultRadius = .all(cornerRadius);

    final bool needsMinTargetSize = sizeDimension < 48.0;

    return Semantics(
      button: true,
      label: tooltip,
      hint: isLoading ? 'Loading' : null,
      enabled: isInteractive,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: needsMinTargetSize ? 48.0 : sizeDimension,
          minWidth: needsMinTargetSize ? 48.0 : sizeDimension,
        ),
        child: Center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: JustPressable(
            enabled: isInteractive,
            onTap: onPressed == null
                ? null
                : () {
                    if (finalEnableHaptic) {
                      HapticFeedback.lightImpact();
                    }
                    onPressed?.call();
                  },
            builder: (BuildContext context, JustInteractionState state) {
              final bool isHovered = state.isHovered;
              final bool isPressed = state.isPressed;
              final JustButtonColors resolved = resolveJustButtonColors(
                variant: variant,
                colors: colors,
                presetTokens: presetTokens,
                isInteractive: isInteractive,
                isPressed: isPressed,
                isHovered: isHovered,
              );
              final Color bg = resolved.bg;
              final Color text = resolved.text;
              final Color border = resolved.border;

              final Color finalBg =
                  style?.backgroundColor ?? themeStyle?.backgroundColor ?? bg;
              final Color finalFg =
                  style?.foregroundColor ?? themeStyle?.foregroundColor ?? text;
              final Color finalBorder =
                  style?.borderColor ?? themeStyle?.borderColor ?? border;
              final BorderRadius resolvedRadius =
                  style?.borderRadius ??
                  themeStyle?.borderRadius ??
                  defaultRadius;

              Widget content;
              if (isLoading) {
                content = JustProgressSpinner(
                  size: iconSize,
                  color: finalFg,
                  excludeSemantics: true,
                );
              } else {
                content = IconTheme.merge(
                  data: IconThemeData(size: iconSize, color: finalFg),
                  child: icon,
                );
              }

              final double scale = isPressed ? 0.97 : 1.0;

              // Shadows resolution (flat solid offset shadow for neobrutalism)
              final JustShadowLevel shadowLevel = size == JustButtonSize.xs
                  ? JustShadowLevel.xs
                  : JustShadowLevel.sm;

              final double? styleElevation =
                  style?.elevation ?? themeStyle?.elevation;
              final JustShadowLevel level = styleElevation != null
                  ? (styleElevation <= 1.5
                        ? JustShadowLevel.xs
                        : JustShadowLevel.sm)
                  : shadowLevel;

              final bool hasShadow = styleElevation != null
                  ? styleElevation > 0.0
                  : (presetTokens.showsDefaultBorder &&
                        variant != JustButtonVariant.link &&
                        variant != JustButtonVariant.ghost);

              final List<BoxShadow> resolvedShadows;
              final Offset? pressOffset;
              if (hasShadow) {
                resolvedShadows = presetTokens.resolveShadow(
                  shadows,
                  level,
                  isPressed: isPressed,
                );
                final List<BoxShadow> unpressed = presetTokens.resolveShadow(
                  shadows,
                  level,
                  isPressed: false,
                );
                pressOffset = unpressed.isNotEmpty
                    ? unpressed.first.offset
                    : null;
              } else {
                resolvedShadows = const <BoxShadow>[];
                pressOffset = null;
              }

              final double finalBorderWidth =
                  presetTokens.showsDefaultBorder &&
                      variant != JustButtonVariant.link
                  ? presetTokens.borderWidth
                  : (finalBorder != const Color(0x00000000) ? 1.0 : 0.0);

              return presetTokens.buildPressEffect(
                isPressed: isPressed,
                animations: animations,
                customOffset: pressOffset,
                customScale: scale,
                child: AnimatedContainer(
                  duration: presetTokens.showsDefaultBorder
                      ? animations.instant
                      : animations.fast,
                  curve: animations.defaultCurve,
                  width: sizeDimension,
                  height: sizeDimension,
                  decoration: BoxDecoration(
                    color: finalBg,
                    borderRadius: resolvedRadius,
                    border:
                        finalBorder != const Color(0x00000000) &&
                            finalBorderWidth > 0.0
                        ? .all(color: finalBorder, width: finalBorderWidth)
                        : null,
                    boxShadow: resolvedShadows.isNotEmpty
                        ? resolvedShadows
                        : null,
                  ),
                  child: FocusIndicator(
                    isFocused: state.isFocusVisible,
                    borderRadius: resolvedRadius,
                    child: Center(child: content),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
