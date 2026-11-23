# Mobile Web Browser Performance Analysis, Profiling & Evaluation

Read this reference whenever analyzing, building, profiling, or evaluating a Flutter Web application for **mobile web browsers** (`--wasm` Skwasm and `dart2js` + CanvasKit fallback).

Mobile web browsers amplify bottlenecks that desktop and native Impeller hide: **4x-6x slower single-core CPUs**, **2x-3x DPR** multiplying fill rate (`390x844 @3x` = `1170x2532` physical pixels), strict tab RAM/WebGL VRAM limits, **Skia-over-WebGL2** shader compilation, iOS WebKit defaulting to `dart2js` + `CanvasKit`, and cellular download latency.

> **Resolving `<skill_dir>`:** Run the Node scripts below using the directory containing the active `SKILL.md` (for example `.agents/skills/flutter-expert` or `~/.gemini/config/skills/flutter-expert`), not relative to the target app's working directory.

---

## 1. 4-Stage AI Agent Evaluation Workflow

### Stage 1: Analyze Code, `--wasm` Compatibility & Bundle Budget
1. **Verify clean Wasm + Fallback compilation (note: `--analyze-size` is native-only, not supported on `flutter build web`):**
   - For runtime profiling:
     `flutter build web --wasm --profile`
   - For final payload audit and JS-interop hygiene (`--no-deprecated-js-interop` rejects legacy imports in the `dart2js` fallback):
     `flutter build web --wasm --release --no-deprecated-js-interop`
   - **Deferred Loading Flag (Flutter 3.50):** Dart `deferred as` splits JS (`*.part.js`) automatically, **but `main.dart.wasm` remains monolithic unless `--enable-wasm-deferred-loading` is passed** (`flutter build web --wasm --release --enable-wasm-deferred-loading`). Note `--enable-wasm-deferred-loading` cannot be combined with `--web-content-hash`.
   - **CDN vs Self-Hosted Runtime (`--web-resources-cdn`):** By default, Flutter fetches `skwasm.wasm` (~3.5 MB raw), `skwasm_heavy.wasm` (~5.1 MB raw), and `canvaskit.wasm` (~7.3 MB raw) from `gstatic.com`. Use `--no-web-resources-cdn` behind strict CSP, offline-first caches, or restrictive `COOP/COEP`.
2. **Measure mobile bundle & asset budgets:**
   Run [analyze_web_bundle.mjs](../scripts/analyze_web_bundle.mjs) (zero npm dependencies). It separates **Initial App Core Payload** from **Initial Startup Payload (Core + Fonts + Manifests)** and **Bundled Renderer Runtime**, inspects `flutter_bootstrap.js` even when `index.html` is pruned (multi-view embed bundles), strips HTML comments, flags JS-only deferred chunks missing `--enable-wasm-deferred-loading`, recommends `.woff2` for large TTF/OTF fonts, and ignores Flutter's lazy `assets/NOTICES`:
   ```bash
   node <skill_dir>/scripts/analyze_web_bundle.mjs <project_dir>/build/web
   # CI / strict gate example:
   node <skill_dir>/scripts/analyze_web_bundle.mjs <project_dir>/build/web --fail-on fail --json
   ```
   Pass `--max-initial-kb 1500 --max-asset-kb 250` for custom budgets, and `--fail-on <none|fail|warn>` (default `none`) to control non-zero exit codes.
3. **Audit mobile-web source & shell hotspots:**
   - **Active Viewport & Fast App Shell (`web/index.html` + `web/flutter_bootstrap.js`):**
     * Check whether `<meta name="viewport">` is commented out in `index.html` and keep it active: `<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">`.
     * Eliminate white-screen boot lag with an inline HTML/CSS splash in `<body>`, `<link rel="preconnect">` to CDN/API origins, and clean teardown via `flutter_bootstrap.js`.
     * Serve `index.html` and `flutter_bootstrap.js` with `Cache-Control: no-cache`, and `--web-content-hash` hashed files with `max-age=31536000, immutable`.
   - **Image Double-Decode Trap on Web:** On Web (`Image.network` with default `WebHtmlElementStrategy.never`), passing `cacheWidth`/`cacheHeight` invokes `instantiateImageCodecWithSize`, which **decodes the full-resolution image first** just to read dimensions before rescaling while still downloading full bytes over 4G. Omit `cacheWidth`/`cacheHeight` on `Image.network` for Web and request CDN-sized WebP/AVIF URLs (`?w=...`), tune `PaintingBinding.instance.imageCache.maximumSizeBytes`, and use `WebHtmlElementStrategy.fallback` only when third-party CORS cannot be configured (avoiding `HtmlElementView` inside scrolling lists).
   - **Fonts & `FallbackFontService` Waterfall:** Subset custom fonts and convert `.ttf`/`.otf` to **`.woff2`**. Missing glyphs (icons/CJK/emoji) trigger runtime Noto font downloads from `fonts.gstatic.com/s/` -- bundle needed glyphs (or map fallback font families locally when strict CSP blocks `gstatic.com`) or set `fontFallbackBaseUrl` in `flutter_bootstrap.js`.
   - **WebGL2 Shaders, Blurs & Soft-Keyboard Rebuilds:** Warm up custom `FragmentProgram`s before interaction, minimize `BackdropFilter`, `Opacity` `saveLayer()`, large `BoxShadow`s, and oversized `scrollCacheExtent` on 3x DPR screens, and use `MediaQuery.sizeOf` / `viewInsetsOf` (see [modern-dart-and-flutter350.md](./modern-dart-and-flutter350.md) and [rendering-impeller-webgl.md](./rendering-impeller-webgl.md)).

