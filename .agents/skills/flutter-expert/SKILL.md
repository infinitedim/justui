---
name: flutter-expert
description: >-
  Portable Flutter 3.50 and Dart 3.14+ engineering standard and Antigravity
  workflow for building, refactoring, optimizing, and empirically evaluating
  high-performance apps across native and mobile web targets. Apply for widgets,
  forms, theming, state scopes, slivers, CustomPainters, FragmentShaders, 3D
  Matrix4 transforms, SIMD (v128), native interop (FFIgen/JNIgen/Native
  Assets), isolates, WebAssembly (--wasm) builds, mobile web profiling, or
  orchestrating Flutter MCP tools and plugin skills.
---

# Flutter 3.50 & Dart 3.14+ Engineering Standard

Build idiomatic, empirically verifiable Flutter 3.50 (Dart 3.14+) code that matches project lints, keeps rebuilds and allocations lean, respects threading and WebGL/Wasm boundaries, meets baseline accessibility on custom controls, and integrates cleanly with Antigravity MCP tools and plugin skills.

---

## 1. Antigravity Execution Workflow

1. **Ground in Project Context First (Files + Lazy MCP):**
   - Inspect `pubspec.yaml` (SDK bounds, `material_ui`/`cupertino_ui`, `flutter_web_plugins`), `analysis_options.yaml` (`always_specify_types`, `strict-*`, `primary-constructors`), and `web/index.html` / `web/flutter_bootstrap.js` when targeting web.
   - Use **`flutter_dart-mcp-server`** (or `dart-mcp-server`) inspection tools (`read_package_uris`, `rip_grep_packages`, `lsp` `hover`/`signatureHelp`/`resolveWorkspaceSymbol`, `pub_dev_search`, `pub`) instead of guessing APIs. **Lazy MCP rule:** read `<appDataDir>/mcp/<serverName>/<toolName>.json` before `call_mcp_tool`.
   - **Compatibility Guard:** Default to Dart 3.14+ / Flutter 3.50 syntax unless `pubspec.yaml` pins an older SDK. Only import `package:material_ui/material_ui.dart` / `package:cupertino_ui/cupertino_ui.dart` when already declared or explicitly adding them (`dart fix --apply` in Flutter 3.50.0 does not auto-migrate `package:flutter/material.dart`).
2. **Scope, Accessibility & Baseline Ergonomics:**
   - Change only what the task requires; preserve unrelated code/comments and never suppress diagnostics with `// ignore:` without a same-line reason.
   - Provide `Semantics`, keyboard `Focus` traversal, visible focus styling, and reduced-motion (`MediaQuery.disableAnimationsOf(context)`) on custom interactive, `CustomPaint`, or icon-only controls, and follow project a11y rules (`flutter.md`, `ui-a11y`) when present. Avoid redundant `Semantics` wrappers over widgets that already expose native semantics (`Text`, standard buttons) and avoid unrequested a11y rewrites on unrelated screens.
3. **Load Specialist References On-Demand (Read Only What You Need):**
   - **Dart 3.14+ Syntax, Daily UI Patterns & Flutter 3.50 Migrations** (dot shorthands, `class const` + `const new`, explicit types, forms/focus, async UI states, token themes, `MediaQuery.*Of`, `material_ui` guard): [modern-dart-and-flutter350.md](./references/modern-dart-and-flutter350.md)
   - **Rendering, Impeller & WebGL2** (`CustomPainter`, `ui.Picture`/`toImageSync`, `TextPainter`, 3D `Matrix4`, batched canvas calls, `FragmentProgram`, `saveLayer`/`Opacity`/`Visibility`, surgical `RepaintBoundary`): [rendering-impeller-webgl.md](./references/rendering-impeller-webgl.md)
   - **Concurrency, SIMD, Native Interop & `--wasm`** (`Float32x4List` `v128`, `Isolate.run`/pools, `TransferableTypedData`, Web chunking/Workers, `ffigen`/`jnigen`/Native Assets, `dart2wasm` JS buffers, iOS WebKit fallback): [concurrency-simd-interop-wasm.md](./references/concurrency-simd-interop-wasm.md)
   - **Mobile Web Performance & CDP Profiling** (`--wasm` Skwasm vs `dart2js`, deferred loading, WOFF2 fonts, `Image.network` double-decode trap, bundle budgets, `analyze_web_bundle.mjs`, `profile_mobile_web.mjs`): [mobile-web-performance.md](./references/mobile-web-performance.md)
