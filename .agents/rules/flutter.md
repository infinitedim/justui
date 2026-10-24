---
trigger: glob
globs: "packages/core/**, packages/tokens/**, apps/showcase/**, apps/sandbox/**, registry/**, tools/**"
description: "Flutter and Dart rules for the JustUI theme engine, tokens, components, registry and workbench apps."
---

# Flutter and Dart

## Component structure

Each component lives in `packages/core/lib/src/components/<name>/` with 4 files:

1. `just_<name>.dart` - the widget (state, layout, semantics)
2. `just_<name>_style.dart` - instance style (geometry, borders, colors)
3. `just_<name>_variants.dart` - size, intent and variant enums
4. `just_<name>_theme.dart` - `ThemeExtension<Just<Name>Theme>` defaults

Private helpers that only one component uses may live next to it as
`_<name>_<part>.dart`. Shared internals live in `components/shared/_shared_*.dart`.
Use the `justui create <name>` layout as the reference for new components.

## Theme access

- In `build()`, read only the aspect you need: `context.justColors`,
  `context.justTypo`, `context.justSpacing`, `context.justRadius`,
  `context.justPreset`. Avoid `context.justTheme` in small widgets: it
  rebuilds on any theme change.
- In callbacks (`onTap`, `onPressed`, gestures), use `context.readTheme()` so
  the widget does not subscribe to rebuilds.
- Do not add new `JustThemeProvider.of(context)` calls without an aspect.

## Presets

- Preset differences go through `JustPresetTokens`
  (`DefaultPresetTokens`, `NeobrutalismPresetTokens` in
  `packages/core/lib/src/theme/preset_tokens.dart`). Add a token there instead
  of writing `context.justPreset == .neobrutalism` branches in a component.
  Do not add new preset comparisons; existing ones are legacy.
- Neobrutalism specifics:
  - Border width 2.5 on containers and controls; 3.0 only for the sidebar
    active accent and the table selected row.
  - Borders use `colors.textPrimary` in every state. Never tint borders to
    primary or accent colors.
  - Flutter paints borders inside the box. In tight containers (switch thumb,
    checkbox mark), subtract `2 * borderWidth` from inner sizes and offset by
    `borderWidth`.
  - Press translation must equal the solid shadow offset, and both animate
    with the same duration (`animations.instant`), so nothing jitters.
- A new preset must be registered in `packages/cli/src/commands/init.rs` and in
  `JustThemeData` (`operator ==`, `hashCode`, `copyWith`).

## Dart syntax

- Use dot shorthands where the type is inferred: `.all(radius.lg)`,
  `.symmetric(horizontal: spacing.md)`, `.w600`. Never expand them.
- `packages/core` uses the `primary-constructors` experiment
  (`class const JustButton({...}) extends StatelessWidget`). Keep that syntax in
  core; the CLI transpiles it for users on `dart_target: standard`. If you add
  a constructor shape the transpiler might not handle, add a case to
  `packages/cli/src/utils/constructor_transpiler_tests.rs`.
- `color.withValues(alpha: x)`, never `withOpacity`.
- Import Material only with `show`: `import 'package:flutter/material.dart' show Theme;`.
  The only bare Material import allowed is in `theme_data_material.dart`.
- `const` for every immutable widget, style and token constant.
- Follow `analysis_options.yaml` (strict casts, strict inference,
  `always_specify_types`, `prefer_final_locals`). Do not add `// ignore:`
  comments without a reason on the same line.

## Tokens and values

Visual values come from tokens: `JustSpacing`, `JustRadius`, typography,
`JustShadows`, colors from `JustColorScheme` / `JustColorScale`. Arbitrary
numbers for layout math are fine; new colors, fonts, radii or shadow styles
are not (see `design.md`).

## Accessibility

- Every interactive widget has correct `Semantics` (label, button/toggled/
  checked/selected state, enabled), keyboard focus, and a visible focus
  indicator (`_shared_focus_indicator.dart`).
