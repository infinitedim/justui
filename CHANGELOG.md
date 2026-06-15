# Changelog

All notable changes to the JustUI monorepo will be documented in this file.

---

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
