# Phase 7: Docs UI and Content

Status: Draft v2 (2026-10-14: non-docs pages deprecated)
Depends on: P6 (tokens and utilities), P3 (Dart API used in snippets)
Blocks: P9
Areas: `apps/docs/src/components`, `apps/docs/src/app/[lang]`, `apps/docs/src/lib`, `apps/docs/content/docs`, `apps/docs/test`, `apps/docs/e2e`, `README.md`

## 0. Scope change (2026-10-14, owner decision)

The owner will redesign every Next.js page that is not a docs page. In this
phase those pages are deprecated: they are not migrated, they only keep
rendering until the redesign replaces them.

1. In scope: the docs pages (`/[lang]/docs/**`), the shared shell they use
   (navbar, footer, search, theme and preset switchers, layout) and the MDX
   content.
2. Deprecated (not migrated here): `/[lang]` (landing), `/[lang]/components`
   (catalog), `/[lang]/studio` (Theme Studio) and `not-found`, plus every
   component used only by those pages (for example `what-you-get`,
   `contrast-demo`, `component-preview-grid`, `living-stage`,
   `component-card`, `components-catalog-client`, `theme-configurator`,
   `studio-preview`, `code-export-drawer`, `theme-studio-context`,
   `not-found-view`).
3. New task P7.T0 builds the real split from the import graph of the docs
   route. Files imported by both sides count as in scope. The lists in this
   file are a starting guess and P7.T0 overrides them.
4. Consequences, applied in the sections below:
   - FR-7.3 to FR-7.5 (Studio tint picker, URL compatibility, code export,
     parity test) and FR-7.7 (landing and decorative areas) move to
     "Deprecated" and are not built. The Studio keeps its seed UI and its
     `fromSeed` export; the export is marked deprecated and the redesign
     replaces it.
   - FR-7.1 and FR-7.2 sweep only in-scope files.
   - Deprecated files stay on the transitional aliases from P6. FR-7.8 changes
     accordingly: the alias block is not deleted; it shrinks to what the
     deprecated files still use, carries a "remove with the redesign" comment,
     and the style guards keep an allow-list that contains only deprecated
     files. New files may not use aliases.
   - AC-7.4 (no `a3e635`) and the M7 metric (zero accent utilities) are
     measured only on in-scope files. The deprecated list is reported as the
     number left for the redesign.
   - The Studio no longer blocks P8 (the `--seed` alias in the CLI still
     exists for it).
5. Axe and keyboard checks (FR-7.10, V-10, V-11) cover docs pages only, plus
   the landing page as "known, not gated".

## 1. Summary

Move every docs component, the Theme Studio, the landing page and the MDX
content from the old accent and status utilities to Ink and Paper roles. At the
end of this phase the transitional aliases from P6 are deleted, no file uses
an accent utility, status color appears only where it carries meaning, and the
docs explain the new palette, the tint and the migration path in English and
Indonesian.

## 2. Background

1. Accent utilities appear 124 times in 54 files (`03-baseline-audit.md`
   section 2). Status utilities appear in 12 files.
2. P6 kept those files rendering through aliases (`accent` to `inverse`,
   `muted` to `tertiary`, and so on). Aliases hide intent: some accent uses
   mean "primary action", some mean "link", some mean "selected", some are
   pure decoration. Each use must be mapped by meaning, not by name.
3. The Theme Studio is built around a seed color. Its default seed `#a3e635`
   appears in:
   - `src/lib/theme-studio-context.tsx:43` (`DEFAULT_SEED_COLOR`)
   - `src/components/organisms/theme-configurator/theme-configurator.tsx:225`
     and `:237`
   - `src/lib/theme/perceptual.ts:33` (fallback of `normalizeHex`)
   - comments in `src/lib/theme/url-serializer.ts:16` and
     `src/components/organisms/code-export-drawer/code-generators.ts:7`
4. `url-serializer.ts` writes `seed=<hex>&dark=&preset=&cs=` into shared Studio
   links. Links already shared on the web must keep working.
