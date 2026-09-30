# Changelog

All notable changes to the JustUI monorepo will be documented in this file.

---

## [Unreleased]
### Added
- Docs site: interactive `ButtonPlayground` (live prop editor with generated Dart source) and `CheckoutDemo` (async pay-button flow showing loading, disabled and paid states), exposed to MDX together with fumadocs `Tabs`/`Tab` and `JustButtonPreview`.
- Docs site: `justui-shiki-theme.ts` light/dark Shiki themes, wired into `source.config.ts`, so fenced code blocks use the same syntax palette as the playground.
- Docs site: `SegmentedToggle` molecule (accessible two-option `radiogroup`), used by the preset and theme switchers.
- Docs site: `ComponentPreviewGrid` homepage organism with miniature, token-driven component previews that follow the active preset and theme.
- Docs site: `WhatYouGet` homepage organism with three demonstrated claims (CLI writes source into the repo, presets swap tokens not components, text color follows background contrast), including a live `ContrastDemo` and side-by-side default/neobrutalism samples.
- Docs site: new design tokens `--just-fill`, `--just-accent-text`, `--just-destructive`/`--just-on-destructive`, a four-step shadow scale (`xs`/`sm`/`md`/`lg`), `xl`/`2xl` radii, and `--just-syn-*` syntax colors.
- Docs site: shared `.just-press` utility giving every solid control the same press feedback (scale in default, translate-into-shadow in neobrutalism).
- Docs site: fumadocs `--color-fd-*` variables are bridged to `--just-*` tokens so the docs shell follows the active preset and theme.
- Docs site: English and Indonesian strings for the new homepage sections and the Cargo install tab.

### Changed
- Docs site: `globals.css` restructured into three complete, independently scopable token sets (default light, default dark, neobrutalism light/dark), so a subtree can be pinned to a preset regardless of what `<body>` uses.
- Docs site: neobrutalism preset rebuilt to the design rules in `AGENTS.md` §10: 2.5px solid black/white borders, sharp corners (pills and circles stay round), flat 4/6/8px offset shadows, cream light background and a dedicated dark palette, and instant transitions.
- Docs site: all preview mocks, `LivingComponentCard`, `CardActionBar` and `DartCodeModal` normalized to the same neobrutalism border width, radius and shadow offset.
- Docs site: `color-resolver.ts` neobrutalism values aligned with the CSS (`#fff8e7` background, `#000000` border and shadow, dedicated dark surfaces, black accent foreground).
- Docs site: homepage hero copy rewritten ("One command. One file. Yours.") and simplified (no pulse-dot badge or arrow icon); the component grid and bento section replaced by `ComponentPreviewGrid` and `WhatYouGet`. Legacy `bento*` translation keys are kept until the bento components are removed.
- Docs site: header controls (`GitHubPill`, `LanguageSwitcher`, `SearchBar`, mobile icon buttons) share one 28px box model; `PresetToggle` and `ThemeSwitcher` now show both options and fill the active one instead of a single letter/icon button.
- Docs site: footer trimmed to a tagline plus two link columns, removing the version badge and copyright/note rows.
- Docs site: `button.mdx` rewritten around a playground, an "Add to your project" step and a tabbed code/preview "Advanced usage" section; the prose theming section was folded into "Accessibility".
- Docs site: `PresetProvider` and the anti-flash script now apply `theme-neobrutalism` to both `<html>` and `<body>`.
- Docs site: `InteractiveTerminal` scrolls its buffer by setting `scrollTop` instead of `scrollIntoView`, removing the smooth-scroll animation on each new line.

### Fixed
- Docs site: default light `--just-text-muted` raised from `#828282` (3.6:1) to `#6b6b6b` to meet WCAG AA 4.5:1; accent-as-text now uses the dedicated `--just-accent-text` token.
- Docs site: neobrutalism border/shadow color corrected from `#18181b` to true `#000000`.

---

## [0.14.0] - 2026-09-13
### Added
- Scaffolded the docs site's atom and molecule component library (`apps/docs`).
- Implemented the homepage's "hero dual-reality stage" and an interactive Rust CLI terminal simulator.
- Added SHA-256 verification to the CLI's self-update installer.

### Fixed
- Fixed cross-preset shared component imports (a component in one preset resolving a shared dependency registered under a different preset).
- Fixed a broken e2e test.

