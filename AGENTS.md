# JustUI — Agent Onboarding & Codebase Manual

Welcome! This document serves as the **single source of truth** for AI Agents to understand JustUI's polyglot architecture, project structure, conventions, and development environment constraints without needing to re-analyze the codebase from scratch.

---

## 1. Project Overview & Polyglot Architecture

**JustUI** is a production-grade Flutter UI component library built around a **copy-paste distribution model** (inspired by shadcn/ui).

- **Copy-Paste Philosophy:** Users **do not install** this library as a monolithic third-party `pub.dev` dependency. Instead, they use the native JustUI CLI (`justui`) to copy component source code directly into their own project repositories.
- **Zero External Runtime Footprint:** All Flutter components (`packages/core` and `packages/tokens`) have zero third-party pub dependencies; they rely strictly on Flutter built-ins and internal design tokens.
- **Polyglot Monorepo:** The repository is partitioned into three specialized engineering pillars:
  1. **Flutter / Dart:** Core theming engine, tokens, visual components, Widgetbook preview, and the CLI sandbox app.
  2. **Rust:** High-performance distribution CLI (`justui`) providing AST transpilation, diffing, interactive terminal UI (TUI), and dependency management.
  3. **TypeScript / Next.js:** Interactive documentation portal and registry preview hosted on Vercel.
- **Core Tenet:** **Visual & Performance Excellence** — 120 FPS jank-free rendering, zero heap allocations in layout/paint loops, strict WCAG AA contrast enforcement, and agency-grade design aesthetics.

---

## 2. Monorepo Topography & Workspace Mapping

JustUI is structured as a polyglot monorepo coordinated by three package managers: **Melos** (Dart/Flutter), **Cargo** (Rust), and **Bun** (Node/TypeScript).

```
justui/
├── packages/
│   ├── tokens/             # [Dart: just_ui_tokens] Visual primitives, perceptual color engines, typography & a11y
│   ├── core/               # [Dart: just_ui_core] Theming engine, InheritedModel aspect kernel, & 30+ visual components
│   └── cli/                # [Rust: justui / justui_cli] Native CLI tool (clap, ratatui, syntect, serde, similar)
├── apps/
│   ├── docs/               # [Next.js 16 + React 19] Fumadocs documentation site & interactive registry portal
│   ├── preview/            # [Flutter] Widgetbook 3 interactive component workbench (28 use cases)
│   └── showcase/           # [Flutter] CLI sandbox: components installed via `justui add --all` from ../../registry
├── registry/               # Generated component distribution definitions & mirrored component files
├── tools/                  # Polyglot release scripts, checksum generators, & changeset automations
├── .changeset/             # Multi-package changelog & versioning definitions
├── melos.yaml              # Dart workspace configuration
├── Cargo.toml              # Rust workspace configuration
└── package.json            # Bun workspace configuration (apps/docs)
```

### Workspace Management Matrix

| Pillar                | Sub-Directory     | Package Manager     | Manifest File  | Primary Commands                                            |
| --------------------- | ----------------- | ------------------- | -------------- | ----------------------------------------------------------- |
| **Flutter Tokens**    | `packages/tokens` | Melos / Flutter SDK | `pubspec.yaml` | `melos bootstrap`, `dart analyze packages/tokens`           |
| **Flutter Core**      | `packages/core`   | Melos / Flutter SDK | `pubspec.yaml` | `dart analyze packages/core`                                |
| **Rust CLI**          | `packages/cli`    | Cargo               | `Cargo.toml`   | `cargo check --workspace`, `cargo test --workspace`         |
| **Documentation**     | `apps/docs`       | Bun                 | `package.json` | `bun run dev`, `bun run build`, `bun run test`              |
| **Component Preview** | `apps/preview`    | Flutter SDK         | `pubspec.yaml` | `dart run build_runner build --delete-conflicting-outputs`  |
| **CLI Sandbox**       | `apps/showcase`   | Flutter SDK         | `pubspec.yaml` | `flutter analyze && flutter test` (after regenerating, see §6.2) |

---

## 3. Flutter & Dart Core Engine (`packages/core` & `packages/tokens`)