---

### Stage 2: Profile Under Mobile Browser Emulation
1. **(Recommended for Build vs Raster & First-Frame Attribution):**
   Copy [web_perf_probe.dart](../examples/web_perf_probe.dart) into your app's `lib/` directory and wire `installMobileWebPerfProbe()` conditionally in `main()` under `--profile` or `--dart-define=PERF_PROBE=true`. This exposes `FrameTiming` (`buildUs`, `rasterUs`, `totalUs`) on `window.__flutterFrameTimings` and `window.__flutterFirstFrameMs` via `dart:js_interop`.
2. **Run automated mobile CDP profiling:**
   Use [profile_mobile_web.mjs](../scripts/profile_mobile_web.mjs) (headless Chrome via CDP with touch, DPR, 4x CPU throttle, 4G shaping, alternating touch scroll sweeps, and zero npm deps):
   ```bash
   # 1. Mid-tier Android Skwasm baseline (390x844 @3x DPR, 4x CPU throttle, 4G)
   node <skill_dir>/scripts/profile_mobile_web.mjs --serve <project_dir>/build/web --screenshot <out>/mobile_mid.png

   # 2. Compact Android + Slow 4G + multi-threaded Skwasm (COOP/COEP)
   node <skill_dir>/scripts/profile_mobile_web.mjs --serve <project_dir>/build/web --device compact-android --network slow-4g --cpu 4 --coop-coep --coep-mode credentialless --screenshot <out>/mobile_compact.png

   # 3. Simulated iOS WebKit fallback (exercises Flutter 3.50 dart2js + CanvasKit fallback path)
   node <skill_dir>/scripts/profile_mobile_web.mjs --serve <project_dir>/build/web --device ios-safari --simulate-webkit-fallback --cpu 4 --network 4g --fail-on fail
   ```
   > **iOS Safari Emulation Caveat:** Running `--device ios-safari` *without* `--simulate-webkit-fallback` still executes Chromium Blink (`Skwasm`). Always pass `--simulate-webkit-fallback` to exercise the `dart2js` + `CanvasKit` path, and test real iOS hardware/WebKit for JSC/Metal GPU and tab RAM limits.
3. **Antigravity Interactive Browser Verification (`playwright` vs `chrome-devtools`):**
   - Inspect `--screenshot` PNGs for clipping, horizontal overflow, soft-keyboard crowding, or small touch targets (`< 44x44` on primary touch controls).
   - **Follow project MCP rules first:** When **`playwright`** MCP is active/mandated (as in JustUI), use `playwright` (`browser_resize`, `browser_emulate_media`, `browser_snapshot`, `browser_take_screenshot`, `browser_console_messages`, `browser_network_requests`) for UI, dark/light, and a11y checks, and pair it with `profile_mobile_web.mjs` for CDP mobile frame/network telemetry.
   - Only use **`chrome-devtools`** MCP (`emulate`, `performance_start_trace`, `performance_analyze_insight`) when that server is enabled and allowed (`lighthouse_audit` covers accessibility/SEO/best-practices and **excludes performance**). Note also `chrome-devtools` `drag` requires DOM UIDs while Flutter paints to `<canvas>`, so prefer `profile_mobile_web.mjs` touch sweeps for scroll FPS.
   - If `chromedriver` + `integration_test` exist, `watchPerformance` also runs via:
     `flutter drive --driver=test_driver/perf_driver.dart --target=integration_test/perf_test.dart -d chrome --profile --wasm --browser-dimension=390x844@3`

---

### Stage 3: Assess Against Mobile Web Thresholds

