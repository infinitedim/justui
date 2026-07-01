# Project: JustUI Showcase Marquee & Homepage Layout Update

## Architecture
- **Showcase App (Flutter)**: Running in Flutter Web (compiling to WASM/JS). We will replace the current `ShowcaseGrid` with a `ShowcaseMarquee` that handles infinite smooth scrolling using an `AnimationController`.
- **Docs App (Next.js)**: Integrates the Flutter Web app as an `iframe` via `ShowcaseFrame`. The height will be fixed to 180px, and the homepage (`page.tsx`) layout will center the hero text and place the marquee full-width below it.

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | M1: Flutter Showcase Marquee & Style | Rebuild `widgets/showcase_marquee.dart` with infinite scrolling and apply default/neobrutalism dynamic styles to 5 component groups. | None | PLANNED |
| 2 | M2: Fixed Height & Height Reporter | Update `height_reporter.dart` and `main.dart` to use fixed height of 180px. | M1 | PLANNED |
| 3 | M3: Next.js docs showcase & homepage | Update Next.js component `showcase-frame.tsx` and homepage `page.tsx` layout and styling. | M2 | PLANNED |
| 4 | M4: Build, Run, & Audit | Verify build succeeds for both showcase and docs, check styling and alignment, and run forensic audit. | M3 | PLANNED |

## Interface Contracts
- **Flutter -> Next.js Communication**: `postMessage` protocol. Since we are using a fixed height of 180px, the height reporter no longer sends dynamic height updates. The frame no longer listens to height updates. However, dark/light theme switching must still send theme changes via `postMessage` (`{ type: 'justui-theme', preset: 'neobrutalism', mode: 'dark'/'light' }`).
- **ShowcaseMarquee height**: Constrained strictly to 180px.

## Code Layout
- `apps/showcase/lib/widgets/showcase_marquee.dart` — Newly created marquee widget.
- `apps/showcase/lib/widgets/showcase_grid.dart` — Kept or superseded (or references updated in `main.dart`).
- `apps/showcase/lib/height_reporter.dart` — Modified to report/act under fixed 180px.
- `apps/showcase/lib/main.dart` — Modified to display the `ShowcaseMarquee` and set its height.
- `apps/docs/src/components/showcase-frame.tsx` — Simplified to fixed 180px, removed dynamic height listener.
- `apps/docs/src/app/[lang]/page.tsx` — Modified for centered hero text and full-width iframe.
