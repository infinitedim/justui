<h1 align="center">JustUI</h1>

<p align="center">
  A high-performance, copy-paste Flutter UI component library — inspired by <a href="https://ui.shadcn.com">shadcn/ui</a>.
</p>

<p align="center">
  <a href="https://github.com/infinitedim/justui/actions/workflows/ci.yaml"><img src="https://github.com/infinitedim/justui/actions/workflows/ci.yaml/badge.svg" alt="CI" /></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License" /></a>
  <a href="https://docs.justui.dev"><img src="https://img.shields.io/badge/docs-justui.dev-lime" alt="Docs" /></a>
</p>

---

## What is JustUI?

JustUI is **not** a Flutter package you add to `pubspec.yaml`. Instead, you use the CLI to copy component source code directly into your project. You own the code — no black boxes, no version lock-in, no bloated transitive dependencies.

```bash
justui add button
```

That's it. The component lives in your codebase.

---

## Features

- **Zero external dependencies** — Built entirely on native Flutter widgets and layout APIs.
- **Copy-paste model** — Inspired by shadcn/ui. Copy components once, own them forever.
- **Aspect-based rebuilds** — Uses `InheritedModel` so only the widgets that depend on a changed theme aspect rebuild. Not the whole tree.
- **Dynamic theming** — Seed any brand color and get a full accessible light/dark theme automatically, with WCAG AA contrast enforcement baked in.
- **Fluid spacing & radii** — Scales responsively from mobile (75%) to desktop (100%).
- **Ambient tinted shadows** — Dual-layer shadow system: crisp key shadow + brand-tinted ambient shadow.
- **Rust-powered CLI** — Fast, reliable toolchain with interactive prompts, SHA-256 integrity checks, conflict resolution, and dry-run support.

---

## Monorepo Structure

```
justui/
├── packages/
│   ├── tokens/          # Design system primitives (colors, spacing, typography, shadows)
│   ├── core/            # Theming engine, InheritedModel, seed generator
│   └── cli/             # Rust CLI (justui binary)
├── registry/            # Component source files + index.json
├── apps/
│   ├── docs/            # Next.js + Fumadocs documentation site
│   └── showcase/        # Flutter showcase app
└── docs/                # Phase specs and architecture decisions
```

---

## Quick Start

### 1. Install the CLI

**Via install script (recommended):**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/infinitedim/justui/main/packages/cli/install/install.sh | sh

# Windows (PowerShell)
irm https://raw.githubusercontent.com/infinitedim/justui/main/packages/cli/install/install.ps1 | iex
```

**From source:**

```bash
git clone https://github.com/infinitedim/justui.git
cd justui/packages/cli
cargo install --path .
```

---

### 2. Initialize in Your Flutter Project

From your Flutter project root:

```bash
justui init
```

The wizard will prompt you for:

- Components directory (default: `lib/ui`)
- Tokens directory (default: `lib/tokens`)
- Brand color hex (e.g. `#3b82f6`)
- Theme preset (`default` or `neobrutalism`)

This generates `justui.config.yaml` and bootstraps a theme file at `lib/theme/just_theme.dart`.

---

### 3. Add Components

```bash
# Add a single component
justui add button

# Add multiple at once
justui add button input card

# Interactive fuzzy multi-select (no args)
justui add

# Preview without writing to disk
justui add button --dry-run

# Show diff before writing
justui add button --diff
```

The CLI automatically resolves recursive dependencies, verifies SHA-256 checksums, handles conflicts with a three-way prompt, and edits your `pubspec.yaml` if third-party pub packages are needed.

---

## All CLI Commands

| Command                      | Description                                     |
| ---------------------------- | ----------------------------------------------- |
| `justui init [--preset]`     | Initialize config and theme in the project root |
| `justui add [components...]` | Copy components and their dependencies          |
| `justui list`                | List all available registry components          |
| `justui search <query>`      | Search by name, description, or category        |
| `justui info`                | Show CLI version, config, and registry info     |
| `justui view <component>`    | Print component source code to terminal         |
| `justui diff <component>`    | Compare local files against registry            |
| `justui update`              | Check for and apply registry updates            |
| `justui create <name>`       | Scaffold a new custom component                 |

---

## Available Components

### Primitives

`button` · `icon-button` · `input` · `badge` · `avatar` · `checkbox` · `radio` · `switch`

### Layout

`card` · `separator` · `skeleton` · `scroll-area`

### Navigation

`tabs` · `breadcrumb` · `sidebar` · `bottom-nav`

---

## Theme Consumption

Always use aspect-specific extensions in `build()` to avoid unnecessary rebuilds:

```dart
@override
Widget build(BuildContext context) {
  final colors  = context.justColors;   // rebuilds only when colors change
  final spacing = context.justSpacing;  // rebuilds only when spacing changes
  final typo    = context.justTypo;     // rebuilds only when typography changes

  return Container(
    padding: .symmetric(horizontal: spacing.md),
    color: colors.background,
    child: Text('Hello', style: typo.bodyMd),
  );
}
```

In event callbacks, use the non-registering read API:

```dart
onPressed: () {
  final colors = context.readTheme().colors;
}
```

---

## Setup with MaterialApp

```dart
MaterialApp(
  theme: JustThemeData.light.toThemeData(),
  darkTheme: JustThemeData.dark.toThemeData(),
  home: const MyHomeScreen(),
)
```

For `CupertinoApp` or `WidgetsApp`, wrap manually with a `Theme` widget:

```dart
CupertinoApp(
  builder: (context, child) => Theme(
    data: JustThemeData.light.toThemeData(),
    child: child!,
  ),
  home: const MyHomeScreen(),
)
```

---

## Documentation

Full documentation at **[docs.justui.dev](https://docs.justui.dev)** — installation, theming, all component APIs, and guides.

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for setup instructions, coding rules, and how to add components to the registry.

## License

[MIT](./LICENSE)
