# Handoff Report: Extending JustPresetTokens

## 1. Observation

We directly observed and traced the codebase to find how components currently resolve preset-dependent values:

### A. Slider (`packages/core/lib/src/components/slider/just_slider.dart`)
Lines 126-145:
```dart
    final finalEnableHaptic =
        widget.enableHaptic ?? globalTheme?.enableHaptic ?? isNeobrutalism;

    // Resolve size metrics
    final double trackHeight;
    final double thumbSize;
    switch (widget.size) {
      case .sm:
        trackHeight = isNeobrutalism ? 6.0 : 4.0;
        thumbSize = isNeobrutalism ? 16.0 : 14.0;
        break;
      case .md:
        trackHeight = isNeobrutalism ? 10.0 : 6.0;
        thumbSize = isNeobrutalism ? 22.0 : 20.0;
        break;
      case .lg:
        trackHeight = isNeobrutalism ? 14.0 : 8.0;
        thumbSize = isNeobrutalism ? 28.0 : 26.0;
        break;
    }
```
* **Enums**: `JustSliderSize` is defined in `packages/core/lib/src/components/slider/just_slider_style.dart`.
* **Preset values**:
  * Default preset:
    * `enableHaptic` defaults to `false`.
    * Track height: `sm` -> 4.0, `md` -> 6.0, `lg` -> 8.0.
    * Thumb size: `sm` -> 14.0, `md` -> 20.0, `lg` -> 26.0.
  * Neobrutalism preset:
    * `enableHaptic` defaults to `true`.
    * Track height: `sm` -> 6.0, `md` -> 10.0, `lg` -> 14.0.
    * Thumb size: `sm` -> 16.0, `md` -> 22.0, `lg` -> 28.0.

### B. Progress (`packages/core/lib/src/components/progress/just_progress.dart`)
Lines 320-335:
```dart
    double diameter;
    double defaultStrokeWidth;
    switch (widget.size) {
      case .sm:
        diameter = 32.0;
        defaultStrokeWidth = isNeobrutalism ? 3.0 : 2.0;
        break;
      case .md:
        diameter = 48.0;
        defaultStrokeWidth = isNeobrutalism ? 4.0 : 3.0;
        break;
      case .lg:
        diameter = 64.0;
        defaultStrokeWidth = isNeobrutalism ? 5.0 : 4.0;
        break;
    }
```
Lines 296 and 388:
```dart
fontWeight: isNeobrutalism ? .w700 : .w500,
```
* **Enums**: `JustProgressSize` is defined in `packages/core/lib/src/components/progress/just_progress_variants.dart`.
* **Preset values**:
  * Default preset:
    * Stroke width: `sm` -> 2.0, `md` -> 3.0, `lg` -> 4.0.
    * Label font weight: `FontWeight.w500` (`.w500`).
  * Neobrutalism preset:
    * Stroke width: `sm` -> 3.0, `md` -> 4.0, `lg` -> 5.0.
    * Label font weight: `FontWeight.w700` (`.w700`).

### C. Separator (`packages/core/lib/src/components/separator/just_separator.dart`)
Lines 101-104:
```dart
    final resolvedThickness =
        style?.thickness ??
        themeStyle?.thickness ??
        (isNeobrutalism ? 2.0 : thickness);
```
Where `thickness` defaults to `1.0`.
* **Preset values**:
  * Default preset: 1.0.
  * Neobrutalism preset: 2.0.

### D. Tab Indicator (`packages/core/lib/src/components/tabs/just_tab_indicator.dart`)
Lines 52-53:
```dart
        final thickness =
            style?.indicatorThickness ?? (isNeobrutalism ? 4.0 : 2.0);
```
* **Preset values**:
  * Default preset: 2.0.
  * Neobrutalism preset: 4.0.

### E. Transitions & Dropdowns
In `packages/core/lib/src/components/input/just_input.dart` (lines 761-765) and `packages/core/lib/src/components/button/just_icon_button.dart` (lines 320-324):
```dart
                  duration: isNeobrutalism
                      ? customTheme.animations.instant
                      : customTheme.animations.fast,
```
* **Focus transition duration**:
  * Default preset: `animations.fast` (150ms).
  * Neobrutalism preset: `animations.instant` (50ms).

In `packages/core/lib/src/components/select/just_select.dart` (lines 687-704):
```dart
              if (!isNeobrutalism) {
                // Fade and Slide transition for non-neobrutalism
                dropdownContent = TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: customTheme.animations.fast,
                  curve: customTheme.animations.defaultCurve,
                  ...
```
* **Dropdown curves/durations**:
  * Default preset: duration = `animations.fast`, curve = `animations.defaultCurve`.
  * Neobrutalism preset: duration = `Duration.zero` (fully instant, omitting fade/slide animations), curve = `Curves.linear`.

---

## 2. Logic Chain

1. **Preset Abstraction Principle**:
   Components should query all preset-specific style choices from `JustPresetTokens` instead of branching internally on `theme.preset == JustThemePreset.neobrutalism`.
2. **Helper Method Encapsulation**:
   Based on the observed values, we need to extract:
   * Slider track height and thumb size (dependent on `JustSliderSize`) and the default haptic enable flag.
   * Progress stroke width (dependent on `JustProgressSize`) and the label font weight.
   * Separator thickness.
   * Tab indicator thickness.
   * Focus transition duration, dropdown animation duration, and dropdown transition curve (dependent on `JustMotionProfile`).
