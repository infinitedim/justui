# Modern Dart 3.14+ Syntax, Daily Flutter Patterns & Flutter 3.50 Hygiene

Read this reference when authoring or refactoring Dart/Flutter code to apply Dart 3.14+ syntax, project-compatible strict typing, daily Flutter ergonomics, and Flutter 3.50 API migrations without breaking `pubspec.yaml` bounds.

> **Plugin Skill Coordination:** Defer dedicated refactoring checklists for primary constructors and pattern matching to `dart-use-primary-constructors` and `dart-use-pattern-matching` when active.

---

## 1. Syntax Hygiene vs Runtime/Size Impact

Do not confuse syntax conciseness with runtime speedups:
- **Syntax & Deprecation Hygiene (No Direct Speedup):** Dot shorthands (Dart 3.10+), non-`const` primary constructors (Dart 3.13+), null-aware collection elements (Dart 3.8+), `package:material_ui` / `cupertino_ui`, `scrollCacheExtent`, `PopScope<T>`, `WidgetState`.
- **Actual Compiler / Runtime / Size Impact:** `const` canonicalization, zero-`dynamic` typing (enables AOT Type Flow Analysis devirtualization), unboxed `extension type`s, `Matrix4.*ByDouble` (avoids dynamic dispatch in deprecated `translate`/`scale`), and importing `package:flutter/widgets.dart` when building custom design systems without Material/Cupertino overhead.

---

## 2. Dart 3.14+ Style (Strict Typing, `0.0` Decimals & Dot Shorthands)

Prefer dot shorthands wherever the target type is statically inferred (parameter type, variable annotation, return type, `FutureOr<T>`, nullable `T?`, collection elements/keys/values, `switch` cases, `==`). Use `.new(...)` / `const .new(...)` when the inferred type matches the owning class.

### Style Guardrails
1. **Explicit Leading Zeroes (`0.0`, `0.5`):** Always write `0.0` and `0.5` (not `.0` or `.5`) for readability and compatibility with standard Dart formatters/codebases. Write explicit `.0` (`10.0`, `22.0`) on whole-number `double` literals.
2. **Strict Typing (`always_specify_types` / `prefer_final_locals`):** Never use `dynamic` or unchecked casts; use `Object?`, `Map<String, Object?>`, constrained generics, `sealed` hierarchies, or typed records. When the project enables `always_specify_types: true`, annotate local variables (`final double width = ...`), typed collection literals (`<Widget>[...]`, `<BoxShadow>[...]`), loop variables (`for (final FrameTiming t in list)`), and closure parameters (`(Duration _)`).
3. **Static Members & Forwarding Geometry:** Replace `double.*` with `.infinity`, `.maxFinite`, `.parse(...)`, `.tryParse(...)` only when the context type is `double`/`double?`. Use named forwarding factories (`.all`, `.symmetric`, `.only`, `.xy`, `.directional`) for `EdgeInsetsGeometry`, `AlignmentGeometry`, and `BorderRadiusGeometry`, and `.new(...)` / `const .new(...)` when the static type owns a matching generative constructor.
4. **Unambiguous Context & Helper Classes:** Keep explicit prefixes for `var`/`final` without type (`final ThemeMode mode = .dark;`), helper-class constants (`Icons.*`, `Colors.*`, `Curves.*`), and unforwarded supertypes (`Decoration?` needs `BoxDecoration`, `ShapeBorder` needs `RoundedRectangleBorder`, `WidgetStateProperty.fromMap` keys need `WidgetState.*`).

```dart
import 'package:flutter/widgets.dart';

enum LoadStatus { idle, loading, ready, failed }

Future<LoadStatus> fetchStatus() async => .ready;

String statusLabel(LoadStatus status) => switch (status) {
  .idle => 'Idle',
  .loading => 'Loading',
  .ready => 'Ready',
  .failed => 'Failed',
};

const double halfAlpha = 0.5;
const double itemPadding = 10.0;
const Duration timeout = .new(milliseconds: 250);
final Set<WidgetState> interactiveStates = <WidgetState>{.hovered, .focused};
final Map<LoadStatus, double> statusOpacity = <LoadStatus, double>{
  .idle: 0.0,
  .loading: 0.5,
  .ready: 1.0,
  .failed: 0.25,
};

Widget buildMetricTile({required bool isCompact, AlignmentGeometry? align}) {
  return SizedBox(
    width: .infinity,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: .fromRGBO(18, 22, 30, 1.0),
        borderRadius: .all(.circular(12.0)),
        boxShadow: <BoxShadow>[
          .new(
            blurRadius: 12.0,
            offset: .new(0.0, 4.0),
            color: .fromRGBO(0, 0, 0, 0.25),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const .new(minHeight: 48.0),
        child: Align(
          alignment: align ?? .center,
          child: Padding(
            padding: const .symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: isCompact ? .start : .spaceBetween,
              crossAxisAlignment: .center,
              children: const <Widget>[
                DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: .all(.circular(8.0)),
                      side: .new(width: 1.0, color: .fromRGBO(0, 229, 255, 0.4)),
                    ),
                  ),
                  child: Padding(
                    padding: .symmetric(horizontal: 10.0, vertical: 6.0),
                    child: Text(
                      'Synced',
                      overflow: .ellipsis,
                      style: .new(fontSize: 13.0, fontWeight: .w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
```

---

## 3. Primary Constructors (`class const`), Null-Aware Elements & Extension Types

