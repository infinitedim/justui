---
trigger: glob
globs: "apps/docs/**"
description: "Docs site rules: TypeScript, React and Next.js practice, structure, i18n, ASCII, demos, snippets, SEO, tests and tooling."
---

# Docs site (`apps/docs`)

Next.js 16 (App Router, typed routes), React 19, Fumadocs, Tailwind CSS 4,
Bun, Vitest, Playwright, zod 4. Deployed on Vercel. Each rule says why; when a
lint or `tsc` enforces it, trust the tool over your reading of the prose.

Legacy code that breaks a rule carries an
`// eslint-disable-next-line <rule> -- legacy: fix when touched` (or a
file-level `/* eslint-disable <rule> -- legacy ... */`). When you change that
code, fix it and remove the comment. Never add a new legacy disable.

## TypeScript

- `strict` plus `noUncheckedIndexedAccess`, `noFallthroughCasesInSwitch`,
  `verbatimModuleSyntax`. Handle `undefined` from index access; never
  silence it. Why: parsers and data maps are where runtime crashes start.
- `any` is banned (`no-explicit-any`). Use `unknown` plus zod or a type guard.
- No non-null `!` outside tests (`no-non-null-assertion`).
- No `as` type assertions (`consistent-type-assertions`, `never`). `as const`
  is fine. DOM narrowing that cannot be written as a guard needs
  `// eslint-disable-next-line ... -- <reason>`. Never assert to bypass typed
  routes; use the helpers in `src/lib/i18n.ts`. Prefer `satisfies`.
- Object shapes and props are `interface`; unions, mapped and utility types
  are `type` (`consistent-type-definitions`). Why: it matches the 85
  interfaces already in the code.
- No `enum`. Use an `as const` object and derive the union:
  `type Preset = (typeof presets)[number]`. Why: no runtime surprises,
  strippable syntax.
- Exported functions in `src/lib` declare return types
  (`explicit-module-boundary-types`). Why: an implementation change cannot
  silently change a shared contract.
- Type-only imports use `import type` (`consistent-type-imports`). Import
  order is enforced by `import/order`; let `lint:fix` sort it.
- Type-aware lint is on (`recommendedTypeChecked`) plus
  `no-floating-promises`, `no-misused-promises`,
  `switch-exhaustiveness-check`, `prefer-nullish-coalescing`. Mark
  intentional fire-and-forget with `void`.
- Expected failures (bad input, missing data, fetch failure) return a
  `Result<T, E>` (`{ ok: true, value } | { ok: false, error }`); add
  `src/lib/result.ts` with that type when the first one is needed. Throw
  only for bugs. Why: the caller is forced to handle the failure, and a bad
  URL never becomes a 500.

## Validation and env

- Everything crossing a trust boundary is parsed with zod (search params,
  `postMessage`, storage, fetched JSON, route handler input). Server code
  imports `zod`; client components import `zod/mini`. Why: same safety,
  smaller client bundle.
- Env vars are read only in `src/lib/env.ts`, parsed with zod and exported
  typed (`no-restricted-properties` bans `process.env` elsewhere; config files
  are exempt). Reference `NEXT_PUBLIC_*` vars there by literal name. Why: a
  missing or misspelled env fails the build, and Next only inlines literal
  `process.env.NEXT_PUBLIC_X` reads.

## Modules and naming

- Named exports only (`import/no-default-export`), except files Next or a
  tool requires as default: `page`, `layout`, `not-found`, `error`, `loading`,
  `opengraph-image`, `sitemap`, `robots`, `*.config.*`.
- Each component folder has an `index.ts` re-export. No higher-level barrels
  (`atoms/index.ts`, `components/index.ts`). Why: deep barrels pull whole
  trees into client bundles and hide import cycles.
- Imports across folders use `@/`. Relative imports only inside the same
  folder (`no-restricted-imports` bans `../`).
- Files kebab-case, components PascalCase, hooks `use-*.ts` exporting
  `useX`, functions and variables camelCase, `UPPER_SNAKE` only for true
  module-level constants.

## Structure

- Routes: `src/app/[lang]/...` (`page.tsx` landing,
  `docs/(fumadocs)/[[...slug]]` for the Fumadocs pages,
  `docs/components/page.tsx` for the components page), plus the root
  `not-found.tsx`, which serves every unknown URL as the 404. Content:
  `content/docs/{en,id}/`.
- UI: `src/components/{atoms,molecules,organisms,templates}`, `providers/`,
  `docs/` (components used inside MDX). Atomic design stays.
