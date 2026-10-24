# Phase 1: Token Source and Generator

Status: Draft v1 (2026-10-13)
Depends on: P0
Blocks: P2, P6
Areas: `packages/tokens/design` (new), `tools/`, generated outputs

## 1. Summary

Create one JSON file that is the only place a JustUI color is authored, and a
pure Dart generator that turns it into Dart constants for Flutter, CSS
variables and TypeScript constants for the docs, and contrast-contract data
for tests. The generator also validates every contrast rule, so a palette that
breaks WCAG cannot be generated.

## 2. Background

1. Flutter colors live in `packages/tokens/lib/src/colors/*.dart` and docs
   colors live in `apps/docs/src/app/globals.css`. They are hand-written and
   have drifted (blue vs lime).
2. `packages/tokens/lib` and `packages/core/lib` are embedded in the CLI
   binary. A JSON source placed under `lib/` would ship to every user.
3. Users must keep receiving plain `const` Dart with zero dependencies.

## 3. Goals

1. One authored source for primitives, roles, preset part mappings, contrast
   rules and font family names.
2. A deterministic generator with `--check` that fails on drift or on any
   contrast violation.
3. Outputs committed to the repository and formatted so that formatters leave
   them unchanged.

## 4. Non-goals

1. Wiring the outputs into the theme or the docs (P2 and P6).
2. Generating spacing, radius, typography sizes or motion tokens. Only color
   and font family names are in scope. The format must allow adding them
   later.

## 5. Functional requirements

### FR-1.1 Token source file

Path: `packages/tokens/design/ink_and_paper.tokens.json` (outside `lib/`).
Format: DTCG-style JSON (`$type`, `$value`, `$description`). ASCII only.

Top-level sections:

| Section    | Content                                                                                                                                                                                                                                                                                                                                                                                                                    |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `meta`     | Format version (integer, starts at 1), source name                                                                                                                                                                                                                                                                                                                                                                         |
| `tint`     | `default: { hue: 80, chroma: 0.0035 }`, `graphite: { hue: 260, chroma: 0.0035 }`                                                                                                                                                                                                                                                                                                                                           |
| `neutral`  | Every primitive from `02-design-spec.md` section 3 with `$value` (hex) and `oklchL` (4 decimals)                                                                                                                                                                                                                                                                                                                           |
| `status`   | `error`, `errorHover`, `errorTint`, `success`, `successTint`, `warning`, `warningTint`, each with `light` and `dark` hex                                                                                                                                                                                                                                                                                                   |
| `alpha`    | `scrim.light: { base: "{neutral.n174}", alpha: 0.48 }`, `scrim.dark: { base: "{neutral.n135}", alpha: 0.72 }`                                                                                                                                                                                                                                                                                                              |
| `roles`    | `light` and `dark` maps from role name to a reference such as `"{neutral.n985}"`                                                                                                                                                                                                                                                                                                                                           |
| `presets`  | Per preset: `parts` map and `roleOverrides` map (see FR-1.2)                                                                                                                                                                                                                                                                                                                                                               |
| `contrast` | List of rules (see FR-1.3)                                                                                                                                                                                                                                                                                                                                                                                                 |
| `fonts`    | `sans: { css: "Plus Jakarta Sans", flutter: "PlusJakartaSans" }` (DP-6), `mono: { css: "IBM Plex Mono" }` (docs monospaced text only: code, commands, terminal output, paths, token names, keys; DP-6 item 1). The two sans names differ on purpose: CSS uses the Google Fonts name, Flutter uses the family key that `typography.dart`, the CLI `pubspec.yaml` entry and the test `FontLoader` must all spell identically |

Example (abbreviated):

```json
{
  "meta": { "version": 1 },
  "tint": { "default": { "hue": 80, "chroma": 0.0035 } },
  "neutral": {
    "n985": { "$type": "color", "$value": "#fbfaf8", "oklchL": 0.985 }
  },
  "roles": {
    "light": { "canvas": "{neutral.n985}", "textPrimary": "{neutral.n174}" },
    "dark": { "canvas": "{neutral.n155}", "textPrimary": "{neutral.n955}" }
  },
  "presets": {
    "default": {
      "parts": {
        "primaryBg": "inverse",
        "primaryFg": "onInverse",
        "containerBorder": "borderSubtle",
        "controlBorder": "borderControl",
        "shadowColor": "textPrimary"
      },
      "roleOverrides": {}
    },
    "neobrutalism": {
      "parts": {
        "primaryBg": "surface",
        "primaryFg": "textPrimary",
        "containerBorder": "textPrimary",
        "controlBorder": "textPrimary",
        "shadowColor": "textPrimary"
      },
      "roleOverrides": {}
    }
  },
  "contrast": [
    {
      "fg": "textTertiary",
      "on": ["canvas", "surface", "sunken", "raised"],
      "min": 7.0
    }
  ]
}
```

