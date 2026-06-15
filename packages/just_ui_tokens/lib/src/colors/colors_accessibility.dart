import 'package:flutter/painting.dart';

/// Extension methods on [Color] to audit color contrast ratios for accessibility.
///
/// Follows the WCAG 2.0 guidelines for contrast calculations.
extension JustColorAccessibility on Color {
  /// Calculates the contrast ratio against another [Color].
  ///
  /// The returned value is in the range of 1.0 to 21.0, where:
  /// - 1.0 indicates no contrast (identical colors).
  /// - 21.0 indicates maximum contrast (perfect black and white).
  double contrastRatioWith(Color other) {
    final double l1 = computeLuminance();
    final double l2 = other.computeLuminance();

    if (l1 > l2) {
      return (l1 + 0.05) / (l2 + 0.05);
    } else {
      return (l2 + 0.05) / (l1 + 0.05);
    }
  }

  /// Verifies if this color is accessible when paired with [other] under WCAG AA standards.
  ///
  /// For normal text, a contrast ratio of at least 4.5:1 is required.
  /// For large text (18pt/24px or bold 14pt/18.67px), a ratio of at least 3.0:1 is required.
  bool isAccessibleWith(Color other, {bool isLargeText = false}) {
    final double ratio = contrastRatioWith(other);
    return ratio >= (isLargeText ? 3.0 : 4.5);
  }
}