5. `code-generators.ts` emits `JustThemeData.fromSeed(...)` (lines 55 to 94),
   which is deprecated after P3.
6. `e2e/accessibility.spec.ts:16` runs axe with AA tags only.
7. `README.md:10` shows a lime "docs" badge.
8. MDX pages that describe colors, contrast or theming exist in `en` and `id`
   (`cn` is empty): `tokens/colors`, `tokens/shadows`, `theming`,
   `guides/custom-theme`, `guides/accessibility`, `guides/copy-paste-workflow`,
   `guides/migration`, `cli-setup`, and the component pages for carousel,
   dialog, toast and tooltip.

## 3. Goals

1. Zero accent utilities and zero transitional aliases.
2. Every remaining status color use is on the allow-list in `02-design-spec.md`
   and is paired with a glyph and text.
3. The Studio edits a tint, not a seed, and its output matches Dart exactly.
4. The docs content tells the truth about colors, contrast levels and APIs.
5. axe passes with AAA color tags and WCAG 2.2 AA tags in 4 combinations.

## 4. Non-goals

1. Changing page layout, spacing, typography scale or copy outside color and
   theming topics.
2. Translating to `cn`.
3. Redesigning the landing page structure (`91-out-of-scope.md`).
4. Touching the inline preset script in `src/app/[lang]/layout.tsx`.

## 5. Functional requirements

### FR-7.1 Accent sweep mapping

Every accent use is mapped by meaning. The implementer reads each use, decides
which row applies, and records non-obvious cases in the batch notes.

| Old class or helper                      | Meaning                       | New class or helper                                                                  |
| ---------------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------ |
| `bg-accent text-accent-foreground`       | Primary action, selected chip | `bg-inverse text-on-inverse` with `hover:bg-inverse-hover active:bg-inverse-pressed` |
| `accentControl` helper (`ui-classes.ts`) | Primary control               | Uses the `--just-primary-*` part variables so neobrutalism gets Rule A               |
| `bg-accent-muted`, `bg-surface-muted`    | Hover or soft highlight       | `bg-hover`                                                                           |
| `text-accent-text` on a link             | Link                          | `text-foreground` plus the `link` helper (always underlined)                         |
| `text-accent-text` on non-link text      | Emphasis                      | `text-foreground font-medium`                                                        |
| `border-accent`                          | Control or selected edge      | `border-control`, or `border-foreground` when it marks selection                     |
| `accent-accent` (native inputs)          | Checkbox, radio, range        | `accent-inverse`                                                                     |
| `fill-accent`                            | Icon or logo fill             | `fill-foreground`                                                                    |
| `caret-accent-text`                      | Text caret                    | `caret-foreground`                                                                   |
| `ring-accent`, `outline-accent`          | Focus                         | The `focusRing` helper from P6                                                       |
| `decoration-accent`                      | Link underline                | `decoration-foreground`                                                              |
| `bg-black/60` and similar                | Backdrop                      | `bg-scrim`                                                                           |
| `bg-white`                               | Text on dark fill             | `bg-on-inverse`                                                                      |
| `text-white`                             | Text on dark fill             | `text-on-inverse`                                                                    |
| Gradients or glows using accent          | Decoration                    | Removed. If depth is needed, use the shadow tokens                                   |

Rules:

1. Selected state is never shown by color alone. Selected chips, tabs, pills
   and segmented toggles use the inverse fill plus `aria-pressed`,
   `aria-selected` or `aria-current`.
2. Hover never changes only the hue; it changes fill (`hover`), decoration
   thickness (links) or the inverse step.
3. The 54 files are swept in the groups below so review stays small. After
   each group the `ACCENT_ALLOWED` list in `style-guards.test.ts` shrinks.