4. **Verify Empirically (`--profile` / `--release` for Perf):**
   - **Static & Tests:** Run `analyze_files` MCP (or `dart analyze`) and `flutter test` after edits (note some `flutter` plugin docs mention `launch_app`/`run_tests`, which may not be mounted on every server; use CLI `flutter test` / `flutter run` when absent).
   - **Live App (`dtd`):** When an interactive debug/profile app is running, call `dtd` (`listDtdUris` -> `connect` -> `listConnectedApps`) before `hot_reload`, `hot_restart`, `get_runtime_errors`, `widget_inspector`, or `flutter_driver_command`. Honor `flutter-hot-reload` on `lib/**/*.dart` only when an active app is connected.
   - **Browser & Telemetry Verification:** Follow project browser rules first (e.g., use **`playwright`** MCP when configured for UI, snapshot, dark/light, and a11y checks). Measure native perf in `--profile`/`--release` (`--analyze-size`, `addTimingsCallback`) and Mobile Web via `flutter build web --wasm --profile|--release` + [analyze_web_bundle.mjs](./scripts/analyze_web_bundle.mjs) + [profile_mobile_web.mjs](./scripts/profile_mobile_web.mjs) (pass `--fail-on fail|warn` in CI). Resolve `<skill_dir>` from this `SKILL.md` directory, not app CWD. Only use **`chrome-devtools`** MCP (`emulate`, `performance_start_trace`, `performance_analyze_insight`) if enabled and permitted (`lighthouse_audit` excludes performance).
   - **Multi-Screen Fan-Out:** For >3 independent screens, invoke parallel `self` subagents via `invoke_subagent` with `Workspace: "inherit"`.

---

## 2. Plugin Skill & Tool Synergy Matrix

**Precedence Rule:** When a domain plugin skill owns a workflow whose examples show older idioms (`package:flutter/material.dart`, `MediaQuery.of`, `Map<String, dynamic>`, Web `compute()`), follow *that skill's* workflow while upgrading its code to Dart 3.14+ syntax, project lint rules, and the guardrails below.

| Domain / Task | Primary Owner (Skill / MCP) | `flutter-expert` Guardrails |
| :--- | :--- | :--- |
| **Static Analysis, Errors & Pub** | `dart-run-static-analysis` (`analyze_files`), `dart-fix-runtime-errors` (`dtd`, `get_runtime_errors`, `lsp`, `hot_reload`), `dart-resolve-package-conflicts` (`pub`) | Honor `analysis_options.yaml` (`always_specify_types`, `strict-*`), zero `dynamic`, explicit `dispose()` |
| **Layout, Forms & Adaptive UI** | `flutter-fix-layout-issues` (`dtd`, `widget_inspector`), `flutter-build-responsive-layout`, `ui-a11y` | Use `MediaQuery.*Of`, lazy `CustomScrollView` slivers, keyboard focus & `Shortcuts`/`Actions`, custom control `Semantics` |
| **Architecture & State Scope** | `flutter-apply-architecture-best-practices` (or project state pattern) | Keep state architecture agnostic (Notifier, Riverpod, Bloc, MVVM); push high-frequency state into leaf `ValueListenableBuilder`s |
| **JSON, HTTP & Routing** | `flutter-implement-json-serialization`, `flutter-use-http-package`, `dart-use-pattern-matching`, `flutter-setup-declarative-routing` | Use `Map<String, Object?>` + pattern matching; avoid Web `compute()` on heavy payloads (chunk/Worker/paginate); pair `go_router` + `deferred as` |
| **FFI, Native Assets & Constructors** | `dart-use-ffigen`, `dart-setup-ffi-assets`, `dart-build-cli-app`, `dart-use-path-package`, `dart-write-documentation`, `dart-use-primary-constructors` | Never hand-write `@Native` when `.h` exists; enforce `isLeaf` rules & worker isolates for blocking calls; use `class const` + `const new` |
| **Tests & Previews** | `dart-add-unit-test`, `dart-generate-test-mocks`, `dart-migrate-to-checks-package`, `flutter-add-widget-test`, `flutter-add-integration-test`, `flutter-add-widget-preview` | Keep `@Preview` free of unguarded `dart:io`/`dart:ffi`; use `watchPerformance` on Web |
| **Mobile Web Telemetry vs UI** | [analyze_web_bundle.mjs](./scripts/analyze_web_bundle.mjs), [profile_mobile_web.mjs](./scripts/profile_mobile_web.mjs), `playwright` MCP (or `chrome-devtools` if active) | Enforce startup + frame budgets, verify `skwasm` + `--simulate-webkit-fallback`, check zero failed/CORS requests |

