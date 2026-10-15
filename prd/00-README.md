# JustUI Ink and Paper Rebrand: PRD Set

Status: Draft v3 (2026-10-15)
Changes in v2: Plus Jakarta Sans everywhere (P2, P6, P8); non-docs Next.js pages deprecated (P7)
Changes in v3 (2026-10-15): fixes from an external review (P7 criteria aligned with the deprecated scope, font files and test loading, parts mapping, preset token replacements, focus ring width, guard targets)
Owner: Dimas (GitHub: infinitedim)
Repository: https://github.com/infinitedim/justui
Baseline commit: `development` at `d80b55e` (2026-10-13)

This folder holds the product requirements for the JustUI color rebrand called
"Ink and Paper". The rebrand replaces the lime docs identity and the blue
Flutter identity with one luxurious monochrome palette that passes every WCAG
2.2 color criterion, including AAA.

The work is split into ten phases. Each phase has its own PRD so it can be
planned, built, reviewed and shipped on its own.

## 1. How to read this folder

Read the files in this order:

1. `01-product-overview.md` for the why, the goals, the scope and the success
   metrics.
2. `02-design-spec.md` for the palette, the roles, the contrast numbers and the
   usage rules. Every phase PRD points to this file instead of repeating it.
3. `03-baseline-audit.md` for the verified current state of the repository.
4. The phase PRDs (`10-` to `19-`) in order.
5. `90-pending-decisions.md` for the questions the owner still has to answer.
   Every phase PRD names the default it assumes until a decision is made.
6. `91-out-of-scope.md` for the work that was found but deliberately left out.

## 2. File index

| File                                     | Content                                           |
| ---------------------------------------- | ------------------------------------------------- |
| 00-README.md                             | This index                                        |
| 01-product-overview.md                   | Problem, goals, non-goals, metrics, constraints   |
| 02-design-spec.md                        | Palette, roles, contrast, usage rules             |
| 03-baseline-audit.md                     | Verified current state with file and line refs    |
| 10-phase-0-baseline-and-safety-nets.md   | Pre-existing defects and guard tests              |
| 11-phase-1-token-source-and-generator.md | Single token source and generator                 |
| 12-phase-2-tokens-api.md                 | JustColorScheme roles and deprecations            |
| 13-phase-3-core-theme-engine.md          | Preset tokens, JustThemeData, Material bridge     |
| 14-phase-4-component-migration.md        | All 30 component families                         |
| 15-phase-5-registry-showcase-preview.md  | Registry sync, showcase, Widgetbook               |
| 16-phase-6-docs-foundation.md            | Docs tokens, Fumadocs, focus, links, code blocks  |
| 17-phase-7-docs-ui-and-content.md        | Docs UI sweep and MDX (non-docs pages deprecated) |
| 18-phase-8-cli.md                        | CLI init, tint option, doctor check               |
| 19-phase-9-verification-and-release.md   | Release gate, changelog, migration guide          |
| 90-pending-decisions.md                  | Open questions with the assumed defaults          |
| 91-out-of-scope.md                       | Follow-up work outside this rebrand               |

## 3. Phase map

```
P0 Baseline and safety nets
 |
P1 Token source and generator
 |
P2 Tokens API ------------------------------+
 |                                          |
P3 Core theme engine                        |
 |                                          |
P4 Component migration                      |
 |                                          |
P5 Registry, showcase, preview              |
                                            |
P6 Docs foundation (needs P0, P1) ----------+
 |
P7 Docs UI and content (needs P3 for Dart snippets, P6)
 |
P8 CLI (needs P3)
 |
P9 Verification and release (needs everything)
```

P6 can start as soon as P1 is merged, in parallel with P2 to P5. P8 can start
as soon as P3 is merged. P9 is the only release gate: no intermediate phase is
released to users on its own.

## 4. Conventions used in every PRD

- Requirement IDs look like `FR-3.4` (functional requirement 4 of phase 3) and
  `NFR-3.2` (non-functional requirement 2 of phase 3).
- Acceptance criteria look like `AC-3.4` and are written so that a test or a
  command can prove them.
- Decision references look like `DP-2` and point to `90-pending-decisions.md`.
- "Role" means a semantic color name such as `textPrimary`. "Primitive" means a
  raw brand color such as `n174`. Both are defined in `02-design-spec.md`.
- Paths are relative to the repository root.
- Line numbers refer to the baseline commit and will drift. Implementers must
  re-locate code by symbol, not by line.
- "Owner machine" means a check that needs the full Flutter SDK, Playwright or
  a browser and cannot run in an offline sandbox.

## 5. Global rules for whoever implements these PRDs

1. Follow `AGENTS.md` and the area rules in `.agents/rules/`. Where a PRD
   conflicts with a rule file, the rule file wins until the owner changes it.
   P0 lists the rule changes this rebrand needs.
2. Keep Dart dot shorthand (`.all(...)`, `.symmetric(...)`) and the primary
   constructor syntax exactly as the surrounding code writes them.
3. Add no pub, npm or cargo dependency.
4. Write plain ASCII in every file. No em dashes, curly quotes or emoji.
5. Never hand-edit generated files (registry, showcase, `*.generated.*`).
6. Never push, tag or open pull requests unless the owner asks.