| Group | Files (under `apps/docs/src/`)                                                                                                                                                                                                                    |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| G1    | `lib/ui-classes.ts`, `lib/catalog-i18n/ui-classes.ts`, `lib/layout.shared.tsx`, atoms (badge, button, code, input, logo-mark, progress-bar, slider, toggle-chip)                                                                                  |
| G2    | molecules (catalog-filter-bar, category-filter-pill, color-swatch-item, copy-button, formula-math-block, install-tabs, search-result-item, segmented-toggle, state-toggle, terminal-prompt, theme-switcher, variant-picker, viewport-switch)      |
| G3    | organisms (code-export-drawer, component-preview-grid, footer, interactive-terminal, living-component-card and its dart-code-modal, living-stage, navbar, not-found-view, studio-preview, theme-configurator, what-you-get and its contrast-demo) |
| G4    | `components/preview-mocks/*` (badge, checkbox, input, mock-styles.ts, progress, radio-group, scroll-area, select, sidebar, slider, switch, toggle)                                                                                                |
| G5    | `app/[lang]/page.tsx`, `app/[lang]/components/components-catalog-client.tsx`, `components/component-card.tsx`, `components/docs/button-playground.tsx`, `components/docs/just-button-preview.tsx`                                                 |

### FR-7.2 Status sweep

The 12 files that use status utilities are handled one by one:

| File or component                  | New behavior                                                                                                                                                     |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| atoms/badge                        | Status variants render monochrome with a leading glyph (check, triangle, cross, dot). Mirrors DP-3                                                               |
| atoms/button                       | Destructive variant: `bg-error text-on-inverse`, hover `bg-error-hover`                                                                                          |
| atoms/input                        | Error state: `border-error`, 3px under neobrutalism, message in `text-error` with an error glyph and `aria-invalid`                                              |
| docs/just-button-preview           | Same as atoms/button                                                                                                                                             |
| interactive-terminal terminal-line | Each line kind gets an ASCII prefix (`ok`, `!`, `x`, `>`). Only error lines keep `text-error`; success and warning lines are `text-foreground` with their prefix |
| component-preview-grid             | Category chips are monochrome; no hue per category                                                                                                               |
| studio-preview                     | Status swatches show the three status colors with tints, each labeled                                                                                            |
| theme-configurator                 | No status colors outside the status swatch block                                                                                                                 |
| preview-mocks avatar               | Presence dots use shape plus `aria-label` (filled circle online, ring away, slashed ring busy) in `text-foreground`                                              |
| preview-mocks dialog               | Destructive confirm uses the destructive button                                                                                                                  |
| preview-mocks icon-button          | Destructive icon button uses `text-error` with a visible label or tooltip                                                                                        |
| preview-mocks toast                | Status toasts: monochrome surface, colored glyph, `role="status"` or `role="alert"`; tint background allowed only for error                                      |

After the sweep, `STATUS_ALLOWED` in `style-guards.test.ts` contains only the
files listed above that still use a status utility, and each use is on the
allow-list in `02-design-spec.md`.

### FR-7.3 Theme Studio becomes a tint picker (DEPRECATED, see section 0; not built)

1. State: replace `seedColor` with `tintHue` (0 to 359, default 80) and
   `tintChroma` (0 to 0.010, default 0.0035). Keep `isDark` and `preset`.
2. The color space selector (`cs`) is removed from the UI. It no longer
   affects colors (option D, DP-4).
3. Controls: a hue slider, a chroma slider, and two preset buttons "Warm"
   (80, 0.0035) and "Graphite" (260, 0.0035). Each control has a visible
   label and an `aria-valuetext`.
4. Color math: a new `src/lib/theme/ink-and-paper.ts` rebuilds every neutral
   from the generated neutral L table in `tokens.generated.ts` plus
   `(tintHue, tintChroma)` using the existing `oklch.ts`. Status colors come
   straight from `tokens.generated.ts` and do not move with the tint.
5. The Studio shows the live minimum ratio of each contract rule and marks any
   rule below its floor. With chroma at most 0.010 no rule can fail (verified
   by the hue sweep in `02-design-spec.md`), so the check is a safety net.
