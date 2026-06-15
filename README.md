# JustUI 🚀

JustUI is a high-performance, premium Flutter UI component library designed around the **copy-paste model** (heavily inspired by `shadcn/ui`).

Instead of adding a bloated third-party package to your project, you use the CLI tool to copy the source code of specific components directly into your own codebase. You own the code, the styling, and the performance characteristics.

---

## Key Architecture & Features

1. **Zero-Dependency Footprint:** Built entirely using native Flutter widgets and layout APIs. No external pubspec.yaml dependencies (except Flutter itself).
2. **Aspect-Based Rebuilds (`InheritedModel`):** Rather than rebuilding whole widget trees when a theme changes, JustUI utilizes aspect-based rebuilds so only widgets depending on the specific modified aspect (colors, spacing, or typography) are re-rendered.
3. **Lazy-Cached Material ThemeData:** Compiles custom themes into Flutter's `ThemeData` lazily and caches the instance, saving significant rendering overhead.
4. **Dynamic Seed Seeding & Contrast Enforcement:** Instantiates a custom theme scale from a single seed color and automatically audits/adjusts active elements to guarantee WCAG AA accessibility compliance (contrast ratio $\ge$ 3.0:1) at runtime.
5. **Robust Command Line Interface:** Handles configuration initialization, recursive component dependency resolution, local pubspec.yaml injection, and local change diffing.

---

## Monorepo Packages Directory Map

```
justui/
├── packages/
│   ├── just_ui_tokens/     # Visual design system primitives (colors, spacing, typography, etc.)
│   ├── just_ui_core/       # Theming engine, lazy caches, InheritedModel, & seed generator
│   └── just_ui_cli/        # Command-Line Interface (scaffolding & copy-paste workflow)
├── registry/               # Raw registry components and files (the copy-paste catalog)
└── docs/                   # Phase specifications and design rules
```

---

## Quick Start Guide

### 1. Register and Compile the CLI

Navigate to `just_ui_cli` and activate it globally or compile it:

```bash
cd packages/just_ui_cli
dart pub global activate --source path .
```

### 2. Initialize JustUI in Your Target Project

From the root directory of your Flutter application, run:

```bash
justui init
```

This generates a `justui.config.yaml` specifying target directories for your components and tokens:

```yaml
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: https://raw.githubusercontent.com/username/justui/main/registry
```

### 3. List Available Components

To view all categorized components available in the remote registry:

```bash
justui list
```

### 4. Copy a Component to Your Project

To copy a component and all of its required local dependencies recursively, run:

```bash
justui add button
```

This will:

- Check for circular dependencies and copy component files into `lib/ui/` or `lib/tokens/`.
- Edit your local `pubspec.yaml` to append any third-party dependencies required (e.g. `flutter_animate`) below `dependencies:` (making a backup file at `pubspec.yaml.bak`).

### 5. Check for Code Modifications

To compare your local copy-pasted files against the original registry versions:

```bash
justui diff button
```

For a line-by-line file difference visual output, run:

```bash
justui diff button --verbose
```

---

## Theme Consumption Guidelines

To preserve 60/120fps rendering speeds, always query design tokens using the specific aspect-based extension methods on `BuildContext`:

### 1. In Build Methods (Register Rebuild Listener)

Always fetch specific aspects to ensure widgets only rebuild when that exact property changes:

```dart
@override
Widget build(BuildContext context) {
  // Good: Rebuilds ONLY when color tokens change
  final colors = context.justColors;
  // Good: Rebuilds ONLY when spacing tokens change
  final spacing = context.justSpacing;

  return Container(
    padding: .all(spacing.md), // Using dot shorthand
    color: colors.background,
    child: Text(
      'JustUI Card',
      style: context.justTypo.bodyMd, // Rebuilds ONLY on typo changes
    ),
  );
}
```

### 2. In Callback Event Methods (Static Read)

Avoid registering rebuild listeners inside event callbacks where rendering state updates are unnecessary. Use `readTheme()` instead:

```dart
ElevatedButton(
  onPressed: () {
    // Good: Fetches color statically without registering listener to context
    final colors = context.readTheme().colors;
    print("Primary theme color is: ${colors.primary}");
  },
  child: const Text("Tap Me"),
)
```

---

## Contributing & Development

Please refer to the [CONTRIBUTING.md](./CONTRIBUTING.md) guide for setup instructions, code-style rules (including the **Dart Dot Shorthand** convention), and registry index formatting.
