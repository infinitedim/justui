# Phase 3: Docs, DX & Showcase

> **Status:** 🟡 In Progress
> **Sprint:** 11–16
> **Packages:** `packages/cli/`, `apps/docs/`, `apps/showcase/`
> **Dependency:** Phase 2 Milestone I–II complete
> **Priority:** High — developer adoption depends entirely on docs quality and DX.

---

## Overview

Phase 3 doesn't add new UI components — it makes everything built in Phase 1 & 2 **discoverable, understandable, and pleasant to use**. Three pillars:

```
Docs Site (Next.js)  +  CLI Polishing  +  Showcase App  →  Developer Adoption
```

---

## Milestone I — Docs Site ✅ (Core complete, content ongoing)

**Stack:**

| Layer           | Technology                                      |
| --------------- | ----------------------------------------------- |
| Framework       | Next.js (App Router)                            |
| Docs engine     | Fumadocs v16 (MDX)                              |
| Styling         | Tailwind CSS v4 (CSS-first, `@theme` directive) |
| Package manager | Bun                                             |
| Search          | Fumadocs built-in (Orama, client-side fuzzy)    |
| i18n            | Indonesian (default) + English                  |
| Fonts           | IBM Plex Sans + IBM Plex Mono                   |
| Accent color    | Lime (`#a3e635`)                                |
| Testing         | Vitest (unit) + Playwright (E2E)                |
| Deployment      | Vercel                                          |

**Site structure:**

```
docs.justui.dev/
├── /                          # Landing page
├── /[lang]/docs/
│   ├── introduction           # What is JustUI, philosophy
│   ├── installation           # CLI install + init
│   ├── quick-start            # 5-minute tutorial
│   ├── cli-setup              # Full CLI command reference
│   ├── theming                # Seed color, dark mode, ThemeExtension
│   ├── components/            # One page per component
│   │   ├── button
│   │   ├── input
│   │   └── ...
│   ├── tokens/                # Colors, spacing, typography, shadows
│   │   ├── colors
│   │   ├── spacing
│   │   ├── typography
│   │   └── shadows
│   └── guides/                # Copy-paste workflow, custom theme, accessibility, migration
```

**Status per section:**

| Section           | Indonesian | English |
| ----------------- | ---------- | ------- |
| Introduction      | ✅         | ✅      |
| Installation      | ✅         | ✅      |
| Quick start       | ✅         | ✅      |
| CLI setup         | ✅         | ✅      |
| Theming           | ✅         | ✅      |
| All 15 components | ✅         | ✅      |
| Token pages (4)   | ✅         | ✅      |
| Guides (5)        | ✅         | ✅      |

**Live preview widget:** Deferred. Documentation uses static code samples and screenshots for now. Flutter Web WASM embed is tracked for a future milestone.

---

## Milestone II — CLI Polishing 🟡 In Progress

Improvements to the CLI DX on top of the core command set from Phase 1.

### Completed

- Interactive multi-select with fuzzy search via `inquire` crate (`justui add` without args)
- Colored structured output — `logger::panel()`, `logger::summary()`
- Summary box after successful `add` showing installed components and paths
- Three-way conflict resolution (overwrite / skip / show diff) in `add` and `diff`
- SHA-256 integrity verification per file
- `--dry-run` and `--diff` flags for `add`
- `pubspec.yaml` automatic dependency injection

### In Progress / Planned

- `justui preset --apply <name>` — retroactively rewrite all installed components to a different preset (requires registry rework for per-preset component variants)
- `justui build` — validate and recompile `registry/index.json` from source
- `justui eject <component>` — unmanage a component (stop tracking updates for it)
- Registry structure rework: per-preset subfolders (`registry/components/button/default/`, `registry/components/button/neobrutalism/`)
- `index.json` schema update: `files` keyed by preset name, `supportedPresets` per component

### CI/CD (Completed)

GitHub Actions pipeline for CLI:

```
cli-check ──┬──► cli-cargo-audit
            ├──► cli-security-scan
            └──► cli-clippy ──► cli-build

cli-test     (independent)
cli-coverage (independent)
```

---

## Milestone III — Showcase App 🟡 In Progress

**Package:** `apps/showcase/`

Flutter web app that renders all JustUI components live. Used as visual reference and regression check.

- Framework: Flutter web (compiled to WASM for preview)
- Embedded in docs site: Deferred (see above)
- Standalone showcase app at `apps/showcase/`: basic structure in place, component coverage ongoing