---

## 3. Core Engineering Standards

### A. Rebuild Isolation, Ergonomic Helpers & Daily Patterns
- **Leaf Reactive Scopes:** Never call `setState()` high in the tree for scroll, drag, timers, or stream ticks. Scope updates to leaf `ValueListenableBuilder<T>` / `ListenableBuilder` (`child:` cached). On 120 Hz hot paths, prefer transform/paint updates over layout-invalidating size changes.
- **Aspect-Scoped Context Reads:** Prefer `MediaQuery.sizeOf(context)`, `paddingOf`, `viewInsetsOf`, and `devicePixelRatioOf` over `MediaQuery.of(context)`. For custom design systems, prefer `InheritedModel` aspect accessors over monolithic theme subscriptions (`Theme.of` is not aspect-scoped).
- **Pragmatic `_build*()` Helpers vs `class const` Extraction:** Small private `Widget _buildPart(...)` methods inside a `State` or widget are fine when the subtree shares the same rebuild scope and reads no distinct `InheritedWidget`/`Listenable`. Extract into a private `class const _Section(...) extends StatelessWidget` whenever you need rebuild isolation, narrower `InheritedWidget`/`Listenable` subscription, or subtree reuse (`>= 2x`). Replace single-purpose `Container`s with `const Padding`, `ColoredBox`, `DecoratedBox`, `SizedBox`, or `Align`.
- **Daily Flutter Ergonomics:** Keep `TextEditingController`/`FocusNode` lifecycle paired with `dispose()` and `Form` `AutovalidateMode.onUserInteraction`, model async screens with sealed loading/error/empty states + retry callbacks, and support desktop/tablet keyboard shortcuts (`CallbackShortcuts` / `Shortcuts` + `Actions`). Details in [modern-dart-and-flutter350.md](./references/modern-dart-and-flutter350.md).

### B. Viewports, Images & Grouped Blurs
- **Lazy Slivers First:** Use `CustomScrollView` + `SliverFixedExtentList.builder` / `SliverPrototypeExtentList.builder` / `SliverVariedExtentList.builder` (`scrollCacheExtent: const .pixels(...)` or `.viewport(...)`), reserving `shrinkWrap: true` only for small `<= 10`-item intrinsic sheets/dialogs.
- **Native vs Web Image Decoding:** Set `useLogicalCacheSize: true` or single-dimension `cacheWidth` on native targets; omit `cacheWidth` on Web `Image.network` and serve CDN-sized WebP/AVIF URLs to prevent double-decoding ([mobile-web-performance.md](./references/mobile-web-performance.md)).
- **Grouped Blurs:** Cache `BackdropKey` in `State` for `BackdropGroup` + clipped `BackdropFilter.grouped`, and minimize blurs inside Mobile Web scrollables.

