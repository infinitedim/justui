/// The visual style variants for [JustProgress].
enum JustProgressVariant {
  /// Horizontal linear progress bar.
  linear,

  /// Circular progress indicator.
  circular,
}

/// The physical size classification for [JustProgress].
enum JustProgressSize {
  /// Small size
  /// - Linear height: 4px
  /// - Circular diameter: 32px
  sm,

  /// Medium size (default)
  /// - Linear height: 8px
  /// - Circular diameter: 48px
  md,

  /// Large size
  /// - Linear height: 12px
  /// - Circular diameter: 64px
  lg,
}