### FR-1.2 Preset part mapping

1. `parts` keys (closed set for version 1): `primaryBg`, `primaryFg`,
   `primaryBorder`, `secondaryBg`, `secondaryBorder`, `containerBorder`,
   `controlBorder`, `shadowColor`, `selectedBg`, `selectedFg`.
2. Every value must be a role name from `roles` or the literal
   `"transparent"`. `"transparent"` is emitted as `Color(0x00000000)` in Dart
   and `transparent` in CSS. Any other value fails generation.
3. `roleOverrides` maps a role name to a neutral or status reference. Any
   other value (a raw hex, an unknown primitive) is rejected.
4. A preset must define every `parts` key. Missing keys fail generation. The
   JSON example in FR-1.1 is abbreviated; the full mapping is:

| Key             | default       | neobrutalism |
| --------------- | ------------- | ------------ |
| primaryBg       | inverse       | surface      |
| primaryFg       | onInverse     | textPrimary  |
| primaryBorder   | inverse       | textPrimary  |
| secondaryBg     | transparent   | transparent  |
| secondaryBorder | borderControl | textPrimary  |
| containerBorder | borderSubtle  | textPrimary  |
| controlBorder   | borderControl | textPrimary  |
| shadowColor     | textPrimary   | textPrimary  |
| selectedBg      | inverse       | inverse      |
| selectedFg      | onInverse     | onInverse    |

The values follow `02-design-spec.md` section 6 (Rule A, DP-2).

### FR-1.3 Contrast rules

Each rule: `{ "fg": role, "on": [roles], "min": number, "modes": ["light","dark"], "presets": ["*"] }`.
`modes` and `presets` default to all. The file must contain at least:

| fg                                       | on                                                       | min |
| ---------------------------------------- | -------------------------------------------------------- | --- |
| textPrimary, textSecondary, textTertiary | canvas, surface, sunken, raised, hoverFill               | 7.0 |
| textPrimary                              | selection, errorTint, successTint, warningTint           | 7.0 |
| onInverse                                | inverse, inverseHover, inversePressed, error, errorHover | 7.0 |
| error, success, warning                  | canvas, surface, sunken, raised, own tint                | 7.0 |
| borderControl                            | canvas, surface, sunken, raised, hoverFill               | 3.0 |
| focusRing                                | canvas, surface, sunken, raised                          | 3.0 |
| inverse                                  | canvas, surface, sunken, raised                          | 3.0 |
| part `primaryFg`                         | part `primaryBg`                                         | 7.0 |
| part `selectedFg`                        | part `selectedBg`                                        | 7.0 |

Rules may reference parts with the prefix `part:` so they are evaluated per
preset.

### FR-1.4 Generator

Path: `tools/generate_tokens.dart`, optional helpers in `tools/tokens/`
(`oklch.dart`, `wcag.dart`, `emit_dart.dart`, `emit_css.dart`,
`emit_ts.dart`). Uses only `dart:convert`, `dart:io` and `dart:math`.

Pipeline:

1. Parse the JSON and validate its shape (unknown top-level keys fail).
2. Resolve references. Fail on unknown references and on cycles, naming the
   path.
3. For each neutral, rebuild the hex from (`oklchL`, default tint) and fail if
   any 8-bit channel differs by more than 1 from `$value`.
4. Validate preset `parts` and `roleOverrides` (FR-1.2).
5. Evaluate every contrast rule for every mode and preset. On failure, print
   `CONTRAST FAIL <preset>/<mode>: <fg> on <bg> = <ratio> < <min>` and exit 1.
6. Emit outputs (FR-1.5).

Flags:

| Flag              | Behavior                                                              |
| ----------------- | --------------------------------------------------------------------- |
| (none)            | Validate and write outputs                                            |
| `--check`         | Validate, render in memory, compare to disk, exit 1 on any difference |
| `--dry-run`       | Validate and print which files would change, write nothing            |
| `--only=<target>` | Limit to `dart`, `css` or `ts` (for staged rollout in P1.T3)          |

Exit codes: 0 success, 1 validation or drift failure, 2 usage error.

### FR-1.5 Outputs

Every output starts with the header:
`GENERATED FILE. Do not edit. Source: packages/tokens/design/ink_and_paper.tokens.json. Regenerate: dart run tools/generate_tokens.dart`

