# Handoff Report: Milestone 1 — Explorer 1

## 1. Observation
From inspecting the codebase, the following locations and behaviors were observed:
- **`JustPresetTokens` and its implementations** are located in `packages/core/lib/src/theme/preset_tokens.dart`.
- **Slider Component**:
  - Located in `packages/core/lib/src/components/slider/just_slider.dart`.
  - In `_JustSliderState.build` (lines 129–145), the track height and thumb size are resolved based on `size` (enum `JustSliderSize`) and `isNeobrutalism`:
    - `.sm`: `trackHeight = isNeobrutalism ? 6.0 : 4.0`, `thumbSize = isNeobrutalism ? 16.0 : 14.0`.
    - `.md`: `trackHeight = isNeobrutalism ? 10.0 : 6.0`, `thumbSize = isNeobrutalism ? 22.0 : 20.0`.
    - `.lg`: `trackHeight = isNeobrutalism ? 14.0 : 8.0`, `thumbSize = isNeobrutalism ? 28.0 : 26.0`.
  - Haptic feedback enablement (lines 125–127) defaults to `isNeobrutalism`.
  - `JustSliderSize` is defined in `packages/core/lib/src/components/slider/just_slider_style.dart`.
- **Progress Component**:
  - Located in `packages/core/lib/src/components/progress/just_progress.dart`.
  - In `_JustProgressState._buildCircular` (lines 320–335), the stroke width is resolved based on `size` (enum `JustProgressSize`) and `isNeobrutalism`:
    - `.sm`: `defaultStrokeWidth = isNeobrutalism ? 3.0 : 2.0`.
    - `.md`: `defaultStrokeWidth = isNeobrutalism ? 4.0 : 3.0`.
    - `.lg`: `defaultStrokeWidth = isNeobrutalism ? 5.0 : 4.0`.
  - In `_buildLinear` (line 296) and `_buildCircular` (line 388), the label font weight is resolved as `isNeobrutalism ? FontWeight.w700 : FontWeight.w500`.
  - `JustProgressSize` is defined in `packages/core/lib/src/components/progress/just_progress_variants.dart`.
- **Separator Component**:
  - Located in `packages/core/lib/src/components/separator/just_separator.dart`.
  - In `JustSeparator.build` (lines 101–104), the thickness defaults to `isNeobrutalism ? 2.0 : thickness` (where `thickness` parameter defaults to `1.0`).
- **Tabs Component**:
  - Located in `packages/core/lib/src/components/tabs/just_tabs.dart` and `just_tab_indicator.dart`.
  - In `JustTabIndicator.build` (lines 52–53, 119–120), the indicator thickness defaults to `isNeobrutalism ? 4.0 : 2.0`.
- **Select Component**:
  - Located in `packages/core/lib/src/components/select/just_select.dart`.
  - In `JustSelect`'s dropdown transition building (lines 687–704), non-neobrutalism dropdowns animate with a duration of `customTheme.animations.fast` and curve of `customTheme.animations.defaultCurve`. Neobrutalism dropdowns do not animate (resolved immediately).
- **Focus Transitions**:
  - In `just_button.dart` (lines 555–559), the state/focus animation duration is resolved using `presetTokens.showsDefaultBorder ? customTheme.animations.instant : customTheme.animations.fast`.

---

## 2. Logic Chain
To transition these component-specific preset branches into the generic `JustPresetTokens` contract, we establish the following logic:
1. **Slider Values**:
   - Create `resolveSliderTrackHeight(JustSliderSize size)` returning `4.0`/`6.0`/`8.0` for default and `6.0`/`10.0`/`14.0` for neobrutalism.
   - Create `resolveSliderThumbSize(JustSliderSize size)` returning `14.0`/`20.0`/`26.0` for default and `16.0`/`22.0`/`28.0` for neobrutalism.
   - Create `enableSliderHapticDefault` returning `false` for default and `true` for neobrutalism.
2. **Progress Values**:
   - Create `resolveProgressStrokeWidth(JustProgressSize size)` returning `2.0`/`3.0`/`4.0` for default and `3.0`/`4.0`/`5.0` for neobrutalism.
   - Create `progressLabelFontWeight` returning `FontWeight.w500` for default and `FontWeight.w700` for neobrutalism.
3. **Separator Values**:
   - Create `separatorThickness` returning `1.0` for default and `2.0` for neobrutalism.
4. **Tabs Values**:
   - Create `tabIndicatorThickness` returning `2.0` for default and `4.0` for neobrutalism.
5. **Transitions & Durations**:
   - Create `resolveFocusTransitionDuration(JustMotionProfile animations)` returning `animations.fast` for default and `animations.instant` for neobrutalism.
   - Create `resolveDropdownTransitionDuration(JustMotionProfile animations)` returning `animations.fast` for default and `Duration.zero` for neobrutalism.
   - Create `resolveDropdownTransitionCurve(JustMotionProfile animations)` returning `animations.defaultCurve` for default and `Curves.linear` for neobrutalism.
