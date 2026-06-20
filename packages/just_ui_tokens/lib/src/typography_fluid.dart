import 'package:flutter/widgets.dart';
import 'breakpoints.dart';
import 'typography.dart';

/// Extension on [TextStyle] to add fluid typography scaling and adaptive line heights.
extension JustFluidTypography on TextStyle {
  /// Dynamically scales the font size based on the screen width using a fluid formula.
  ///
  /// The font size will scale linearly between [minSize] and [maxSize] as the screen
  /// width moves between [minWidth] and [maxWidth].
  TextStyle fluid({
    required double screenWidth,
    double minWidth = JustBreakpoints.sm,
    double maxWidth = JustBreakpoints.lg,
    required double minSize,
    required double maxSize,
  }) {
    assert(maxWidth > minWidth, 'maxWidth must be greater than minWidth');
    final double clampedWidth = screenWidth.clamp(minWidth, maxWidth);
    final double slope = (maxSize - minSize) / (maxWidth - minWidth);
    final double calculatedSize = minSize + slope * (clampedWidth - minWidth);
    return copyWith(fontSize: calculatedSize);
  }

  /// Calculates and applies an optimal line-height multiplier (`height`) based on the
  /// current scaled font size.
  ///
  /// As font size increases (including system accessibility scaling), the line height
  /// is tightened to prevent text lines from overlapping or feeling excessively disconnected.
  ///
  /// - For font sizes <= 12.0, the height is loose (~1.6).
  /// - For font sizes >= 36.0, the height is tight (~1.15).
  /// - For intermediate font sizes, height is linearly interpolated.
  TextStyle withAdaptiveHeight(BuildContext context) {
    final double baseSize = fontSize ?? 16.0;
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final double scaledSize = textScaler.scale(baseSize);

    double targetHeight;
    if (scaledSize <= 12.0) {
      targetHeight = 1.6;
    } else if (scaledSize >= 36.0) {
      targetHeight = 1.15;
    } else {
      final double t = (scaledSize - 12.0) / (36.0 - 12.0);
      targetHeight = 1.6 - (1.6 - 1.15) * t;
    }

    return copyWith(height: targetHeight);
  }
}

/// A collection of responsive fluid typography preset tokens.
///
/// Automatically scales font sizes based on viewport screen width.
/// Call `.resolve(context)` on any of these presets to retrieve the active,
/// resolved [TextStyle] with dynamic line heights applied.
abstract final class JustFluidTypo {
  /// Fluid display large text style (scales from 36px on mobile to 48px on desktop).
  static TextStyle displayLg(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return JustTypo.displayLg
        .fluid(screenWidth: width, minSize: 36.0, maxSize: 48.0)
        .withAdaptiveHeight(context);
  }

  /// Fluid display medium text style (scales from 30px to 38px).
  static TextStyle displayMd(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return JustTypo.displayMd
        .fluid(screenWidth: width, minSize: 30.0, maxSize: 38.0)
        .withAdaptiveHeight(context);
  }

  /// Fluid display small text style (scales from 24px to 32px).
  static TextStyle displaySm(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return JustTypo.displaySm
        .fluid(screenWidth: width, minSize: 24.0, maxSize: 32.0)
        .withAdaptiveHeight(context);
  }

  /// Fluid heading large text style (scales from 20px to 24px).
  static TextStyle headingLg(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return JustTypo.headingLg
        .fluid(screenWidth: width, minSize: 20.0, maxSize: 24.0)
        .withAdaptiveHeight(context);
  }

  /// Fluid heading medium text style (scales from 18px to 20px).
  static TextStyle headingMd(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return JustTypo.headingMd
        .fluid(screenWidth: width, minSize: 18.0, maxSize: 20.0)
        .withAdaptiveHeight(context);
  }

  /// Fluid heading small text style (scales from 16px to 18px).
  static TextStyle headingSm(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return JustTypo.headingSm
        .fluid(screenWidth: width, minSize: 16.0, maxSize: 18.0)
        .withAdaptiveHeight(context);
  }

  /// Fluid body large text style (scales from 15px to 16px).
  static TextStyle bodyLg(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return JustTypo.bodyLg
        .fluid(screenWidth: width, minSize: 15.0, maxSize: 16.0)
        .withAdaptiveHeight(context);
  }

  /// Fluid body medium text style (scales from 13px to 14px).
  static TextStyle bodyMd(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return JustTypo.bodyMd
        .fluid(screenWidth: width, minSize: 13.0, maxSize: 14.0)
        .withAdaptiveHeight(context);
  }

  /// Fluid body small text style (scales from 11px to 12px).
  static TextStyle bodySm(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return JustTypo.bodySm
        .fluid(screenWidth: width, minSize: 11.0, maxSize: 12.0)
        .withAdaptiveHeight(context);
  }
}
