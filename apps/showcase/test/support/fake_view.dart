import 'dart:ui' show FlutterView, Scene, SemanticsUpdate, Size;

import 'package:flutter_test/flutter_test.dart';

/// A second view for multi-view tests, like the docs page's extra hosts.
///
/// Copied from the framework's own `multi_view_testing.dart`: it shares the
/// test view's dispatcher and display, and drops renders and semantics
/// updates because the engine only observes the test view.
class FakeView extends TestFlutterView {
  /// A view with [viewId] that mirrors [view].
  FakeView(FlutterView view, {this.viewId = 100})
    : super(
        view: view,
        platformDispatcher: view.platformDispatcher as TestPlatformDispatcher,
        display: view.display as TestDisplay,
      );

  @override
  final int viewId;

  @override
  void render(Scene scene, {Size? size}) {}

  @override
  void updateSemantics(SemanticsUpdate update) {}
}
