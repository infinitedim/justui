import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import '../../theme/theme_provider.dart';
import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import 'just_toggle_style.dart';
import 'just_toggle_theme.dart';
import 'just_toggle_variants.dart';

/// An InheritedWidget to pass group layout and position info to individual [JustToggle] buttons.
class JustToggleGroupInfo extends InheritedWidget {
  /// The index of the toggle within the group.
  final int index;

  /// The total count of toggles in the group.
  final int totalCount;

  /// The layout direction of the group.
  final Axis direction;

  /// Creates a [JustToggleGroupInfo] context.
  const JustToggleGroupInfo({
    super.key,
    required this.index,
    required this.totalCount,
    required this.direction,
    required super.child,
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

  /// Creates a [JustToggle] component.
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
    final customTheme = JustThemeProvider.of(context).theme;
    final toggleTheme = Theme.of(context).extension<JustToggleTheme>();
    final themeStyle = toggleTheme?.style;

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final radius = customTheme.radius;
    final shadows = customTheme.shadows;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final isNeobrutalism = customTheme.preset == .neobrutalism;

    final isInteractive = enabled && onPressed != null;

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
    final groupInfo = JustToggleGroupInfo.of(context);
    final BorderRadius defaultRadius = isNeobrutalism ? .zero : .all(radius.md);
    BorderRadius resolvedRadius =
        style?.borderRadius ?? themeStyle?.borderRadius ?? defaultRadius;

    if (groupInfo != null && !isNeobrutalism) {
      final isFirst = groupInfo.index == 0;
      final isLast = groupInfo.index == groupInfo.totalCount - 1;

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
    final finalSelectedBg =
        style?.selectedBackgroundColor ??
        themeStyle?.selectedBackgroundColor ??
        (isNeobrutalism
            ? colors.textPrimary
            : colors.borderFocus.withValues(alpha: 0.15));

    final finalUnselectedBg =
        style?.unselectedBackgroundColor ??
        themeStyle?.unselectedBackgroundColor ??
        (isNeobrutalism ? colors.background : const Color(0x00000000));

    final finalSelectedBorder =
        style?.selectedBorderColor ??
        themeStyle?.selectedBorderColor ??
        (isNeobrutalism ? colors.textPrimary : colors.borderFocus);

    final finalUnselectedBorder =
        style?.unselectedBorderColor ??
        themeStyle?.unselectedBorderColor ??
        (isNeobrutalism ? colors.textPrimary : colors.borderDefault);

    final finalSelectedText =
        style?.selectedTextColor ??
        themeStyle?.selectedTextColor ??
        (isNeobrutalism ? colors.textInverse : colors.borderFocus);

    final finalUnselectedText =
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
        builder: (context, isHovered, isPressed, isFocused, _) {
          Color bg = selected ? finalSelectedBg : finalUnselectedBg;
          Color text = selected ? finalSelectedText : finalUnselectedText;
          Color border = selected ? finalSelectedBorder : finalUnselectedBorder;

          // Apply state modifiers
          if (!isInteractive) {
            bg = bg.withValues(alpha: 0.5);
            text = text.withValues(alpha: 0.4);
            border = border.withValues(alpha: 0.4);
          } else if (isPressed) {
            if (isNeobrutalism) {
              // Press effect handled by customTheme.buildPressEffect
            } else {
              bg = selected
                  ? finalSelectedBg.withValues(alpha: 0.8)
                  : colors.borderDefault.withValues(alpha: 0.15);
            }
          } else if (isHovered) {
            if (isNeobrutalism) {
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
          if (isNeobrutalism) {
            resolvedBorder = Border.all(color: border, width: 2.5);
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
            resolvedBorder = Border.all(color: border, width: 1.0);
          }

          Widget buttonContent = Container(
            height: height,
            padding: .symmetric(horizontal: paddingH),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              border: resolvedBorder,
              borderRadius: isNeobrutalism ? .zero : resolvedRadius,
            ),
            child: DefaultTextStyle.merge(
              style: textStyle.copyWith(
                color: text,
                fontWeight: selected ? .w600 : .w400,
              ),
              child: child,
            ),
          );

          if (isNeobrutalism) {
            if (selected) {
              buttonContent = customTheme.buildPressEffect(
                isPressed: isPressed,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: customTheme.resolveShadows(
                      shadows.md,
                      isPressed: isPressed,
                    ),
                    borderRadius: .zero,
                  ),
                  child: buttonContent,
                ),
              );
            } else {
              buttonContent = customTheme.buildPressEffect(
                isPressed: isPressed,
                child: buttonContent,
              );
            }
          }

          return FocusIndicator(
            isFocused: isFocused,
            focusColor: colors.borderFocus,
            borderRadius: isNeobrutalism ? .zero : resolvedRadius,
            child: buttonContent,
          );
        },
      ),
    );
  }
}
