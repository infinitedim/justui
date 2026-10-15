# Phase 6: Docs Foundation

Status: Draft v1 (2026-10-13)
Depends on: P0, P1
Blocks: P7
Areas: `apps/docs/src/app/globals.css`, `apps/docs/src/lib`, `apps/docs/src/app/[lang]/layout.tsx`, `apps/docs/test`, `apps/docs/e2e`

## 1. Summary

Wire the generated tokens into the docs site and rebuild the docs color
foundation: Tailwind theme mapping, Fumadocs mapping, focus ring, link style,
forced colors, prefers-contrast, text selection and monochrome code
highlighting. After this phase every docs utility resolves to Ink and Paper,
while transitional aliases keep old utility names rendering until P7 sweeps
the components.

## 2. Background

1. `globals.css` holds about 104 hand-written hex values across raw palette,
   default and neobrutalism, light and dark blocks.
2. The `@theme` block defines these color utilities today: background,
   foreground, secondary, muted, border, card, surface, surface-muted,
   elevated, fill, accent, accent-foreground, accent-text, accent-light,
   accent-dark, accent-deep, accent-muted, success, warning, error,
   destructive, destructive-solid, on-destructive, info, syn-keyword,
   syn-string, syn-type, syn-number, syn-comment.
3. The focus ring and links fail WCAG (`03-baseline-audit.md` section 2).
4. Shiki colors fail AAA.
5. The inline preset script in `src/app/[lang]/layout.tsx` adds
   `theme-neobrutalism` before hydration. It must not change.

## 3. Goals

1. Docs colors come only from `tokens.generated.css`.
2. Utility names describe roles, not hues.
3. AAA text, AA non-text and AAA focus appearance in all 4 combinations.
4. Forced colors and prefers-contrast supported.

## 4. Non-goals

1. Sweeping component classes (P7).
2. Changing layout, spacing, radius or motion tokens.
3. Touching CSP, headers or the inline preset script.

## 5. Functional requirements

### FR-6.1 Import generated tokens

1. `globals.css` imports `./tokens.generated.css` right after the Tailwind and
   Fumadocs imports.
2. Delete the hand-written color values: raw palette (72 to 91), default light
   and dark color lines (93 to 167) and the color lines inside the neobrutalism
   blocks (169 to 246). Keep radius, border width, motion and shadow geometry.
3. Neobrutalism blocks keep only shape and motion variables and the part
   variables that the generator emits for them.

### FR-6.2 Tailwind `@theme` mapping

Keep (meaning unchanged): `background` (canvas), `foreground` (textPrimary),
`secondary` (textSecondary), `card` (surface), `elevated` (raised), `border`
(container border, resolved per preset by the part mapping).

Add:

| Utility                                                | Variable                          |
| ------------------------------------------------------ | --------------------------------- |
| tertiary                                               | `--just-text-tertiary`            |
| disabled                                               | `--just-text-disabled`            |
| sunken                                                 | `--just-sunken`                   |
| hover                                                  | `--just-hover-fill`               |
| scrim                                                  | `--just-scrim`                    |
| selection                                              | `--just-selection`                |
| border-control                                         | `--just-border-control`           |
| border-subtle                                          | `--just-border-subtle`            |
| inverse                                                | `--just-inverse`                  |
| inverse-hover                                          | `--just-inverse-hover`            |
| inverse-pressed                                        | `--just-inverse-pressed`          |
| on-inverse                                             | `--just-on-inverse`               |
| focus                                                  | `--just-focus-ring`               |
| error-hover                                            | `--just-error-hover`              |
| error-tint                                             | `--just-error-tint`               |
| success-tint                                           | `--just-success-tint`             |
| warning-tint                                           | `--just-warning-tint`             |
| primary-bg, primary-fg, primary-border, primary-shadow | part variables from the generator |

Transitional aliases (shrunk in P7.T7 to what deprecated non-docs files still use; removed by the redesign, OS-2), in one clearly marked block:

