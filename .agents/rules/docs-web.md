---
trigger: glob
globs: "apps/docs/**"
description: "Next.js docs site rules: structure, React and TypeScript, i18n, ASCII, demos, snippets, SEO and tests."
---

# Docs site (`apps/docs`)

Next.js 16 (App Router, typed routes), React 19, Fumadocs, Tailwind CSS 4,
Bun, Vitest, Playwright. Deployed on Vercel.

## Structure

- Routes: `src/app/[lang]/...` (`page.tsx`, `docs/[[...slug]]`, `components`,
  `studio`). Content: `content/docs/{en,id}/`.
- UI code: `src/components/{atoms,molecules,organisms,templates}`,
  `providers/`, `docs/` (components used inside MDX).
- Every atom, molecule and organism is a folder with exactly:
  `<name>.tsx`, `<name>.types.ts` (props and public types), `index.ts`
  (re-exports). Extra files (helpers, generators, tests data) are allowed
  beside them. Folders that miss this shape are legacy; fix them when you
  change them.
- Classification: atom = one element, no children components from this repo;
  molecule = a few atoms with one job; organism = a section with its own
  state or data; template = page layout.
- Shared logic goes in `src/lib/`. Use `cn` from `src/lib/cn.ts` for class
  merging.

## React

- New components are Server Components by default. Add `'use client'` only to
  the smallest leaf that needs state, effects, refs or browser APIs, and add a
  one-line comment saying why. Existing client components stay as they are
  unless the task is about them.
- The project targets React Compiler. Write compiler-safe code: no mutation of
  props, state or values read during render; no reading `ref.current` during
  render; no conditional hooks. Do not add `useMemo`/`useCallback` for
  performance unless you measured a problem.
- Effects only for syncing with outside systems, never to derive state.

## TypeScript

- `strict` is on. `any` is forbidden (lint error). Use `unknown` plus a zod
  schema or a type guard.
- Index access may be `undefined` (`noUncheckedIndexedAccess`). Handle it;
  do not silence it with `!`.
- No `as` casts to bypass typed routes or types. Build routes with the helpers
  in `src/lib/i18n.ts`.
- Exported functions and components get TSDoc when the name does not explain
  the contract.

## Styling

- Tailwind utilities mapped to JustUI tokens in `src/app/globals.css`
  (`bg-background`, `text-foreground`, `border-border`, `bg-accent`,
  `rounded-md`, `shadow-sm`, ...). Colors, fonts, radii and shadows must come
  from these tokens (see `design.md`). Arbitrary layout values
  (`w-[13.5rem]`) are allowed.
- Both presets must work: `.preset-default` and `.theme-neobrutalism`, each in
  light and dark. Never style only one.
- Icons: `lucide-react` only. Brand marks (GitHub) are local SVG components.
  Do not import `react-icons` or any other icon set.

## i18n

- Locales come from `src/lib/i18n.ts` (`en`, `id`). Never hardcode a locale
  list. `cn` is an inactive placeholder; do not add content there.
- Every user-facing change in EN ships with the ID version in the same
  change: MDX in `content/docs/id/`, UI strings in `src/lib/*-translations.ts`.
- No user-facing strings hardcoded in components; put them in the
  translation modules.
- Indonesian register: use "kamu", casual-professional. Keep technical terms
  in English (widget, preset, token, build, commit). When you edit an ID file
  that still uses "Anda", convert the whole file so one page never mixes both.
- No marketing filler in either language ("seamless", "unlock",
  "revolutionary", "next-level", "effortless").

## ASCII only

`test/ascii-purity.test.ts` fails on any byte above 127 in `src/`,
`content/` and `test/`. Use:
- `-` or `--` instead of dashes, straight quotes `'` and `"`, `...` instead of
  an ellipsis character, `x` instead of a multiplication sign.
- In JSX and MDX text: HTML entities (`&mdash;`, `&rarr;`, `&times;`) when the
  typographic character matters. In TS strings: `\u2014` escapes.
- Key names as text: `Cmd`, `Ctrl`, `Shift`, not symbols.

## Code snippets in docs

Every Dart snippet (MDX, catalog cards, Studio export, `code-generators.ts`)
must compile against the real API:
- Check every class, constructor and parameter name in `packages/core` before
  writing it. Never invent parameters.
- Imports must match what the CLI installs into a user project (paths from
  the default `justui.config.yaml`), never `package:just_ui_core` or
  `package:just_ui_tokens`, which users do not have.
- CLI commands shown to users must exist in `packages/cli/src/main.rs` with
  those exact flags.

## Interactive demos

- Direction: component demos render the real Flutter components (Flutter web
  embed) instead of React look-alikes. Building the embed is red-zone work:
  plan first, because it changes CSP (`wasm-unsafe-eval`, frames) and bundle
  size.
- Do not add new React mocks to `src/components/organisms/simulators/`.
  Existing mocks are legacy until replaced; when you must touch one, keep its
  values sourced from the tokens that mirror `packages/core`.
- Messages between the page and the stage use `src/lib/stage-bridge.ts`.
  Every incoming message is parsed with the zod schema and checked for origin.
  Add new event types to the schema; never read `event.data` unparsed.
- Studio color math (`src/lib/theme/color-resolver.ts`) must match
  `packages/tokens`. When you change one, add a test that compares outputs for
  the same seed.

## Data

- Component facts come from `src/lib/components.generated.ts`. Regenerate
  with `bun run generate:components`; check drift with
  `bun run generate:components -- --check`.

## Routing and SEO

- Every `[lang]` route validates `lang` with `isLocale` and calls `notFound()`
  otherwise, and exports `generateStaticParams` from `localeStaticParams`.
- Every page exports `generateMetadata` with a unique title and description,
  `alternates.languages` for both locales, and Open Graph data.
- Locale-less paths redirect via `next.config.ts` `redirects()`. There is no
  middleware; do not add one without approval.

## Tests

- Unit and component tests: Vitest in `test/` (`bun run test`).
- E2E: Playwright in `e2e/` (`bun run test:e2e`, runs against `bun run start`).
- Visual snapshots: every new page or component demo gets a Playwright
  `toHaveScreenshot` test for default and neobrutalism, light and dark.
  Baselines live next to the spec and are committed. Update a baseline only
  when the visual change is intended, and say so in the summary.
- Bug fix = failing test first (see `workflow.md`).

## Performance

- No new client-side dependency without approval (see `security.md`).
- Images via `next/image`, fonts via `next/font`. No layout shift from theme
  or preset switching (both are applied before hydration).
