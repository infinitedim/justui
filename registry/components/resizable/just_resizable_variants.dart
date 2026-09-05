export 'package:flutter/widgets.dart' show Axis;

/// Visual handle variants for the splitter divider in [JustResizable].
enum JustResizableHandleVariant {
  /// Simple divider line without grip affordance.
  line,

  /// Divider line with a centered grip pill / handle.
  grip,

  /// Invisible splitter line, interactive hit-box only.
  none,
}

/// Action performed when double-tapping or double-clicking a splitter handle.
enum JustResizableDoubleTapBehavior {
  /// Toggles between collapsed and expanded state for the adjacent collapsible panel.
  toggle,

  /// Collapses the adjacent collapsible panel.
  collapse,

  /// Resets all panels to their initial configured proportions.
  reset,

  /// Disables double-tap interaction.
  none,
}
