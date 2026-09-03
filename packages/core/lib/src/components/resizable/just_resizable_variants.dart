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
