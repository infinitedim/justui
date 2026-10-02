---
trigger: model_decision
description: "Apply to any UI, visual, layout, motion, copy or accessibility work, in the docs site or in Flutter components."
---

# Design

Load the `justui-design` skill for the process (design read, checklists).
This file holds the constraints.

## Two different design surfaces

1. **The docs site** (`apps/docs`) has a locked visual identity (below).
2. **The component library** (`packages/core`, `packages/tokens`) ships
   defaults to users (for example `JustTypo.fontFamily = 'Inter'`,
   seed-generated color scales). Changing a library default is a public API
   change: ask first.

Do not copy docs-site identity choices into library defaults, or the reverse.

## Docs site identity (locked)

- Type: IBM Plex Sans (UI and text), IBM Plex Mono (code, terminal, numbers in
  tables). Loaded weights: Sans 400/500/600/700, Mono 400/500. No other fonts.
- Accent: lime. `--just-accent` #a3e635 with `-light`, `-dark`, `-deep`,
  `-muted`. When accent is used as text on light backgrounds use
  `--just-accent-text` (#4d7c0f), never raw lime.
- Neutrals: the zinc/gray set in `globals.css` (`--just-background`,
  `--just-text-primary/secondary/muted`, `--just-border`, `--just-card-bg`,
  `--just-elevated-bg`, `--just-fill`).
- Semantic: success, warning, error, info, destructive tokens only.
- Radius: `--just-radius-xs..2xl` (2, 4, 6, 12, 16, 24).
- Shadows: flat in the default preset; solid offset shadows in neobrutalism.
- Spacing: 4px grid.

You may not add a new color, font, radius or shadow style. If a design needs
one, stop and propose it (value, token name, where it is used, why existing
tokens do not work). Raw numbers for layout and sizing are allowed. Raw color
values are allowed only inside token definitions (`globals.css`,
`color-resolver.ts`, `justui-shiki-theme.ts`).

## Presets

Every UI must look intentional in 4 combinations: default light, default
dark, neobrutalism light, neobrutalism dark.
Neobrutalism on the web mirrors Flutter: border width from
`--just-border-width`, borders in the primary text color, solid shadows, and a
press transform equal to the shadow offset.

## Anti-slop (never do these)

- Purple, violet or blue gradients; gradient text; glow and neon effects.
- Glassmorphism or backdrop blur used as decoration.
- Emoji as icons or bullets.
- Centered hero + floating pill badge + two buttons as the default layout.
- Rows of 3 equal cards with icon, title and one line of text.
- Cards inside cards. Every element in a rounded box with a shadow.
- The same radius and the same spacing everywhere with no rhythm.
- Low-contrast gray text on gray to look "subtle".
- Fake product shots made of gray div rectangles.
- Lorem ipsum or placeholder names in shipped UI.
- Filler copy: "seamless", "unlock", "supercharge", "next-level",
  "effortless", "beautifully crafted".

Intentional exceptions: the interactive terminal and the live component
demos are product features, not decoration. Keep them; make them accurate.

## Layout and type

- Default to left-aligned content. Center only short, single-purpose blocks.
- Clear hierarchy through size and weight, not through more colors.
- At most 3 font sizes and 2 weights in one component; a page may use more.
- Line length for prose 60-80 characters.
- Use space to group; use borders only where grouping by space is not enough.
- Match the heading and button casing already used in the same section.

## Motion

- Landing page: expressive motion is allowed (entrance, stagger, interactive
  hero), using transform and opacity only, up to about 600ms.
- Docs, catalog and Studio: functional motion only, 200ms or less.
- Always honor `prefers-reduced-motion` (web) and `animations.resolve(context)`
  (Flutter). Reduced motion removes movement, not feedback.
- No scroll-jacking, no parallax on text, no animation that delays reading.

## Accessibility (WCAG 2.2 AA)

- Text contrast 4.5:1, large text and UI boundaries 3:1. Compute ratios with
  the tokens helpers or a script; never state a number you did not compute.
- Full keyboard use, visible focus on every interactive element, logical tab
  order, no keyboard traps.
- Follow the WAI-ARIA Authoring Practices pattern for tabs, dialogs, menus,
  comboboxes, sliders and toggles. Native elements first.
- Target size: at least 24x24 CSS px everywhere; 44x44 for primary actions on
  touch layouts.
- Layout works from 360px wide with no horizontal page scroll; check 360,
  768 and 1280.
- Information never depends on color alone.

## Visual verification

- New page, new section or new component: open it with the Playwright MCP
  tools, capture the 4
  preset/theme combinations at 360, 768 and 1280 widths, review them against
  this file and the `justui-design` checklist, fix what fails, and say what
  you checked in the summary. Also add the Playwright visual snapshot test
  (see `docs-web.md`).
- Small changes (spacing, a color token swap, copy): confirm the change uses
  tokens and does not break the other preset. No full capture needed.
- Flutter components: launch `apps/preview` (Widgetbook) with the dart MCP
  tools and check both presets in light and dark, with no runtime errors.
