/// How a view talks to the page that hosts it.
///
/// The web implementation reads the view's `initialData` and hands the page a
/// controller through its `onReady` callback. Tests and VM runs use a stub,
/// so the bridge widgets stay testable without a browser.
abstract interface class BridgePlatform {
  /// The `config` object of [viewId]'s `initialData`, converted to Dart
  /// values (maps, lists, strings, numbers, booleans), or null.
  Object? initialConfig(int viewId);

  /// Gives the page a controller for [viewId]. [update] applies a config
  /// patch and completes after the next frame shows it.
  void announce(int viewId, Future<void> Function(Object? patch) update);
}
