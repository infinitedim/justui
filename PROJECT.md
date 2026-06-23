# Project: JustUI Documentation (Indonesian)

## Architecture
- **Documentation Portal (`apps/docs`)**: A Next.js application powered by Fumadocs, Tailwind CSS, and TypeScript. All documentation files are written in MDX.
- **Design Tokens (`packages/just_ui_tokens`)**: Holds all primitive constants for colors, spacing, typography, shadows, radius, animations, and the WCAG AA contrast logic.
- **Core Package (`packages/just_ui_core`)**: The main Flutter library containing the aspect-based rebuild theming system (`InheritedModel`), lazy-cached ThemeData, and 15 premium UI components.
- **CLI Package (`packages/just_ui_cli`)**: Command-line interface for component scaffolding and offline version tracking.

## Code Layout
- `apps/docs/content/docs/` — General MDX guides (`quick-start.mdx`, `theming.mdx`, `cli-setup.mdx`).
- `apps/docs/content/docs/tokens/` — Design primitives MDX guides (`colors.mdx`, `typography.mdx`, `spacing.mdx`, `shadows.mdx`).
- `apps/docs/content/docs/guides/` — Advanced concept MDX guides (`copy-paste-workflow.mdx`, `custom-theme.mdx`, `accessibility.mdx`, `responsive-design.mdx`, `migration.mdx`).
- `apps/docs/content/docs/components/` — UI Component MDX reference files (15 components).
- `packages/just_ui_tokens/` — Dart files for tokens and accessibility contrast check.
- `packages/just_ui_core/lib/src/components/` — Source Dart files of components to analyze.
- `packages/just_ui_cli/` — CLI source code defining commands and initialization scaffolding logic.

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | M1: Exploration & Code Analysis | Analyze component parameters, tokens, theme engine, CLI commands | None | DONE |
| 2 | M2: General Guides MDX | Create quick-start.mdx, theming.mdx, cli-setup.mdx | M1 | DONE |
| 3 | M3: Design Tokens MDX | Create colors.mdx, typography.mdx, spacing.mdx, shadows.mdx | M1 | DONE |
| 4 | M4: Advanced Guides MDX | Create copy-paste-workflow.mdx, custom-theme.mdx, accessibility.mdx, responsive-design.mdx, migration.mdx | M1 | DONE |
| 5 | M5: Component Docs Part 1 | Create MDX for Button, Input, Badge, Avatar, Card, Checkbox, Switch, Radio | M1 | DONE |
| 6 | M6: Component Docs Part 2 | Create MDX for Tabs, Breadcrumb, BottomNav, Sidebar, Skeleton, ScrollArea, Separator | M1 | DONE |
| 7 | M7: Validation & Docs Build | Run type-check and build commands inside apps/docs | M2, M3, M4, M5, M6 | DONE |

## Interface Contracts
- **MDX metadata**: Each MDX file must contain standard yaml frontmatter:
  ```yaml
  ---
  title: <Title>
  description: <Description>
  ---
  ```
- **Component reference format**:
  1. Deskripsi: Deskripsi fungsionalitas dan peran komponen.
  2. Usage: Contoh kode Dart (Basic & Advanced) menggunakan code blocks (` ```dart `).
  3. API Reference: Tabel parameter dengan kolom: Properti, Tipe, Default, Deskripsi.
  4. Theming & Accessibility: Detail preset visual dan kesesuaian WCAG AA.