| Old utility                            | Alias to      |
| -------------------------------------- | ------------- |
| accent                                 | inverse       |
| accent-foreground                      | on-inverse    |
| accent-text                            | foreground    |
| accent-light, accent-dark, accent-deep | inverse-hover |
| accent-muted, surface-muted            | hover         |
| muted                                  | tertiary      |
| fill                                   | sunken        |
| destructive                            | error         |
| destructive-solid                      | error         |
| on-destructive                         | on-inverse    |
| info                                   | foreground    |
| syn-\*                                 | see FR-6.6    |

### FR-6.3 Fumadocs mapping

The restored `body` block (P0) maps:

| Fumadocs variable       | Role         |
| ----------------------- | ------------ |
| fd-background           | canvas       |
| fd-foreground           | textPrimary  |
| fd-muted                | sunken       |
| fd-muted-foreground     | textTertiary |
| fd-card                 | surface      |
| fd-card-foreground      | textPrimary  |
| fd-popover              | raised       |
| fd-popover-foreground   | textPrimary  |
| fd-border               | borderSubtle |
| fd-primary              | textPrimary  |
| fd-primary-foreground   | onInverse    |
| fd-secondary            | sunken       |
| fd-secondary-foreground | textPrimary  |
| fd-accent               | hoverFill    |
| fd-accent-foreground    | textPrimary  |
| fd-ring                 | focusRing    |

Plus `::selection { background: var(--just-selection); color: var(--just-text-primary); }`.

### FR-6.4 Focus and links

1. Define `--just-focus-ring-width` in `globals.css`: `2px` on `:root`,
   `2.5px` on `.theme-neobrutalism`, `3px` inside
   `@media (prefers-contrast: more)`. `ui-classes.ts` `focusRing` becomes
   `focus-visible:outline-solid focus-visible:outline-[length:var(--just-focus-ring-width)] focus-visible:outline-offset-2 focus-visible:outline-focus`.
   A fixed utility such as `outline-2` must not be used: in Tailwind v4
   (`tailwindcss` ^4.3.3) it compiles to a static `outline-width: 2px`, so the
   neobrutalism value would never apply and AC-6.5 would fail.
2. `accentLink` is renamed `link` and is always underlined:
   `underline underline-offset-4 decoration-1 hover:decoration-2`.
3. Prose links inside MDX content are underlined in `globals.css`.
4. Navigation links keep no underline and must set `aria-current` when active.

### FR-6.5 Forced colors and prefers-contrast

1. `@media (forced-colors: active)`:
   - inverse buttons get a 1px transparent border that becomes visible;
   - selected states map to `Highlight` and `HighlightText`;
   - SVG icons use `currentColor`;
   - focus uses `outline` (already).
2. `@media (prefers-contrast: more)` uses the generated high contrast block
   (the same collapse as Flutter: tertiary and secondary become primary,
   subtle borders become control borders).
3. `viewport.themeColor` in `src/app/[lang]/layout.tsx` is set to the light
   and dark canvas values.

### FR-6.6 Monochrome code highlighting

1. `src/lib/justui-shiki-theme.ts` reads colors from `tokens.generated.ts`
   instead of its own palette.
2. Mapping on the `sunken` background: keyword textPrimary bold; type
   textPrimary; string, number and punctuation textSecondary; comment
   textTertiary italic.
3. The `--just-syn-*` variables used by the playground (`CodeLines`) map to the
   same roles.
4. Code stays on IBM Plex Mono and keywords use weight 500 (DP-6, decided
   2026-10-14). The difference between classes comes from weight 500 vs 400
   plus italic comments. No Plex Mono 600 is loaded. The sans font change is
   FR-6.7.

### FR-6.7 Font: Plus Jakarta Sans

1. `src/app/[lang]/layout.tsx` loads `Plus_Jakarta_Sans` through
   `next/font/google` as `--font-sans`, replacing `IBM_Plex_Sans`. Weights:
   400, 500, 600, 700. The inline preset script is not touched.
2. Plus Jakarta Sans has no monospace sibling. The mono family for code
   stays IBM Plex Mono until the owner picks another (DP-6).
3. Check after the swap: heading sizes and line heights (Plus Jakarta Sans is
   wider than IBM Plex Sans), table and navbar overflow, and layout shift
   (NFR-6.3 is relaxed for this task; the visual diff is reviewed manually).
