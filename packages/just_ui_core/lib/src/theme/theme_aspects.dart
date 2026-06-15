/// Aspects of the JustUI theme.
///
/// Used by the InheritedModel provider to allow widgets to subscribe
/// to only specific components of the theme, minimizing rebuilds.
enum JustThemeAspect {
  /// Color scheme aspect.
  colors,

  /// Typography aspect.
  typography,

  /// Spacing aspect.
  spacing,

  /// Border radius aspect.
  radius,

  /// Shadows aspect.
  shadows,

  /// Durations and curves aspect.
  animations,
}
