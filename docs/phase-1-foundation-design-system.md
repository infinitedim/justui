# Phase 1: Foundation & Design System

> **Status:** 🟢 Complete
> **Sprint:** 1–4
> **Packages:** `packages/tokens/`, `packages/core/` (theming)
> **Priority:** Critical — all subsequent phases depend on this foundation.

---

## Overview

Phase 1 establishes the absolute foundation of JustUI: a token system, a theming engine, and a CLI scaffold. Nothing in Phase 2 onwards is possible without these being solid and consistent.

Three milestones:

```
Milestone I: Token System  →  Milestone II: Theming Engine  →  Milestone III: CLI Scaffold
```

---

## Milestone I — Token System ✅

**Package:** `packages/tokens/`

Single source of truth for all visual primitives. All values are Dart `const` — compile-time safe, zero runtime cost.

### Color Tokens

| Category               | Keys                                                          | Description        |
| ---------------------- | ------------------------------------------------------------- | ------------------ |
| `JustColors.primary`   | `primary`, `primaryLight`, `primaryDark`                      | Brand primary      |
| `JustColors.secondary` | `secondary`, `secondaryLight`, `secondaryDark`                | Supporting color   |
| `JustColors.neutral`   | `neutral50`–`neutral950`                                      | 11-step grey scale |
| `JustColors.semantic`  | `success`, `warning`, `error`, `info`                         | Contextual states  |
| `JustColors.surface`   | `background`, `card`, `elevated`, `overlay`                   | Surface layers     |
| `JustColors.border`    | `borderDefault`, `borderFocus`, `borderError`                 | Border states      |
| `JustColors.text`      | `textPrimary`, `textSecondary`, `textDisabled`, `textInverse` | Text hierarchy     |

**Rules:**

- Every color has minimum 11 shades (50, 100, 200 … 900, 950) following Material 3 scale.
- Stored as `const Color(0xFF...)` for compile-time efficiency.
- Semantic colors reference the palette — no hardcoded hex in semantic layer.
- Opacity uses `Color.withValues(alpha:)` — never `withOpacity` (deprecated).

### Spacing Tokens

| Token             | Value  | Use Case               |
| ----------------- | ------ | ---------------------- |
| `JustSpacing.xxs` | `2.0`  | Micro gaps, icon-label |
| `JustSpacing.xs`  | `4.0`  | Compact padding        |
| `JustSpacing.sm`  | `8.0`  | Default inline spacing |
| `JustSpacing.md`  | `12.0` | Standard padding       |
| `JustSpacing.lg`  | `16.0` | Section padding        |
| `JustSpacing.xl`  | `24.0` | Card internal padding  |
| `JustSpacing.xxl` | `32.0` | Section gap            |

Spacing scales fluidly: 75% on mobile (≤640px viewport), 100% on desktop (≥1024px).

### Typography Tokens

Scale: `displayLg`, `displayMd`, `displaySm`, `headingLg`, `headingMd`, `headingSm`, `bodyLg`, `bodyMd`, `bodySm`, `labelLg`, `labelMd`, `labelSm`, `code`.

All sizes are fluid — scale 90% on mobile to 100% on desktop.

### Other Tokens

- **Shadows:** Dual-layer per elevation (key shadow + brand-tinted ambient shadow).
- **Border radius:** `none`, `xs`, `sm`, `md`, `lg`, `xl`, `full` — scales with viewport.
- **Motion:** Custom easing curves + duration scale (`fast` 150ms → `slow` 500ms).
- **Breakpoints:** `xs` 320px, `sm` 640px, `md` 768px, `lg` 1024px, `xl` 1280px.

---

## Milestone II — Theming Engine ✅

**Package:** `packages/core/`

### Seed Generator & Dynamic Theming

Takes a single brand hex color and generates a full accessible theme:

- **HSL-based scale** — derives primary, secondary, neutral from one seed.
- **WCAG AA enforcement** — automatically adjusts lightness at runtime to meet:
  - ≥4.5:1 contrast for `success`, `error`, `info`
  - ≥3.0:1 contrast for `warning` and focused borders
- **Dark mode** — brand-tinted surfaces: background L=3%, card L=7%, elevated L=12%, overlay L=2%. Saturations clamped to prevent oversaturation.

### Lazy-Cached ThemeData

`JustThemeData.toThemeData()` compiles a Flutter `ThemeData` once and caches the instance. Subsequent calls return the cached value — no repeated computation on rebuilds.

### Aspect-Based Rebuilds (InheritedModel)

`JustThemeProvider` uses `InheritedModel` with three aspects:

| Aspect       | Extension             | Rebuilds when            |
| ------------ | --------------------- | ------------------------ |
| `colors`     | `context.justColors`  | Color tokens change      |
| `spacing`    | `context.justSpacing` | Spacing tokens change    |
| `typography` | `context.justTypo`    | Typography tokens change |

Non-registering read for callbacks: `context.readTheme()`.

### ThemeExtension per Component

Each component registers a `ThemeExtension` (e.g. `JustButtonTheme`) on Flutter's `ThemeData`. This requires a `Theme` widget at the widget tree root — automatically satisfied by `MaterialApp`. For `CupertinoApp`/`WidgetsApp`, wrap manually.

---

## Milestone III — CLI Scaffold ✅

**Package:** `packages/cli/` (Rust)

Initial CLI scaffold implemented `init`, `add`, `list`, `diff`, `update`, `create`, `view`, `search`, `info` commands. See [CLI README](../packages/cli/README.md) for full command reference.

**Key implementation decisions:**

- Written in Rust for performance and single-binary distribution.
- Component target directory driven by explicit `"internal"` field in `index.json` (not heuristic dependency counting).
- Import paths rewritten post-copy via `import_rewriter.rs` to match target project structure.
- SHA-256 checksums per file for integrity verification and local-modification detection.