| Metric | PASS | WARN | FAIL |
| :--- | :--- | :--- | :--- |
| **Runtime / Console / HTTP Errors** | 0 errors, 0 failed requests | -- | >= 1 uncaught error, console error, or failed/COEP-blocked asset |
| **Renderer (`--wasm` build)** | `skwasm-wasm` (or `canvaskit-js` under `--simulate-webkit-fallback`) | Unexpected `canvaskit-js` fallback | Boot failure (`flutterDetectedAtMs: null`) |
| **First Scene / Startup (4G + 4x CPU)** | <= 4,000 ms | 4,001-8,000 ms | > 8,000 ms |
| **Initial App Core / Startup Payload (Brotli)** | <= 1,500 KB | 1,501-3,000 KB | > 3,000 KB |
| **Total Initial Network Transfer (incl. CDN)** | <= 2,500 KB | 2,501-5,000 KB | > 5,000 KB |
| **Single Image / Font / Asset (Raw)** | <= 250 KB | 251-500 KB | > 500 KB |
| **Throttled Mobile p95 Frame Time** | <= 24.0 ms | 24.1-33.3 ms | > 33.3 ms (< 30 FPS) |
| **Severe Jank (> 50 ms) / Interactive Long Task** | 0 frames / <= 200 ms (boot <= 600 ms) | 1-3 frames / > 200 ms (boot > 600 ms) | > 3 severe frames |
| **Flutter Engine Build / Raster p95** | Each <= 12.0 ms | 12.1-16.7 ms | > 16.7 ms |
| **HTML Horizontal Overflow** | 0 px | > 0 px | -- |

> **Memory Note (`--wasm`):** CDP `JSHeapUsedSize` only reports JS glue memory (~5-15 MB) and **excludes** WasmGC Dart objects, Skwasm linear memory, and WebGL texture VRAM. Profile real mobile Safari/Android tabs when investigating VRAM OOMs.

---

### Stage 4: Evaluate & Diagnose Root Causes

Map observed telemetry directly to fixes, rebuild (`--wasm --profile`), and **re-run the exact same probe** to verify improvement:

| Observed Mobile Web Symptom | Primary Culprit | Target Fix |
| :--- | :--- | :--- |
| **Slow 4G startup (> 4s) / large transfer** | Monolithic Wasm, large TTF/OTF fonts, oversized images, missing splash shell | Split heavy routes with `deferred as` + `--enable-wasm-deferred-loading` (omit `--web-content-hash`), subset fonts to `.woff2`, add inline splash + `<link rel="preconnect">`, trim unused Material dependencies |
| **High `buildDuration` during scroll / typing** | `shrinkWrap: true`, missing `itemExtent`, broad `MediaQuery.of` rebuilding on soft-keyboard `viewInsets`, whole-screen notifiers | Switch to `CustomScrollView` + `SliverFixedExtentList`/`SliverVariedExtentList`, `MediaQuery.*Of`, leaf `ValueListenableBuilder`, `class const` leaf widgets |
| **High `rasterDuration` / first-tap jank at 3x DPR** | First-use WebGL compile of custom `FragmentProgram`s (or forced `InkSparkle`), `BackdropFilter`, `Opacity` `saveLayer()`, large `BoxShadow`s, oversized `scrollCacheExtent` | Warm up custom shaders off-path, drop forced `InkSparkle` on Web, use leaf `withValues(alpha:)`, trim blurs/shadows on scrollables, cap `scrollCacheExtent` |
| **Long Tasks (> 50 ms) during data load** | Sync JSON/binary parsing or `compute()` running on Web main thread, byte-by-byte `.toDart` loops | Paginate APIs, chunk transforms into `<= 4 ms` async slices, or offload to a Web Worker (`package:web` + `dart:js_interop`); copy `JSUint8Array.toDart` once |
| **Text pop-in / extra font requests** | `FallbackFontService` fetching Noto fonts from `fonts.gstatic.com` | Subset & bundle `.woff2` fonts covering app locales/glyphs; configure `fontFallbackBaseUrl` if self-hosted |
| **`ERR_BLOCKED_BY_RESPONSE` under `--coop-coep`** | `COEP: require-corp` blocking third-party CDN images or iframes lacking `CORP` headers | Test `--coep-mode credentialless`, add `Cross-Origin-Resource-Policy: cross-origin` on owned CDNs, or evaluate single-threaded Skwasm |
| **iOS Safari slowdowns or crashes** | `defaultWasmSupport.webkit: false` running `dart2js` + `canvaskit.wasm`, double-decoded 4K images, `Float32x4List` scalar overhead | Benchmark `--simulate-webkit-fallback`, omit `cacheWidth` on `Image.network` and serve sized CDN WebP/AVIF URLs, lower `ImageCache.maximumSizeBytes`, avoid `HtmlElementView` in lists |
