// justui-meta: registry=ee33b2e3c2f3cc1525ba494b595e060be53f73af87d76674ec17b2e09a1bca1f local=800cb16e64ef91ec2274971779c61c489b0a1d66bca2a7c11734561a6614d094
import 'package:flutter/widgets.dart';
import 'package:sandbox/core/just_ui_core.dart';

import 'just_tabs_style.dart';
import 'just_tabs_variants.dart';

/// An internal, package-private widget that renders the active tab indicator shape
/// based on the selected [JustTabVariant].
class JustTabIndicator extends StatelessWidget {
  /// The active variant.
  final JustTabVariant variant;

  /// The active tabs orientation.
  final Axis orientation;

  /// The active color scheme.
  final JustColorScheme colors;

  /// The active radius scheme.
  final JustRadiusScheme radius;

  /// The active theme data.
  final JustThemeData theme;

  /// Optional per-instance styles.
  final JustTabsStyle? style;

  const JustTabIndicator({
    super.key,
    required this.variant,
    required this.orientation,
    required this.colors,
    required this.radius,
    required this.theme,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final JustPresetTokens presetTokens = theme.presetTokens;
    // Resolve styling colors and shapes
    final Color activeColor =
        style?.indicatorColor ?? style?.activeColor ?? colors.borderFocus;
    final BorderRadius indicatorRadius =
        style?.indicatorRadius ??
        presetTokens.resolveBorderRadius(radius, isPill: variant == .pill);

    switch (variant) {
      case .line:
        final double thickness = presetTokens.resolveTabIndicatorThickness(
          style?.indicatorThickness,
        );
        if (orientation == .horizontal) {
          final BorderRadius horizontalLineRadius =
              presetTokens.showsDefaultBorder
              ? .zero
              : .only(
                  topLeft: .circular(radius.sm.x),
                  topRight: .circular(radius.sm.x),
                );
          return Align(
            alignment: .bottomCenter,
            child: Container(
              height: thickness,
              width: .infinity,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: horizontalLineRadius,
              ),
            ),
          );
        } else {
          // Vertical layout: line on the starting edge (respecting Directionality)
          final bool isRtl = Directionality.of(context) == .rtl;
          final BorderRadius verticalLineRadius =
              presetTokens.showsDefaultBorder
              ? .zero
              : .only(
                  topRight: isRtl ? .circular(radius.sm.x) : .zero,
                  bottomRight: isRtl ? .circular(radius.sm.x) : .zero,
                  topLeft: !isRtl ? .circular(radius.sm.x) : .zero,
                  bottomLeft: !isRtl ? .circular(radius.sm.x) : .zero,
                );
          return Align(
            alignment: isRtl ? .centerRight : .centerLeft,
            child: Container(
              width: thickness,
              height: .infinity,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: verticalLineRadius,
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
                ? .all(
                    color: colors.textPrimary,
                    width: presetTokens.borderWidth,
                  )
                : null,
          ),
        );

      case .vertical:
        // Fallback for vertical: line by default, or similar to line
        final double thickness = presetTokens.resolveTabIndicatorThickness(
          style?.indicatorThickness,
        );
        final bool isRtl = Directionality.of(context) == .rtl;
        final BorderRadius verticalLineRadius = presetTokens.showsDefaultBorder
            ? .zero
            : .only(
                topRight: isRtl ? .circular(radius.sm.x) : .zero,
                bottomRight: isRtl ? .circular(radius.sm.x) : .zero,
                topLeft: !isRtl ? .circular(radius.sm.x) : .zero,
                bottomLeft: !isRtl ? .circular(radius.sm.x) : .zero,
              );
        return Align(
          alignment: isRtl ? .centerRight : .centerLeft,
          child: Container(
            width: thickness,
            height: .infinity,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: verticalLineRadius,
            ),
          ),
        );
    }
  }
}
