# Rendering Pipeline, Impeller vs WebGL2, `RepaintBoundary` & Zero-Allocation Hot Paths

Read this reference when implementing or optimizing `CustomPainter`, `RenderBox.paint()`, 3D `Matrix4` projections, `ui.Picture` / `ui.Image` caching, `FragmentProgram` shaders, batched draw calls, or diagnosing `saveLayer()` and `RepaintBoundary` bottlenecks.

---

## 1. Zero Heap Allocations Inside `paint()` and `Ticker` Callbacks

At 120 Hz, the total frame budget is **8.33 ms** (16.67 ms at 60 Hz).

- Never allocate mutable or engine-backed objects (`Paint`, `Path`, `Matrix4`, `Float64List`, `TextPainter`, `PictureRecorder`, `ui.Shader` via `gradient.createShader(rect)`, or temporary `List`s) inside `CustomPainter.paint()`, `RenderBox.paint()`, or animation tick callbacks.
- `Gradient` itself (`const LinearGradient(...)`) is immutable; `gradient.createShader(rect)` allocates a disposable `ui.Shader` and must be cached until `size` or gradient inputs change.
- Pre-allocate and mutate buffers in place (`_wavePath.reset()`). Cache `late final _painter` in `State` only when inputs are fixed or driven by a `Listenable` (`super(repaint: phase)`) -- never share one mutable `CustomPainter` across multiple `CustomPaint` widgets, and reconstruct when widget inputs change.
- **Pre-Recording `ui.Picture` vs Rasterized `ui.Image` under Impeller & Web:**
  * Recording a `ui.Picture` once outside `paint()` and replaying `canvas.drawPicture(picture)` eliminates **Dart CPU `paint()` and `DisplayList` recording overhead**, **not** GPU rasterization.
  * When dense static vector geometry still bottlenecks the **Raster thread**, benchmark rasterizing once with `picture.toImageSync(physicalW, physicalH)` (or `toImage`), trading VRAM and fixed pixel resolution for a texture blit. **Mobile Web caveat:** On Skwasm/CanvasKit, `toImageSync` allocates WebGL textures -- at 3x DPR on mobile tabs with tight GPU memory, bound cached sizes and dispose promptly to avoid WebGL context loss.
  * Dispose all cached `Picture`, `Image`, and `Shader` objects in `dispose()`.
