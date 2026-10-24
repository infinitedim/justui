import 'package:showcase/bridge/bridge.dart';

/// Stands in for the page: serves configs and records announced views.
class FakeBridgePlatform implements BridgePlatform {
  FakeBridgePlatform(this.configs);

  /// The `initialData.config` per view id.
  final Map<int, Object?> configs;

  /// The update callback of each announced view.
  final Map<int, Future<void> Function(Object? patch)> controllers =
      <int, Future<void> Function(Object? patch)>{};

  /// How many times each view was announced.
  final Map<int, int> announceCount = <int, int>{};

  @override
  Object? initialConfig(int viewId) => configs[viewId];

  @override
  void announce(int viewId, Future<void> Function(Object? patch) update) {
    controllers[viewId] = update;
    announceCount[viewId] = (announceCount[viewId] ?? 0) + 1;
  }
}