- **Primary Constructors (Dart 3.13+):** Place `const` before the class name (`class const MetricBadge(...) extends StatelessWidget`), end empty bodies with `;`, and use `this : super(...)` / `this : assert(...)` for initializers. Only `final`/`var` header parameters become fields; use `const new named(...) : this(...)` for redirecting named constructors.
- **Pragmatic `_build*()` vs `class const` Widget:** Use small `_buildPart()` methods inside `State` when splitting layout that shares the exact same rebuild cadence; extract to `class const _Section(...) extends StatelessWidget` whenever you isolate rebuilds, read a narrower `InheritedWidget`/`Listenable`, or reuse the subtree (`>= 2x`).
- **Null-Aware Collection Elements (Dart 3.8+):** Use `?element`, `?key: value`, and `key: ?value` inside `<Widget>[...]`, `<T>{...}`, and `<K, V>{...}`.
- **Extension Types & Sealed States:** Wrap domain units with `extension type const` (beware boxing when passed as `Object?`, `num`, nullable `T?`, or unspecialized generics) and model state machines with `sealed class const`.

```dart
extension type const Radians(double value) {
  double get toDegrees => value * (180.0 / 3.141592653589793);
}

sealed class const LoadState<T>();
final class const Loading<T>() extends LoadState<T>;
final class const Ready<T>(final T data) extends LoadState<T>;
final class const Failure<T>(final String message) extends LoadState<T>;

class const MetricBadge(
  final String label,
  final String value, {
  super.key,
}) extends StatelessWidget {
  const new empty({Key? key, required String label})
    : this(label, '--', key: key);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(borderRadius: .all(.circular(8.0))),
    child: Padding(
      padding: const .all(8.0),
      child: Text('$label: $value'),
    ),
  );
}
```

---

## 4. Daily Flutter Patterns (Forms, Async UI, Theming, Adaptive Input)

- **Forms & Focus Lifecycle:** Own `TextEditingController` and `FocusNode` in `State` and dispose every one in `dispose()`. Prefer `AutovalidateMode.onUserInteraction` and keep per-field error listeners scoped so typing does not rebuild unrelated sections. Support `TextInputAction.next` / `onFieldSubmitted` traversal and wrap custom form controls in `Semantics` (label, value, enabled, error/validation hint).
- **Async UI States (Loading / Error / Empty):** Exhaustively switch on `sealed` states (`Loading`, `Ready`, `Empty`, `Failure`) with an explicit retry callback, preserve scroll controllers/keys across reloads so list positions are not lost, and guard every post-`await` `State` mutation or `BuildContext` read with `if (!mounted) return;`.
- **Theming & Aspect-Scoped Reads:**
  - Always use `MediaQuery.sizeOf(context)`, `paddingOf`, `viewInsetsOf`, and `devicePixelRatioOf` instead of `MediaQuery.of(context)` (critical on Mobile Web where soft-keyboard animations mutate `viewInsets` every frame).
  - `Theme.of(context)`, `ColorScheme.of(context)`, and `TextTheme.of(context)` subscribe to the full `ThemeData`. For custom design systems, build an `InheritedModel<Aspect>` with aspect helpers (`context.colors`, `context.typography`) or `ThemeExtension<T>` classes read inside small leaf widgets.
- **Adaptive Desktop & Keyboard Input:** Support keyboard navigation (`Focus`, `CallbackShortcuts` / `Shortcuts` + `Actions`, `FocusTraversalGroup`), hover/focus states (`WidgetState`), and `MediaQuery.disableAnimationsOf(context)` to zero out nonessential motion while preserving state feedback.
- **Architecture Agnosticism:** Whether the codebase uses MVVM, Riverpod, Bloc, or feature-scoped `ValueNotifier` controllers, isolate high-frequency fields (scroll offset, drag progress, timers) into leaf `ValueListenableBuilder<T>`s instead of triggering whole-page rebuilds.

---

## 5. Flutter 3.50 Package Boundary & Migration Table

- **Material / Cupertino Packages:** `package:flutter/material.dart` and `package:flutter/cupertino.dart` were deprecated after `v3.47.0-0.0.pre` in favor of `package:material_ui/material_ui.dart` and `package:cupertino_ui/cupertino_ui.dart` (added via `flutter pub add material_ui cupertino_ui`). Inspect `pubspec.yaml` first: use `material_ui` when already declared (or import `package:flutter/material.dart show ...` only as a codebase requires); do not silently edit `pubspec.yaml` or emit unresolvable imports on projects that have not migrated yet.
- Run `dart fix --apply` for mechanical widget/rendering updates (`scrollCacheExtent`, `PopScope<T>`, `WidgetState`), and update Material/Cupertino imports manually when adopting `material_ui`.

| Deprecated / Legacy API | Flutter 3.50 Replacement |
| :--- | :--- |
| `package:flutter/material.dart` / `cupertino.dart` | `package:material_ui/material_ui.dart` / `package:cupertino_ui/cupertino_ui.dart` (when in `pubspec.yaml`) |
| `cacheExtent` / `cacheExtentStyle` | `scrollCacheExtent: const ScrollCacheExtent.pixels(...)` or `.viewport(...)` |
| `color.withOpacity(a)`, `.value`, `.red`/`.green`/`.blue`/`.alpha` | `color.withValues(alpha: a)`, `.toARGB32()`, `.r`/`.g`/`.b`/`.a` |
| `Matrix4.translate(...)` / `Matrix4.scale(...)` | `Matrix4.translateByDouble(...)` / `translateByVector3(...)`, `scaleByDouble(...)` / `scaleByVector3(...)` |
| `WillPopScope`, `MaterialStateProperty` / `MaterialState` | `PopScope<T>`, `WidgetStateProperty` / `WidgetState` |
| Physical-only `cacheWidth` / `cacheHeight` | `useLogicalCacheSize: true` (when passing logical dp on native) |