### 3.1 Aspect-Based Rebuilds (`InheritedModel`)

To minimize widget tree rebuild overhead when theme properties change, `packages/core` provides `JustThemeProvider` backed by an `InheritedModel<JustThemeAspect>`:

- Widgets listening to a specific aspect only re-render when that exact aspect mutates.
- **Consumption Rule inside `build()`**:
  - `context.justColors` $
ightarrow$ Re-renders only when color palette changes (e.g., dark/light toggle).
  - `context.justTypo` $
ightarrow$ Re-renders only when typography scale changes.
  - `context.justSpacing` $
ightarrow$ Re-renders only when spacing changes.
  - `context.justTheme` $
ightarrow$ Avoid inside small child widgets; listening to the whole theme causes rebuilds on _any_ aspect mutation.
- **Non-Registering Reads in Callbacks**:
  - Use `context.readTheme()` inside `onPressed`, `onTap`, or gesture callbacks to obtain theme data without subscribing the widget context to rebuilds.

### 3.2 Expando Lazy-Cached Material `ThemeData`

Converting a `JustThemeData` instance into a Material `ThemeData` can be expensive. JustUI uses an internal `Expando` cache: repeated calls to `themeData.toThemeData()` return the identical cached `ThemeData` reference, eliminating object allocations across build loops.

### 3.3 Component Architecture Convention (4-File Standard)

Each component inside `packages/core/lib/src/components/<name>/` strictly follows this 4-file structure:

1. `just_<name>.dart` — The presenter widget implementing state and layout.
2. `just_<name>_style.dart` — Instance configuration class controlling geometry, borders, and colors.
3. `just_<name>_variants.dart` — Size, intent, and variant enums.
4. `just_<name>_theme.dart` — Component-specific `ThemeExtension<Just<Name>Theme>` for global design tokens.

### 3.4 Critical Invariant: `// CLI:REGISTER_EXTENSIONS` Anchor

In `packages/core/lib/src/theme/theme_data_material.dart` (inside `ThemeData.extensions`), there is a strict marker:

```dart
      extensions: const [
        // CLI:REGISTER_EXTENSIONS
      ],
```

> [!IMPORTANT]
> **Never remove, rename, or reformat the `// CLI:REGISTER_EXTENSIONS` comment.**
> The Rust CLI (`packages/cli/src/utils/theme_editor.rs`) uses this exact string as an AST anchor to inject newly added component theme defaults into user projects. Removing it breaks the CLI component installation workflow.

### 3.5 Perceptual Color & Design Tokens Engine (`packages/tokens`)

- **Perceptual Color Spaces:** Provides native engines for OKLCH (`oklch_engine.dart`) and HSLuv (`hsluv_engine.dart`) with smooth mathematical tweens (`oklch_color_tween.dart`, `hsluv_color_tween.dart`).
- **WCAG AA Contrast Auditor (`colors_accessibility.dart`):** Extension methods `color.contrastRatioWith(bg)` and `color.isAccessibleWith(bg)`. Enforces $\ge 4.5:1$ for body text and $\ge 3.0:1$ for large components/borders.
- **Fluid Typography (`typography_fluid.dart`):** Viewport-clamped dynamic font scaling for multi-device support.
- **Responsive Breakpoints (`breakpoints.dart`):**
  - Mobile: $< 640	ext{px}$
  - Tablet: $640	ext{px} - 1024	ext{px}$
  - Desktop: $> 1024	ext{px}$
- **Reduced Motion Profile (`motion.dart`):** `JustMotionProfile.resolve(context)` automatically detects OS-level accessibility reduce-motion settings and clamps duration to zero.

---

## 4. Rust CLI Architecture (`packages/cli` — `justui`)

The JustUI CLI is a high-performance native binary compiled from Rust 2021 edition (`packages/cli`), leveraging `clap 4`, `ratatui 0.30` (TUI), `syntect 5.2` (syntax highlighting), `similar 3` (diffing), `serde`, and `inquire`.

### 4.1 Subcommands Matrix

