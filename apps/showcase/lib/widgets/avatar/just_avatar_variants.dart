// justui-meta: registry=c924f3f83a250f154c975722148828042a49db34f03c8be11987119346a01ea9 local=c924f3f83a250f154c975722148828042a49db34f03c8be11987119346a01ea9
/// Sizing classifications for [JustAvatar].
enum JustAvatarSize {
  /// Extra small avatar (diameter: 24px)
  xs,

  /// Small avatar (diameter: 32px)
  sm,

  /// Medium avatar (diameter: 40px)
  md,

  /// Large avatar (diameter: 48px)
  lg,

  /// Extra large avatar (diameter: 64px)
  xl,

  /// Double extra large avatar (diameter: 96px)
  xxl,
}

/// Border shape boundary options for [JustAvatar].
enum JustAvatarShape {
  /// Circular shape.
  circle,

  /// Soft square shape (border radius xl = 16px).
  rounded,
}

/// Presence status dot indicators.
enum JustAvatarStatus {
  /// User is active / online.
  online,

  /// User is inactive / offline.
  offline,

  /// User is away.
  away,

  /// User is busy / do not disturb.
  busy,
}
