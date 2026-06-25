import 'package:flutter/painting.dart';

/// Radius tokens for JustUI.
///
/// Exposes circular [Radius] constants to be used in borders or custom shapes.
/// All values are compile-time constants.
abstract final class JustRadius {
  /// Sharp corners (0.0px)
  static const Radius none = .zero;

  /// Extra small corner rounding (2.0px) - subtle elements
  static const Radius xs = .circular(2.0);

  /// Small corner rounding (4.0px) - badges / tags
  static const Radius sm = .circular(4.0);

  /// Medium corner rounding (8.0px) - buttons / inputs / checkboxes
  static const Radius md = .circular(8.0);

  /// Large corner rounding (12.0px) - cards / banners
  static const Radius lg = .circular(12.0);

  /// Extra large corner rounding (16.0px) - dialogs / sheets
  static const Radius xl = .circular(16.0);

  /// Double extra large corner rounding (24.0px) - bottom sheets / large modals
  static const Radius xxl = .circular(24.0);

  /// Fully rounded pill shape (9999.0px) - avatars / pill buttons
  static const Radius full = .circular(9999.0);
}

/// A helper class providing [BorderRadius] shortcuts mapping directly to [JustRadius].
///
/// Avoids the boilerplate of wrapping `Radius` values in `.all`.
abstract final class JustBorderRadius {
  /// Sharp corners (0.0px)
  static const BorderRadius none = .zero;

  /// Extra small [BorderRadius] (2.0px)
  static const BorderRadius xs = .all(JustRadius.xs);

  /// Small [BorderRadius] (4.0px)
  static const BorderRadius sm = .all(JustRadius.sm);

  /// Medium [BorderRadius] (8.0px)
  static const BorderRadius md = .all(JustRadius.md);

  /// Large [BorderRadius] (12.0px)
  static const BorderRadius lg = .all(JustRadius.lg);

  /// Extra large [BorderRadius] (16.0px)
  static const BorderRadius xl = .all(JustRadius.xl);

  /// Double extra large [BorderRadius] (24.0px)
  static const BorderRadius xxl = .all(JustRadius.xxl);

  /// Fully rounded pill [BorderRadius] (9999.0px)
  static const BorderRadius full = .all(JustRadius.full);
}