| Command           | Arguments / Flags                                                  | Purpose & Behavior                                                                                                       |
| ----------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `init`            | `--preset <name>`, `--color-space <space>`, `--dart-target <mode>` | Initializes `justui.config.yaml` and scaffolds local theme kernel.                                                       |
| `add`             | `<component...>`, `--diff`, `-y`, `--dry-run`                      | Resolves dependencies, injects pub dependencies via `pubspec_editor.rs`, transpiles AST, and registers theme extensions. |
| `diff`            | `<component>`                                                      | Interactive visual diff (powered by `similar` & `syntect`) comparing local component files against registry source.      |
| `update`          | `<component...>`, `--all`, `--force`                               | Synchronizes local component code with upstream registry without wiping local modifications.                             |
| `preset`          | `list`, `apply <name>`, `info <name>`                              | Inspects and switches active design system presets in a user project.                                                    |
| `create`          | `<name>`                                                           | Scaffolds standard 4-file boilerplate for authoring new components locally.                                              |
| `doctor`          | N/A                                                                | Diagnostics: Flutter/Dart SDK, pubspec context, FVM, and registry availability.                                          |
| `list` / `search` | `[query]`                                                          | Lists or queries components available in the remote/local registry.                                                      |
| `view` / `info`   | `<component>`                                                      | Displays component metadata, variants, and dependency requirements.                                                      |
| `upgrade`         | N/A                                                                | Self-updates the `justui` binary to the latest release.                                                                  |

### 4.2 Configuration Schema (`justui.config.yaml`)

```yaml
components_dir: lib/widgets
tokens_dir: lib/tokens
shared_dir: lib/widgets/shared
registry_url: https://raw.githubusercontent.com/infinitedim/justui/main/registry
preset: default # 'default' | 'neobrutalism'
color_space: hsl # 'hsl' | 'oklch' | 'hsluv'
dart_target: standard # 'standard' | 'primary' (primary-constructors experiment)
```

### 4.3 AST Transpilation & Safety Invariants

- **Primary Constructor Transpilation (`constructor_transpiler.rs`):** Core components use Dart's `primary-constructors` language experiment internally. When `dart_target: standard` is configured, the CLI transpiles primary constructors back into conventional Dart constructors during component installation so user projects do not require experimental SDK flags.
- **Integrity Headers:** Distributed files carry metadata headers:
  `// justui-meta: registry=<sha256> local=<sha256>`
  The `update` and `diff` commands parse these hashes to safely detect upstream updates vs. local user edits.
- **Backup Protection:** `pubspec_editor.rs` creates `pubspec.yaml.bak` before modifying user dependencies.
- **Cargo Audit Compliance:** `.cargo/audit.toml` intentionally ignores `RUSTSEC-2025-0141` (an unmaintained transitive dependency in `bincode`, code-justified for static templates).

---

## 5. Web Documentation Portal (`apps/docs`)

`apps/docs` is a Next.js 16.3 + React 19 application built with Fumadocs UI/Core and Tailwind CSS 4, deployed on Vercel.

### 5.1 Active Locales & i18n Rules

- **Strict Active Locales:** Currently, documentation is authored and maintained **strictly in two active languages**:
  1. English: `apps/docs/content/docs/en/` (Default)
  2. Indonesian: `apps/docs/content/docs/id/`
- **Inactive Stubs (`cn`):** The `apps/docs/content/docs/cn/` directory is an unactivated placeholder containing only `.gitkeep`. The active locale list lives in one place, `apps/docs/src/lib/i18n.ts` (`locales`, `isLocale`, `localeStaticParams`); every `[lang]` route derives from it. **Do not author or enforce `cn` files** until Chinese localization is officially activated.
- **Routing:** Locale-less URLs are redirected by `next.config.ts` `redirects()`. There is no middleware/proxy file; note that because the app lives in `src/`, Next.js would only pick up `src/proxy.ts`, never a root-level `proxy.ts`.

### 5.2 Stage Bridge Telemetry Protocol (`stage-bridge.ts`)

The living stage and hero workbench in the documentation portal exchange events over a typed `window.postMessage` protocol ([`apps/docs/src/lib/stage-bridge.ts`](apps/docs/src/lib/stage-bridge.ts)). There is currently no embedded Flutter iframe; incoming messages are validated with the zod `stageBridgeEventSchema`:

