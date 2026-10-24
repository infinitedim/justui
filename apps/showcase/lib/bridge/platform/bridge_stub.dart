import 'bridge_platform.dart';

/// Outside the browser there is no page to talk to.
final BridgePlatform platform = _StubBridgePlatform();

class _StubBridgePlatform implements BridgePlatform {
  @override
  Object? initialConfig(int viewId) => null;

  @override
  void announce(int viewId, Future<void> Function(Object? patch) update) {}
}