- **`TextPainter` & Shader Warmup (Impeller Native vs Web WebGL2):**
  * Cache `TextPainter` outside `paint()` and call `textPainter.layout(maxWidth: ...)` only when text, `TextStyle`, `TextDirection`, or `maxWidth` changes.
  * **Impeller (Native) vs Skwasm/CanvasKit (Web):** Impeller pre-compiles built-in PSOs ahead of time on native backends, whereas **Flutter Web (`Skwasm` and `CanvasKit`) renders via Skia over WebGL2/ANGLE**. Load custom `FragmentProgram`s asynchronously outside `build()`/`paint()` and draw once off-screen before the first user interaction. (`ThemeData` already sets `useInkSparkle = platform == TargetPlatform.android && !kIsWeb`, so Web uses `InkRipple` by default; never force `InkSparkle.splashFactory` unconditionally on Web targets.)

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final class ZeroAllocWavePainter({required final ValueListenable<double> phase})
    extends CustomPainter {
  this : super(repaint: phase);

  final Paint _strokePaint = .new()
    ..style = .stroke
    ..strokeWidth = 2.0
    ..strokeCap = .round
    ..isAntiAlias = true
    ..color = const .fromRGBO(0, 229, 255, 1.0);

  final Path _wavePath = .new();

  @override
  void paint(Canvas canvas, Size size) {
    _wavePath.reset();
    final double midY = size.height * 0.5;
    _wavePath.moveTo(0.0, midY);
    // Populate _wavePath from pre-allocated ring buffer...
    canvas.drawPath(_wavePath, _strokePaint);
  }

  @override
  bool shouldRepaint(ZeroAllocWavePainter oldDelegate) =>
      oldDelegate.phase != phase;
}
```

---

## 2. Pre-Allocated 3D Perspective & `Matrix4` Transformations

When rendering 3D carousels, cylindrical galleries, or perspective cards:

- Pre-allocate `Matrix4` buffers in `State` or the painter and mutate entries in place (`setIdentity()`, `setEntry(3, 2, perspective)`, `rotateY()`, `translateByDouble(x, y, z, 1.0)`, `scaleByDouble(sx, sy, sz, 1.0)`) rather than allocating new matrices per frame.
- Inside `CustomPainter.paint()` when drawing cards/sprites directly, pass `_matrix.storage` to `canvas.transform(...)` to avoid `RenderTransform`'s `Matrix4.copy(value)` and compositor `TransformLayer` overhead. (If cards host interactive child widgets, gestures, text selection, or `PlatformView`s, use `Transform`.)
- Perform backface culling and Z-order depth sorting on lightweight index buffers before building or painting visible items (verify screen-space winding sign against your `setEntry(3, 2, ...)` sign).

---

## 3. Batch Canvas Primitives, `saveLayer()` Elimination & Surgical `RepaintBoundary`

### A. Batch Draw Calls
Prefer `Canvas.drawRawPoints`, `Canvas.drawRawAtlas`, or `Canvas.drawVertices` (backed by pre-allocated `Float32List` / `Int32List` buffers) over hundreds of individual `drawCircle` / `drawRect` calls.

### B. Eliminate `saveLayer()` Stalls
- **Avoid `Opacity` / `AnimatedOpacity` / `FadeTransition` over multi-child or overlapping subtrees when leaf alpha works.** `RenderOpacity` sets `alwaysNeedsCompositing => child != null && _alpha > 0` and `isRepaintBoundary => alwaysNeedsCompositing` -- so **even `Opacity(opacity: 1.0)` forces a `RepaintBoundary` and `OpacityLayer`**, while intermediate alpha (`0 < alpha < 255`) on multi-primitive subtrees triggers an offscreen `saveLayer()` pass.
- **Best:** Modulate alpha on leaf primitives (`color.withValues(alpha: a)`, `Image(..., opacity: cachedAnimation)` on native/canvas targets -- cache an `AlwaysStoppedAnimation` in `State` or pass an `AnimationController`; note `opacity` is ignored on Web HTML `<img>` platform views, `TextStyle`, or `Paint.color`).
- **When fading a composite group is unavoidable:** Prefer `FadeTransition` (explicit `Animation<double>`) or `AnimatedOpacity` over animating `Opacity` via `setState`, keep the subtree tight, and unmount/hide when `opacity == 0.0`.
- **Binary Show/Hide:**
  * `Visibility(visible: ..., child: ...)` replaces hidden content with `SizedBox.shrink()`.
  * `Visibility(visible: ..., maintainState: true, child: ...)` uses `Offstage` (non-interactive).
  * To preserve layout, animations, and state while blocking touches and focus, use `Visibility(visible: ..., maintainState: true, maintainAnimation: true, maintainSize: true, child: ...)`, which wraps `IgnorePointer` and `ExcludeFocus`.
  * Avoid `Visibility.maintain`, because `.maintain` sets `maintainInteractivity: true` and `maintainFocusability: true`.
- **Avoid `Clip.antiAliasWithSaveLayer`:** Use `Clip.antiAlias` or `BoxDecoration(borderRadius: ...)`.

### C. Surgical `RepaintBoundary` (Impeller vs Skia)
- **How it works:** `RepaintBoundary` stops `markNeedsPaint()` propagation and isolates `DisplayList` recording (`PictureLayer` / `OffsetLayer`) so static ancestors/siblings do not re-run `paint()` on the UI thread. Unlike legacy Skia, **Impeller removed the persistent `PictureLayer` raster texture cache** -- do not expect `RepaintBoundary` to cache static subtrees as persistent offscreen GPU bitmaps under Impeller.
- **When to USE (Asymmetric Repaints):** Tightly wrap high-frequency `CustomPaint` canvases, continuous tickers, or localized animations so static siblings do not re-record; or isolate a genuinely heavy static background beneath an independently animating overlay.
- **When to AVOID:**
  1. **Symmetric / Co-Repainting Subtrees:** Never wrap parent and child when both repaint on the same frames.
  2. **Micro-Boundaries on Cheap Widgets:** Never wrap simple `Text`, `Icon`, or basic `DecoratedBox` widgets -- layer-tree overhead outweighs paint savings.
  3. **Double Boundaries & KeepAlives in Lazy Lists:** `ListView.builder`, `GridView.builder`, and `SliverList.builder` wrap each item in `RepaintBoundary` (`addRepaintBoundaries: true`) and `AutomaticKeepAlive` (`addAutomaticKeepAlives: true`) by default. Never add another `RepaintBoundary` at item root; for ultra-light rows benchmark `addRepaintBoundaries: false`, and set `addAutomaticKeepAlives: false` on stateless rows. Keep `scrollCacheExtent` conservative on Mobile Web (`<= 1.0` viewport) to limit decoded texture VRAM on 3x DPR tabs.
  4. **Misplaced Around `Transform`:** Wrapping `RepaintBoundary` outside an animating `Transform` still re-records `Transform` and child together unless the heavy static child inside `Transform` is isolated.
  5. **Non-Paint Jank:** `RepaintBoundary` never fixes `build()` or `layout()` bottlenecks.
- **Verify:** Inspect `debugRepaintRainbowEnabled` and `RenderRepaintBoundary.debugSymmetricPaintCount` vs `debugAsymmetricPaintCount` via `debugDumpRenderTree()` in Debug, then confirm actual UI/Raster frame-time reduction in **Profile mode** (`--profile`).

---

## 4. Fragment Shaders (`ui.FragmentProgram`)

- Load `FragmentProgram.fromAsset('shaders/effect.frag')` **once** during initialization.
- Create and cache the reusable `FragmentShader` via `program.fragmentShader()` (simultaneous callers with distinct uniforms need separate instances).
- Update uniforms (`shader.setFloat(...)` / `shader.setImageSampler(...)`) inside `paint()`, and call `shader.dispose()` in `dispose()`.