```typescript
export type StageBridgeEvent =
  | StageReadyEvent // 'justui-ready': Flutter stage initialized
  | StageMountEvent // 'justui-mount': Mount component with specific props
  | StageThemeEvent // 'justui-theme': Switch theme preset & light/dark mode
  | StageTokensEvent // 'justui-tokens': Live-override design tokens
  | StageInteractEvent // 'justui-interact': Dispatch user interaction events
  | StageMountedEvent // 'justui-mounted': Flutter stage confirms component mount
  | StageClearEvent // 'justui-clear': Dismount current component
  | StageTelemetryEvent; // 'justui-event': General interaction telemetry
```

### 5.3 Vercel Deployment Invariants

- Configured in `apps/docs/vercel.json`: Singapore region (`sin1`), build command `bun run build`, install command `bun install`.
- Strict Content Security Policy (CSP) and Cache-Control headers are declared in `next.config.ts`.

---

## 6. Interactive Workbenches (`apps/preview` & `apps/showcase`)

### 6.1 `apps/preview` (Widgetbook 3 Workbench)

- Primary visual testing and interactive sandbox for Flutter components.
- Contains 28 use-case files under `apps/preview/lib/usecases/`.
- Pre-configured with 4 themes: `Light`, `Dark`, `Neobrutalism Light`, and `Neobrutalism Dark`.
- **Code Generation Command:**
  ```bash
  cd apps/preview && dart run build_runner build --delete-conflicting-outputs
  ```

### 6.2 `apps/showcase` (CLI Sandbox)

- A Flutter app whose `lib/core`, `lib/tokens` and `lib/widgets` are **generated by the CLI** from the local registry (`registry_url: ../../registry`, `dart_target: standard`). `lib/main.dart` renders a small gallery and `test/widget_test.dart` smoke-tests it.
- It is the end-to-end check that installed components compile: never edit the generated folders by hand; regenerate them after changing `packages/core` or the CLI:
  ```bash
  cargo build --release
  cd apps/showcase
  rm -rf lib/core lib/tokens lib/widgets
  ../../target/release/justui init -y --preset neobrutalism --color-space oklch --dart-target standard
  sed -i 's#^registry_url:.*#registry_url: ../../registry#' justui.config.yaml
  ../../target/release/justui add --all -y
  dart format lib && flutter analyze && flutter test
  ```

---

## 7. Registry Architecture & Checksum Synchronization

The `registry/` directory stores pre-packaged component definitions consumed by the CLI.

### 7.1 `registry/index.json` Schema

```json
{
  "name": "button",
  "version": "0.13.2",
  "category": "components",
  "internal": false,
  "hidden": false,
  "files": [
    "just_button.dart",
    "just_button_style.dart",
    "just_button_variants.dart",
    "just_button_theme.dart"
  ],
  "registryDependencies": ["_shared_pressable"],
  "pubDependencies": []
}
```

### 7.2 Component Placement & Routing Heuristics

When installing components, the CLI routes files according to strict precedence:

1. `category == "tokens"` or `"core"` $
ightarrow$ `config.tokens_dir`
2. `name == "_shared_theme_provider"` $
ightarrow$ `lib/theme`
3. `internal: true` $
ightarrow$ `config.shared_dir`
4. All standard components $
ightarrow$ `{config.components_dir}/{component.name}`

### 7.3 Checksum Synchronization Tool (`tools/generate_checksums.dart`)

When components in `packages/core` are added or updated, their registry definitions and SHA-256 hashes must be synchronized:

```bash
# Dry-run inspection:
export HOME=/home/yourblooo/development/justui/.home && dart run tools/generate_checksums.dart --dry-run

# Live write and update registry:
export HOME=/home/yourblooo/development/justui/.home && dart run tools/generate_checksums.dart
```

---

## 8. Coding Standards & Syntax Rules per Language

### 8.1 Dart & Flutter Conventions

