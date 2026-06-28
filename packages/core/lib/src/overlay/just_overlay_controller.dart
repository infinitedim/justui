import 'package:flutter/widgets.dart';

/// Callback signature for custom overlay transition animations.
typedef JustOverlayAnimationBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// Base contract for all imperative overlay controllers in JustUI.
abstract class JustOverlayController {
  /// Whether the overlay is currently visible.
  bool get isVisible;

  /// Dismisses the overlay, triggering any exit animations.
  void dismiss();

  /// Disposes resources held by the controller.
  void dispose();
}