- Every atom, molecule and organism is a folder with exactly
  `<name>.tsx`, `<name>.types.ts` (props and public types), `index.ts`.
  Extra helpers are allowed beside them. Folders missing this shape are
  legacy; fix them when you change them.
- Classification: atom = one element, no child components from this repo;
  molecule = a few atoms with one job; organism = a section with its own
  state or data; template = page layout.
- Shared logic in `src/lib/`. Class merging with `cn` from `src/lib/cn.ts`.
- Component files stay under 200 lines (`max-lines`), functions under 80
  lines including JSX (`max-lines-per-function`). This overrides the general
  400/60 in `workflow.md` for `apps/docs`. Why: JSX makes 60 too tight and
  400 too loose for one component.
- Exports from `src/lib` have TSDoc (`jsdoc/require-jsdoc` on `src/lib`).
  Components get TSDoc only when the name does not explain the contract.

## React

- New components are Server Components. `'use client'` goes on the smallest
  leaf that needs state, effects, refs or browser APIs, with a one-line
  comment saying why. When you touch an existing client component, push the
  boundary down if you can. Why: 70% of the components ship JS today.
- React Compiler is on. Code must be compiler-safe: no mutation of props,
  state or values read during render, no `ref.current` during render, no
  conditional hooks. `react-hooks` v7 `recommended` enforces this, and
  `exhaustive-deps` is an error.
- Do not add `useMemo`/`useCallback`. Remove existing ones in files you
  change, unless the value is an effect dependency whose identity matters.
- Effects only sync with outside systems, never derive state.
- State: shareable state lives in the URL, local state in
  `useState`, Context only for state many distant components read.
- Variants: `cn` plus a typed map,
  `const sizes = { sm: '...', md: '...' } satisfies Record<Size, string>`.
  No `cva` or similar. Why: no dependency and the compiler checks every key.

## Next.js

- Pages render statically at build. External data (GitHub stars) uses
  `fetch` with an explicit `revalidate`. No dynamic rendering without
  approval. Why: fast, cheap, CDN cached.
- No Server Actions (`'use server'` is banned by lint). Why: the site has no
  mutations; actions are public endpoints.
- Route handlers (`install.sh`, `install.ps1`, `api/search`): export their
  route config explicitly, set `Content-Type` and `Cache-Control`, parse
  query params with zod and answer 400 on bad input, and have a Vitest test.
- Every `[lang]` route validates `lang` with `isLocale` and calls
  `notFound()` otherwise, and exports `generateStaticParams` from
  `localeStaticParams`.
- Every page exports `generateMetadata` with a unique title and description,
  `alternates.languages` for both locales, and Open Graph data.
- Locale-less paths redirect via `next.config.ts` `redirects()`. No
  `proxy.ts` (formerly middleware) without approval: it makes pages dynamic.
- CSP keeps `'unsafe-inline'` in `script-src` only for theme
  bootstrapping and the RSC payload. New code must not depend on it.
  See `security.md`.

## Styling

- Tailwind utilities mapped to JustUI tokens in `src/app/globals.css`.
  Colors, fonts, radii and shadows come from tokens (see `design.md`);
  arbitrary layout values (`w-[13.5rem]`) are allowed.
- Class order follows `prettier-plugin-tailwindcss`; CI runs
  `prettier --check`.
- Both presets in light and dark must work: `.preset-default` and
  `.theme-neobrutalism`. Preset classes go only on stage regions through
  `presetScopeClass()` from `src/lib/presets.ts`, never on `<html>` or
  `<body>`.
- Icons: `lucide-react` only. Brand marks are local SVG atoms.

## i18n

- Locales come from `src/lib/i18n.ts` (`en`, `id`). `cn` is an inactive
  placeholder.
- UI strings live in `src/lib/*-translations.ts` as one dictionary interface
  per module and `satisfies Record<Locale, Dict>`. Why: a missing ID key
  fails `tsc`, not a user.
- Every EN change ships its ID version in the same change (MDX in
  `content/docs/id/`, strings in the translation modules). No user-facing
  strings hardcoded in components.
- Indonesian register: "kamu", casual-professional, technical terms in
  English. When you edit an ID file still using "Anda", convert the whole file.
- No marketing filler in either language ("seamless", "unlock",
  "revolutionary", "next-level", "effortless").

## ASCII only

`test/ascii-purity.test.ts` fails on any byte above 127 in `src/`,
`content/` and `test/`. Use `-`/`--`, straight quotes, `...`, `x`. In JSX and
MDX use HTML entities (`&mdash;`, `&rarr;`); in TS strings `\u2014`. Key names
as text: `Cmd`, `Ctrl`, `Shift`.

