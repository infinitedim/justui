# SIMD (`v128`), Concurrency, Direct Native Interop & WebAssembly (`--wasm`)

Read this reference when implementing `Float32x4List` / `v128` SIMD pipelines, `Isolate`s or Web Workers, direct native interop (`@Native`, `FFIgen`, `JNIgen`, Native Assets), or `dart2wasm` JS-buffer interop.

---

## 1. 128-Bit SIMD Acceleration (`Float32x4List`) for Native & WebAssembly

Dart 3.14 (`flutter build web --wasm`) compiles `Float32x4`, `Int32x4`, `Float64x2`, and directly constructed `Float32x4List` / `Int32x4List` / `Float64x2List` (`WasmArray<WasmV128>`) to **WebAssembly 128-bit SIMD (`v128`)** instructions as well as ARM NEON and x86 SSE on native AOT targets:

```dart
import 'dart:typed_data';

void integrateParticlesSimd({
  required Float32x4List positions,
  required Float32x4List velocities,
  required double dt,
}) {
  final Float32x4 dtVec = .splat(dt);
  final int count = positions.length;
  for (int i = 0; i < count; i++) {
    positions[i] += velocities[i] * dtVec;
  }
}
```

**Critical SIMD Guardrails:**

- **Allocate `Float32x4List(n)` directly:** On `dart2wasm`, calling `.buffer.asFloat32x4List()` on a `Float32List` or JS-backed `ByteBuffer` falls back to scalar `NaiveFloat32x4List` instead of `WasmArray<WasmV128>`.
- **Avoid scalar-fallback methods in tight loops:** Operations such as `Float32x4.clamp()` extract scalar lanes under `dart2wasm`.
- **`dart2js` fallback awareness:** On browsers without WasmGC where `dart2js` runs, `Float32x4List` has no hardware SIMD and allocates a JS wrapper per element access -- benchmark against plain `Float32List` if non-Wasm web users are a primary target.

---

## 2. Concurrency: Native Isolates, Worker Pools & Web Workers

- **Native Targets (iOS, Android, Desktop):**
  - Use `Isolate.run(...)` only for **coarse-grained / one-off** heavy tasks (large JSON parsing, RSA/AES crypto, image decode, large binary parse) where work substantially exceeds isolate spawn overhead (~1 ms+). Never capture `State`, `BuildContext`, or controllers inside `Isolate.run` closures; use top-level/static functions with sendable arguments.
  - For **high-frequency / per-frame** streams (audio frames, live sensor/DAQ buffers), keep a **long-lived worker `Isolate`** (`Isolate.spawn` + `SendPort`/`ReceivePort`) to avoid repeated spawn/teardown overhead.
  - **`TransferableTypedData` Accuracy:** Creating `TransferableTypedData.fromList([buffer])` takes **$O(N)$ copy time proportional to byte length**; `SendPort.send()` moves it between isolates in **$O(1)$** without a second copy, and never reuse the local transferable after sending. Returning results via `Isolate.exit(port, result)` (used by `Isolate.run`) is zero-copy from worker to caller.
- **Web & `--wasm` Targets:**
  - `dart:isolate` (`Isolate.run`, `Isolate.spawn`, `TransferableTypedData`) is **unsupported on Web** and throws `UnsupportedError` at runtime (`compute()` runs on the single Web UI thread!).
  - Guard isolate code behind `kIsWeb` / conditional imports and choose the right Web offloading strategy:
    1. **Time-sliced / chunked cooperative scheduling (Lowest friction):** Process moderate transforms in slices using a `Stopwatch` budget (`<= 4 ms` per slice) and yield between chunks (`await Future<void>.delayed(Duration.zero)` or `SchedulerBinding.instance.scheduleTask(...)`) so frames never stall on `> 50 ms` Long Tasks.
    2. **Dedicated Web Workers (`package:web` + `dart:js_interop`):** Spawn an external JS/Wasm worker (`web.Worker('worker.js'.toJS)`) and transfer `JSArrayBuffer` payloads via `postMessage` transferables for heavy parsing, crypto, or DSP.
    3. **Server-side pagination & binary framing:** Fetch paginated slices (`limit=20`) instead of downloading multi-megabyte JSON payloads to mobile web clients.

