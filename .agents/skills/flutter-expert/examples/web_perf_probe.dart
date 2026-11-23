// Optional Flutter Web (--wasm / dart2js) frame-timing and first-frame bridge
// for `scripts/profile_mobile_web.mjs`. Copy into your target app's `lib/`
// directory (do not import directly across packages).
//
// In cross-platform apps, import conditionally so native targets stay clean:
//   import 'web_perf_probe_stub.dart'
//       if (dart.library.js_interop) 'web_perf_probe.dart';
//
// Activate only in profile builds or when `--dart-define=PERF_PROBE=true` is set.

import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

const bool _enablePerfProbe =
    kProfileMode || bool.fromEnvironment('PERF_PROBE');

@JS('performance')
external _JsPerformance get _performance;

extension type _JsPerformance._(JSObject _) implements JSObject {
  external double now();
}

@JS('__flutterFrameTimings')
external _MutableJsArray<_JsFrameSample>? get _jsFrameTimings;

@JS('__flutterFrameTimings')
external set _jsFrameTimings(_MutableJsArray<_JsFrameSample>? value);

@JS('__flutterFirstFrameMs')
external set _jsFirstFrameMs(double? value);

@JS('Array')
extension type _MutableJsArray<T extends JSAny?>._(JSArray<T> _)
    implements JSArray<T> {
  external factory _MutableJsArray();
  external void push(T item);
  external void shift();
  external int get length;
}

extension type _JsFrameSample._(JSObject _) implements JSObject {
  external factory _JsFrameSample({
    required int buildUs,
    required int rasterUs,
    required int totalUs,
  });
}

bool _installed = false;

/// Registers a bounded ring buffer of Flutter [FrameTiming] samples on
/// `window.__flutterFrameTimings` and records `window.__flutterFirstFrameMs`
/// after the first post-frame callback for mobile web CDP profiling.
///
/// Note: `scripts/profile_mobile_web.mjs` clears
/// `window.__flutterFrameTimings.length = 0` in place before active scroll
/// sampling so cold startup warmup frames do not skew p95 build/raster timings.
void installMobileWebPerfProbe({int maxSamples = 600}) {
  assert(maxSamples > 0, 'maxSamples must be positive');
  if (!_enablePerfProbe || !kIsWeb || _installed || maxSamples <= 0) return;
  WidgetsFlutterBinding.ensureInitialized();
  _installed = true;

  final _MutableJsArray<_JsFrameSample> buffer = _jsFrameTimings ?? .new();
  _jsFrameTimings = buffer;

  SchedulerBinding.instance.addPostFrameCallback((Duration _) {
    _jsFirstFrameMs = _performance.now();
  });

  SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
    for (final FrameTiming timing in timings) {
      buffer.push(
        .new(
          buildUs: timing.buildDuration.inMicroseconds,
          rasterUs: timing.rasterDuration.inMicroseconds,
          totalUs: timing.totalSpan.inMicroseconds,
        ),
      );
      if (buffer.length > maxSamples) buffer.shift();
    }
  });
}