4. Contrast is unaffected, but 7:1 text at weight 400 must stay legible:
   body copy uses weight 400 or 500, never 300.

## 6. Non-functional requirements

1. NFR-6.1: All files ASCII.
2. NFR-6.2: No new npm dependency.
3. NFR-6.3: No layout shift: only color, outline and decoration properties
   change.

## 7. Files

| File                                           | Change                                                               |
| ---------------------------------------------- | -------------------------------------------------------------------- |
| `apps/docs/src/app/globals.css`                | Import, mapping, aliases, media queries                              |
| `apps/docs/src/lib/ui-classes.ts`              | focusRing, link                                                      |
| `apps/docs/src/lib/catalog-i18n/ui-classes.ts` | Same as above if it duplicates them                                  |
| `apps/docs/src/lib/justui-shiki-theme.ts`      | Generated roles                                                      |
| `apps/docs/src/app/[lang]/layout.tsx`          | `Plus_Jakarta_Sans` font swap and themeColor (not the inline script) |
| `apps/docs/test/*.test.ts`                     | New tests (section 9)                                                |
| `apps/docs/e2e/*.spec.ts`                      | New checks (section 9)                                               |

## 8. Tasks

| ID     | Task                                                          | Depends on      |
| ------ | ------------------------------------------------------------- | --------------- |
| P6.T1  | Import generated CSS, delete hand-written colors, add aliases | P0, P1          |
| P6.T2  | `@theme` and Fumadocs mapping, `::selection`                  | P6.T1           |
| P6.T3  | Focus, links, forced colors, prefers-contrast, themeColor     | P6.T2           |
| P6.T4  | Monochrome Shiki and playground                               | P6.T1           |
| P6.T4b | Font swap to Plus Jakarta Sans (FR-6.7)                       | P6.T1           |
| P6.T5  | Tests                                                         | P6.T1 to P6.T4b |

## 9. Tests and acceptance criteria

1. AC-6.1: `globals.css` contains no hex literal outside the generated import
   (Vitest test counts hex values in `globals.css`).
2. AC-6.2: A Vitest test computes every role pair from `tokens.generated.ts`
   with the WCAG formula and asserts the floors in `02-design-spec.md`.
3. AC-6.3: A Vitest test asserts every Shiki token color is at least 7.0 on
   the code background in both modes.
4. AC-6.4: Playwright reads computed `--color-fd-primary` on `body` and expects
   the textPrimary value in 4 combinations.
5. AC-6.5: Playwright tabs through the header and the search dialog; for each
   focused element, `outline-style` is solid, `outline-width` is 2px (2.5px in
   neobrutalism, 3px with `prefers-contrast: more`), `outline-offset` is 2px, and `outline-color` equals the
   focus ring value.
6. AC-6.6: Playwright with `emulateMedia({ forcedColors: 'active' })`: primary
   buttons have a computed border width of at least 1px.
7. AC-6.7: Every link inside MDX prose has `text-decoration-line: underline`.
8. AC-6.8: `bun run lint`, `bun run type-check`, `bun run test`, `bun run
build` pass.

## 10. Risks

| Risk                                                                           | Mitigation                                                                                  |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------- |
| Aliases hide places that still mean "accent"                                   | P7 sweeps every in-scope file; the guard list may only keep deprecated files (P7 section 0) |
| Fumadocs regions look different once mapped                                    | Visual review of 4 combinations after P6.T2                                                 |
| Overriding Tailwind `black` and `white` variables (current globals.css 73, 76) | Remove the overrides in P6.T1; P7 sweeps `bg-black`, `bg-white`, `text-white`               |

## 11. Pending decisions

| Decision | Default assumed                                                        |
| -------- | ---------------------------------------------------------------------- |
| DP-6     | Plus Jakarta Sans for sans; Plex Mono stays for code; keywords use 500 |
| DP-8     | Warm tint                                                              |

## 12. Exit criteria

All acceptance criteria met; docs render in Ink and Paper with transitional
aliases still present.
