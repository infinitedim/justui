import 'package:flutter/widgets.dart';
import '../../theme/theme_data.dart';
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

  /// Optional per-instance styles.
  final JustTabsStyle? style;

  /// Creates a [JustTabIndicator] widget.
  const JustTabIndicator({
    super.key,
    required this.variant,
    required this.orientation,
    required this.colors,
    required this.radius,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve styling colors and shapes
    final activeColor = style?.indicatorColor ?? style?.activeColor ?? colors.borderFocus;
    final defaultIndicatorRadius = variant == JustTabVariant.pill
        ? .all(radius.full)
        : .all(radius.md);
    final indicatorRadius = style?.indicatorRadius ?? defaultIndicatorRadius;

    switch (variant) {
      case JustTabVariant.line:
        final thickness = style?.indicatorThickness ?? 2.0;
        if (orientation == Axis.horizontal) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: thickness,
              width: double.infinity,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: .only(
                  topLeft: Radius.circular(radius.sm.x),
                  topRight: Radius.circular(radius.sm.x),
                ),
              ),
            ),
          );
        } else {
          // Vertical layout: line on the starting edge (respecting Directionality)
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          return Align(
            alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: thickness,
              height: double.infinity,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: .only(
                  topRight: isRtl ? Radius.circular(radius.sm.x) : Radius.zero,
                  bottomRight: isRtl ? Radius.circular(radius.sm.x) : Radius.zero,
                  topLeft: !isRtl ? Radius.circular(radius.sm.x) : Radius.zero,
                  bottomLeft: !isRtl ? Radius.circular(radius.sm.x) : Radius.zero,
                ),
              ),
            ),
          );
        }

      case JustTabVariant.enclosed:
        // Card-style outline wrapper
        return Container(
          decoration: BoxDecoration(
            color: style?.containerBackgroundColor ?? colors.card,
            borderRadius: indicatorRadius,
            border: .all(
              color: colors.borderDefault,
              width: 1.0,
            ),
          ),
        );

      case JustTabVariant.pill:
        // Pill solid background indicator
        return Container(
          decoration: BoxDecoration(
            color: activeColor.withValues(alpha: 0.1),
            borderRadius: indicatorRadius,
          ),
        );

      case JustTabVariant.vertical:
        // Fallback for vertical: line by default, or similar to line
        final thickness = style?.indicatorThickness ?? 2.0;
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return Align(
          alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thickness,
            height: double.infinity,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: .only(
                topRight: isRtl ? Radius.circular(radius.sm.x) : Radius.zero,
                bottomRight: isRtl ? Radius.circular(radius.sm.x) : Radius.zero,
                topLeft: !isRtl ? Radius.circular(radius.sm.x) : Radius.zero,
                bottomLeft: !isRtl ? Radius.circular(radius.sm.x) : Radius.zero,
              ),
            ),
          ),
        );
    }
  }
}