- Respect reduced motion: resolve the motion profile with
  `animations.resolve(context)` (returns `JustMotionProfile.reduced` when
  `MediaQuery.disableAnimationsOf(context)` is true).
- Text contrast is at least 4.5:1, UI boundaries and large text at least 3:1.
  Check with `contrastRatioWith` / `isAccessibleWith` from `packages/tokens`;
  never state a ratio you did not compute.
- Minimum hit area 44x44 logical pixels for primary actions on touch; never
  below 24x24.

## Comments

- Every public class, constructor parameter and method has a `///` dartdoc.
- Comments explain why, not what. No narration (`// now we build the row`).
- Never repeat a doc comment. Check for duplicated lines before you finish.

## File size

New files stay under 400 lines and new methods (including `build`) under 60
lines; split into private widgets or `_<name>_<part>.dart` files. Existing
large files are split only when you change them substantially, and only if the
task allows it.

## Registry sync

After changing anything in `packages/core` that the registry mirrors:

```bash
dart run tools/generate_checksums.dart --dry-run   # inspect, read for drift
dart run tools/generate_checksums.dart             # write
```

The dry run can report drift and still exit 0. Read its output.
Never edit files in `registry/components/` by hand.

## apps/sandbox (generated)

`apps/sandbox` is the CLI sandbox: the only place where real CLI output
(transpiled constructors, rewritten imports) is compiled, analyzed and tested
in CI. Never edit `apps/sandbox/lib/core`, `lib/tokens` or `lib/widgets` by
hand. Regenerate after changes to `packages/core` or the CLI:

```bash
cargo build --release
cd apps/sandbox
rm -rf lib/core lib/tokens lib/widgets
../../target/release/justui init -y --preset neobrutalism --color-space oklch --dart-target standard
sed -i 's#^registry_url:.*#registry_url: ../../registry#' justui.config.yaml
../../target/release/justui add --all -y --trust-registry
dart format lib && flutter analyze && flutter test
```

`rm -rf` here deletes generated folders only; it still counts as deleting
files, so include it in your plan. `--trust-registry` is needed when the run
is not interactive. The sandbox keeps the plain `flutter_lints` analysis of a
user project, not the strict root options.

## apps/showcase (bridge)

`apps/showcase` is a Flutter web app (Wasm, multi-view embedded mode) that
renders real core components into host elements on the docs pages. Its bundle
is built into `apps/docs/public/flutter/` (see `docs-web.md`).

- It imports `packages/core` and `packages/tokens` by path. Components come in
  through implementation imports (`package:just_ui_core/src/components/...`)
  with `// ignore_for_file: implementation_imports`.
  Invariant 3 still holds.
- The Ink and Paper look lives in showcase (`lib/theme/`): a
  `CustomColorScheme`, typography and component `ThemeExtension` overrides.
  Do not change core or the docs runner-kit to match it. The constants are
  locked to the `--ip-*` blocks in `apps/docs/src/app/globals.css` by a drift
  test, and the role pairs by a contrast test.
- Register every core `*Theme.defaults` (what the CLI writes at
  `// CLI:REGISTER_EXTENSIONS`) through `toThemeData(additionalExtensions:)`;
  a drift test lists them.
- One `MaterialApp(title: null)` per view: a title rewrites the host page's
  `document.title`, and the route scope is what lets Tab leave the view.
- Semantics are always on (`SemanticsBinding.instance.ensureSemantics()`).
- JS interop uses SDK libraries only (`dart:js_interop`, `dart:ui_web`) behind
  a conditional import. No `package:web`, no `postMessage`, no new globals.
  Every value that comes from JS is checked against a whitelist; invalid
  input keeps the defaults.
- Scenes mirror the composition of the docs `KitPart` for the same slug.
- Golden tests run on Linux with the Flutter version in `.fvmrc` and load the
  real font files. Update a golden only for an intended change, and look at
  the new image before committing it.

## Tests

- Widget tests in `packages/core/test/`, token tests in `packages/tokens/test/`.
- Bug fix = failing test first (see `workflow.md`).
- Run with the commands in `AGENTS.md` section 6.
