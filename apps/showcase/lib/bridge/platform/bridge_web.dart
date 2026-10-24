import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'bridge_platform.dart';

/// The browser implementation: `initialData` in, `onReady(controller)` out.
final BridgePlatform platform = _WebBridgePlatform();

/// The `initialData` the docs bridge passes to `app.addView`.
extension type _InitialData._(JSObject _) implements JSObject {
  external JSAny? get config;
  external JSAny? get onReady;
}

/// The only object the page receives. It exposes one method, so the page
/// can change a view only through the validated config patch.
@JSExport()
class _ViewController {
  _ViewController(this._update);

  final Future<void> Function(Object? patch) _update;

  /// Applies [patch] (validated in Dart) and resolves after the next frame.
  JSPromise<JSAny?> update(JSAny? patch) => _update(patch.dartify()).toJS;
}

class _WebBridgePlatform implements BridgePlatform {
  _InitialData? _data(int viewId) {
    final JSAny? data = ui_web.views.getInitialData(viewId);
    if (data == null || !data.isA<JSObject>()) return null;
    return data as _InitialData;
  }

  @override
  Object? initialConfig(int viewId) => _data(viewId)?.config.dartify();

  @override
  void announce(int viewId, Future<void> Function(Object? patch) update) {
    final JSAny? onReady = _data(viewId)?.onReady;
    if (onReady == null || !onReady.isA<JSFunction<Function>>()) return;
    final JSObject controller = createJSInteropWrapper<_ViewController>(
      _ViewController(update),
    );
    (onReady as JSFunction<Function>).callAsFunction(null, controller);
  }
}