## [0.13.2] - 2026-09-08
### Added
- Implemented the `just_ui_core` design system's base component library, tokens, and themes.

### Changed
- Bumped `melos` from 8.3.0 to 8.6.0.
- Optimized the primary-constructor transpiler's regex usage with `OnceLock` and fixed a brace-counting bug in its parser.
- Removed the (at the time template-only) showcase app and updated carousel registry components pending its rework into a real CLI sandbox.

## [0.12.1] - 2026-09-06
### Added
- Added CSS-4 gamut mapping and OKLCH color interpolation utilities, using Halley's method for the gamut-mapping search and premultiplied-alpha interpolation.
- Added `HsluvColorTween` with perceptual Cartesian CIELUV interpolation in the HSLuv engine.
- Implemented `JustResizable`: layout engine, fraction math, controller, splitter handles (line/grip/none variants), double-tap behaviors (toggle/collapse/reset), full WCAG AA accessibility (Semantics slider role, focus integration, keyboard navigation), and a Neobrutalism preset.
- Implemented `JustCarousel`: `PageView`-based engine with dual-orientation support, infinite virtual looping, `JustCarouselController` with zero-rebuild reactive sync, auto-scroll lifecycle, interactive indicators (dots/line/fraction), slide transitions (slide/scale/fade), desktop trackpad/mouse-wheel pagination, and full keyboard navigation.
- Registered `JustCarouselTheme`/resizable and carousel registry entries, with checksum sync via `tools/generate_checksums.dart`.
- Added the `apps/showcase` app.

### Fixed
- Restored real CLI self-update by decoupling update planning from execution, and bypassed GitHub API rate limits (HTTP 403) by resolving GitHub's web redirect instead of calling the API directly.
- Hardened `install.sh`/`install.ps1` with rate-limit-free redirect resolution, version normalization, and guards against empty tags; added a `validate-tag-version` CI guard ensuring git tags match `Cargo.toml`.
- Replaced the misleading `cargo install justui --force` fallback with the official install scripts and release URLs.
- Fixed premature theme extension pollution and monorepo `dart_target` auto-detection.

## [0.10.0] - 2026-09-01
### Added
- Added OKLCH and HSLuv color engines (pluggable across `packages/tokens`, `packages/core`, and the CLI), with contrast correction for dynamic color generation.
- Implemented theme schemes for spacing, shadows, radius, and typography, and optimized color scale generation.
- Implemented `JustDatePicker`: responsive variant with adaptive mobile sheet and desktop popover, using `OverlayPortal` for positioning and screen-boundary handling.
- Implemented `JustTimePicker`: spinner, dial, and input variants.
- Added multi-device input detection and elastic physics to `JustScrollArea`.
- Added the `justui doctor` command to diagnose Flutter/Dart SDK and project environment health.
- Added SDK constraint parsing from the user's `pubspec.yaml`, a local FVM detector, and environment resolution/fallback logic so the CLI can infer the right `dart_target` automatically.
- Built the regex-based primary-constructor transpiler and integrated it into `add`/`init` (this is what `dart_target: standard` relies on).
- Added the interactive CLI bulk component selector: multi-selection with keyboard handlers, checkbox indicators and a selection counter, a dependency preview panel, and a panic hook + RAII terminal guard for clean TUI teardown on crash.
- Added the `apps/preview` Widgetbook workbench application.

### Changed
- Consolidated component registry structure: unified component style/theme/variant files, modularized prompt functions for I/O injection and testability.
- Expanded CLI command arguments, category filtering, and component management.

## [0.7.8] - 2026-08-20
### Added
- Added the initial Widgetbook preview application scaffold.

### Changed
- Modernized CLI preset commands and redirected their output to stderr.
- Migrated theme extension registration to `.defaults` static properties, and updated the corresponding CLI extraction logic.
- Improved `JustSlider` interactivity: mouse cursors and refined track rendering.

## [0.7.5] - 2026-08-19
### Changed
- Migrated all component and theme constructors to Dart's primary-constructor syntax across the registry.
- Standardized component theme architecture and registry component structure/naming conventions.
- Reorganized the theme file structure and unified typography scheme classes.
- Preserved directory structure during CLI template extraction and simplified import path rewriting.

### Fixed
- Resynced registry components after an accidental component-deletion incident during the registry restandardization.

