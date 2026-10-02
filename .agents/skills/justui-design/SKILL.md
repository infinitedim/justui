---
name: justui-design
description: JustUI's design process for any UI work on the docs site (landing, catalog, docs pages, Studio) or on Flutter components. Forked from taste-skill and narrowed to this product. Use with .agents/rules/design.md, which holds the hard constraints.
---

# justui-design

This skill is the process. `.agents/rules/design.md` is the law (locked
tokens, anti-slop list, accessibility, verification). When they disagree,
`design.md` wins.

## 1. Design read (always first)

Before any code, write one line:

> Reading this as: <surface> for <audience>, mode <evolve|overhaul>,
> dials <variance>/<motion>/<density>.

Surfaces:

| Surface | Path | What it must do |
| --- | --- | --- |
| Landing | `src/app/[lang]/page.tsx`, `templates/landing-template.tsx` | Make a Flutter developer understand JustUI in 10 seconds and try the CLI |
| Catalog | `src/app/[lang]/components` | Let people scan, filter and compare components fast |
| Docs page | `content/docs/**`, `[lang]/docs` | Let people read, copy code and get it working |
| Studio | `src/app/[lang]/studio` | Let people tune a theme and export something that reproduces exactly in Flutter |
| Flutter component | `packages/core/lib/src/components` | Be correct, accessible and consistent with the other 30 components |

Audience: Flutter developers evaluating a UI library. They read code, distrust
marketing, and judge quality by details (spacing, focus states, real APIs).

If the surface or mode is unclear and the answer changes the result, ask one
question. Otherwise state your read and continue.

## 2. Dials

Three numbers from 1 to 10 that steer every choice.
VARIANCE: 1 strict symmetry, 10 experimental. MOTION: 1 static, 10
cinematic. DENSITY: 1 airy, 10 packed.

| Surface | Variance | Motion | Density |
| --- | --- | --- | --- |
| Landing | 7 | 6 | 4 |
| Catalog | 4 | 3 | 6 |
| Docs page | 3 | 2 | 5 |
| Studio | 4 | 3 | 7 |
| Flutter component | follow the component conventions; motion from `JustMotionProfile` |

The user can override dials in conversation. Motion above 3 is only allowed
on the landing page (see `design.md` Motion).

## 3. Mode: evolve or overhaul

- **Evolve** (default): keep information architecture, routes, nav labels,
  copy voice and tokens. Improve in this order and stop when the brief is met:
  1. typography hierarchy, 2. spacing and rhythm, 3. color use within the
  locked tokens, 4. interaction states, 5. section recomposition,
  6. replacing a block that cannot be saved.
- **Overhaul**: only when the user says so. New layout language on top of the
  same content and the same locked tokens. Changing the tokens themselves is a
  separate approval (`design.md`).

Never change without approval, in either mode: route slugs, locale structure,
primary nav labels, token names, component public APIs, CLI commands or flags
shown to users, the logo or wordmark.

## 4. Before you build: audit what exists

For any change to an existing surface, list in your plan:
- tokens and components already used there (reuse them),
- what is doing real work vs filler,
- accessibility that already works (do not regress it),
- tests and visual baselines that cover it.

Reuse atoms and molecules from `src/components` before creating new ones.
Search first; duplicates of an existing atom are a failure.

## 5. Interaction states (every interactive element)

Implement and check all of them, in both presets, light and dark:
- default, hover, active/pressed, focus-visible, disabled
- loading (skeleton in the final shape, not a lonely spinner)
- empty (says what to do next)
- error (inline, says how to fix)
- selected/checked where relevant

Buttons and inputs: label text fits on one line at desktop; labels above
inputs; no placeholder used as a label; one label per intent on a page
(do not mix "Get started" and "Try it" for the same action).

## 6. Layout discipline

- Hero fits the first viewport at 1280x800: headline max 2 lines, subtext max
  about 20 words, one primary CTA plus at most one secondary, max 4 text
  elements total. Trust logos, taglines and feature lists go below the hero.
- Eyebrow labels (small uppercase tracking text above a heading): at most one
  per three sections.
- A layout family (3 cards, split text/image, full-width quote) appears at
  most once per page. No more than 2 consecutive left/right zigzag sections.
- No "big headline left, small paragraph right" section header by default.
  Stack headline and body unless the right column carries a real visual.
- Navigation stays on one line at 1024px and is at most 72px tall.
- Every multi-column layout declares its below-768px layout in the same
  component.
- Bento or grid: exactly as many cells as content items. No empty filler cell.

## 7. Product-specific surfaces

These are features, not decoration. Make them accurate.

- **Terminal** (`organisms/interactive-terminal`): every command, flag, path
  and output line matches the real CLI in `packages/cli/src/main.rs` and the
  default `justui.config.yaml`. ASCII only.
- **Live component demos**: the direction is the real Flutter component
  (Flutter web embed). Do not create new React look-alikes. If you must touch
  an existing mock, its values come from the tokens that mirror
  `packages/core`.
- **Code blocks**: real API only (verify names in `packages/core`), real
  import paths that the CLI installs, copy button works, shiki theme from
  `src/lib/justui-shiki-theme.ts`.
- **Catalog cards**: same structure for every component, preview rendered
  from data in `components.generated.ts`, no hand-typed lists.
- **Studio**: what the preview shows must be what Flutter renders for the
  same seed, preset and color space. The export must reproduce the theme.
  Any accessibility claim shown in the UI is computed, not assumed.

## 8. Typography and color within the locked tokens

- Hierarchy by size and weight first. Color is for meaning (accent for the
  primary action and active state, semantic colors for status).
- Lime accent is a highlight, not a fill for large areas. Large areas use
  neutrals. Accent as text uses `--just-accent-text`.
- Mono (IBM Plex Mono) for code, commands, token names and tabular numbers.
- Headings: tight but readable line height; body 1.5-1.7; prose 60-80
  characters per line.

## 9. Copy voice

- EN: direct, concrete, technical. Say what it does and how, with a real
  example. No filler ("seamless", "unlock", "supercharge", "next-level",
  "effortless", "beautifully crafted").
- ID: same content, register "kamu", casual-professional, technical terms in
  English. Never a word-for-word translation that reads stiff.
- Numbers and claims must be true and checkable (component count from
  `components.generated.ts`, not typed by hand).

## 10. Pre-flight checklist (run before you say done)

Mechanical checks. Any "no" means fix it first.

1. Design read and dials written at the start of the task?
2. Only locked tokens for color, font, radius and shadow?
3. Looks intentional in default light, default dark, neobrutalism light,
   neobrutalism dark?
4. Works at 360, 768 and 1280 with no horizontal scroll?
5. All interaction states from section 5 present?
6. Focus visible on every interactive element; keyboard-only path works?
7. Contrast computed for text and UI boundaries (numbers in the summary)?
8. Reduced motion respected?
9. Nothing from the anti-slop list in `design.md`?
10. Eyebrows, layout families and hero rules from section 6 respected?
11. Code, commands and numbers shown to users verified against the source?
12. EN and ID both updated, ID in "kamu"?
13. ASCII only in `apps/docs` files?
14. Playwright visual snapshot added or updated, with the reason?