6. `color-resolver.ts`, `hsluv.ts` and `perceptual.ts` keep only what other
   code still imports. Unused exports are deleted with their tests.
7. `perceptual.ts` `normalizeHex` falls back to the light `textPrimary` hex
   instead of `#a3e635`.

### FR-7.4 Studio URL compatibility (DEPRECATED, see section 0; not built)

1. New format: `tint=<hue>,<chroma>&dark=<0|1>&preset=<def|neo>`.
2. Old links with `seed=<hex>` still load: the seed is converted with the same
   rule as Dart `fromSeed` option D (seed OKLCH hue, chroma 0.0035, warm when
   the seed chroma is below 0.02). The `cs` parameter is ignored.
3. Invalid values fall back to warm.

### FR-7.5 Code export (DEPRECATED, see section 0; not built)

1. `generateDart` emits:

```
final theme = JustThemeData.inkAndPaper(
  brightness: Brightness.light,
  preset: JustThemePreset.neobrutalism,
  tint: JustTint.warm,
);
```

with `JustTint.graphite` for hue 260 and chroma 0.0035, and
`JustTint(hue: <h>, chroma: <c>)` for any other value. 2. `generateYaml` and `generateCli` emit the P8 options (`--tint` or
`--tint-hue`) instead of `--seed`. 3. The generated Dart matches the dot shorthand style used in the repository
where the parameter type allows it. 4. `seedToArgbHex` is deleted if nothing else uses it.

### FR-7.6 Studio and Dart parity (DEPRECATED, see section 0; not built)

`apps/docs/test/ink-and-paper-parity.test.ts` (new):

1. For tint hue 260 and chroma 0.0035, every role computed by
   `ink-and-paper.ts` equals the hex that Dart `JustThemeData.inkAndPaper`
   produces with `JustTint.graphite`. The generator (P1) already knows both
   named tints from the token source; P7.T4 extends it to also emit the
   resolved graphite roles into `tokens.generated.ts`, so the test needs no
   Dart run and both sides come from the same source.
2. For hue 80 and chroma 0.0035, every role equals the generated warm values.
3. Tolerance: 1 unit per channel.

### FR-7.7 Landing page and decorative areas (DEPRECATED, see section 0; not built)

1. `app/[lang]/page.tsx` and `what-you-get`: no lime, no colored glow, no
   colored gradient. Emphasis comes from type weight, the inverse block and
   shadow tokens.
2. `contrast-demo` shows the real contract: each role pair, its measured ratio
   from `tokens.generated.ts`, and the floor (7:1 text, 3:1 non-text).
3. `logo-mark` uses `fill-foreground`. The logo shape does not change (DP-10).
4. `not-found-view` and `footer` follow the accent mapping.

### FR-7.8 Remove transitional aliases (in-scope files only, see section 0)

1. Delete the alias block added in P6 from `globals.css`.
2. `ACCENT_ALLOWED` becomes empty and is replaced by a hard ban of the accent
   pattern.
3. The hard bans from P0 (`focus-visible:outline-accent`, `bg-black`,
   `bg-white`, `text-white`) keep an empty allow-list.

### FR-7.9 MDX content (en and id)

