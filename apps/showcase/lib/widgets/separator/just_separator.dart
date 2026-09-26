// justui-meta: registry=f41ebe55b7f934ca4f6501fb0b23bd6c1fb5a58e9c16e6a7d829cd990723b252 local=a7e29c292abe942041a81b3c8a55aa864154ba43b33d973afcea247447eb1613
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:showcase/core/theme/schemes/spacing_scheme.dart';
import 'package:showcase/core/theme/schemes/typography_scheme.dart';

import 'package:showcase/core/just_ui_core.dart';

import 'just_separator_style.dart';
import 'just_separator_theme.dart';

/// A divider widget supporting horizontal and vertical directions and centered text labels.
///
/// Follows zero-Material visual widget policy and maps styles using JustUI tokens.
/// Can be responsive to screen/viewport width breakpoints when using the [JustSeparator.responsive] constructor.
class JustSeparator extends StatelessWidget {
  /// The direction of the separator. If null, the separator is responsive.
  final Axis? direction;

  /// The screen/viewport width breakpoint below which the separator orientation is horizontal.
  /// Only used when [direction] is null. Defaults to 640.0.
  final double breakpoint;

  /// The thickness of the divider line. Defaults to 1.0.
  final double thickness;

  /// Custom color of the divider line. Defaults to [JustColorScheme.borderDefault].
  final Color? color;

  /// Leading indent space before the line starts. Defaults to 0.0.
  final double indent;

  /// Trailing indent space after the line ends. Defaults to 0.0.
  final double endIndent;

  /// Optional text label to display inside the separator (e.g. "OR").
  final String? label;

  /// Custom text style for the label. Defaults to [JustTypographyScheme.caption].
  final TextStyle? labelStyle;

  /// Custom height override, especially useful for vertical dividers.
  final double? height;

  /// Custom width override.
  final double? width;

  /// Per-instance style overrides.
  final JustSeparatorStyle? style;

  /// Creates a standard [JustSeparator].
  const JustSeparator({
    super.key,
    this.direction = .horizontal,
    this.thickness = 1.0,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.label,
    this.labelStyle,
    this.height,
    this.width,
    this.style,
  }) : breakpoint = 640.0;

  /// Creates a responsive [JustSeparator] that adapts its direction depending on viewport size.
  const JustSeparator.responsive({
    super.key,
    this.breakpoint = 640.0,
    this.thickness = 1.0,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.label,
    this.labelStyle,
    this.height,
    this.width,
    this.style,
  }) : direction = null;

  @override
  Widget build(BuildContext context) {
    // Resolve theme extension configurations
    final JustSeparatorTheme? globalSeparatorTheme = Theme.of(context)
        .extension<JustSeparatorTheme>();
    final JustSeparatorStyle? themeStyle = globalSeparatorTheme?.style;

    // Aspect-based subscriptions
    final JustColorScheme colors = JustThemeProvider.of(
      context,
      aspect: .colors,
    ).theme.colors;
    final JustTypographyScheme typo = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final JustSpacingScheme spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;

    // Preference hierarchy resolution
    final Color resolvedColor =
        style?.color ?? themeStyle?.color ?? color ?? colors.borderDefault;
    final double resolvedThickness =
        style?.thickness ??
        themeStyle?.thickness ??
        JustThemeProvider.of(context).theme.presetTokens
            .resolveSeparatorThickness(thickness);
    final double resolvedIndent = style?.indent ?? themeStyle?.indent ?? indent;
    final double resolvedEndIndent =
        style?.endIndent ?? themeStyle?.endIndent ?? endIndent;

    final TextStyle defaultLabelStyle = typo.caption.copyWith(
      color: colors.textSecondary,
    );
    final TextStyle resolvedLabelStyle =
        style?.labelStyle ??
        themeStyle?.labelStyle ??
        labelStyle ??
        defaultLabelStyle;
    final EdgeInsets resolvedLabelPadding =
        style?.labelPadding ?? themeStyle?.labelPadding ?? .all(spacing.sm);

    // Resolve direction adaptively if null
    final Axis resolvedDirection =
        direction ??
        (MediaQuery.sizeOf(context).width < breakpoint
            ? .horizontal
            : .vertical);

    if (resolvedDirection == .horizontal) {
      if (label == null) {
        return Padding(
          padding: .only(left: resolvedIndent, right: resolvedEndIndent),
          child: SizedBox(
            width: width,
            height: height ?? resolvedThickness,
            child: Container(height: resolvedThickness, color: resolvedColor),
          ),
        );
      }

      return SizedBox(
        width: width,
        height: height,
        child: Row(
          mainAxisSize: .min,
          crossAxisAlignment: .center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: .only(
                  left: resolvedIndent,
                  right: resolvedLabelPadding.left,
                ),
                child: Container(
                  height: resolvedThickness,
                  color: resolvedColor,
                ),
              ),
            ),
            Text(label!, style: resolvedLabelStyle),
            Expanded(
              child: Padding(
                padding: .only(
                  left: resolvedLabelPadding.right,
                  right: resolvedEndIndent,
                ),
                child: Container(
                  height: resolvedThickness,
                  color: resolvedColor,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Vertical direction
      // Default vertical length fallback to prevent unbounded constraints crash
      final double verticalLength =
          height ?? (label == null ? spacing.lg : spacing.xl * 2);

      if (label == null) {
        return Padding(
          padding: .only(top: resolvedIndent, bottom: resolvedEndIndent),
          child: SizedBox(
            width: width ?? resolvedThickness,
            height: verticalLength,
            child: Container(width: resolvedThickness, color: resolvedColor),
          ),
        );
      }

      return SizedBox(
        width: width ?? spacing.xl,
        height: verticalLength,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: .only(
                  top: resolvedIndent,
                  bottom: resolvedLabelPadding.top,
                ),
                child: Container(
                  width: resolvedThickness,
                  color: resolvedColor,
                ),
              ),
            ),
            Padding(
              padding: .symmetric(vertical: spacing.xxs),
              child: Text(label!, style: resolvedLabelStyle),
            ),
            Expanded(
              child: Padding(
                padding: .only(
                  top: resolvedLabelPadding.bottom,
                  bottom: resolvedEndIndent,
                ),
                child: Container(
                  width: resolvedThickness,
                  color: resolvedColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
