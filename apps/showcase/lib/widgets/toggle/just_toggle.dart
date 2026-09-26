// justui-meta: registry=fc009f8be3d2aabaa5b1272aa65b72eb45f6f2b4fc492600ad29362e35158776 local=c4f946b5557a050f3fd9664743d423cbaf988b566e0b27b79a7089c0569ff199
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:showcase/core/theme/theme_data.dart';

import 'package:showcase/core/just_ui_core.dart';

import '../shared/just_focus_indicator.dart';
import '../shared/just_pressable.dart';
import 'just_toggle_style.dart';
import 'just_toggle_theme.dart';
import 'just_toggle_variants.dart';

/// An InheritedWidget to pass group layout and position info to individual [JustToggle] buttons.
/// An InheritedWidget to pass group layout and position info to individual [JustToggle] buttons.
class JustToggleGroupInfo extends InheritedWidget {
  /// The index of the toggle within the group.
  final int index;

  /// The total count of toggles in the group.
  final int totalCount;

  /// The layout direction of the group.
  final Axis direction;

  const JustToggleGroupInfo({
    super.key,
    required super.child,
    required this.index,
    required this.totalCount,
    required this.direction,
  });

  /// Retrieves group info from the current context.
  static JustToggleGroupInfo? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<JustToggleGroupInfo>();
  }

  @override
  bool updateShouldNotify(JustToggleGroupInfo oldWidget) {
    return index != oldWidget.index ||
        totalCount != oldWidget.totalCount ||
        direction != oldWidget.direction;
  }
}

/// A single button that can be toggled on/off (selected/unselected).
/// A single button that can be toggled on/off (selected/unselected).
class JustToggle extends StatelessWidget {
  /// Whether this toggle is currently in the selected (active) state.
  final bool selected;

  /// Callback when the toggle is pressed. If null, the toggle is disabled.
  final VoidCallback? onPressed;

  /// The content displayed inside the toggle button.
  final Widget child;

  /// Whether the toggle is interactive.
  final bool enabled;

  /// The physical size classification.
  final JustToggleSize size;

  /// Per-instance style overrides.
  final JustToggleStyle? style;

