# Scope: Milestone 2 — Components Batch A Migration

## Architecture
- **Theme System**:
  - `JustPresetTokens` contains the dynamic helper methods (e.g. `resolveSliderTrackHeight`, `resolveSliderThumbSize`, `sliderHapticDefault`, `resolveProgressStrokeWidth`, `progressLabelFontWeight`, `resolveSeparatorThickness`, `tabIndicatorThickness`, `resolveFocusTransitionDuration`, `resolveDropdownDuration`, `resolveDropdownCurve`).
- **Goal**:
  - Migrate the following components in `packages/core/lib/src/components/` to resolve visual styling via `presetTokens` instead of hardcoding `isNeobrutalism` or checking `preset == .neobrutalism`:
    - Slider (`slider/just_slider.dart`)
    - Progress (`progress/just_progress.dart`)
    - Separator (`separator/just_separator.dart`)
    - Tab Indicator (`tabs/just_tab_indicator.dart`)
    - Switch (`switch/just_switch.dart`)
    - Radio (`radio/just_radio.dart`)
    - Checkbox (`checkbox/just_checkbox.dart`)
    - Toggle (`toggle/just_toggle.dart`)
    - Skeleton (`skeleton/just_skeleton.dart`)
  - Ensure any private helper methods/widgets that take `isNeobrutalism` parameters are updated to accept `presetTokens` or context-derived preset tokens instead.

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | M2.1: Explore Batch A | Map occurrences of `isNeobrutalism` in the 9 components and formulate migration strategies. | None | DONE |
| 2 | M2.2: Implement migration | Refactor all 9 components. | M2.1 | IN_PROGRESS |
| 3 | M2.3: Verification & Review | Run static analysis and reviews to ensure correctness and styling preservation. | M2.2 | PLANNED |

## Code Layout
- `packages/core/lib/src/components/slider/just_slider.dart`
- `packages/core/lib/src/components/progress/just_progress.dart`
- `packages/core/lib/src/components/separator/just_separator.dart`
- `packages/core/lib/src/components/tabs/just_tab_indicator.dart`
- `packages/core/lib/src/components/switch/just_switch.dart`
- `packages/core/lib/src/components/radio/just_radio.dart`
- `packages/core/lib/src/components/checkbox/just_checkbox.dart`
- `packages/core/lib/src/components/toggle/just_toggle.dart`
- `packages/core/lib/src/components/skeleton/just_skeleton.dart`
