# Handoff Report: Extending JustPresetTokens

## 1. Observation

In the current codebase, several components contain explicit checks for `preset == JustThemePreset.neobrutalism` (or a local boolean `isNeobrutalism`) to resolve visual and behavioral properties.

### A. Slider (`packages/core/lib/src/components/slider/just_slider.dart`)
1. **Haptic Feedback Default**:
   ```dart
   // Line 126-127
   final finalEnableHaptic =
       widget.enableHaptic ?? globalTheme?.enableHaptic ?? isNeobrutalism;
   ```
2. **Track Height and Thumb Size**:
   ```dart
   // Line 130-145
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

### B. Progress (`packages/core/lib/src/components/progress/just_progress.dart`)
1. **Stroke Width (Circular Progress)**:
   ```dart
   // Line 322-335
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
2. **Label Font Weight**:
   ```dart
   // Line 296 (Linear progress) & Line 388 (Circular progress)
   fontWeight: isNeobrutalism ? .w700 : .w500,
   ```

### C. Separator (`packages/core/lib/src/components/separator/just_separator.dart`)
1. **Separator Thickness**:
   ```dart
   // Line 101-104
   final resolvedThickness =
       style?.thickness ??
       themeStyle?.thickness ??
       (isNeobrutalism ? 2.0 : thickness);
   ```

### D. Tabs (`packages/core/lib/src/components/tabs/just_tab_indicator.dart`)
1. **Tab Indicator Line Thickness**:
   ```dart
   // Line 52-53 & Line 119-120
   final thickness =
       style?.indicatorThickness ?? (isNeobrutalism ? 4.0 : 2.0);
   ```

### E. Focus and Dropdown Transition (`packages/core/lib/src/components/input/just_input.dart` & `packages/core/lib/src/components/select/just_select.dart`)
1. **Focus State Container Transition Duration**:
   ```dart
   // packages/core/lib/src/components/input/just_input.dart Line 761-764
   return AnimatedContainer(
     duration: isNeobrutalism
         ? theme.animations.instant
         : theme.animations.fast,
   ```
2. **Dropdown Menu Transitions (Slide / Fade)**:
   ```dart
   // packages/core/lib/src/components/select/just_select.dart Line 687-704
   if (!isNeobrutalism) {
     // Fade and Slide transition for non-neobrutalism
     dropdownContent = TweenAnimationBuilder<double>(
       tween: Tween(begin: 0.0, end: 1.0),
       duration: customTheme.animations.fast,
       curve: customTheme.animations.defaultCurve,
       builder: (context, val, child) {
         return Opacity(
           opacity: val,
           child: Transform.translate(
             offset: Offset(0, (1 - val) * 10),
             child: child,
           ),
         );
       },
       child: dropdownContent,
     );
   }
   ```

---

## 2. Logic Chain

1. **Slider Track Height, Thumb Size, & Haptic Feedback**:
   - Explicit branching on `isNeobrutalism` is used to determine `trackHeight` and `thumbSize` based on `JustSliderSize` (sm, md, lg).
   - In `Default` preset: trackHeight values are `4.0, 6.0, 8.0` and thumbSize values are `14.0, 20.0, 26.0`.
   - In `Neobrutalism` preset: trackHeight values are `6.0, 10.0, 14.0` and thumbSize values are `16.0, 22.0, 28.0`.
   - The default haptic status resolves to `isNeobrutalism` (`true` for Neobrutalism, `false` for Default).
   - To abstract this, `JustPresetTokens` should expose:
     - `double resolveSliderTrackHeight(JustSliderSize size)`
     - `double resolveSliderThumbSize(JustSliderSize size)`
     - `bool get sliderHapticDefault`

2. **Progress Stroke Width & Label Font Weight**:
   - The default stroke width for circular progress indicators branches on `isNeobrutalism` for each `JustProgressSize`.
   - `Default` stroke widths: `.sm -> 2.0`, `.md -> 3.0`, `.lg -> 4.0`.
   - `Neobrutalism` stroke widths: `.sm -> 3.0`, `.md -> 4.0`, `.lg -> 5.0`.
   - The percentage/custom label text font weight uses `.w700` under Neobrutalism and `.w500` under Default.
   - To abstract this, `JustPresetTokens` should expose:
     - `double resolveProgressStrokeWidth(JustProgressSize size)`
     - `FontWeight get progressLabelFontWeight`

3. **Separator Thickness**:
   - Separator lines fall back to a thickness of `2.0` under Neobrutalism, and the user-specified thickness (default `1.0`) under Default.
   - To abstract this, `JustPresetTokens` should expose:
     - `double resolveSeparatorThickness(double thickness)`

4. **Tab Indicator Thickness**:
   - Underline tab indicators default to a thickness of `4.0` under Neobrutalism and `2.0` under Default.
   - To abstract this, `JustPresetTokens` should expose:
     - `double get tabIndicatorThickness`