6. **Circular Dependency Avoidance**:
   - Component files import the theme provider and theme data, which depends on `preset_tokens.dart`.
   - If `preset_tokens.dart` imports the components' main files, an import cycle occurs (`preset_tokens.dart` -> `just_slider.dart` -> `theme_provider.dart` -> `preset_tokens.dart`).
   - To prevent this, `preset_tokens.dart` should import ONLY the pure "leaf" style/variant files (`just_slider_style.dart` and `just_progress_variants.dart`) that declare the enums. Since these files only depend on `package:flutter/widgets.dart` and contain no theme dependencies, the import graph remains a strict DAG.

---

## 3. Caveats
- No caveats identified. All components in scope were successfully analyzed, and their preset resolutions were mapped out cleanly.

---

## 4. Conclusion
We can extend `JustPresetTokens` cleanly with 10 helper methods and getters that capture the visual and motion personality of each preset. By importing the target enums via direct relative paths to the component style/variant files, we guarantee zero circular dependencies.

### Proposed Additions in `JustPresetTokens`

```dart
// Imports to add at the top of preset_tokens.dart:
import '../components/slider/just_slider_style.dart' show JustSliderSize;
import '../components/progress/just_progress_variants.dart' show JustProgressSize;

// Add inside `abstract class JustPresetTokens`:

  /// Resolves the track height for [JustSlider] based on the slider size.
  double resolveSliderTrackHeight(JustSliderSize size);

  /// Resolves the thumb size (diameter) for [JustSlider] based on the slider size.
  double resolveSliderThumbSize(JustSliderSize size);

  /// Default setting for whether [JustSlider] triggers haptic feedback on changes.
  bool get enableSliderHapticDefault;

  /// Resolves the default stroke width for circular [JustProgress] based on the size.
  double resolveProgressStrokeWidth(JustProgressSize size);

  /// Resolves the font weight for the [JustProgress] text labels.
  FontWeight get progressLabelFontWeight;

  /// The default thickness for [JustSeparator] lines.
  double get separatorThickness;

  /// The default thickness for [JustTabs] indicators.
  double get tabIndicatorThickness;

  /// Resolves the animation duration for focus state transitions.
  Duration resolveFocusTransitionDuration(JustMotionProfile animations);

  /// Resolves the duration for dropdown entrance transitions (e.g. in [JustSelect]).
  /// Returns [Duration.zero] if the preset does not animate the dropdown entrance.
  Duration resolveDropdownTransitionDuration(JustMotionProfile animations);

  /// Resolves the animation curve for dropdown entrance transitions.
  Curve resolveDropdownTransitionCurve(JustMotionProfile animations);
```

### Proposed Additions in `DefaultPresetTokens`

```dart
  @override
  double resolveSliderTrackHeight(JustSliderSize size) => switch (size) {
        .sm => 4.0,
        .md => 6.0,
        .lg => 8.0,
      };

  @override
  double resolveSliderThumbSize(JustSliderSize size) => switch (size) {
        .sm => 14.0,
        .md => 20.0,
        .lg => 26.0,
      };

  @override
  bool get enableSliderHapticDefault => false;

  @override
  double resolveProgressStrokeWidth(JustProgressSize size) => switch (size) {
        .sm => 2.0,
        .md => 3.0,
        .lg => 4.0,
      };

  @override
  FontWeight get progressLabelFontWeight => FontWeight.w500;

  @override
  double get separatorThickness => 1.0;

  @override
  double get tabIndicatorThickness => 2.0;

  @override
  Duration resolveFocusTransitionDuration(JustMotionProfile animations) =>
      animations.fast;

  @override
  Duration resolveDropdownTransitionDuration(JustMotionProfile animations) =>
      animations.fast;

  @override
  Curve resolveDropdownTransitionCurve(JustMotionProfile animations) =>
      animations.defaultCurve;
```

### Proposed Additions in `NeobrutalismPresetTokens`

```dart
  @override
  double resolveSliderTrackHeight(JustSliderSize size) => switch (size) {
        .sm => 6.0,
        .md => 10.0,
        .lg => 14.0,
      };

  @override
  double resolveSliderThumbSize(JustSliderSize size) => switch (size) {
        .sm => 16.0,
        .md => 22.0,
        .lg => 28.0,
      };

  @override
  bool get enableSliderHapticDefault => true;

  @override
  double resolveProgressStrokeWidth(JustProgressSize size) => switch (size) {
        .sm => 3.0,
        .md => 4.0,
        .lg => 5.0,
      };

  @override
  FontWeight get progressLabelFontWeight => FontWeight.w700;

  @override
  double get separatorThickness => 2.0;

  @override
  double get tabIndicatorThickness => 4.0;

  @override
  Duration resolveFocusTransitionDuration(JustMotionProfile animations) =>
      animations.instant;

  @override
  Duration resolveDropdownTransitionDuration(JustMotionProfile animations) =>
      Duration.zero;

  @override
  Curve resolveDropdownTransitionCurve(JustMotionProfile animations) =>
      Curves.linear;
```

---

## 5. Verification Method
- Independent verification can be performed by running static analysis on the core package to ensure no compile errors or cycle reports:
  ```bash
  export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/core
  ```
- Run local unit tests in the user-land environment to verify that nothing breaks:
  ```bash
  flutter test packages/core
  ```