1. **Mandatory Dot Shorthands (Dart 3.10+):**
   - Static constructors must use leading dot syntax when types are inferrable:
     ```dart
     borderRadius: .all(radius.lg)               // NEVER expand to BorderRadius.all!
     padding: .symmetric(horizontal: spacing.md) // NEVER expand to EdgeInsets.symmetric!
     fontWeight: .w600                           // NEVER expand to FontWeight.w600!
     ```
   - **Absolute Rule:** Never expand leading dot shorthand syntax back to its verbose form.
2. **Modern Color Alpha:** Use `color.withValues(alpha: 0.5)` instead of the deprecated `color.withOpacity(0.5)`.
3. **Restrictive Material Imports:** Always use `show` clauses when importing Material in `packages/core` to prevent namespace pollution:
   ```dart
   import 'package:flutter/material.dart' show Theme, ThemeData, ThemeExtension;
   ```
4. **Enforce `const`:** All immutable widgets, styles, and token constants must be declared `const`.
5. **No Barrel Leakage:** Never export component files in `packages/core/lib/just_ui_core.dart`.

### 8.2 Rust Conventions

1. **Zero Unwrapped Panics:** Never use `.unwrap()` or `.expect()` in production CLI code; use `anyhow::Context` or `?` error propagation.
2. **Strict Clippy Compliance:** Code must pass `cargo clippy --workspace -- -D warnings`.
3. **Graceful User Experience:** Use `inquire` for interactive prompts and `indicatif` spinners for network operations.

### 8.3 TypeScript Conventions

1. **Strict Type Safety:** Zero `any` in business logic; use `unknown` with Zod schema parsing.
2. **ESLint & Prettier:** Flat config compliance with `eslint-plugin-react-compiler`.

---

## 9. Development & Sandbox Constraints (Crucial!)

When executing tools in this environment, AI Agents must strictly adhere to the following operational constraints:

1. **Offline Environment (No Internet):**
   - The container cannot reach `pub.dev` or external package registries.
   - Local package inter-dependencies are pre-configured in `.dart_tool/package_config.json`. **Never delete or regenerate `.dart_tool` carelessly.**
2. **Dart Telemetry & Read-Only HOME:**
   - Dart CLI commands fail if telemetry writes to the default root home directory.
   - **Required Solution:** Always prefix Dart commands with `HOME=/home/yourblooo/development/justui/.home`.
3. **Verified Static Analysis & Quality Commands:**

   ```bash
   # Core Packages (Always verify before completing Dart tasks):
   export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/core
   export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/tokens

   # Rust CLI Workspace:
   cargo check --workspace
   cargo test --workspace

   # Documentation Portal:
   cd apps/docs && bun run type-check && bun run lint
   ```

4. **Running Tests:**
   - Due to container sandbox graphics and socket limitations, full Flutter widget tests must be executed in CI or on the host machine.
   - When unit testing is possible, run:
     ```bash
     melos exec --dir-exists="test" -- "flutter test"
     ```

---

## 10. Design Presets & Neobrutalism Guidelines

JustUI features first-class preset support. When creating or modifying presets (such as `neobrutalism`), follow these strict rules:

1. **Inner-Layout Calculation & Inward Borders:**
   - Flutter paints borders inward (`BorderAlign.inside`). In tight containers (such as `JustSwitch`), dynamic borders can clip internal child widgets.
   - Under `neobrutalism`, reduce the switch thumb size by `2 * borderWidth` and offset placement:
     `Positioned(top: padding + borderWidth, left: padding + borderWidth)`.
2. **Preventing Press Animation Visual Drift (Jitter):**
   - Synchronize position translation with the collapsing solid shadow: set `AnimatedContainer` duration to `animations.instant` (not `animations.fast`) to eliminate visual jitter.
3. **Solid Contrast & Border Width:**
   - Standard container/component border width is `2.5` (sidebar active border: `3.0`).
   - Enforce border colors to `colors.textPrimary` (solid black in light mode, solid white in dark mode) across all states (normal, hover, focused, error). Never transition border colors to primary or tinted hues.
   - Bypass dynamic HSL contrast adjustments (`_makeAccessible`) for default/focus borders in `neobrutalism`.
