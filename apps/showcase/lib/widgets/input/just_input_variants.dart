// justui-meta: registry=6c24b485a5d5140fd3195ddd83de963b6c62987813f734e06f41bc8b5f677408 local=6c24b485a5d5140fd3195ddd83de963b6c62987813f734e06f41bc8b5f677408
/// The visual style variants for [JustInput].
enum JustInputVariant {
  /// Standard text input
  text,

  /// Password input with visibility toggle
  password,

  /// Search input with leading search icon and trailing clear button
  search,

  /// Numeric input with optional stepper buttons
  number,

  /// Text area with multi-line expandability
  textarea,

  /// OTP segmented code input
  otp,
}

/// The sizing options for [JustInput].
enum JustInputSize {
  /// Small size (height: 36px)
  sm,

  /// Medium size (height: 44px)
  md,

  /// Large size (height: 52px)
  lg,
}
