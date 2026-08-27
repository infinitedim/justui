# Contributing to JustUI

Thanks for wanting to contribute! This document covers everything you need to know before opening a PR — architecture, dev setup, coding rules, and how to add components to the registry.

Looking for a place to start? Check out open issues tagged with [`good first issue`](https://github.com/infinitedim/justui/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) or [`help wanted`](https://github.com/infinitedim/justui/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22).

---

## Table of Contents

1. [Philosophy](#1-philosophy)
2. [Monorepo Structure](#2-monorepo-structure)
3. [Development Setup](#3-development-setup)
4. [Coding Rules](#4-coding-rules)
5. [Adding a Component to the Registry](#5-adding-a-component-to-the-registry)
6. [Working on the CLI](#6-working-on-the-cli)
7. [Pull Request Guidelines](#7-pull-request-guidelines)

---

## 1. Philosophy

JustUI is a **copy-paste component library**, not a traditional Flutter package. The key implications:

- Components must be **fully self-contained** — no external pub.dev dependencies (unless absolutely necessary, and declared in `pubDependencies` in `index.json`).
- Code must be **readable and modifiable** by developers who copy it into their project. Complexity should be justified.
- Every token value, every style, every spacing unit must come from `packages/tokens/` — **no hardcoded values**.
- Performance is non-negotiable: `const` constructors everywhere possible, `ValueNotifier` over `setState`, `RepaintBoundary` around all animated components.

---

## 2. Monorepo Structure

```
justui/
├── packages/
│   ├── tokens/          # Design system primitives — colors, spacing, typography, shadows
│   ├── core/            # Theming engine, InheritedModel, lazy ThemeData cache
│   └── cli/             # Rust CLI binary
├── registry/
│   ├── components/      # Raw component source files (what the CLI copies)
│   └── index.json       # Registry manifest with versions, deps, and checksums
├── apps/
│   ├── docs/            # Next.js + Fumadocs documentation site
│   └── showcase/        # Flutter showcase app
└── docs/                # Phase specs and architecture decision records
```

**Package name mapping:**

| Folder             | Dart package name      |
| ------------------ | ---------------------- |
| `packages/tokens/` | `just_ui_tokens`       |
| `packages/core/`   | `just_ui_core`         |
| `packages/cli/`    | `justui` (Rust binary) |

---

## 3. Development Setup

### Prerequisites

- Flutter SDK (stable channel)
- Melos (`dart pub global activate melos`)
- Rust toolchain (`rustup` + `cargo`) — only needed for CLI work
- Bun — only needed for docs site work

### Bootstrap Monorepo

```bash
# Clone the repo
git clone https://github.com/infinitedim/justui.git
cd justui

# Bootstrap all Dart/Flutter packages
melos bootstrap
```

> If you hit Dart telemetry path errors, prefix with `export HOME=~/development/justui/.home`

### Static Analysis

```bash
melos exec --flutter -- "flutter analyze ."
melos exec --no-flutter -- "dart analyze ."
```

### Running Tests

```bash
# Flutter packages
melos exec --flutter --dir-exists="test" -- "flutter test"

# Dart-only packages
melos exec --no-flutter --dir-exists="test" -- "dart test"

# CLI (Rust)
cd packages/cli
cargo test
```

### CLI Development

```bash
cd packages/cli

# Build and install locally
cargo install --path .

# Run tests
cargo test

# Lint
cargo clippy --all-targets -- -D warnings
```

---

## 4. Coding Rules

These rules are enforced in CI and in code review. PRs that violate them will not be merged.

### A. No Material imports without `show`

Never import `flutter/material.dart` without a restrictive `show` clause:

```dart
// ✅ Correct
import 'package:flutter/material.dart' show Theme, ThemeData, ThemeExtension;

// ❌ Wrong — imports the entire Material library
import 'package:flutter/material.dart';
```

### B. Dot shorthand everywhere

Use Dart dot shorthand for constructors wherever the type is statically inferred:

```dart
// ✅ Correct
borderRadius: .all(radius.lg)
padding: .symmetric(horizontal: spacing.md)
fontWeight: .w600

// ❌ Wrong
borderRadius: BorderRadius.all(radius.lg)
padding: EdgeInsets.symmetric(horizontal: spacing.md)
fontWeight: FontWeight.w600
```

### C. `Color.withValues(alpha:)` not `withOpacity`

```dart
// ✅ Correct
color.withValues(alpha: 0.5)

// ❌ Wrong — deprecated API
color.withOpacity(0.5)
```

### D. `ValueNotifier` over `setState`

Use `ValueNotifier` + `ValueListenableBuilder` for local widget state. Avoid `setState` in components.

### E. `const` constructors everywhere

Every component must have a `const` constructor. Every style class must have a `const` constructor.

### F. `RepaintBoundary` for animated components

Wrap every animated component in a `RepaintBoundary` to isolate repaints:

```dart
return RepaintBoundary(
  child: AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => ...,
  ),
);
```

### G. Aspect-based theme consumption

Always use specific aspect extensions in `build()`. Never use the generic `context.justTheme` in small components.

```dart
// ✅ Correct — only rebuilds when colors change
final colors = context.justColors;

// ❌ Avoid in small widgets — rebuilds on any theme change
final theme = context.justTheme;
```

### H. Border widths (neobrutalism preset)

- Component containers: `2.5` logical pixels
- Sidebar active-item accent border only: `3.0` logical pixels

---

## 5. Adding a Component to the Registry

### Step 1 — Build the component in `packages/core/`

Place your component files under:

```
packages/core/lib/src/components/<component_name>/
├── just_<name>.dart           # Widget implementation
├── just_<name>_style.dart     # Per-instance style overrides
├── just_<name>_variants.dart  # Size/variant enums
└── just_<name>_theme.dart     # ThemeExtension for global overrides
```

Every component that depends on shared internal utilities (`_shared_pressable`, `_shared_focus_indicator`, etc.) must import them from their respective paths — the CLI handles path rewriting on install.

### Step 2 — Copy files to `registry/components/<name>/`

Registry files are synced from `packages/core/` source using the checksum tool:

```bash
dart run tools/generate_checksums.dart
```

This copies files, computes SHA-256 checksums, and updates `registry/index.json` automatically. Do **not** manually edit files under `registry/components/` — always edit the source in `packages/core/` first.

To preview without writing:

```bash
dart run tools/generate_checksums.dart --dry-run
```

### Step 3 — Register in `registry/index.json`

The checksum tool updates `index.json` automatically, but you must ensure the component entry exists with the correct metadata before running the tool. Add your component entry:

```json
{
  "name": "my-component",
  "version": "0.1.0",
  "description": "Short description of what the component does",
  "category": "primitives",
  "hidden": false,
  "internal": false,
  "registryDependencies": ["_shared_pressable"],
  "pubDependencies": {},
  "files": []
}
```

**Field reference:**

| Field                  | Description                                                                    |
| ---------------------- | ------------------------------------------------------------------------------ |
| `name`                 | Kebab-case component name (used in `justui add <name>`)                        |
| `version`              | Semver string, start at `0.1.0`                                                |
| `category`             | One of: `primitives`, `layout`, `navigation`, `tokens`, `core`                 |
| `hidden`               | `true` hides from `justui list` (use for internal/WIP components)              |
| `internal`             | `true` for `_shared_*` utilities — files go to `shared/` not a named subfolder |
| `registryDependencies` | Other JustUI components this one depends on                                    |
| `pubDependencies`      | External pub.dev packages required (will be auto-added to `pubspec.yaml`)      |
| `files`                | Populated automatically by the checksum tool                                   |

### Step 4 — Export from `packages/core/`

Add your component to the barrel export at `packages/core/lib/just_ui_core.dart`.

### Step 5 — Write tests

Add widget tests under `packages/core/test/components/just_<name>_test.dart`. Tests must include at minimum: renders without error, responds to theme changes, and handles all variants.

### Step 6 — Add Widgetbook Use-Case

To preview and test your component interactively during development, add a Widgetbook use-case under `apps/showcase/lib/usecases/`:
- Create `just_<name>_usecase.dart`
- Register both Light and Dark mode states, plus all visual variants (`default_`, `neobrutalism`).
- Ensure knobs are provided for key interactive props (labels, sizes, state toggles).

---

## 6. Working on the CLI

The CLI lives in `packages/cli/` and is written in Rust. Key files:

```
packages/cli/src/
├── main.rs              # Clap command definitions
├── registry.rs          # RegistryIndex, RegistryComponent structs + fetch logic
├── config.rs            # JustUIConfig (reads justui.config.yaml)
├── commands/
│   ├── add.rs           # justui add
│   ├── init.rs          # justui init
│   ├── diff.rs          # justui diff
│   ├── update.rs        # justui update
│   ├── list.rs          # justui list
│   ├── search.rs        # justui search
│   ├── view.rs          # justui view
│   ├── info.rs          # justui info
│   └── create.rs        # justui create
└── utils/
    ├── logger.rs         # Colored terminal output
    ├── prompt.rs         # Interactive prompts (inquire-based)
    ├── import_rewriter.rs # Rewrites import paths after file copy
    ├── diff_formatter.rs  # Unified diff renderer
    └── pubspec_editor.rs  # pubspec.yaml dependency injection
```

**Key architectural rules for CLI:**

- Component routing to output folder is controlled by `component.internal` field (`true` → `shared/`, `false` → `{components_dir}/{name}/`).
- `compute_shared_components()` has been removed — never re-add heuristic-based shared detection.
- Import paths are rewritten by `import_rewriter::rewrite()` after file copy — always verify rewrite logic when adding new file categories.

---

## 7. Pull Request Guidelines

- **One concern per PR.** Don't mix new components with CLI changes.
- **All CI checks must pass** before requesting review — format, analyze, test, clippy.
- **Describe what and why** in the PR description. Link to a relevant issue if one exists.
- **Screenshots or terminal output** for visual or CLI changes.
- For new components, include a usage example in the PR description.

If you're unsure whether a change fits the project direction, open an issue first to discuss before spending time on implementation.