4. **CLI Preset Registration:** Update `init_command.rs` in `packages/cli` when adding new presets and ensure the preset is registered in `operator ==`, `hashCode`, and `copyWith` on `JustThemeData`.

---

## 11. Testing Matrix & Quality Assurance Protocols

| Layer                    | Framework & Tooling                 | Location                             | Verification Command               |
| ------------------------ | ----------------------------------- | ------------------------------------ | ---------------------------------- |
| **Tokens Unit Tests**    | Flutter Test (7 modular files)      | `packages/tokens/test/*_test.dart`   | `flutter test packages/tokens`     |
| **Theming Engine Tests** | Flutter Test                        | `packages/core/test/theme_test.dart` | `flutter test packages/core`       |
| **Rust CLI Integration** | `assert_cmd`, `predicates`          | `packages/cli/tests/`                | `cargo test --workspace`           |
| **Docs Unit Tests**      | Vitest 5 + JSDOM (`bun-preload.ts`) | `apps/docs/src/**/__tests__/`        | `cd apps/docs && bun run test`     |
| **Docs E2E Tests**       | Playwright 1.63                     | `apps/docs/e2e/`                     | `cd apps/docs && bun run test:e2e` |

---

## 12. Versioning, Changesets & CI/CD Release Pipeline

JustUI coordinates multi-runtime versioning using **Changesets** paired with custom polyglot automation scripts.

### 12.1 Authoring Changesets

When making user-facing changes to packages, create a changeset markdown file under `.changeset/<name>.md`:

```markdown
---
"just_ui_core": minor
"just_ui_tokens": minor
"justui_cli": minor
"docs": patch
---

Detailed description of changes following Conventional Commits.
```

### 12.2 Release Script Execution

```bash
# Update Dart package versions (packages/tokens & packages/core):
export HOME=/home/yourblooo/development/justui/.home && dart run tools/apply_changesets.dart

# Update Rust CLI version (packages/cli/Cargo.toml):
bash tools/apply_changesets_cargo.sh

# Update Markdown changelogs:
bun changeset version
```

### 12.3 GitHub Actions CI/CD Architecture

- `.github/workflows/ci.yaml`: Runs 3 parallel matrix pipelines on pull requests:
  1. `dart-flutter-ci`: Format check, `dart analyze`, and `flutter test`.
  2. `nextjs-ci`: Bun install, linting, type-checking, and Vitest suite.
  3. `cli-check`: `cargo clippy`, `cargo audit`, and integration test matrix.
- `.github/workflows/release.yaml`: Automatically builds release binaries across Linux (`x86_64`, `aarch64`), macOS (`x86_64`, `aarch64`), and Windows (`x86_64`) with cryptographic SLSA provenance attestations.

---

## 13. Known Documentation Gaps & Deprecation Warnings

1. **Undocumented Components Gap:**
   - `packages/core` contains 30 component directories, but `apps/docs` currently only documents 25 components.
   - **4 components are currently missing MDX documentation:** `carousel`, `date-picker`, `resizable`, and `time-picker`.
   - When modifying or finalizing these components, author new MDX files under both `apps/docs/content/docs/en/components/` and `apps/docs/content/docs/id/components/`.
