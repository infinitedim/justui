# Project: JustUI presetTokens refactoring

## Architecture
- **Theme System (`packages/core/lib/src/theme`)**:
  - `JustPresetTokens`: Defines the contract for preset-specific visual values (borders, shadows, radii, press effects, hover decorations, etc.).
  - `DefaultPresetTokens` & `NeobrutalismPresetTokens`: Core implementations of `JustPresetTokens`.
  - Goal: Extend `JustPresetTokens` with helper methods for slider track/thumb, progress stroke/label, separator thickness, tab indicator thickness, focus transition duration, and dropdown curves/durations.
- **Components (`packages/core/lib/src/components`)**:
  - Migrate 26 components to resolve visual styling via `presetTokens` instead of branching on `isNeobrutalism`, `preset == .neobrutalism`, or `JustThemePreset.neobrutalism`.

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | M1: Extend JustPresetTokens | Implement helper methods in `preset_tokens.dart` for Slider, Progress, Separator, Tab Indicator, Focus/Dropdown motion. | None | DONE |
| 2 | M2: Components Batch A | Migrate Slider, Progress, Separator, Tab Indicator, Switch, Radio, Checkbox, Toggle, Skeleton to resolve styles via `presetTokens`. | M1 | IN_PROGRESS |
| 3 | M3: Components Batch B | Migrate Accordion, Badge, Avatar, Avatar Group, Tabs, Scroll Area, Table to resolve styles via `presetTokens`. | M1 | PLANNED |
| 4 | M4: Components Batch C | Migrate Dialog, Sheet, Select, Tooltip, Toast, Input, Sidebar, Bottom Nav, Breadcrumb, Button/IconButton. | M1 | PLANNED |
| 5 | M5: Verification & Audit | Run compiler checks, static analysis, unit tests, and forensic auditor. | M2, M3, M4 | PLANNED |

## Interface Contracts
- Components must query the theme's `presetTokens` (e.g. `context.justTheme.preset.tokens` or similar via `presetTokens` parameter) instead of checking if the preset is neobrutalism.
- `JustPresetTokens` will not import files from `packages/core/lib/src/components` directly to avoid circular dependency loops, or we must use standard types or carefully structured enums. Let's see: `JustSliderSize` and `JustProgressSize` are required in `preset_tokens.dart`. If they are moved/imported, we must make sure no circular dependencies occur.

## Code Layout
- `packages/core/lib/src/theme/preset_tokens.dart` - Preset tokens definition and default/neobrutalism implementations.
- `packages/core/lib/src/components/*` - Visual component implementations.
