import 'package:flutter/widgets.dart';

/// Spacing tokens for JustUI.
///
/// Based on a 4px grid system to ensure consistent margins and paddings.
/// All numeric values are compile-time constants.
abstract final class JustSpacing {
  /// Extra extra small spacing (2.0px) - micro gap / inline icons
  static const double xxs = 2.0;

  /// Extra small spacing (4.0px) - tight spacing / helper layout
  static const double xs = 4.0;

  /// Small spacing (8.0px) - base gap between content blocks
  static const double sm = 8.0;

  /// Medium spacing (12.0px) - default padding for badges and small cards
  static const double md = 12.0;

  /// Large spacing (16.0px) - default margin and container padding
  static const double lg = 16.0;

  /// Extra large spacing (24.0px) - padding inside main cards / page headers
  static const double xl = 24.0;

  /// Double extra large spacing (32.0px) - margins between sections
  static const double xxl = 32.0;

  /// Triple extra large spacing (48.0px) - page layout boundaries
  static const double xxxl = 48.0;

  /// Huge spacing (64.0px) - massive vertical gaps / hero page layout
  static const double huge = 64.0;

  /// Quick utility to generate [EdgeInsets] using token values.
  ///
  /// Priority:
  /// 1. If [all] is provided, returns [EdgeInsets.all].
  /// 2. If [h] or [v] are provided, returns [EdgeInsets.symmetric].
  /// 3. Otherwise returns [EdgeInsets.zero].
  static EdgeInsets insets({double? all, double? h, double? v}) {
    if (all != null) {
      return .all(all);
    }
    return .symmetric(horizontal: h ?? 0.0, vertical: v ?? 0.0);
  }
}

/// A helper class providing [SizedBox] shortcuts mapping directly to [JustSpacing].
///
/// Useful for vertical or horizontal inline spacers.
abstract final class JustGap {
  /// Extra extra small gap (2.0px)
  static Widget get xxs =>
      const SizedBox(height: JustSpacing.xxs, width: JustSpacing.xxs);

  /// Extra small gap (4.0px)
  static Widget get xs =>
      const SizedBox(height: JustSpacing.xs, width: JustSpacing.xs);

  /// Small gap (8.0px)
  static Widget get sm =>
      const SizedBox(height: JustSpacing.sm, width: JustSpacing.sm);

  /// Medium gap (12.0px)
  static Widget get md =>
      const SizedBox(height: JustSpacing.md, width: JustSpacing.md);

  /// Large gap (16.0px)
  static Widget get lg =>
      const SizedBox(height: JustSpacing.lg, width: JustSpacing.lg);

  /// Extra large gap (24.0px)
  static Widget get xl =>
      const SizedBox(height: JustSpacing.xl, width: JustSpacing.xl);

  /// Double extra large gap (32.0px)
  static Widget get xxl =>
      const SizedBox(height: JustSpacing.xxl, width: JustSpacing.xxl);

  /// Triple extra large gap (48.0px)
  static Widget get xxxl =>
      const SizedBox(height: JustSpacing.xxxl, width: JustSpacing.xxxl);

  /// Huge gap (64.0px)
  static Widget get huge =>
      const SizedBox(height: JustSpacing.huge, width: JustSpacing.huge);
}