### C. Rendering, Threading & Mobile Web (`--wasm` / JS Fallback)
- **Zero-Allocation Hot Paths & `saveLayer()` Avoidance:** Never allocate `Paint`, `Path`, `Matrix4`, `Float64List`, `TextPainter`, `PictureRecorder`, or `ui.Shader` in `paint()`/`Ticker` callbacks. Prefer leaf alpha (`.withValues(alpha: a)`, `Image.opacity`) over `Opacity`, avoid `Clip.antiAliasWithSaveLayer`, and pick safe `Visibility` flags ([rendering-impeller-webgl.md](./references/rendering-impeller-webgl.md)).
- **Impeller vs Web WebGL2 Reality:** Apply `RepaintBoundary` only at asymmetric repaint seams (never on trivial widgets or `ListView.builder` item roots). Remember Web (`Skwasm`/`CanvasKit`) runs Skia over WebGL2/ANGLE: warm up custom `FragmentProgram`s off the interaction path and bound `toImageSync` textures on 3x DPR tabs.
- **Off-Main-Thread & Web Interop:** Keep blocking IO/FFI/JNI off the UI isolate; on Web (`dart:isolate` unsupported), use `<= 4 ms` chunked tasks, Web Workers, or pagination, ban legacy `dart:html`/`dart:js`/`dart:js_util`/`package:js` in favor of `package:web` + `dart:js_interop`, and benchmark iOS WebKit `dart2js` fallback ([concurrency-simd-interop-wasm.md](./references/concurrency-simd-interop-wasm.md)).

---

## 4. Pre-Output Gates

1. **Scope & Accessibility:** Zero unrequested changes outside task scope; custom interactive/icon-only controls have proper `Semantics`, focus handling, and `MediaQuery.disableAnimationsOf(context)` support without redundant wrappers; project rules (`flutter.md`/`ui-a11y`) honored.
2. **Rebuild & Viewport Hygiene:** Leaf `ValueListenableBuilder`/`ListenableBuilder`; `MediaQuery.*Of`; `class const` extraction where rebuild isolation/reuse applies (small same-scope `_build*()` helpers allowed); lazy slivers with `scrollCacheExtent`, no primary `shrinkWrap: true`.
3. **Hot-Path & `saveLayer` Safety:** Zero allocations or uncached `TextPainter.layout` in `paint()`/`Ticker`; leaf alpha over `Opacity`; surgical `RepaintBoundary`; cached `BackdropKey` in `BackdropGroup`.
4. **Native vs Web Parity:** Native `useLogicalCacheSize: true` / `cacheWidth`; Web omits `Image.network` `cacheWidth`, warms up custom `FragmentProgram`s, never forces `InkSparkle` on Web, and bounds offscreen VRAM.
5. **Concurrency, SIMD & `--wasm`:** Direct `Float32x4List` (`v128`); `ffigen`/Native Assets off UI isolate; Web avoids `compute()` for heavy work and uses `package:web` + `dart:js_interop` while keeping `dart2js` fallback fast.
6. **Lifecycle & Verification:** Dispose controllers, focus/scroll nodes, subscriptions, `Timer`s, `FragmentShader`s, `ui.Picture`/`ui.Image`, and JNI refs; guard async `State` gaps with `if (!mounted) return;`; verify with `analyze_files`/`flutter test`, `dtd` (if live), and `--profile`/`--release` metrics for any perf claim.
7. **Dart 3.14+ / Project Style Hygiene:** Honor `pubspec.yaml` SDK & `material_ui`/`cupertino_ui` bounds; match `analysis_options.yaml` (`always_specify_types`, explicit `<Widget>[]`, `prefer_final_locals`); use `0.0`/`0.5` decimals (not `.0`/`.5`), dot shorthands where inferred, `class const` + `const new`, `PopScope<T>`, `WidgetState`, and `Matrix4.*ByDouble`.
