import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/theme/theme_data.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart'
    show JustColorScheme, JustMotionProfile;

import '../../theme/theme_provider.dart';
import '../../theme/preset_tokens.dart';
import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import '../shared/_shared_progress_spinner.dart';
import 'just_button_style.dart';
import 'just_button_variants.dart';
import 'just_button_theme.dart';

/// An InheritedWidget to pass group information to individual buttons.
/// An InheritedWidget to pass group information to individual buttons.
class const JustButtonGroupInfo({
  super.key,
  required super.child,

  /// The index of the button in the group.
  required final int index,

  /// The total count of buttons in the group.
  required final int totalCount,

  /// The layout direction of the group.
  required final Axis direction,
}) extends InheritedWidget {
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
/// A highly customizable, accessible button component that adheres to JustUI design tokens.
class const JustButton({
  super.key,

  /// The text label displayed inside the button.
  required final String label,

  /// Callback executed when the button is tapped. If null, the button is disabled.
  required final VoidCallback? onPressed,

  /// The visual style variant.
  final JustButtonVariant variant = .primary,

  /// The physical size classification.
  final JustButtonSize size = .md,

  /// An optional widget (such as an icon) displayed before the label.
  final Widget? leading,

  /// An optional widget (such as an icon) displayed after the label.
  final Widget? trailing,

  /// Whether the button is currently in a loading state.
  final bool isLoading = false,

  /// Whether the button is explicitly disabled.
  final bool isDisabled = false,

  /// Whether the button should stretch to fill the horizontal width of its parent.
  final bool isFullWidth = false,

  /// Per-instance style overrides.
  final JustButtonStyle? style,

  /// If null, falls back to the theme setting.
  final bool? enableHaptic,
}) extends StatelessWidget {
  /// Named constructor for primary solid buttons.
  const new primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    JustButtonSize size = .md,
    Widget? leading,
    Widget? trailing,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    JustButtonStyle? style,
    bool? enableHaptic,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: .primary,
         size: size,
         leading: leading,
         trailing: trailing,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         style: style,
         enableHaptic: enableHaptic,
       );

  /// Named constructor for secondary outline buttons.
  const new secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    JustButtonSize size = .md,
    Widget? leading,
    Widget? trailing,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    JustButtonStyle? style,
    bool? enableHaptic,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: .secondary,
         size: size,
         leading: leading,
         trailing: trailing,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         style: style,
         enableHaptic: enableHaptic,
       );

  /// Named constructor for ghost transparent buttons.
  const new ghost({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    JustButtonSize size = .md,
    Widget? leading,
    Widget? trailing,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    JustButtonStyle? style,
    bool? enableHaptic,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: .ghost,
         size: size,
         leading: leading,
         trailing: trailing,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         style: style,
         enableHaptic: enableHaptic,
       );

  /// Named constructor for destructive solid buttons.
  const new destructive({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    JustButtonSize size = .md,
    Widget? leading,
    Widget? trailing,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    JustButtonStyle? style,
    bool? enableHaptic,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: .destructive,
         size: size,
         leading: leading,
         trailing: trailing,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         style: style,
         enableHaptic: enableHaptic,
       );

  /// Named constructor for link buttons.
  const new link({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    JustButtonSize size = .md,
    Widget? leading,
    Widget? trailing,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    JustButtonStyle? style,
    bool? enableHaptic,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: .link,
         size: size,
         leading: leading,
         trailing: trailing,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         style: style,
         enableHaptic: enableHaptic,
       );

  @override
  Widget build(BuildContext context) {
    // Attempt to read from Flutter Theme Extension
    // Using context.justTheme which resolves InheritedModel aspects properly
    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
    final JustButtonTheme? buttonTheme = Theme.of(context)
        .extension<JustButtonTheme>();
    final JustPresetTokens presetTokens = customTheme.presetTokens;

    final JustButtonStyle? themeStyle = buttonTheme?.styleFor(variant);
    final bool finalEnableHaptic =
        enableHaptic ??
        buttonTheme?.enableHaptic ??
        presetTokens.showsDefaultBorder;

    // We register dependency to colors aspect
    final JustColorScheme colors = JustThemeProvider.of(
      context,
      aspect: .colors,
    ).theme.colors;
    final JustTypographyScheme typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final JustSpacingScheme spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final JustRadiusScheme radius = customTheme.radius;
    final JustMotionProfile animations = customTheme.animations;

    final bool isInteractive = onPressed != null && !isDisabled && !isLoading;

    final _ButtonMetrics metrics = _buttonMetrics(size, spacing, typography);
    final double height = metrics.height;
    final double paddingH = metrics.paddingH;
    final TextStyle textStyle = metrics.textStyle;
    final double iconSize = metrics.iconSize;
    final BorderRadius defaultRadius = presetTokens.resolveBorderRadius(radius);

    // Apply button group attached adjustments if in a group
    final BorderRadius resolvedRadius = _attachedGroupRadius(
      style?.borderRadius ?? themeStyle?.borderRadius ?? defaultRadius,
      JustButtonGroupInfo.of(context),
    );

    // Accessibility Target enforcement
    // Touch targets must be at least 48x48
    final bool needsMinTargetSize = height < 48.0;

    return Semantics(
      button: true,
      label: isLoading ? 'Loading $label' : label,
      enabled: isInteractive,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: needsMinTargetSize ? 48.0 : height,
          minWidth: isFullWidth ? .infinity : (needsMinTargetSize ? 48.0 : 0.0),
        ),
        child: Center(
          widthFactor: isFullWidth ? null : 1.0,
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

              // Apply theme & manual instance styles if provided
              final Color finalBg =
                  style?.backgroundColor ?? themeStyle?.backgroundColor ?? bg;
              final Color finalFg =
                  style?.foregroundColor ?? themeStyle?.foregroundColor ?? text;
              final Color finalBorder =
                  style?.borderColor ?? themeStyle?.borderColor ?? border;
              final EdgeInsets finalPadding =
                  style?.padding ??
                  themeStyle?.padding ??
                  (variant == .link ? .zero : .symmetric(horizontal: paddingH));
              final TextStyle finalTextStyle =
                  style?.textStyle ??
                  themeStyle?.textStyle ??
                  textStyle.copyWith(color: finalFg);

              // Link decoration
              final bool isLinkWithHover = variant == .link && isHovered;

              final Text labelWidget = Text(
                label,
                style: isLinkWithHover
                    ? finalTextStyle.copyWith(decoration: .underline)
                    : finalTextStyle,
                maxLines: 1,
                overflow: .ellipsis,
              );

              // Layout children inside button
              Widget content;
              if (isLoading) {
                content = Row(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  children: <Widget>[
                    JustProgressSpinner(
                      size: iconSize,
                      color: finalFg,
                      excludeSemantics: true,
                    ),
                  ],
                );
              } else {
                final bool hasLeading = leading != null;
                final bool hasTrailing = trailing != null;

                if (hasLeading || hasTrailing) {
                  content = Row(
                    mainAxisSize: .min,
                    mainAxisAlignment: .center,
                    children: <Widget>[
                      if (hasLeading) ...<Widget>[
                        IconTheme.merge(
                          data: IconThemeData(size: iconSize, color: finalFg),
                          child: leading!,
                        ),
                        SizedBox(width: spacing.sm),
                      ],
                      labelWidget,
                      if (hasTrailing) ...<Widget>[
                        SizedBox(width: spacing.sm),
                        IconTheme.merge(
                          data: IconThemeData(size: iconSize, color: finalFg),
                          child: trailing!,
                        ),
                      ],
                    ],
                  );
                } else {
                  content = labelWidget;
                }
              }

              // Shadows resolution
              List<BoxShadow> resolvedShadows;
              if (variant == .link || variant == .ghost) {
                resolvedShadows = const <BoxShadow>[];
              } else {
                final double? styleElevation =
                    style?.elevation ?? themeStyle?.elevation;

                final bool hasShadow = styleElevation != null
                    ? styleElevation > 0.0
                    : presetTokens.showsDefaultBorder;

                if (hasShadow) {
                  final JustShadowLevel level;
                  if (styleElevation != null) {
                    level = styleElevation <= 1.5 ? .xs : .sm;
                  } else {
                    level = size == .xs ? .xs : .sm;
                  }
                  resolvedShadows = presetTokens.resolveShadow(
                    customTheme.shadows,
                    level,
                    isPressed: isPressed,
                  );
                } else {
                  resolvedShadows = const <BoxShadow>[];
                }
              }

              final double finalBorderWidth =
                  presetTokens.showsDefaultBorder && variant != .link
                  ? presetTokens.borderWidth
                  : (finalBorder != const Color(0x00000000) ? 1.0 : 0.0);

              return presetTokens.buildPressEffect(
                isPressed: isPressed,
                animations: customTheme.animations,
                child: AnimatedContainer(
                  duration: presetTokens.showsDefaultBorder
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

/// Size-dependent geometry of a [JustButton].
typedef _ButtonMetrics = ({
  double height,
  double paddingH,
  TextStyle textStyle,
  double iconSize,
});

/// Table-driven lookup of button geometry for each [JustButtonSize].
_ButtonMetrics _buttonMetrics(
  JustButtonSize size,
  JustSpacingScheme spacing,
  JustTypographyScheme typography,
) {
  final (
    double height,
    double paddingH,
    TextStyle base,
    double iconSize,
  ) = switch (size) {
    .xs => (28.0, spacing.sm, typography.caption, 14.0),
    .sm => (32.0, spacing.md, typography.bodySm, 16.0),
    .md => (40.0, spacing.lg, typography.bodyMd, 18.0),
    .lg => (48.0, spacing.xl, typography.bodyLg, 20.0),
    .xl => (56.0, spacing.xxl, typography.headingSm, 22.0),
  };
  return (
    height: height,
    paddingH: paddingH,
    textStyle: base.copyWith(fontWeight: .w500),
    iconSize: iconSize,
  );
}

/// Keeps only the outer corners of [radius] for a button inside an attached
/// [JustButtonGroup]; returns [radius] unchanged outside a group.
BorderRadius _attachedGroupRadius(
  BorderRadius radius,
  JustButtonGroupInfo? groupInfo,
) {
  if (groupInfo == null) return radius;

  final bool isFirst = groupInfo.index == 0;
  final bool isLast = groupInfo.index == groupInfo.totalCount - 1;
  if (!isFirst && !isLast) return .zero;

  final bool horizontal = groupInfo.direction == .horizontal;
  return switch ((horizontal, isFirst)) {
    (true, true) => .only(
      topLeft: radius.topLeft,
      bottomLeft: radius.bottomLeft,
    ),
    (true, false) => .only(
      topRight: radius.topRight,
      bottomRight: radius.bottomRight,
    ),
    (false, true) => .only(topLeft: radius.topLeft, topRight: radius.topRight),
    (false, false) => .only(
      bottomLeft: radius.bottomLeft,
      bottomRight: radius.bottomRight,
    ),
  };
}

/// A layout component to group multiple buttons together.
/// A layout component to group multiple buttons together.
class const JustButtonGroup({
  super.key,

  /// The children buttons.
  required final List<JustButton> children,

  /// The direction to layout the buttons.
  final Axis direction = .horizontal,

  /// Whether the buttons should be attached directly (sharing borders/corners).
  final bool attached = true,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    if (!attached) {
      final JustSpacingScheme spacing = JustThemeProvider.of(context)
          .theme
          .spacing;
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
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          // Translate subsequent items to overlap their 1px borders
          Builder(
            builder: (BuildContext context) {
              Widget button = JustButtonGroupInfo(
                index: i,
                totalCount: children.length,
                direction: direction,
                child: children[i],
              );
              if (i > 0) {
                final Offset offset = direction == .horizontal
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
