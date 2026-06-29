import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';
import '../../theme/theme_provider.dart';
import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import '../shared/_shared_progress_spinner.dart';
import 'just_button_style.dart';
import 'just_button_variants.dart';
import 'just_button_theme.dart';

/// An icon-only button component following JustUI tokens and strict accessibility rules.
class JustIconButton extends StatefulWidget {
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
  State<JustIconButton> createState() => _JustIconButtonState();
}

class _JustIconButtonState extends State<JustIconButton> {
  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context).theme;
    final buttonTheme = Theme.of(context).extension<JustButtonTheme>();
    JustButtonStyle? themeStyle;
    if (buttonTheme != null) {
      switch (widget.variant) {
        case .primary:
          themeStyle = buttonTheme.primaryStyle;
          break;
        case .secondary:
          themeStyle = buttonTheme.secondaryStyle;
          break;
        case .ghost:
          themeStyle = buttonTheme.ghostStyle;
          break;
        case .destructive:
          themeStyle = buttonTheme.destructiveStyle;
          break;
        case .link:
          themeStyle = buttonTheme.linkStyle;
          break;
      }
    }
    final finalEnableHaptic =
        widget.enableHaptic ??
        buttonTheme?.enableHaptic ??
        (customTheme.preset == .neobrutalism);

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final radius = customTheme.radius;
    final animations = customTheme.animations;

    final isInteractive =
        widget.onPressed != null && !widget.isDisabled && !widget.isLoading;

    // Resolve dimension (width = height) based on size
    double sizeDimension;
    double iconSize;
    BorderRadius defaultRadius;

    switch (widget.size) {
      case .xs:
        sizeDimension = 28.0;
        iconSize = 14.0;
        defaultRadius = .all(radius.sm);
        break;
      case .sm:
        sizeDimension = 32.0;
        iconSize = 16.0;
        defaultRadius = .all(radius.md);
        break;
      case .md:
        sizeDimension = 40.0;
        iconSize = 18.0;
        defaultRadius = .all(radius.md);
        break;
      case .lg:
        sizeDimension = 48.0;
        iconSize = 20.0;
        defaultRadius = .all(radius.md);
        break;
      case .xl:
        sizeDimension = 56.0;
        iconSize = 22.0;
        defaultRadius = .all(radius.lg);
        break;
    }

    final bool needsMinTargetSize = sizeDimension < 48.0;

    return Semantics(
      button: true,
      label: widget.tooltip,
      hint: widget.isLoading ? 'Loading' : null,
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
            onTap: widget.onPressed == null
                ? null
                : () {
                    if (finalEnableHaptic) {
                      HapticFeedback.lightImpact();
                    }
                    widget.onPressed?.call();
                  },
            builder: (context, isHovered, isPressed, isFocused, focusNode) {
              final isNeobrutalism = customTheme.preset == .neobrutalism;
              Color bg;
              Color text;
              Color border;

              final primaryBg = colors.borderFocus;
              final primaryFg = colors.textInverse;
              final errorBg = colors.error;

              switch (widget.variant) {
                case .primary:
                  bg = primaryBg;
                  text = primaryFg;
                  border = isNeobrutalism
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
                  bg = const Color(0x00000000);
                  text = colors.textPrimary;
                  border = isNeobrutalism
                      ? colors.textPrimary
                      : colors.borderDefault;

                  if (!isInteractive) {
                    text = text.withValues(alpha: 0.4);
                    border = border.withValues(alpha: 0.4);
                  } else if (isPressed) {
                    bg = primaryBg.withValues(alpha: 0.15);
                    border = isNeobrutalism ? colors.textPrimary : primaryBg;
                    text = primaryBg;
                  } else if (isHovered) {
                    bg = primaryBg.withValues(alpha: 0.08);
                    border = isNeobrutalism ? colors.textPrimary : primaryBg;
                    text = primaryBg;
                  }
                  break;

                case .ghost:
                  bg = const Color(0x00000000);
                  text = colors.textPrimary;
                  border = isNeobrutalism
                      ? colors.textPrimary
                      : const Color(0x00000000);

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
                  text = primaryFg;
                  border = isNeobrutalism
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
                  text = primaryBg;
                  border = const Color(0x00000000);

                  if (!isInteractive) {
                    text = text.withValues(alpha: 0.4);
                  } else if (isPressed) {
                    text = primaryBg.withValues(alpha: 0.7);
                  } else if (isHovered) {
                    text = primaryBg.withValues(alpha: 0.8);
                  }
                  break;
              }

              final finalBg =
                  widget.style?.backgroundColor ??
                  themeStyle?.backgroundColor ??
                  bg;
              final finalFg =
                  widget.style?.foregroundColor ??
                  themeStyle?.foregroundColor ??
                  text;
              final finalBorder =
                  widget.style?.borderColor ??
                  themeStyle?.borderColor ??
                  border;
              final resolvedRadius =
                  widget.style?.borderRadius ??
                  themeStyle?.borderRadius ??
                  defaultRadius;

              Widget content;
              if (widget.isLoading) {
                content = JustProgressSpinner(size: iconSize, color: finalFg);
              } else {
                content = IconTheme.merge(
                  data: IconThemeData(size: iconSize, color: finalFg),
                  child: widget.icon,
                );
              }

              final double scale = isPressed ? 0.97 : 1.0;

              // Shadows resolution (flat solid offset shadow for neobrutalism)
              List<BoxShadow> defaultShadows;
              if (isNeobrutalism && widget.variant != JustButtonVariant.link) {
                defaultShadows = widget.size == JustButtonSize.xs
                    ? customTheme.shadows.xs
                    : customTheme.shadows.sm;
              } else {
                defaultShadows = const [];
              }

              final double? styleElevation =
                  widget.style?.elevation ?? themeStyle?.elevation;
              List<BoxShadow> resolvedShadows;
              if (styleElevation != null) {
                resolvedShadows = styleElevation > 0.0
                    ? (styleElevation <= 1.5
                          ? customTheme.shadows.xs
                          : customTheme.shadows.sm)
                    : const [];
              } else {
                resolvedShadows = defaultShadows;
              }

              resolvedShadows = customTheme.resolveShadows(
                resolvedShadows,
                isPressed: isPressed,
              );

              final double finalBorderWidth =
                  isNeobrutalism && widget.variant != JustButtonVariant.link
                  ? 2.5
                  : (finalBorder != const Color(0x00000000) ? 1.0 : 0.0);

              return customTheme.buildPressEffect(
                isPressed: isPressed,
                scaleFactor: scale,
                child: AnimatedContainer(
                  duration: isNeobrutalism
                      ? customTheme.animations.instant
                      : customTheme.animations.fast,
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
                    isFocused: isFocused,
                    focusColor: primaryBg,
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