| Page                                              | Change                                                                                                                                                                                                     |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tokens/colors.mdx`                               | Rewrite around roles. Uses a new `ColorRoleTable` component that reads `tokens.generated.ts` and shows role, swatch, light hex, dark hex and measured ratio. Remove the old neobrutalism hex claims        |
| `tokens/shadows.mdx`                              | Shadow colors from roles; neobrutalism shadow is ink, 4px offset                                                                                                                                           |
| `theming.mdx`                                     | `JustThemeData.inkAndPaper`, `JustTint`, presets own shape not color, deprecation of `fromSeed`                                                                                                            |
| `guides/custom-theme.mdx`                         | Custom tint, `CustomColorScheme` new constructor and `copyWith`, `fromLegacy`                                                                                                                              |
| `guides/accessibility.mdx`                        | WCAG 2.2, text floor 7:1, non-text 3:1, focus appearance, `isAccessibleAaaWith`, forced colors, status shape plus text rule                                                                                |
| `guides/copy-paste-workflow.mdx`                  | `init` output now uses `inkAndPaper`                                                                                                                                                                       |
| `guides/migration.mdx`                            | Link to the new migration guide                                                                                                                                                                            |
| `guides/migrate-ink-and-paper.mdx` (new)          | Old role to new role table, `fromSeed` to `inkAndPaper`, `borderDefault` split into subtle and control, badge status variants, CLI `--seed` to `--tint`, how to keep the old look with `CustomColorScheme` |
| `cli-setup.mdx`                                   | `--tint` and `--tint-hue`; remove the `seed_color` config field, which does not exist in `config.rs`                                                                                                       |
| Component pages: carousel, dialog, toast, tooltip | Replace color claims and snippets that use deprecated roles                                                                                                                                                |

Rules:

1. Every Dart snippet compiles against the P3 API (existing
   `mdx-dart-snippets.test.ts` covers this).
2. `en` and `id` change in the same commit.
3. The `meta.json` of `guides` lists the new page in both languages.

### FR-7.10 Accessibility test levels

1. `e2e/accessibility.spec.ts` adds the tags `wcag2aaa` and `wcag22aa`.
2. Runs cover light and dark, default and neobrutalism, on: home, components
   catalog, one component page, theming page, Studio.
3. Any axe rule excluded must be listed with a reason in the spec file. Color
   contrast rules may not be excluded.

### FR-7.11 README badge

`README.md:10` badge color changes from `lime` to `11100f`. No other README
change in this phase.

## 6. Non-functional requirements

1. NFR-7.1: No new npm dependency. `ColorRoleTable` is a server component with
   no client JavaScript.
2. NFR-7.2: All files ASCII (`ascii-purity.test.ts` already enforces this).
3. NFR-7.3: No layout shift on the landing page (visual snapshot diff limited
   to color).
4. NFR-7.4: Studio slider input updates the preview within one frame; color
   math allocates no new arrays per input event beyond the result object.

## 7. Files

| File or folder                                                                              | Change                      |
| ------------------------------------------------------------------------------------------- | --------------------------- |
| The 54 accent files listed in FR-7.1                                                        | Class mapping               |
| The 12 status files listed in FR-7.2                                                        | Status behavior             |
| `src/lib/theme-studio-context.tsx`                                                          | Tint state                  |
| `src/lib/theme/ink-and-paper.ts`                                                            | New                         |
| `src/lib/theme/url-serializer.ts`                                                           | New format, old format read |
| `src/lib/theme/color-resolver.ts`, `hsluv.ts`, `perceptual.ts`                              | Trimmed                     |
| `src/components/organisms/code-export-drawer/code-generators.ts`                            | inkAndPaper output          |
| `src/components/docs/color-role-table.tsx`                                                  | New                         |
| `src/app/globals.css`                                                                       | Alias block removed         |
| `content/docs/{en,id}/**`                                                                   | FR-7.9                      |
| `test/style-guards.test.ts`                                                                 | Ratchets closed             |
| `test/ink-and-paper-parity.test.ts`                                                         | New                         |
| `test/code-generators.test.ts`, `test/color-resolver.test.ts`, `test/theme-studio.test.tsx` | Updated                     |
| `e2e/accessibility.spec.ts`                                                                 | AAA and 2.2 tags            |
| `e2e/visual-snapshots.spec.ts` baselines                                                    | Regenerated (owner machine) |
| `README.md`                                                                                 | Badge color                 |

## 8. Tasks

| ID     | Task                                                                                          | Depends on     |
| ------ | --------------------------------------------------------------------------------------------- | -------------- |
| P7.T0  | Split in-scope and deprecated files from the import graph; record both lists                  | P6             |
| P7.T1  | Accent sweep G1 and G2 (in-scope files only)                                                  | P7.T0          |
| P7.T2  | Accent sweep G3, G4 and G5                                                                    | P7.T1          |
| P7.T3  | Status sweep (FR-7.2)                                                                         | P6             |
| P7.T4  | DEPRECATED (Studio tint picker, URL compatibility, parity test)                               | -              |
| P7.T5  | DEPRECATED (code export)                                                                      | -              |
| P7.T6  | DEPRECATED (landing and decorative areas)                                                     | -              |
| P7.T7  | Shrink aliases to the deprecated files, close ratchets for in-scope files (FR-7.8, section 0) | P7.T1 to P7.T3 |
| P7.T8  | MDX content en and id, `ColorRoleTable`, migration guide (no Studio references)               | P3             |
| P7.T9  | axe tags, snapshot baselines, README badge                                                    | P7.T7, P7.T8   |
| P7.T10 | Changeset (docs: minor)                                                                       | P7.T9          |

## 9. Acceptance criteria

1. AC-7.1: `grep -rnE "(bg|text|border|fill|caret|accent|outline|ring|decoration)-accent" apps/docs/src` returns nothing.
2. AC-7.2: `style-guards.test.ts` passes with `ACCENT_ALLOWED` removed and the
   hard bans at empty allow-lists.
3. AC-7.3: Every status utility left in `apps/docs/src` sits next to a glyph
   or text label (checked by review of the `STATUS_ALLOWED` list, which has at
   most the files in FR-7.2).
4. AC-7.4: `grep -rn "a3e635" apps/docs README.md` returns nothing.
5. AC-7.5: The parity test passes for warm and graphite.
6. AC-7.6: An old Studio link `?seed=3b82f6&dark=0&preset=def&cs=hsl` loads
   with a hue near 260 and no console error (Vitest on the serializer plus one
   Playwright check).
7. AC-7.7: `code-generators.test.ts` asserts `inkAndPaper` output and no
   `fromSeed`.
8. AC-7.8: `mdx-dart-snippets.test.ts` passes; no snippet uses a deprecated
   role or `fromSeed` except inside the migration guide's "before" blocks.
9. AC-7.9: axe with `wcag2a`, `wcag2aa`, `wcag2aaa`, `wcag21a`, `wcag21aa`,
   `wcag22aa` reports zero violations on the listed pages in 4 combinations
   (owner machine).
10. AC-7.10: Keyboard pass over the Studio: every control is reachable, shows
    the focus ring from P6, and announces its value.
11. AC-7.11: `bun run lint`, `bun run type-check`, `bun run test`,
    `bun run build`, `bun run test:e2e` pass (e2e on owner machine).

## 10. Risks

| Risk                                                      | Mitigation                                                                                                      |
| --------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Mapping by name instead of meaning (links lose underline) | Mapping table plus AC-6.7 from P6 still runs                                                                    |
| The page looks flat without lime                          | Design review of the landing in 4 combinations after P7.T6; emphasis through weight, inverse blocks and shadows |
| Shared Studio links break                                 | FR-7.4 and AC-7.6                                                                                               |
| Snapshot churn hides real regressions                     | Regenerate baselines once, after P7.T7, and review the diff image by image                                      |
| `id` content drifts from `en`                             | Same-commit rule in FR-7.9                                                                                      |

## 11. Pending decisions

| Decision | Default assumed                                         |
| -------- | ------------------------------------------------------- |
| DP-3     | Badge status variants monochrome with glyph             |
| DP-4     | Option D (seed hue becomes tint), used for old URLs too |
| DP-6     | Plus Jakarta Sans (set in P6, FR-6.7)                   |
| DP-8     | Warm default, graphite as the second named tint         |
| DP-10    | Logo shape and icons unchanged                          |
| DP-13    | Info has no color                                       |

## 12. Exit criteria

All acceptance criteria met. The docs contain no accent utility, no alias, no
lime and no unpaired status color, and the content matches the shipped API.