| Output                                                  | Content                                                                                                                                                                       | Wired in                               |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| `packages/tokens/lib/src/colors/brand_palette.dart`     | `abstract final class JustBrandPalette` with `static const Color` per primitive and status color, and `static const Map<String, double> neutralLightness`                     | P2                                     |
| `packages/tokens/lib/src/colors/color_semantic.dart`    | Regenerated `JustColorSemanticLight` and `JustColorSemanticDark` with new roles plus `@Deprecated` constants under old names                                                  | P2 (emitted to a temporary path in P1) |
| `packages/tokens/test/contrast_contract_generated.dart` | Contrast rules and part mappings as `const` data for tests (not shipped, `test/` is not embedded)                                                                             | P2                                     |
| `apps/docs/src/app/tokens.generated.css`                | `--just-*` variables for `:root, .preset-default`, `.dark`, `.theme-neobrutalism`, `.dark .theme-neobrutalism` (part mappings), and a `@media (prefers-contrast: more)` block | P6                                     |
| `apps/docs/src/lib/tokens.generated.ts`                 | Typed `as const` objects: roles per mode, parts per preset, contrast rules, neutral L table                                                                                   | P6, P7                                 |

Dart outputs must be stable under `dart format`; CSS and TS under Prettier.
The generator sorts keys so output order is deterministic.

### FR-1.6 Generator tests

`tools/test/generate_tokens_test.dart` (new):

1. Reference resolution, including unknown reference and cycle errors.
2. Hex versus L consistency accepts 1-unit drift and rejects 2-unit drift.
3. `roleOverrides` with a raw hex is rejected.
4. Contrast math: `#11100f` on `#fbfaf8` = 18.22, `#51504d` on `#f3f1ef` =
   7.16, `#81807d` on `#f3f1ef` = 3.51 (two decimals).
5. An injected failing rule makes the run exit 1 and name the pair.
6. `--check` exits 0 on a clean tree and 1 after a one-character edit to any
   output.

## 6. Non-functional requirements

1. NFR-1.1: The generator runs in under 3 seconds.
2. NFR-1.2: No function longer than 60 lines; no file longer than 400 lines.
3. NFR-1.3: Output is byte-identical across runs and platforms (LF endings).
4. NFR-1.4: ASCII only in source and outputs.

## 7. Files

| File                                                    | Change                            |
| ------------------------------------------------------- | --------------------------------- |
| `packages/tokens/design/ink_and_paper.tokens.json`      | New                               |
| `tools/generate_tokens.dart`, `tools/tokens/*.dart`     | New                               |
| `tools/test/generate_tokens_test.dart`                  | New                               |
| `packages/tokens/lib/src/colors/brand_palette.dart`     | New (generated, not exported yet) |
| `packages/tokens/test/contrast_contract_generated.dart` | New (generated)                   |
| `apps/docs/src/app/tokens.generated.css`                | New (generated, not imported yet) |
| `apps/docs/src/lib/tokens.generated.ts`                 | New (generated, not imported yet) |

## 8. Tasks

| ID    | Task                                                                                                                             | Depends on |
| ----- | -------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| P1.T1 | Write the token source with every value from `02-design-spec.md`                                                                 | P0         |
| P1.T2 | Implement the generator and its tests                                                                                            | P1.T1      |
| P1.T3 | Emit and commit `brand_palette.dart`, the test contract, the CSS and the TS. Emit `color_semantic.dart` to a temporary path only | P1.T2      |
| P1.T4 | Add `generate_tokens.dart --check` to the local Definition of done list (after the owner applies the P0 patch)                   | P1.T3      |

## 9. Acceptance criteria

1. AC-1.1: Every hex in the source equals `02-design-spec.md`.
2. AC-1.2: `dart run tools/generate_tokens.dart --check` exits 0 after
   generation.
3. AC-1.3: All tests in `tools/test/generate_tokens_test.dart` pass.
4. AC-1.4: `dart format --set-exit-if-changed .` passes; Prettier check
   passes on the generated CSS and TS.
5. AC-1.5: `flutter analyze` in `packages/tokens` passes with
   `brand_palette.dart` present but unexported.
6. AC-1.6: `bun run lint`, `bun run type-check` and the ASCII purity test pass
   in `apps/docs`.
7. AC-1.7: Nothing under `packages/tokens/lib` or `packages/core/lib` contains
   a non-Dart file.

## 10. Risks

| Risk                                            | Mitigation                                                                 |
| ----------------------------------------------- | -------------------------------------------------------------------------- |
| Generator OKLCH math differs from `OklchEngine` | Parity test in P2 compares both for one tint                               |
| Generated files edited by hand later            | `--check` in Definition of done; AGENTS.md invariant (P0 patch)            |
| JSON grows too complex for presets added later  | Closed `parts` set with a version number; extend by bumping `meta.version` |

## 11. Pending decisions

| Decision | Default assumed in this phase                 |
| -------- | --------------------------------------------- |
| DP-7     | Keep the owner's exact hex (1-unit tolerance) |
| DP-8     | Warm tint is the default                      |
| DP-12    | `errorHover` is part of the palette           |

## 12. Exit criteria

All acceptance criteria met; outputs committed; nothing consumes the outputs
yet, so the visible product is unchanged.