## [0.7.2] - 2026-08-18
### Fixed
- Improved asset selection logic and added binary format validation during CLI self-update.

## [0.7.1] - 2026-08-18
### Added
- Added the `JustProgressSize` enum.

### Changed
- Pinned the Rust toolchain to `stable` in CI workflows.

## [0.7.0] - 2026-08-18
### Changed
- Version bump across `packages/core`, `packages/tokens`, and `packages/cli` following the 0.6.0 CLI version-sync fix.

## [0.6.0] - 2026-08-18
### Fixed
- Synced CLI package version to `0.6.0` in `Cargo.toml` and pubspec files to ensure `justui version` and `justui upgrade` correctly recognize up-to-date status.

## [0.5.0] - 2026-06-27
### Added
- Integrated modular AI agent skill library with orchestrator, SEO, and domain-specific toolsets.
- Added interactive animated spinners (`indicatif` crate) during registry fetches for `add`, `update`, `diff`, and `list` commands.
- Added a unified download progress bar in the `add` command for multiple component file copy operations.
- Added a detailed, minimalist terminal summary output at the end of the `add` command, displaying copied, updated, or skipped/conflicted files with colored checks and warning symbols.

### Changed
- Replaced heuristic shared component detection with an explicit `"internal": true` flag in the registry index (`index.json`).
- Migrated the security scanning workflow job in CI from `cargo-deny` to `trivy` filesystem container scanning.
- Enabled Git tracking for `Cargo.lock` files across the workspace by removing them from both `.gitignore` configurations.
- Upgraded dependencies in the CLI package (`similar` to 3, `reqwest` to 0.13, `melos` to 8.0.0) and updated GitHub Actions steps to use newer checkout/artifact versions.

## [0.4.0] - 2026-06-15
### Added
- Created repository fundamental documentation files in the root folder.
- Added standard [MIT LICENSE](./LICENSE) for flexible copy-paste code usage.
- Added [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) adhering to the Contributor Covenant v2.1.
- Added [CONTRIBUTING.md](./CONTRIBUTING.md) detailing developer guidelines:
  - FVM and Melos setup process.
  - Strict coding style rules (mandatory **Dart Dot Shorthand / Constructor Shorthands** usage and performance considerations).
  - Registry component formatting and checksum calculation rules.
- Added a comprehensive [README.md](./README.md) explaining JustUI core concepts, component lifecycle, installation, and optimization guidelines.

## [0.3.0] - 2026-06-15
### Added
- Implemented the CLI tool package `just_ui_cli`.
- Added `justui init` command to generate default target directories in `justui.config.yaml`.
- Added `justui list` command to display categorized available registry components.
- Added `justui add` command to copy component files recursively with circular dependency protection using a `visited` set guard.
- Added automated `pubspec.yaml` dependency insertion using safe regex edits and creating a backup (`pubspec.yaml.bak`).
- Added `justui diff` command comparing local files against registry index checksums with a line-by-line fallback printed output on verbose mode (`--verbose` / `-v`).
- Implemented clean unit test coverage utilizing in-memory mocked filesystem.

## [0.2.0] - 2026-06-15
### Added
- Implemented the theming compiler and core package `just_ui_core`.
- Added native Material component theme mappings for automatic integration (AppBar, Cards, Dividers, inputs, buttons) with JustUI design tokens.
- Added dynamic color seeding factory `JustThemeData.fromSeed` from HSL scales with focus border lightness enforcement ensuring WCAG AA contrast ratio compliance ($\ge$ 3.0:1) at runtime.
- Added customizable transition duration and easing curves (`transitionDuration` / `transitionCurve`) parameters inside `JustThemeProvider`.
- Implemented performance-optimized aspect-based rebuilds utilizing `InheritedModel`.
- Added lazy caching on the ThemeData compiler to avoid rebuild recalculation overheads.

## [0.1.0] - 2026-06-15
### Added
- Implemented the primitive token system package `just_ui_tokens`.
- Added compile-time constant token values for HSL color scales, typography text scales (Inter and JetBrains Mono fonts), gap spaces, rounded corner radiuses, and shadow levels.
- Added Accessibility Contrast Auditor (`colors_accessibility.dart`) supporting Relative Luminance and WCAG AA contrast ratio calculations directly on `Color`.