3. **Avoiding Circular Dependencies**:
   * The `JustSliderSize` and `JustProgressSize` enums are defined in style/variant files (`just_slider_style.dart` and `just_progress_variants.dart`) that do not import the theme provider or theme data package. They are leaf nodes in the codebase.
   * Therefore, `preset_tokens.dart` can import these files using direct relative imports without creating any dependency cycles.
   * Using specific `show` clauses ensures that only the needed enums are visible, and we must not export them from `preset_tokens.dart` or `just_ui_core.dart` to maintain public barrel isolation.
4. **Code Styling Alignment**:
   In `DefaultPresetTokens` and `NeobrutalismPresetTokens` implementations, we should use dot shorthand syntax (e.g. `.sm`, `.md`, `.lg`) for enum values inside switch statements, matching the codebase styling rules.

---

## 3. Caveats

- We assumed that `Duration.zero` is the desired dropdown transition duration for Neobrutalism to completely bypass the fade/slide transition, aligning with its visual style (which currently skips the animated wrapper block).
- We assumed that `JustDuration.instant` (50ms) is the desired focus transition duration for Neobrutalism, which matches the existing implementations in `JustInput` and `JustIconButton`.

---

## 4. Conclusion

We recommend adding the following helper methods to `JustPresetTokens` and implementing them in `DefaultPresetTokens` and `NeobrutalismPresetTokens`.

### A. Imports to Add to `preset_tokens.dart`
```dart
import '../components/slider/just_slider_style.dart' show JustSliderSize;
import '../components/progress/just_progress_variants.dart' show JustProgressSize;
```

### B. Signatures to Add to `JustPresetTokens`
```dart
  /// Resolves the height of a slider track based on [size].
  double resolveSliderTrackHeight(JustSliderSize size);

  /// Resolves the size (diameter/side length) of a slider thumb based on [size].
  double resolveSliderThumbSize(JustSliderSize size);

  /// Whether haptic feedback is enabled by default for slider interactions.
  bool get enableSliderHapticDefault;

  /// Resolves the stroke width for circular progress indicators based on [size].
  double resolveProgressStrokeWidth(JustProgressSize size);

  /// The font weight for progress label text.
  FontWeight get progressLabelFontWeight;

  /// The default thickness for separators.
  double get separatorThickness;

  /// The default thickness for tab indicators.
  double get tabIndicatorThickness;

  /// Resolves the animation duration for focus transitions.
  Duration resolveFocusTransitionDuration(JustMotionProfile animations);

  /// Resolves the animation duration for dropdown menu appearances.
  ///
  /// Returns [Duration.zero] for presets that show dropdowns instantly without transition.
  Duration resolveDropdownDuration(JustMotionProfile animations);

  /// Resolves the animation curve for dropdown menu transitions.
  Curve resolveDropdownCurve(JustMotionProfile animations);
```

### C. Implementation for `DefaultPresetTokens`
```dart
  @override
  double resolveSliderTrackHeight(JustSliderSize size) {
    return switch (size) {
      .sm => 4.0,
      .md => 6.0,
      .lg => 8.0,
    };
  }

  @override
  double resolveSliderThumbSize(JustSliderSize size) {
    return switch (size) {
      .sm => 14.0,
      .md => 20.0,
      .lg => 26.0,
    };
  }

  @override
  bool get enableSliderHapticDefault => false;

  @override
  double resolveProgressStrokeWidth(JustProgressSize size) {
    return switch (size) {
      .sm => 2.0,
      .md => 3.0,
      .lg => 4.0,
    };
  }

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
  Duration resolveDropdownDuration(JustMotionProfile animations) =>
      animations.fast;

  @override
  Curve resolveDropdownCurve(JustMotionProfile animations) =>
      animations.defaultCurve;
```

### D. Implementation for `NeobrutalismPresetTokens`
```dart
  @override
  double resolveSliderTrackHeight(JustSliderSize size) {
    return switch (size) {
      .sm => 6.0,
      .md => 10.0,
      .lg => 14.0,
    };
  }

  @override
  double resolveSliderThumbSize(JustSliderSize size) {
    return switch (size) {
      .sm => 16.0,
      .md => 22.0,
      .lg => 28.0,
    };
  }

  @override
  bool get enableSliderHapticDefault => true;

  @override
  double resolveProgressStrokeWidth(JustProgressSize size) {
    return switch (size) {
      .sm => 3.0,
      .md => 4.0,
      .lg => 5.0,
    };
  }

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
  Duration resolveDropdownDuration(JustMotionProfile animations) =>
      Duration.zero;

  @override
  Curve resolveDropdownCurve(JustMotionProfile animations) =>
      Curves.linear;
```

---

## 5. Verification Method

To verify these recommendations:
1. **Static Analysis & Lint Checks**:
   Check if adding these imports and overrides compiles clean:
   ```bash
   export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/core
   ```
2. **Reviewing Code Paths**:
   Verify that `just_slider.dart`, `just_progress.dart`, `just_separator.dart`, `just_tab_indicator.dart`, and `just_select.dart` can import and call these helper methods on `JustPresetTokens` directly.
3. **Circular Import Verification**:
   Inspect the dependency graph to confirm that no file inside `theme/` or component style/variant files has cycles.
