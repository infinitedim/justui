// justui-meta: registry=a422e8ee007e739de9a41c7dd635d76c44a9a513b2992fbdfbd467d567e4b6df local=a422e8ee007e739de9a41c7dd635d76c44a9a513b2992fbdfbd467d567e4b6df
/// The position where the tooltip is anchored relative to its target widget.
enum TooltipPosition {
  /// Positioned above the target.
  top,

  /// Positioned below the target.
  bottom,

  /// Positioned to the left of the target.
  left,

  /// Positioned to the right of the target.
  right,

  /// Automatically selects the best position based on viewport space.
  auto,
}
