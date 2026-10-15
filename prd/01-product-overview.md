# 01. Product Overview: Ink and Paper

Status: Draft v1 (2026-10-13)
Applies to: all phases

## 1. Problem

JustUI has two visual identities that do not match.

1. The docs site (`apps/docs`) uses IBM Plex, zinc-like grays and a lime accent
   (`#a3e635`). The owner likes its structure, but the non-docs pages (landing,
   catalog, Studio) read as generic AI-generated UI.
2. The Flutter library (`packages/tokens`, `packages/core`) uses a Tailwind
   blue primary (`#3B82F6`), slate neutrals and Inter. Users who install
   JustUI get a look that has nothing to do with the docs.
3. The two sets of values are written by hand in two places
   (`packages/tokens/lib/src/colors/*.dart` and
   `apps/docs/src/app/globals.css`). They have already drifted apart.
4. The color model has no role for a primary action. Components use
   `borderFocus` as the primary fill, and the neobrutalism preset picks yellow
   (`colors.warning`) for primary buttons through the `showsDefaultBorder`
   flag. Preset decisions are hidden inside color decisions, which makes every
   new preset harder to add.
5. Several current colors fail WCAG. See `03-baseline-audit.md` section 7.

## 2. Vision

One monochrome brand, "Ink and Paper", shared by the docs and the library:

- Ink-colored text and controls on a paper-colored canvas, with a very slight
  warm tint so it reads as premium print instead of default gray.
- No accent color. Primary actions and selected states use inversion (an ink
  fill with paper text).
- Color appears only for status (error, success, warning), and only in a few
  allowed places, always with a shape and text.
- Every text role reaches 7:1 (WCAG AAA) on every surface it can sit on.
- Presets (default, neobrutalism and future ones) change shape and motion,
  never the brand hues.

## 3. Goals

| ID  | Goal                                                                       |
| --- | -------------------------------------------------------------------------- |
| G1  | One color identity for docs and library, generated from one token source   |
| G2  | Pass every WCAG 2.2 color criterion, including 1.4.6 and 2.4.13 (AAA)      |
| G3  | Keep non-monochrome color to three status hues in a fixed allow-list       |
| G4  | Make presets data: no `preset == .neobrutalism` and no color flags in code |
| G5  | Keep neobrutalism recognizable under the monochrome palette                |
| G6  | Give existing users a migration path with no compile break in one release  |
| G7  | Make it cheap to add a third, fourth or tenth preset later                 |

## 4. Non-goals

1. Changing typography in the Flutter library (Inter stays unless DP-6 says
   otherwise).
2. Redesigning page layouts of the docs site beyond what the color change
   requires. A layout redesign of the landing page is a separate project.
3. Adding new components or new presets.
4. Changing the registry format, CSP, security headers or signing.
5. Logo or icon design (see DP-10).
6. Any work listed in `91-out-of-scope.md`.

## 5. Users and how they are affected

| User                                 | Impact                                                       |
| ------------------------------------ | ------------------------------------------------------------ |
| New JustUI user (runs `justui init`) | Gets Ink and Paper by default, with a tint option            |
| Existing user with copied files      | Old role names keep compiling as deprecated getters          |
| User who calls `fromSeed`            | Keeps compiling; the seed hue becomes the neutral tint       |
| Docs reader                          | Sees the monochrome identity in every preset and mode        |
| Keyboard and low-vision reader       | Gets AAA text, visible focus and forced-colors support       |
| Future preset author                 | Adds one preset class and one JSON entry, no component edits |

## 6. Success metrics

| ID  | Metric                                                             | Target           |
| --- | ------------------------------------------------------------------ | ---------------- |
| M1  | Minimum text contrast across all roles, surfaces, presets, modes   | >= 7.00:1        |
| M2  | Minimum control boundary and focus ring contrast                   | >= 3.00:1        |
| M3  | axe violations with `wcag2aaa` and `wcag22aa` tags on docs         | 0                |
| M4  | Hard-coded opaque `Color(0xFF...)` in components (excluding masks) | 0                |
| M5  | `presetTokens.showsDefaultBorder` reads inside components          | 0                |
| M6  | `preset == .neobrutalism` comparisons in core and components       | 0                |
| M7  | Accent utilities (`*-accent*`) in `apps/docs/src`                  | 0                |
| M8  | Places where a color value is authored by hand                     | 1 (token source) |
| M9  | Existing user code that stops compiling after upgrade              | 0                |
| M10 | Files a new preset must touch (excluding tests and docs)           | <= 3             |

