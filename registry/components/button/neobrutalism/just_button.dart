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

/// An InheritedWidget to pass group information to individual buttons.
class JustButtonGroupInfo extends InheritedWidget {
  /// The index of the button in the group.
  final int index;

  /// The total count of buttons in the group.
  final int totalCount;

  /// The layout direction of the group.
  final Axis direction;

  /// Creates a [JustButtonGroupInfo] context.
  const JustButtonGroupInfo({
    super.key,
    required this.index,
    required this.totalCount,
    required this.direction,
    required super.child,
  });

  /// Retrieves group info from the current context.
  static JustButtonGroupInfo? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<JustButtonGroupInfo>();
  }

  @override
  bool updateShouldNotify(JustButtonGroupInfo oldWidget) {
    return index != oldWidget.index ||
        totalCount != oldWidget.totalCount ||
        direction != oldWidget.direction;
  }
}

/// A highly customizable, accessible button component that adheres to JustUI design tokens.
class JustButton extends StatefulWidget {
  /// The text label displayed inside the button.
  final String label;

  /// Callback executed when the button is tapped. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// The visual style variant.
  final JustButtonVariant variant;

  /// The physical size classification.
  final JustButtonSize size;

  /// An optional widget (such as an icon) displayed before the label.
  final Widget? leading;

  /// An optional widget (such as an icon) displayed after the label.
  final Widget? trailing;

  /// Whether the button is currently in a loading state.
  final bool isLoading;

  /// Whether the button is explicitly disabled.
  final bool isDisabled;

  /// Whether the button should stretch to fill the horizontal width of its parent.
  final bool isFullWidth;

  /// Per-instance style overrides.
  final JustButtonStyle? style;

  /// Whether to enable haptic feedback on button presses.
  /// If null, falls back to the theme setting.
  final bool? enableHaptic;

  /// Default constructor for [JustButton].
  const JustButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = .primary,
    this.size = .md,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.style,
    this.enableHaptic,
  });

  /// Named constructor for primary solid buttons.
  const JustButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = .md,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.style,
    this.enableHaptic,
  }) : variant = .primary;

  /// Named constructor for secondary outline buttons.
  const JustButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = .md,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.style,
    this.enableHaptic,
  }) : variant = .secondary;

  /// Named constructor for ghost transparent buttons.
  const JustButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = .md,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.style,
    this.enableHaptic,
  }) : variant = .ghost;

  /// Named constructor for destructive solid buttons.
  const JustButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = .md,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.style,
    this.enableHaptic,
  }) : variant = .destructive;

  /// Named constructor for link buttons.
  const JustButton.link({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = .md,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.style,
    this.enableHaptic,
  }) : variant = .link;

  @override
  State<JustButton> createState() => _JustButtonState();
}

