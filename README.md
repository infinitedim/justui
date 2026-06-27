# JustUI 🚀

JustUI is a high-performance, premium Flutter UI component library designed around the **copy-paste model** (heavily inspired by `shadcn/ui`).

Instead of adding a bloated third-party package to your project, you use the CLI tool to copy the source code of specific components directly into your own codebase. You own the code, the styling, and the performance characteristics.

---

## Key Architecture & Features

1. **Zero-Dependency Footprint:** Built entirely using native Flutter widgets and layout APIs. No external pubspec.yaml dependencies (except Flutter itself).
2. **Aspect-Based Rebuilds (`InheritedModel`):** Rather than rebuilding whole widget trees when a theme changes, JustUI utilizes aspect-based rebuilds so only widgets depending on the specific modified aspect (colors, spacing, or typography) are re-rendered.
3. **Lazy-Cached Material ThemeData:** Compiles custom themes into Flutter's `ThemeData` lazily and caches the instance, saving significant rendering overhead.
4. **Dynamic Seed Seeding & Contrast Enforcement:** Instantiates a custom theme scale from a single seed color and automatically audits/adjusts active elements at runtime.
   - **Global Contrast Audit:** Automatically enforces WCAG AA accessibility compliance (contrast ratio $\ge$ 4.5:1 for `success`, `error`, and `info`, and $\ge$ 3.0:1 for `warning` and focused borders) against generated background colors by adjusting lightness values.
5. **Dynamic Brand-Tinted Dark Mode:** Generates accessible, premium dark-mode surfaces (background L=3%, card L=7%, elevated L=12%, overlay L=2%) with brand-based hues and clamped saturations for rich aesthetics.
6. **Ambient Tinted Shadows:** Employs a dual-layer shadow system, combining a crisp key shadow (black with low opacity) with a soft ambient shadow (brand-tinted at low opacity).
7. **Fluid Spacing & Responsive Corner Radii:** Scales spacing and radius properties dynamically from 75% on mobile (viewport width $\le$ 640px) to 100% on desktop (viewport width $\ge$ 1024px) for optimized responsive layouts.
8. **Interactive CLI Toolchain:** A high-performance, Rust-based CLI featuring animated loading spinners, a unified progress bar, three-way conflict prompts, dry-runs, diffing, and automated dependency insertions.

---

## Monorepo Packages Directory Map

```
justui/
├── packages/
│   ├── tokens/     # Visual design system primitives (colors, spacing, typography, etc.)
│   ├── core/       # Theming engine, lazy caches, InheritedModel, & seed generator
│   └── cli/                # Command-Line Interface (written in Rust)
├── registry/               # Raw registry components and files (the copy-paste catalog)
└── docs/                   # Phase specifications and design rules
```

---

## Quick Start Guide

### 1. Build and Install the Rust-Based CLI

Navigate to `packages/cli` and install the compiled executable globally on your system:

```bash
cd packages/cli
cargo install --path .
```

This registers the `justui` binary globally on your path.

### 2. Initialize JustUI in Your Target Project

From the root directory of your Flutter application, run:

```bash
justui init
```

The initialization wizard will interactively prompt you for:

- **Components target directory** (default: `lib/ui`)
- **Tokens target directory** (default: `lib/tokens`)
- **Primary brand HEX color** (e.g., `#3b82f6`)

It generates a `justui.config.yaml` and bootstraps a brand-seeded theme configuration at `lib/theme/just_theme.dart`:

```yaml
# justui.config.yaml
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: https://raw.githubusercontent.com/username/justui/main/registry
```

### 3. List Available Components

To view all categorized components available in the remote registry (shown with an active animated loading spinner):

```bash
justui list
```

### 4. Search for Components

To search for a specific component in the registry by name or description:

```bash
justui search button
```

### 5. View Component Details

To inspect a component's details, version, category, and its internal registry dependencies:

```bash
justui info button
```

### 6. View Component Source Code

To display the source code of a component file directly from the registry in the terminal:

```bash
justui view button
```

### 7. Copy a Component to Your Project

To copy a component and all of its required local dependencies recursively, run:

```bash
justui add button
```

If you run the command without arguments, an **interactive multi-selection prompt** is displayed:

```bash
justui add
```

During copy-pasting, the CLI automatically:

- Resolves recursive dependencies and counts files to show a **unified download progress bar**.
- Verifies file integrity using **SHA-256 checksums**.
- Triggers the **Three-Way Conflict Resolution Overwrite Guard** if local modifications are detected. You can choose to:
  - `[o] Overwrite` (replace local changes with registry updates)
  - `[s] Skip` (preserve your local modifications)
  - `[d] Show Diff` (visualize additions and deletions on the terminal)
- Edits your local `pubspec.yaml` to append any third-party dependencies required below `dependencies:` (making a backup file at `pubspec.yaml.bak`).
- Displays a clean, minimalist summary of successful additions (✔) and warnings (⚠) at completion.

### 8. Check for Code Modifications

To compare your local copy-pasted files against the original registry versions:

```bash
justui diff button
```

For a line-by-line file difference visual output, run:

```bash
justui diff button --verbose
```

### 9. Dynamic Component Updates

To check which of your installed components differ from the registry version and dynamically update them:

```bash
justui update
```

The CLI will display a list of outdated components with updates available, and let you interactively select and update them using the Overwrite Guard.

### 10. Local Component Scaffolder

To scaffold a new custom UI component following JustUI's layout and styling guidelines:

```bash
justui create my_component
```

This creates a standard 4-file bundle under your components directory:

- `my_component.dart`: Widget implementation utilizing aspect-based listeners (`context.justColors`, `context.justSpacing`, etc.).
- `my_component_style.dart`: Style configuration class for per-instance overrides.
- `my_component_variants.dart`: Enums for sizes and variants.
- `my_component_theme.dart`: A Flutter `ThemeExtension` mapping class for global styling overrides.

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
    padding: .symmetric(horizontal: spacing.md), // Using dot shorthand
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

### 3. Component Theme Extensions (Theme / MaterialApp Requirement)

JustUI utilizes Flutter's native `ThemeExtension` mechanism for per-component style overrides (e.g., `JustButtonTheme` customizes button styles globally).

Because of this, **a `Theme` widget must be present at the root of the widget tree** (which is automatically set up by `MaterialApp`, or can be provided manually under a `WidgetsApp` or `CupertinoApp` by wrapping the tree in a `Theme` widget with the generated `JustThemeData.toThemeData()`):

```dart
// Example using MaterialApp (automatically sets up Theme)
MaterialApp(
  theme: JustThemeData.light.toThemeData(),
  darkTheme: JustThemeData.dark.toThemeData(),
  home: const MyHomeScreen(),
)

// Example using CupertinoApp / WidgetsApp (requires manual Theme wrapping)
CupertinoApp(
  builder: (context, child) {
    return Theme(
      data: JustThemeData.light.toThemeData(),
      child: child!,
    );
  },
  home: const MyHomeScreen(),
)
```

While the components themselves are strictly **zero-Material** (they do not render Material design components like `ElevatedButton` or `TextField` internally, using core Flutter primitives instead), they still rely on the standard Flutter `Theme`/`ThemeData` framework for component style overrides.

---

## Contributing & Development

Please refer to the [CONTRIBUTING.md](./CONTRIBUTING.md) guide for setup instructions, code-style rules (including the **Dart Dot Shorthand** convention), and registry index formatting.