## 7. Scope summary per phase

| Phase | Name                        | Main output                                         |
| ----- | --------------------------- | --------------------------------------------------- |
| P0    | Baseline and safety nets    | CSS comment fix, guard tests, rule-change patches   |
| P1    | Token source and generator  | `ink_and_paper.tokens.json`, `generate_tokens.dart` |
| P2    | Tokens API                  | New roles in `JustColorScheme`, deprecations        |
| P3    | Core theme engine           | Preset tokens, `inkAndPaper`, Material bridge       |
| P4    | Component migration         | 30 component families on the new roles              |
| P5    | Registry, showcase, preview | Regenerated registry, showcase and Widgetbook       |
| P6    | Docs foundation             | Generated CSS, Fumadocs map, focus, links, code     |
| P7    | Docs UI and content         | Accent sweep, Studio, landing, MDX, README          |
| P8    | CLI                         | `--tint`, new init template, doctor check           |
| P9    | Verification and release    | Release gate, changelog, migration guide            |

## 8. Constraints

1. Zero third-party pub dependencies in `packages/core` and `packages/tokens`.
2. `packages/tokens/lib` and `packages/core/lib` are embedded into the CLI
   binary (`packages/cli/src/utils/embedded_templates.rs`, RustEmbed). Any file
   placed there ships to users. The token source must live outside `lib/`.
3. `registry/` is generated from `packages/core` by
   `tools/generate_checksums.dart` and must never be hand-edited.
4. `apps/showcase/lib/{core,tokens,widgets}` are generated by the CLI.
5. Every file under `apps/docs/src`, `apps/docs/content` and `apps/docs/test`
   must be ASCII (`test/ascii-purity.test.ts`).
6. The anchor `// CLI:REGISTER_EXTENSIONS` in
   `packages/core/lib/src/theme/theme_data_material.dart` must not change.
7. Component theme access follows the aspect rules: `context.justColors`,
   `context.justPresetTokens` and the other aspect getters in `build`, and
   `context.readTheme()` in callbacks.
8. No heap allocation in per-frame callbacks (animation builders, drag ticks,
   `LayoutBuilder`).
9. Some checks (Flutter widget tests, goldens, Playwright, build_runner,
   showcase regeneration) only run on the owner machine.

## 9. Release strategy

1. All phases land on one feature branch (for example `feat/ink-and-paper`).
2. Intermediate phases must compile and pass their checks, but they may look
   visually mixed. Nothing is released before P9.
3. The release is a minor version with deprecations by default (DP-1). Old
   role names, `fromSeed` and the neobrutalism scheme factories stay for one
   minor release and are removed in the next one.
4. Changesets are written for `just_ui_tokens`, `just_ui_core`, `justui_cli`
   and `docs`.

## 10. Global risks

| ID  | Risk                                                        | Mitigation                                     |
| --- | ----------------------------------------------------------- | ---------------------------------------------- |
| R1  | Existing users get compile errors after updating components | Deprecated forwarding getters, doctor check    |
| R2  | Web and Flutter drift again                                 | Generator plus `--check` in Definition of done |
| R3  | All text at 7:1 flattens hierarchy                          | Hierarchy by size, weight and Plex Mono        |
| R4  | Neobrutalism loses its character                            | Rule A in `02-design-spec.md` section 6        |
| R5  | Status colors are indistinguishable without hue             | Mandatory icon shape and text                  |
| R6  | Sandbox cannot run visual tests                             | Owner-machine checks are part of the P9 gate   |
| R7  | Wide docs sweep breaks line limits or React Compiler rules  | Sweep per folder, lint after each folder       |
