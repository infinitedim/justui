# Contributing to JustUI

Thank you for your interest in contributing to JustUI! We are building a high-performance, premium, copy-paste Flutter UI component library.

Before you start contributing, please read through this document to understand our codebase architecture, design guidelines, and code conventions.

---

## 1. Project Philosophy & Architecture

JustUI is not a standard third-party Flutter package. It is a **copy-paste component library** (inspired by shadcn/ui).

- Developers do not add JustUI to their `pubspec.yaml` as an external dependency.
- Instead, they copy the raw component source code directly into their own projects using our CLI tool.
- This means our components must be highly portable, easy to understand, and follow a **zero-dependency footprint** (i.e. no external pub.dev packages except native Flutter).

### Repository Structure (Monorepo)

- **`packages/just_ui_tokens`**: Single source of truth for design system constants (`const` colors, spacing, typography, shadow, curves, and durations) and the accessibility contrast ratio auditor.
- **`packages/just_ui_core`**: Theming engine, lazy-cached Material `ThemeData` compiler, dynamic contrast-enforcing seed generator, and aspect-based rebuild optimizations.
- **`packages/just_ui_cli`**: The command-line interface tool (`justui`) used to initialize configs, download, resolve dependencies recursively, and diff component files.
- **`registry/`**: Holds metadata indices (`index.json`) and raw registry source files for components.

---

## 2. Setting Up Your Development Environment

We use [Melos](https://melos.invertase.dev/) to manage our multi-package repository.

### Prerequisites

- Flutter SDK installed locally.
- Melos CLI (`dart pub global activate melos`).

### Scaffolding & Bootstrap

To install all dependencies across the monorepo packages and link them locally:

```bash
# Override HOME directory to local if Dart telemetry errors occur
export HOME=~/development/justui/.home
melos bootstrap
```

### Static Analysis

Always verify your code passes clean analysis before submitting a pull request:

```bash
export HOME=~/development/justui/.home
dart analyze packages/just_ui_tokens
dart analyze packages/just_ui_core
dart analyze packages/just_ui_cli
```

---

## 3. Strict Coding Style & Rules

All contributions must adhere to these rules to maintain codebase consistency:

### A. Dart Dot Shorthand (Constructor Shorthands)

Since Dart 3.10, the compiler supports constructor shorthands when the type is statically declared by a parameter. We utilize this feature heavily.

- **Always use dot shorthand** for widgets and constructors (e.g. `BorderRadius`, `EdgeInsets`, `FontWeight`, `Radius`, etc.):

  ```dart
  // Correct (Dot Shorthand):
  borderRadius: .all(radius.lg)
  padding: .symmetric(horizontal: spacing.md)
  fontWeight: .w600
  borderRadius: .circular(12)

  // Incorrect (Verbose):
  borderRadius: BorderRadius.all(radius.lg)
  padding: EdgeInsets.symmetric(horizontal: spacing.md)
  fontWeight: FontWeight.w600
  ```

- **Do NOT** modify existing dot shorthands or change them back to their long, verbose form.

### B. Aspect-Based Theme Consumption

To maintain 60/120fps rendering speeds, we use `InheritedModel` inside `JustThemeProvider` to avoid rebuilding the entire widget tree when only specific theme tokens change.

- **Use specific aspect extensions** within `build` methods:
  - `context.justColors` (only rebuilds when colors change).
  - `context.justTypo` (only rebuilds when typography changes).
  - `context.justSpacing` (only rebuilds when spacing changes).
- **Avoid** `context.justTheme` in small widgets as it registers listeners for _all_ theme aspects, resulting in unnecessary rebuilds.
- **Use the non-registering API** in interactive event callbacks (e.g. `onPressed`, `onTap`):
  - `context.readTheme()` (accesses theme values statically without registering a rebuild listener).

---

## 4. Design & Motion Excellence

We prioritize premium visual and interactive design:

- **HSL Derived Colors:** Colors must be derived using clean HSL scales for harmonious palettes (sleek dark modes, balanced light modes).
- **Transitions and Motion:** All components should incorporate micro-animations and smooth state transitions. Use default custom transition durations and curves (`transitionDuration` / `transitionCurve`) exposed by `JustThemeProvider`.
- **Zero-dependency footprint:** Always build layout primitives using native Flutter components rather than introducing external packages.

---

## 5. Contributing to the Component Registry

If you are adding a new component or updating an existing one:

### A. Place Raw Code in `registry`

Add the raw source code of the component under `registry/components/<component_name>/`. For example, `registry/components/button/just_button.dart`.

### B. Register in `registry/index.json`

Every component must be cataloged inside the registry index file [index.json](file:///home/yourblooo/development/justui/registry/index.json).

- Structure of a component in `index.json`:
  ```json
  {
    "name": "button",
    "version": "0.1.0",
    "description": "Versatile button with multiple variants",
    "category": "primitives",
    "registryDependencies": ["spacing"],
    "pubDependencies": {
      "flutter_animate": "^1.0.0"
    },
    "files": [
      {
        "name": "just_button.dart",
        "path": "components/button/just_button.dart",
        "checksum": "sha256:e3b0c442..."
      }
    ]
  }
  ```

### C. Calculating SHA-256 Checksums

Every file in `index.json` must have a valid `checksum` field. To compute the checksum for your component files, use the following bash command:

```bash
sha256sum registry/components/button/just_button.dart
```

Prefix the output string with `sha256:`. This is critical for `justui diff` to work properly.
