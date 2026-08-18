import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import '../../theme/theme_data.dart';
import 'just_tabs_style.dart';
import 'just_tabs_variants.dart';

/// An internal, package-private widget that renders the active tab indicator shape
/// based on the selected [JustTabVariant].
/// An internal, package-private widget that renders the active tab indicator shape
/// based on the selected [JustTabVariant].
class const JustTabIndicator({
  super.key,

  /// The active variant.
  required final JustTabVariant variant,

  /// The active tabs orientation.
  required final Axis orientation,

  /// The active color scheme.
  required final JustColorScheme colors,

  /// The active radius scheme.
  required final JustRadiusScheme radius,

  /// The active theme data.
  required final JustThemeData theme,

  /// Optional per-instance styles.
  final JustTabsStyle? style,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final presetTokens = theme.presetTokens;
    // Resolve styling colors and shapes
    final activeColor =
        style?.indicatorColor ?? style?.activeColor ?? colors.borderFocus;
    final BorderRadius defaultIndicatorRadius = variant == .pill
        ? .all(radius.full)
        : .all(radius.md);
    final indicatorRadius = style?.indicatorRadius ?? defaultIndicatorRadius;

    switch (variant) {
      case .line:
        final thickness = presetTokens.resolveTabIndicatorThickness(
          style?.indicatorThickness,
        );
        if (orientation == .horizontal) {
          return Align(
            alignment: .bottomCenter,
            child: Container(
              height: thickness,
              width: .infinity,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: .only(
                  topLeft: .circular(radius.sm.x),
                  topRight: .circular(radius.sm.x),
                ),
              ),
            ),
          );
        } else {
          // Vertical layout: line on the starting edge (respecting Directionality)
          final isRtl = Directionality.of(context) == .rtl;
          return Align(
            alignment: isRtl ? .centerRight : .centerLeft,
            child: Container(
              width: thickness,
              height: .infinity,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: .only(
                  topRight: isRtl ? .circular(radius.sm.x) : .zero,
                  bottomRight: isRtl ? .circular(radius.sm.x) : .zero,
                  topLeft: !isRtl ? .circular(radius.sm.x) : .zero,
                  bottomLeft: !isRtl ? .circular(radius.sm.x) : .zero,
                ),
              ),
            ),
          );
        }

      case .enclosed:
        // Card-style outline wrapper
        return Container(
          decoration: BoxDecoration(
            color: style?.containerBackgroundColor ?? colors.card,
            borderRadius: indicatorRadius,
            border: .all(
              color: presetTokens.showsDefaultBorder
                  ? colors.textPrimary
                  : colors.borderDefault,
              width: presetTokens.borderWidth,
            ),
          ),
        );

      case .pill:
        // Pill solid background indicator
        return Container(
          decoration: BoxDecoration(
            color: presetTokens.showsDefaultBorder
                ? colors.success.withValues(alpha: 0.2)
                : activeColor.withValues(alpha: 0.1),
            borderRadius: indicatorRadius,
            border: presetTokens.showsDefaultBorder
                ? .all(color: colors.textPrimary, width: 1.5)
                : null,
          ),
        );

      case .vertical:
        // Fallback for vertical: line by default, or similar to line
        final thickness = presetTokens.resolveTabIndicatorThickness(
          style?.indicatorThickness,
        );
        final isRtl = Directionality.of(context) == .rtl;
        return Align(
          alignment: isRtl ? .centerRight : .centerLeft,
          child: Container(
            width: thickness,
            height: .infinity,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: .only(
                topRight: isRtl ? .circular(radius.sm.x) : .zero,
                bottomRight: isRtl ? .circular(radius.sm.x) : .zero,
                topLeft: !isRtl ? .circular(radius.sm.x) : .zero,
                bottomLeft: !isRtl ? .circular(radius.sm.x) : .zero,
              ),
            ),
          ),
        );
    }
  }
}