## MDX and code snippets

- MDX may only use components registered in the single MDX component map
  (passed to `<MDXContent components>`). Register new ones there. Why: keeps
  per-page bundles under control.
- Every Dart snippet (MDX and any page that shows Dart code) must compile
  against the real API: check class, constructor and parameter names in
  `packages/core`, never invent parameters.
  Imports match what the CLI installs (default `justui.config.yaml` paths),
  never `package:just_ui_core` or `package:just_ui_tokens`.
- CLI commands shown to users must exist in `packages/cli/src/main.rs` with
  those exact flags.
- A Vitest check validates snippet names on every PR; a separate CI job runs
  `dart analyze` on the extracted snippets. Both must pass.

## Interactive demos

- Live parts are real Flutter components from the `apps/showcase` bridge
  (see `flutter.md`). `bun run flutter:build` builds it into
  `public/flutter/` (gitignored; Vercel and CI build it themselves). The
  bridge code lives only in `src/lib/flutter-bridge/` and
  `src/components/molecules/live-part/`; both are red zones.
- Contract for every live part:
  - The React part from `src/components/runner-kit/` renders first (SSR)
    and stays as the fallback for no JS and a failed or missing bundle.
    Browsers other than Blink with WasmGC (Firefox, Safari, iOS) never
    load Flutter.
  - The engine loads when a host nears the viewport, on idle. Views are
    added on enter and removed after they leave.
  - The host box is locked to the part's box (no layout shift). The swap
    is a 150ms opacity crossfade, instant under reduced motion.
  - Every Flutter view has one fixed size (320 x 344), centered in the
    host box and clipped to it: Flutter 3.47 rasterizes all views through
    one shared surface and cuts off a view larger than another
    (flutter/flutter#194401, not in stable yet). Scenes stay within
    280 x 328 and within their components-page stage
    (`apps/showcase/test/scenes/stage_heights_test.dart`).
  - No new globals and no `postMessage`: the loader and the Dart controller
    stay inside the bridge module. Every value sent to Dart is parsed with
    `zod/mini` first.
  - Page clones (page curl, preset swap) show the React fallback, and live
    hosts fall back while `data-theme-switching` is set.
- The runner-kit parts live in `src/components/runner-kit/`, one folder per
  part family. Their values follow `prd/02-design-spec.md` and the design
  handoff; preset differences come from CSS, not from props.
- Component facts come from `src/lib/components.generated.ts`; regenerate
  with `bun run generate:components`, check with `-- --check`.

## Tests

- Unit and component tests in `test/` (Vitest). Query by role and accessible
  name first; `data-testid` only as a last resort. Why: the test then also
  checks accessibility.
- No network in unit tests. Keep fetching separate from logic and test the
  logic as pure functions.
- `src/lib` has a minimum coverage threshold in `vitest.config.ts`. Do not
  lower it; add tests.
- Type contracts for `components.generated.ts` and the i18n helpers are
  checked with Vitest `expectTypeOf`.
- E2E in `e2e/` (Playwright, against `bun run start`). Main pages run
  `@axe-core/playwright` in all 4 preset/theme combinations, and dialogs,
  search and menus have keyboard tests (tab order, focus return, Escape).
- Visual snapshots: every new page or demo gets `toHaveScreenshot` for the 4
  combinations. Global `maxDiffPixelRatio: 0.01`, animations disabled, fonts
  from the bundle. Update a baseline only for an intended change and say so.
- Live parts: visual snapshots mask the Flutter hosts (Flutter goldens lock
  them), and a separate project blocks `/flutter/**` so the React fallbacks
  stay pixel-tested. axe always includes the hosts. Flutter e2e checks skip
  with a printed reason when the bundle is missing locally; CI requires it.
- Bug fix = failing test first (see `workflow.md`).

## Tooling and dependencies

- ESLint + Prettier. Do not switch tools.
- Bun version comes from `packageManager` in `package.json`; CI reads it.
- Version ranges stay caret with the lockfile committed. Renovate opens
  grouped weekly updates; do not bump versions by hand outside a task.
- No new dependency without approval (see `security.md`).
- The shared JS bundle has a budget (`bun run budget:check`, after
  `bun run build`), and the Flutter bundle has its own
  (`bun run flutter:budget`). If your change breaks a budget, report it
  instead of raising the budget.
- Images via `next/image`, fonts via `next/font`. No layout shift from theme
  or preset switching.
