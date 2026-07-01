# Scope: Milestone 1 — Extend JustPresetTokens

## Architecture
- **Theme System (`packages/core/lib/src/theme`)**:
  - `JustPresetTokens`: Defines the contract for preset-specific visual values.
  - `DefaultPresetTokens` & `NeobrutalismPresetTokens`: Core implementations of `JustPresetTokens`.
  - Goal: Extend `JustPresetTokens` with helper methods for:
    - Slider track height & thumb size & haptic default
    - Progress stroke width & label font weight
    - Separator thickness
    - Tab indicator thickness
    - Focus transition duration & Dropdown curves/durations
  - Required imports: enums from components (`JustSliderSize` and `JustProgressSize`) while avoiding circular dependencies.

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | M1.1: Explore preset_tokens.dart | Analyze preset_tokens.dart and target helper methods. | None | DONE |
| 2 | M1.2: Implement helpers | Implement the new methods in `preset_tokens.dart`. | M1.1 | DONE |
| 3 | M1.3: Verification & Review | Review and verify the additions. | M1.2 | DONE |

## Code Layout
- `packages/core/lib/src/theme/preset_tokens.dart`
