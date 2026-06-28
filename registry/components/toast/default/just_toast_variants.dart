/// Defines how multiple toasts behave when shown.
enum ToastBehavior {
  /// Toasts are stacked on top of each other (up to a limit).
  stacked,

  /// Toasts are shown one at a time in a queue.
  queue,
}

/// The visual style variant of a toast.
enum ToastVariant {
  /// Informational toast, typically neutral or blue.
  info,

  /// Success toast, typically green.
  success,

  /// Warning toast, typically yellow/orange.
  warning,

  /// Error/danger toast, typically red.
  error,
}

/// The screen position where toasts are anchored.
enum ToastPosition {
  /// Anchored at the top-left corner.
  topLeft,

  /// Anchored at the top-center.
  topCenter,

  /// Anchored at the top-right corner.
  topRight,

  /// Anchored at the bottom-left corner.
  bottomLeft,

  /// Anchored at the bottom-center.
  bottomCenter,

  /// Anchored at the bottom-right corner.
  bottomRight,
}
