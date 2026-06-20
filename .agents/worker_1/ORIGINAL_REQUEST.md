## 2026-06-20T04:28:49Z
You are a documentation and technical writer worker. Your task is to generate a comprehensive architectural documentation and code audit report for the entire JustUI monorepo (covering the just_ui_tokens, just_ui_core, and just_ui_cli packages) based on the findings documented in /home/yourblooo/development/justui/.agents/explorer_1/handoff.md.

You must write this report directly to the file:
/home/yourblooo/development/justui/docs/justui_architectural_audit.md

Your generated report must be exceptionally detailed, structured, and contain NO placeholders or TBD tags. It must include the following sections and contents:

1. Title: JustUI Monorepo Architectural Documentation & Code Audit Report
2. Introduction: Briefly explain the philosophy of JustUI (zero-dependency, copy-paste model inspired by shadcn/ui).
3. Design Tokens & Accessibility (packages/just_ui_tokens):
   - Identify the primary visual primitive files, classes, and constants (such as breakpoint values, color scales, semantic keys, radius, shadows, spacing, typography, and motion profiles/durations).
   - Detail the accessibility contrast check engine in colors_accessibility.dart. Document and explain the relative luminance formula (L = 0.2126 * R + 0.7152 * G + 0.0722 * B, including linearized channel calculations) and contrast ratio calculations. Detail how isAccessibleWith aligns with WCAG AA compliance (4.5:1 for normal text, 3.0:1 for large text/components). Provide exact code snippets or implementation patterns.
4. Theme Engine & Provider (packages/just_ui_core):
   - Explain the aspect-based rebuild optimization. Detail InheritedModel<JustThemeAspect> and JustThemeProvider in lib/src/theme/theme_provider.dart and theme_aspects.dart. Showcase the context extensions (e.g. context.justColors, context.justTypo, context.justSpacing) and how they prevent unnecessary rebuilds.
   - Detail the lazy-caching of Material ThemeData via .toThemeData() and how the cache invalidation is handled.
   - Explain the HSL-based dynamic lightness adjustment and seeding algorithm (JustThemeData.fromSeed and _makeAccessible in colors_dynamic.dart) that enforces contrast compliance with background.
   - Highlight the best practices for theme consumption: when to use registering extensions vs non-registering context.readTheme().
5. Component Catalog & Scaffolding Workflow:
   - List all component subdirectories under packages/just_ui_core/lib/src/components.
   - Audit and describe their implementation patterns (such as separation of concerns in a 4-file bundle, specific aspect subscriptions, minimum 48px touch targets, accessibility semantics, and focus/interactive state handling).
   - Detail the CLI architecture in just_ui_cli (structure, config parse, command registry).
   - Detail the copy-paste scaffolding workflow (scaffolding command execution, security checksum SHA-256 validation, conflict resolution overrides, recursive component dependency resolution, and modifying user's pubspec.yaml).
6. Development & Sandbox Constraints:
   - Detail the sandbox constraints: offline package configuration, HOME environment override for Dart telemetry, static analysis commands, and testing procedures.

Ensure you write the file to the exact path. Keep all technical details precise, citing exact file names, classes, and methods.
