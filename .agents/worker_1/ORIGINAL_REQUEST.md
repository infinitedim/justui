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

## 2026-07-01T12:30:36Z
You are a specialist developer subagent. Your task is to implement the Showcase horizontal infinite marquee using AnimationController and update the Next.js homepage layout.

Follow these strict codebase constraints from AGENTS.md:
- Offline environment: use local packages.
- Always use dot shorthand constructors for standard parameters of Flutter classes when their type is statically known (e.g. `padding: .all(spacing.md)`, `borderRadius: .zero` or `.all(radius.md)`).
- DO NOT CHEAT: All implementations must be genuine. Do not hardcode test results or fabricate outputs.

### Tasks to Perform:

1. **Implement `ShowcaseMarquee`**:
   - Location: `apps/showcase/lib/widgets/showcase_marquee.dart`.
   - Use `AnimationController` to animate the scrolling from right to left smoothly without jerking.
   - The marquee must contain two identical copies of a component strip side-by-side (`Row`) translated by `-_controller.value * stripWidth`.
   - Measure the `stripWidth` dynamically using a `GlobalKey` in a post-frame callback (`addPostFrameCallback`).
   - The component strip must contain 5 categories/groups separated by a vertical separator (`_Separator`):
     - **Buttons**: Primary, Secondary (with text color `theme.colors.textPrimary`), Danger, and Ghost buttons.
     - **Badges**: Success (outline/filled/soft), Warning, Error, New.
     - **Avatars**: 3 avatars of sizes sm, md, lg.
     - **Controls**: `_InteractiveControls` stateful widget (Switch, Checkbox, and 2 Radio buttons laid out horizontally in a `Row` to fit within height limits).
     - **Input**: `JustInput` (Username) wrapped in a `SizedBox(width: 200)`.
   - Implement `_GroupCard` for each category:
     - Under `neobrutalism` preset: 2.5px border (`color: theme.colors.textPrimary`), `.zero` border radius, solid 4x4 shadow (`BoxShadow(color: theme.colors.textPrimary, offset: const Offset(4.0, 4.0), blurRadius: 0.0, spreadRadius: 0.0)`).
     - Under `default` preset: 1.0px border (`color: theme.colors.borderDefault`), `.all(theme.radius.md)` border radius, soft shadow or no shadow.
     - Set a fixed height (e.g., 120-130px) for `_GroupCard` to keep them uniform and align them perfectly.
   - Implement `_Separator`:
     - Under `neobrutalism` preset: width 2.5px, color `theme.colors.textPrimary`.
     - Under `default` preset: width 1.0px, color `theme.colors.borderDefault`.
     - Height: e.g. 64px or matching card height.

2. **Update height reporting & main display**:
   - In `apps/showcase/lib/height_reporter.dart`: modify it to use a fixed height of 180px or report a fixed height.
   - In `apps/showcase/lib/main.dart`:
     - Set the body or main layout container height to a fixed 180px.
     - Replace `ShowcaseGrid` with `ShowcaseMarquee`.
     - Ensure the theme postMessage receiver is maintained so light/dark mode transitions work.

3. **Update Next.js docs site integration & homepage layout**:
   - In `apps/docs/src/components/showcase-frame.tsx`:
     - Simplify the iframe to use a fixed height of 180px.
     - Remove the postMessage height listener and dynamic height state.
     - Ensure the light/dark mode sender postMessage remains active.
   - In `apps/docs/src/app/[lang]/page.tsx`:
     - Center the hero section text full-width (remove the grid columns layout for hero).
     - Place the `<ShowcaseFrame />` in a full-width section beneath the hero section with a `border-y` (top/bottom borders).

4. **Verify and Compile**:
   - Build the Flutter Web showcase app: `bun --cwd apps/docs run build:showcase`
   - Lint the showcase: `export HOME=/home/yourblooo/development/justui/.home && dart analyze apps/showcase`
   - Build Next.js docs: `bun --cwd apps/docs run build`
   - Run type checks: `bun --cwd apps/docs run type-check`

Provide a detailed handoff report of what you did and the verification results.
