## 2026-07-01T10:25:47Z
You are a team worker. Your task is to implement the Component Migration (Batch A) for JustUI.

Your working directory is: /home/yourblooo/development/justui/.agents/worker_m2_batch_a/

Detailed analysis and mappings have been prepared by the Explorers:
- Explorer 1 Report: /home/yourblooo/development/justui/.agents/explorer_m2_batch_a_1/analysis.md
- Explorer 2 Report: /home/yourblooo/development/justui/.agents/explorer_m2_batch_a_2/analysis.md
- Explorer 3 Report: /home/yourblooo/development/justui/.agents/explorer_m2_batch_a_3/analysis.md

Your objectives:
1. Extend `JustPresetTokens`, `DefaultPresetTokens`, and `NeobrutalismPresetTokens` in `packages/core/lib/src/theme/preset_tokens.dart` to add the properties:
   - `selectionHapticDefault` (getter returning false for Default, true for Neobrutalism)
   - `usePulsingSkeleton` (getter returning false for Default, true for Neobrutalism)
2. Refactor the 9 components to resolve styling via `presetTokens` instead of checking `preset == .neobrutalism` or hardcoded neobrutalism properties:
   - Slider (`slider/just_slider.dart`)
   - Progress (`progress/just_progress.dart`)
   - Separator (`separator/just_separator.dart`)
   - Tab Indicator (`tabs/just_tab_indicator.dart`)
   - Switch (`switch/just_switch.dart`)
   - Radio (`radio/just_radio.dart`)
   - Checkbox (`checkbox/just_checkbox.dart`)
   - Toggle (`toggle/just_toggle.dart`)
   - Skeleton (`skeleton/just_skeleton.dart`)
3. Follow the strict code styling in `packages/core/` — specifically DO NOT change the existing dot shorthand constructors (e.g. `.all(...)`, `.symmetric(...)`) to verbose forms. Maintain formatting.
4. Run static analysis and the component unit tests to verify:
   ```bash
   export HOME=/home/yourblooo/development/justui/.home
   dart analyze packages/core
   flutter test packages/core/test/components/just_switch_test.dart
   flutter test packages/core/test/components/just_radio_test.dart
   flutter test packages/core/test/components/just_checkbox_test.dart
   flutter test packages/core/test/components/just_skeleton_test.dart
   flutter test packages/core/test/theme_test.dart
   ```
5. Document all changes and tests results in your handoff.md file, and notify the parent when done.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