  const JustToggle({
    super.key,
    required this.selected,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.size = .md,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
    final JustToggleTheme? toggleTheme = Theme.of(context)
        .extension<JustToggleTheme>();
    final JustToggleStyle? themeStyle = toggleTheme?.style;

    final JustColorScheme colors = JustThemeProvider.of(
      context,
      aspect: .colors,
    ).theme.colors;
    final JustRadiusScheme radius = customTheme.radius;
    final JustShadowScheme shadows = customTheme.shadows;
    final JustTypographyScheme typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final bool hasBorder = customTheme.presetTokens.showsDefaultBorder;

    final bool isInteractive = enabled && onPressed != null;

    // Resolve Dimensions based on Size
    double height;
    double paddingH;
    TextStyle textStyle;

    switch (size) {
      case .sm:
        height = 32.0;
        paddingH = 12.0;
        textStyle = typography.bodySm;
        break;
      case .md:
        height = 40.0;
        paddingH = 16.0;
        textStyle = typography.bodyMd;
        break;
      case .lg:
        height = 48.0;
        paddingH = 20.0;
        textStyle = typography.bodyLg;
        break;
    }

    // Resolve BorderRadius with Group Collapse
    final JustToggleGroupInfo? groupInfo = JustToggleGroupInfo.of(context);
    final BorderRadius defaultRadius = customTheme.presetTokens
        .resolveBorderRadius(radius);
    BorderRadius resolvedRadius =
        style?.borderRadius ?? themeStyle?.borderRadius ?? defaultRadius;

    if (groupInfo != null && !hasBorder) {
      final bool isFirst = groupInfo.index == 0;
      final bool isLast = groupInfo.index == groupInfo.totalCount - 1;

      if (groupInfo.direction == Axis.horizontal) {
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

    // Resolve Color States
    final Color finalSelectedBg =
        style?.selectedBackgroundColor ??
        themeStyle?.selectedBackgroundColor ??
        (hasBorder
            ? colors.textPrimary
            : colors.borderFocus.withValues(alpha: 0.15));

    final Color finalUnselectedBg =
        style?.unselectedBackgroundColor ??
        themeStyle?.unselectedBackgroundColor ??
        (hasBorder ? colors.background : const Color(0x00000000));

    final Color finalSelectedBorder =
        style?.selectedBorderColor ??
        themeStyle?.selectedBorderColor ??
        (hasBorder ? colors.textPrimary : colors.borderFocus);

    final Color finalUnselectedBorder =
        style?.unselectedBorderColor ??
        themeStyle?.unselectedBorderColor ??
        (hasBorder ? colors.textPrimary : colors.borderDefault);

    final Color finalSelectedText =
        style?.selectedTextColor ??
        themeStyle?.selectedTextColor ??
        (hasBorder ? colors.textInverse : colors.borderFocus);

    final Color finalUnselectedText =
        style?.unselectedTextColor ??
        themeStyle?.unselectedTextColor ??
        colors.textPrimary;

    return Semantics(
      button: true,
      selected: selected,
      enabled: isInteractive,
      child: JustPressable(
        enabled: isInteractive,
        onTap: onPressed,
        builder: (BuildContext context, JustInteractionState state) {
          final bool isHovered = state.isHovered;
          final bool isPressed = state.isPressed;
          Color bg = selected ? finalSelectedBg : finalUnselectedBg;
          Color text = selected ? finalSelectedText : finalUnselectedText;
          Color border = selected ? finalSelectedBorder : finalUnselectedBorder;

          // Apply state modifiers
          if (!isInteractive) {
            bg = bg.withValues(alpha: 0.5);
            text = text.withValues(alpha: 0.4);
            border = border.withValues(alpha: 0.4);
          } else if (isPressed) {
            if (hasBorder) {
              // Press effect handled by customTheme.presetTokens.buildPressEffect
            } else {
              bg = selected
                  ? finalSelectedBg.withValues(alpha: 0.8)
                  : colors.borderDefault.withValues(alpha: 0.15);
            }
          } else if (isHovered) {
            if (hasBorder) {
              if (!selected) {
                bg = colors.borderDefault.withValues(alpha: 0.08);
              }
            } else {
              bg = selected
                  ? finalSelectedBg.withValues(alpha: 0.9)
                  : colors.borderDefault.withValues(alpha: 0.08);
            }
          }

          BoxBorder resolvedBorder;
          if (hasBorder) {
            resolvedBorder = .all(
              color: border,
              width: customTheme.presetTokens.borderWidth,
            );
          } else if (groupInfo != null) {
            if (groupInfo.direction == Axis.horizontal) {
              resolvedBorder = Border(
                top: BorderSide(color: border),
                bottom: BorderSide(color: border),
                right: BorderSide(color: border),
                left: groupInfo.index == 0 ? BorderSide(color: border) : .none,
              );
            } else {
              resolvedBorder = Border(
                left: BorderSide(color: border),
                right: BorderSide(color: border),
                bottom: BorderSide(color: border),
                top: groupInfo.index == 0 ? BorderSide(color: border) : .none,
              );
            }
          } else {
            resolvedBorder = .all(color: border, width: 1.0);
          }

          Widget buttonContent = Container(
            height: height,
            padding: .symmetric(horizontal: paddingH),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              border: resolvedBorder,
              borderRadius: hasBorder ? .zero : resolvedRadius,
            ),
            child: DefaultTextStyle.merge(
              style: textStyle.copyWith(
                color: text,
                fontWeight: selected ? .w600 : .w400,
              ),
              child: child,
            ),
          );

          if (hasBorder) {
            if (selected) {
              buttonContent = customTheme.presetTokens.buildPressEffect(
                isPressed: isPressed,
                animations: customTheme.animations,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: customTheme.presetTokens.resolveShadow(
                      shadows,
                      JustShadowLevel.md,
                      isPressed: isPressed,
                    ),
                    borderRadius: .zero,
                  ),
                  child: buttonContent,
                ),
              );
            } else {
              buttonContent = customTheme.presetTokens.buildPressEffect(
                isPressed: isPressed,
                animations: customTheme.animations,
                child: buttonContent,
              );
            }
          }

          return FocusIndicator(
            isFocused: state.isFocusVisible,
            borderRadius: hasBorder ? .zero : resolvedRadius,
            child: buttonContent,
          );
        },
      ),
    );
  }
}
