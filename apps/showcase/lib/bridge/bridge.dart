import 'platform/bridge_platform.dart';
import 'platform/bridge_stub.dart'
    if (dart.library.js_interop) 'platform/bridge_web.dart'
    as impl;

export 'platform/bridge_platform.dart';

/// The platform for this build; tests replace it with [debugBridgePlatform].
BridgePlatform get bridgePlatform => debugBridgePlatform ?? impl.platform;

/// Test-only override of [bridgePlatform].
BridgePlatform? debugBridgePlatform;