---

## 3. Direct Native Interop (`JNIgen`, `FFIgen`, `@Native` & Native Assets)

Prefer direct native interop over serialized `MethodChannel` round-trips for **fast, high-frequency, non-blocking** native APIs.

> **Plugin Skill Ownership:** When native `.h` headers exist or C/C++ sources must be compiled/bundled, follow `dart-use-ffigen` (`FfiGenerator` in `tool/ffigen.dart` -> `lib/src/third_party/*.g.dart`) and `dart-setup-ffi-assets` (`hook/build.dart` + `hook/link.dart` + `recordUseMapping`) instead of writing `@Native` or `DynamicLibrary.lookup` bindings by hand.

- **C/C++/Objective-C/Swift (`ffigen` + Native Assets):**
  - Bundle local C/C++ toolchains or verified prebuilt binaries via `hook/build.dart` (`package:hooks`, `package:native_toolchain_c`, `package:code_assets`) and strip unused symbols with `hook/link.dart` + `recordUseMapping`.
  - Enable `isLeaf: true` (via `ffigen` leaf config) only for fast functions that never call back into Dart or touch Dart `Handle`s.
- **Android (`jnigen`) & Pigeon:**
  - Call Kotlin/Java APIs via `jnigen` (or Pigeon with `useJni: true` / `useFfi: true`).
  - Release scoped Android JNI objects with `using((Arena arena) { ... releasedBy(arena); })`, call `.release()` in `dispose()` on long-lived references, and keep reflection/JNI targets via `@Keep` / ProGuard rules in release builds.
- **Threading Guardrail:**
  - Direct `@Native` / FFI / JNI calls execute **synchronously on the calling Dart isolate**. Never run slow/blocking OS or IO calls synchronously on the UI isolate; run them in a worker isolate or async `MethodChannel` / platform queue.

---

## 4. WebAssembly (`--wasm`), iOS WebKit Fallback & Memory Guardrails

Keep cross-platform and web code compatible with `flutter build web --wasm` (Skwasm on Blink/Chromium browsers), and verify with `--no-deprecated-js-interop` to fail fast on legacy imports in the `dart2js` fallback:

- **iOS WebKit & Firefox Default Fallback Reality (Flutter 3.50):** In `flutter_web_sdk`'s `browser_environment.js`, `defaultWasmSupport` enables `blink: true` while defaulting **`webkit: false` and `gecko: false`**. All iOS mobile browsers fall back to **`dart2js` + `CanvasKit`** unless explicitly overridden and verified via `wasmAllowList` in `flutter_bootstrap.js`. Keep `dart2js` fallback paths fast (benchmark `Float32x4List` vs `Float32List` if non-Wasm browsers matter).
- **Skwasm Linear Memory vs Mobile Tab Limits:** Skwasm compiles with shared Wasm memory (`--import-shared-memory --shared-memory-max-pages=32768`, up to 2 GB virtual address space) under COOP/COEP, while mobile Safari/Android tabs enforce tight physical RAM and WebGL limits -- keep decoded bitmaps, cached `ui.Image`s, and `scrollCacheExtent` tight.
- **Strictly Forbidden:** `dart:html`, `dart:js`, `dart:js_util`, `package:js`, and unguarded `dart:io`, `dart:isolate`, or `dart:mirrors`.
- **Required:** `package:web` for DOM/Browser APIs and static `@JS()` extension-type bindings via `dart:js_interop`.
- **WasmGC Buffer Copies vs Boundary Crossings:**
  - In `dart2wasm`, Dart objects live on the WasmGC heap, so calling `.toJS` on a Dart-allocated `Uint8List` **copies** bytes into JS memory.
  - Receiving a `JSArrayBuffer` / `JSUint8Array` from JS and calling `.toDart` creates a zero-copy view (which unwraps back via `.toJS` without copying).
  - **Caveat:** Every indexed read/write on that JS-backed view crosses the Wasm<->JS boundary -- use zero-copy `.toDart` for pass-through or sparse reads, and copy once into a Dart `Uint8List` before tight byte-processing loops in Dart.
