/// The visual style variants for [JustBadge].
enum JustBadgeVariant {
  /// Solid filled background with white text.
  solid,

  /// Outline border with transparent background and colored text.
  outline,

  /// Soft tinted background with colored text.
  soft,

  /// Simple circle dot without any text.
  dot,
}

/// The state color categories for [JustBadge].
enum JustBadgeColor {
  /// Primary theme color.
  primary,

  /// Secondary theme color.
  secondary,

  /// Success state color.
  success,

  /// Warning state color.
  warning,

  /// Error state color.
  error,

  /// Information state color.
  info,

  /// Neutral slate color.
  neutral,
}

/// Sizing classifications for [JustBadge].
enum JustBadgeSize {
  /// Small size (height: 18px / dot: 6px)
  sm,

  /// Medium size (height: 22px / dot: 8px)
  md,

  /// Large size (height: 26px / dot: 10px)
  lg,
}

/// Layout positioning for the badge overlay helper.
enum BadgePosition {
  /// Top-right corner.
  topRight,

  /// Top-left corner.
  topLeft,

  /// Bottom-right corner.
  bottomRight,

  /// Bottom-left corner.
  bottomLeft,
}
