import 'dart:ui' show FlutterView;

import 'package:flutter/widgets.dart';

/// Renders [viewBuilder] into every `FlutterView` the page adds, and drops a
/// view's tree when the page removes its host element.
class const MultiViewApp({
  super.key,

  /// Builds the content of the view with this id.
  required final Widget Function(int viewId) viewBuilder,
}) extends StatefulWidget {
  @override
  State<MultiViewApp> createState() => _MultiViewAppState();
}

class _MultiViewAppState extends State<MultiViewApp>
    with WidgetsBindingObserver {
  Map<int, Widget> _views = <int, Widget>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateViews();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Views are added and removed by the page; the engine reports both as a
  // metrics change.
  @override
  void didChangeMetrics() => setState(_updateViews);

  void _updateViews() {
    final Map<int, Widget> next = <int, Widget>{};
    for (final FlutterView view
        in WidgetsBinding.instance.platformDispatcher.views) {
      next[view.viewId] =
          _views[view.viewId] ??
          View(
            key: ValueKey<int>(view.viewId),
            view: view,
            child: widget.viewBuilder(view.viewId),
          );
    }
    _views = next;
  }

  @override
  Widget build(BuildContext context) =>
      ViewCollection(views: _views.values.toList());
}
