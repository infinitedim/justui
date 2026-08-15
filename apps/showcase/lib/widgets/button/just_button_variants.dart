// justui-meta: registry=9bea3b598953dd5286287ab5c798c28ed738c1a57204fccd3842d03a468f30cc local=9bea3b598953dd5286287ab5c798c28ed738c1a57204fccd3842d03a468f30cc
/// The visual style variants for [JustButton] and [JustIconButton].
enum JustButtonVariant {
  /// Solid primary colored background with white/contrasting text.
  primary,

  /// Outline border with transparent background and colored text.
  secondary,

  /// Fully transparent background with text color only.
  ghost,

  /// Solid red-toned background with white text.
  destructive,

  /// Underlined text with zero background, border, or padding.
  link,
}

/// The sizing options for [JustButton] and [JustIconButton].
enum JustButtonSize {
  /// Extra small button (height: 28px)
  xs,

  /// Small button (height: 32px)
  sm,

  /// Medium button (height: 40px)
  md,

  /// Large button (height: 48px)
  lg,

  /// Extra large button (height: 56px)
  xl,
}
