import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import '../../theme/theme_provider.dart';
import 'just_separator_style.dart';
import 'just_separator_theme.dart';

/// A divider widget supporting horizontal and vertical directions and centered text labels.
///
/// Follows zero-Material visual widget policy and maps styles using JustUI tokens.
class JustSeparator extends StatelessWidget {
  /// The direction of the separator. Defaults to [Axis.horizontal].
  final Axis direction;

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

  /// Creates a [JustSeparator].
  const JustSeparator({
    super.key,
    this.direction = Axis.horizontal,
    this.thickness = 1.0,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.label,
    this.labelStyle,
    this.height,
    this.width,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve theme extension configurations
    final globalSeparatorTheme = Theme.of(
      context,
    ).extension<JustSeparatorTheme>();
    final themeStyle = globalSeparatorTheme?.style;

    // Aspect-based subscriptions
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typo = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;

    // Preference hierarchy resolution
    final resolvedColor =
        style?.color ?? themeStyle?.color ?? color ?? colors.borderDefault;
    final resolvedThickness =
        style?.thickness ?? themeStyle?.thickness ?? thickness;
    final resolvedIndent = style?.indent ?? themeStyle?.indent ?? indent;
    final resolvedEndIndent =
        style?.endIndent ?? themeStyle?.endIndent ?? endIndent;

    final defaultLabelStyle = typo.caption.copyWith(
      color: colors.textSecondary,
    );
    final resolvedLabelStyle =
        style?.labelStyle ??
        themeStyle?.labelStyle ??
        labelStyle ??
        defaultLabelStyle;
    final resolvedLabelPadding =
        style?.labelPadding ?? themeStyle?.labelPadding ?? .all(spacing.sm);

    if (direction == Axis.horizontal) {
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
          children: [
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
          children: [
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