class _JustButtonState extends State<JustButton> {
  @override
  Widget build(BuildContext context) {
    // Attempt to read from Flutter Theme Extension
    // Using context.justTheme which resolves InheritedModel aspects properly
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
        widget.enableHaptic ?? buttonTheme?.enableHaptic ?? (true);

    // We register dependency to colors aspect
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final radius = customTheme.radius;
    final animations = customTheme.animations;

    final isInteractive =
        widget.onPressed != null && !widget.isDisabled && !widget.isLoading;

    // Determine dimensions & paddings based on size
    double height;
    double paddingH;
    TextStyle textStyle;
    double iconSize;
    BorderRadius defaultRadius;

    switch (widget.size) {
      case .xs:
        height = 28.0;
        paddingH = spacing.sm; // 8px
        textStyle = typography.caption.copyWith(fontWeight: .w500);
        iconSize = 14.0;
        defaultRadius = .all(radius.sm);
        break;
      case .sm:
        height = 32.0;
        paddingH = spacing.md; // 12px
        textStyle = typography.bodySm.copyWith(fontWeight: .w500);
        iconSize = 16.0;
        defaultRadius = .all(radius.md);
        break;
      case .md:
        height = 40.0;
        paddingH = spacing.lg; // 16px
        textStyle = typography.bodyMd.copyWith(fontWeight: .w500);
        iconSize = 18.0;
        defaultRadius = .all(radius.md);
        break;
      case .lg:
        height = 48.0;
        paddingH = spacing.xl; // 20px
        textStyle = typography.bodyLg.copyWith(fontWeight: .w500);
        iconSize = 20.0;
        defaultRadius = .all(radius.md);
        break;
      case .xl:
        height = 56.0;
        paddingH = spacing.xxl; // 24px
        textStyle = typography.headingSm.copyWith(fontWeight: .w500);
        iconSize = 22.0;
        defaultRadius = .all(radius.lg);
        break;
    }

    // Apply button group attached adjustments if in a group
    final groupInfo = JustButtonGroupInfo.of(context);
    BorderRadius resolvedRadius =
        widget.style?.borderRadius ?? themeStyle?.borderRadius ?? defaultRadius;
    if (groupInfo != null) {
      final isFirst = groupInfo.index == 0;
      final isLast = groupInfo.index == groupInfo.totalCount - 1;

      if (groupInfo.direction == .horizontal) {
        if (isFirst) {
          resolvedRadius = .only(
            topLeft: resolvedRadius.topLeft,
            bottomLeft: resolvedRadius.bottomLeft,
          );
        } else if (isLast) {
          resolvedRadius = .only(
            topRight: resolvedRadius.topRight,
            bottomRight: resolvedRadius.bottomRight,
          );
        } else {
          resolvedRadius = .zero;
        }
      } else {
        if (isFirst) {
          resolvedRadius = .only(
            topLeft: resolvedRadius.topLeft,
            topRight: resolvedRadius.topRight,
          );
        } else if (isLast) {
          resolvedRadius = .only(
            bottomLeft: resolvedRadius.bottomLeft,
            bottomRight: resolvedRadius.bottomRight,
          );
        } else {
          resolvedRadius = .zero;
        }
      }
    }

    // Accessibility Target enforcement
    // Touch targets must be at least 48x48
    final bool needsMinTargetSize = height < 48.0;

    return Semantics(
      button: true,
      label: widget.isLoading ? 'Loading ${widget.label}' : widget.label,
      enabled: isInteractive,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: needsMinTargetSize ? 48.0 : height,
          minWidth: widget.isFullWidth
              ? .infinity
              : (needsMinTargetSize ? 48.0 : 0.0),
        ),
        child: Center(
          widthFactor: widget.isFullWidth ? null : 1.0,
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
              final isNeobrutalism = true;

              // Resolve states colors
              Color bg;
              Color text;
              Color border;

              // Fallback colors matching semantic rules
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

              // Apply theme & manual instance styles if provided
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
              final finalPadding =
                  widget.style?.padding ??
                  themeStyle?.padding ??
                  (widget.variant == .link
                      ? .zero
                      : .symmetric(horizontal: paddingH));
              final finalTextStyle =
                  widget.style?.textStyle ??
                  themeStyle?.textStyle ??
                  textStyle.copyWith(color: finalFg);

              // Link decoration
              final isLinkWithHover = widget.variant == .link && isHovered;

              final labelWidget = Text(
                widget.label,
                style: isLinkWithHover
                    ? finalTextStyle.copyWith(decoration: .underline)
                    : finalTextStyle,
                maxLines: 1,
                overflow: .ellipsis,
              );

              // Layout children inside button
              Widget content;
              if (widget.isLoading) {
                content = Row(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  children: [
                    JustProgressSpinner(size: iconSize, color: finalFg),
                  ],
                );
              } else {
                final hasLeading = widget.leading != null;
                final hasTrailing = widget.trailing != null;

                if (hasLeading || hasTrailing) {
                  content = Row(
                    mainAxisSize: .min,
                    mainAxisAlignment: .center,
                    children: [
                      if (hasLeading) ...[
                        IconTheme.merge(
                          data: IconThemeData(size: iconSize, color: finalFg),
                          child: widget.leading!,
                        ),
                        SizedBox(width: spacing.sm),
                      ],
                      labelWidget,
                      if (hasTrailing) ...[
                        SizedBox(width: spacing.sm),
                        IconTheme.merge(
                          data: IconThemeData(size: iconSize, color: finalFg),
                          child: widget.trailing!,
                        ),
                      ],
                    ],
                  );
                } else {
                  content = labelWidget;
                }
              }

              // Scale animation on tap/press
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
                  height: height,
                  padding: finalPadding,
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

/// A layout component to group multiple buttons together.
class JustButtonGroup extends StatelessWidget {
  /// The children buttons.
  final List<JustButton> children;

  /// The direction to layout the buttons.
  final Axis direction;

  /// Whether the buttons should be attached directly (sharing borders/corners).
  final bool attached;

  /// Creates a [JustButtonGroup].
  const JustButtonGroup({
    super.key,
    required this.children,
    this.direction = .horizontal,
    this.attached = true,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    if (!attached) {
      final spacing = JustThemeProvider.of(context).theme.spacing;
      return Flex(
        direction: direction,
        mainAxisSize: .min,
        spacing: spacing.sm, // Default small gap
        children: children,
      );
    }

    return Flex(
      direction: direction,
      mainAxisSize: .min,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          // Translate subsequent items to overlap their 1px borders
          Builder(
            builder: (context) {
              Widget button = JustButtonGroupInfo(
                index: i,
                totalCount: children.length,
                direction: direction,
                child: children[i],
              );
              if (i > 0) {
                final offset = direction == .horizontal
                    ? const Offset(-1.0, 0.0)
                    : const Offset(0.0, -1.0);
                button = Transform.translate(offset: offset, child: button);
              }
              return button;
            },
          ),
        ],
      ],
    );
  }
}