5. **Focus Transition Duration & Dropdown Curves/Durations**:
   - High-responsiveness (snappy/instant) transitions are characteristic of Neobrutalism. Focus and hover decorations animate with `animations.instant` under Neobrutalism and `animations.fast` under Default.
   - Select dropdown overlay fades/slides open using `animations.fast` and `animations.defaultCurve` under Default, whereas Neobrutalism should skip this animation or run it instantly (using `animations.instant`).
   - To abstract this, `JustPresetTokens` should expose:
     - `Duration resolveFocusTransitionDuration(JustMotionProfile animations)`
     - `Duration resolveDropdownDuration(JustMotionProfile animations)`
     - `Curve resolveDropdownCurve(JustMotionProfile animations)`

6. **Dependency Management & Circular Dependency Avoidance**:
   - `JustSliderSize` and `JustProgressSize` are defined in `packages/core/lib/src/components/slider/just_slider_style.dart` and `packages/core/lib/src/components/progress/just_progress_variants.dart` respectively.
   - These style/variant files are leaf nodes in the internal dependency tree (they only import basic Flutter widget classes; they do *not* import `preset_tokens.dart`, `theme_data.dart`, or `theme_provider.dart`).
   - Therefore, importing these files in `packages/core/lib/src/theme/preset_tokens.dart` via relative imports is 100% safe and guarantees that no import cycle is formed.
   - To follow the "Theming Kernel Barrel Isolation" (Rule 8 in AGENTS.md), these enums must *not* be exported from `packages/core/lib/just_ui_core.dart`.

---

## 3. Caveats

- **Dropdown Animations**: Currently, `just_select.dart` completely bypasses the `TweenAnimationBuilder` using `if (!isNeobrutalism)`. When converting this code to use the new tokens, the check should be rewritten to apply the animation for all presets, letting the preset dictate the animation duration. Under Neobrutalism, a duration of `animations.instant` (50ms) is near-instant, but if an absolute skip is required, `Duration.zero` can be returned.
- **Other Components**: This investigation only covers the 5 requested components (slider, progress, separator, tabs, select). Other components might have similar patterns that should be migrated in subsequent milestones.

---

## 4. Conclusion

We can successfully extend `JustPresetTokens` with the proposed helper methods to fully isolate component rendering from specific preset conditions. 

### Recommended Additions to `preset_tokens.dart`

```dart
// Imports to add at the top of packages/core/lib/src/theme/preset_tokens.dart:
import '../components/slider/just_slider_style.dart';
import '../components/progress/just_progress_variants.dart';
```

#### A. Interface Contract (`JustPresetTokens` class)

```dart
  /// Resolves the slider track height based on the physical size classification.
  double resolveSliderTrackHeight(JustSliderSize size);

  /// Resolves the slider thumb size based on the physical size classification.
  double resolveSliderThumbSize(JustSliderSize size);

  /// Default setting for enabling haptic feedback on slider interactions.
  bool get sliderHapticDefault;

  /// Resolves the progress indicator's stroke width (for circular progress).
  double resolveProgressStrokeWidth(JustProgressSize size);

  /// Resolves the font weight for progress percentage or custom labels.
  FontWeight get progressLabelFontWeight;

  /// Resolves the separator thickness.
  double resolveSeparatorThickness(double thickness);

  /// Default thickness of the active tab indicator line.
  double get tabIndicatorThickness;

  /// Resolves the animation duration for focus ring state transitions.
  Duration resolveFocusTransitionDuration(JustMotionProfile animations);

  /// Resolves the animation duration for dropdown open/close transitions.
  Duration resolveDropdownDuration(JustMotionProfile animations);

  /// Resolves the easing curve for dropdown transitions.
  Curve resolveDropdownCurve(JustMotionProfile animations);
```

#### B. Implementation in `DefaultPresetTokens`

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
  bool get sliderHapticDefault => false;

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
  double resolveSeparatorThickness(double thickness) => thickness;

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

#### C. Implementation in `NeobrutalismPresetTokens`

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
  bool get sliderHapticDefault => true;

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
  double resolveSeparatorThickness(double thickness) => 2.0;

  @override
  double get tabIndicatorThickness => 4.0;

  @override
  Duration resolveFocusTransitionDuration(JustMotionProfile animations) =>
      animations.instant;

  @override
  Duration resolveDropdownDuration(JustMotionProfile animations) =>
      animations.instant;

  @override
  Curve resolveDropdownCurve(JustMotionProfile animations) =>
      animations.defaultCurve;
```

---

## 5. Verification Method

To independently verify these recommendations without mutating codebase files:
1. **Static Analysis & Compilation Check**:
   Apply these changes locally or in the next step and execute static analysis:
   ```bash
   export HOME=/home/yourblooo/development/justui/.home
   dart analyze packages/core
   ```
   Ensure no circular dependency errors or unresolved reference errors occur.
2. **Unit Tests**:
   Verify that existing tests run successfully:
   ```bash
   flutter test packages/core
   ```
3. **Inspect Exports**:
   Check `packages/core/lib/just_ui_core.dart` to verify that `JustSliderSize` and `JustProgressSize` are **not** exported, ensuring thematic isolation is maintained.