2. **Conflicting Documentation in `CONTRIBUTING.md`:**
   - [`CONTRIBUTING.md:264-266`](file:///home/yourblooo/development/justui/CONTRIBUTING.md#L264-L266) instructs contributors to _"Add your component to the barrel export at packages/core/lib/just_ui_core.dart"_.
   - **DO NOT FOLLOW THIS STEP.** To prevent barrel leakage into user projects, components must never be exported in the public kernel barrel. Follow the rule established in Section 3 and Section 8.1.
3. **`apps/showcase` is a generated CLI sandbox** (see §6.2). There is no pre-compiled web showcase anymore; do not hand-edit its generated folders.

---

## 14. Mandatory Skill Matching & Execution Protocol (Strict!)

To ensure optimal engineering quality, prevent hallucinatory patterns, and enforce domain-specific excellence across all areas of this monorepo:

**Skill catalog (`.agents/skills`).** Only skills that map to this repo's stack are kept in the repository:

| Area | Skills |
| --- | --- |
| Flutter / Dart UI | `flutter-expert`, `ui-a11y`, `ux-audit` |
| Visual direction & presets | `taste-skill`, `soft-skill`, `brutalist-skill`, `minimalist-skill` |
| Code generation | `output-skill` |
| Rust CLI | `rust-pro` |
| Docs portal (Next.js / TypeScript) | `typescript-expert`, `senior-frontend`, `i18n-localization`, `nextjs-seo-indexing` |
| Monorepo & releases | `monorepo-architect`, `changelog-generator` |
| Security review | `cc-skill-security-review`, `security-scanning-security-dependencies`, `security-scanning-security-sast` |

Unrelated general-purpose skills (image generation, cloud/Vercel optimization, orchestrators, PRD tooling, and so on) were removed; keep such skills in your personal agent setup instead of committing them here.

1. **Mandatory Skill Identification on Every Prompt:**
   - For **every prompt and user task**, AI Agents **must proactively analyze and determine** which specialized skill(s) in `.agents/skills` (or active workspace skills) correspond to the request.
   - Agents are strictly prohibited from answering or executing tasks in a generic manner when a dedicated skill exists for the target domain.

2. **Mandatory Skill Utilization & Directive Compliance:**
   - Once the matching skill is identified, the agent **must strictly follow its instructions, rules, and quality standards**:
     - **Flutter / Dart UI (`packages/core`, `packages/tokens`, `apps/showcase`):** Must follow `flutter-expert`, `ui-a11y` (WCAG AA compliance), and `ux-audit`.
     - **Rust CLI (`packages/cli`):** Must follow `rust-pro` (idiomatic Rust, memory safety, clap, ratatui, async/error handling).
     - **Web Docs (`apps/docs`):** Must follow `typescript-expert` and `senior-frontend` (Next.js 16, React 19, Tailwind CSS 4, Fumadocs).
     - **Design Systems & Presets:** Must follow `brutalist-skill` (neobrutalism preset), `minimalist-skill`, and `soft-skill` / `taste-skill` (anti-slop visual standards).
     - **Code Generation:** Must strictly adhere to `output-skill` (never produce truncated code, placeholders like `// TODO`, or incomplete implementations).
     - **Monorepo & Releases:** Must follow `monorepo-architect` and `changelog-generator` (Conventional Commits, SemVer).
     - **Defensive AppSec & Code Review:** Must follow `cc-skill-security-review`, `security-scanning-security-dependencies`, and `security-scanning-security-sast`.
   - **Cross-Domain Tasks:** If a task spans multiple layers (e.g., implementing a new Flutter component, adding CLI scaffolding support in Rust, and writing MDX docs in Next.js), the agent must coordinate and apply all corresponding skills harmoniously without skipping any.

3. **Mandatory UI Character & Anti-AI Slop Policy (`taste-skill`):**
   - For **any prompt or task relating to UI** (component design, widget styling, layout architecture, showcase screens, presets, or web documentation interfaces):
     - **Distinct Character & Agency Craft:** The UI **must exhibit intentional aesthetic direction, strong personality, and agency-grade polish**. Generic, bland, or cookie-cutter templates are strictly prohibited.
     - **Strict Anti-AI Slop Enforcement:** Agents must actively reject and avoid notorious LLM design clichés:
       - No generic AI-purple/violet gradients splashed across dark meshes.
       - No repetitive centered hero sections paired with generic floating pill badges.
       - No lazy 3-column equal feature card spam or cards-inside-cards syndrome.
       - No uncalibrated glassmorphism applied blindly without contrast boundaries.
       - No lazy fallback to default Inter + slate-900 without typographic hierarchy and contrast.
       - No monotonous spacing and uniform timid border radii.
     - **Mandatory Invocation of `taste-skill`:** The agent **must unconditionally invoke and follow `taste-skill`** (`.agents/skills/taste-skill/SKILL.md`) whenever touching UI. The agent must perform a preliminary "Design Read" (identifying page/component kind, vibe language, audience, and intent), calibrate the core design dials (Variance, Motion Intensity, Visual Density), and enforce purposeful typography, intentional color calibration, and rhythmic spacing.
