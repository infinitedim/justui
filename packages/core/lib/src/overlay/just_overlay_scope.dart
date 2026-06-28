import 'package:flutter/widgets.dart';
import 'just_overlay_controller.dart';

/// A generic [InheritedWidget] base class that exposes an overlay controller
/// to the widget tree.
class JustOverlayScope<T extends JustOverlayController>
    extends InheritedWidget {
  /// The controller managed by this scope.
  final T controller;

  /// Creates a [JustOverlayScope].
  const JustOverlayScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Retrieves the controller of type [T] from the nearest ancestor [JustOverlayScope].
  static T of<T extends JustOverlayController>(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<JustOverlayScope<T>>();
    assert(scope != null, 'No JustOverlayScope<$T> found in context');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(covariant JustOverlayScope<T> oldWidget) {
    return controller != oldWidget.controller;
  }
}
