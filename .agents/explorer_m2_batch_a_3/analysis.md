# Component Migration Analysis Report — Milestone 2 Components Batch A

This report details the audit and analysis of the 9 components in Batch A of Milestone 2, identifying all hardcoded references to the `neobrutalism` preset and proposing how they should be migrated to resolve visual properties via the decoupled `JustPresetTokens` contract.

---

## 1. Executive Summary

Milestone 2 aims to decouple components from checking `theme.preset == JustThemePreset.neobrutalism`. Instead, components must resolve visual properties dynamically using `theme.presetTokens` (defined as `JustPresetTokens`).

Through our audit of the 9 components, we found:
- **Direct Preset Checks**: 8 of the 9 components (except `just_separator.dart` and `just_tab_indicator.dart`, which do it slightly differently) perform direct checks on `theme.preset == .neobrutalism` or use it to enable haptics, borders, or shadows.
- **Decoupling Gaps**: In several places, `JustPresetTokens` is missing specific tokens or methods needed to fully replace `isNeobrutalism` checks without changing behavior. These include:
  1. **Border Radius Policies**: Slider and Progress tracks have different radius behaviors under Default vs Neobrutalism that do not match `resolveBorderRadius(radius, isPill: false/true)`.
  2. **Haptic Defaults**: Switch, Radio, and Checkbox components default their haptics to true on Neobrutalism, but `JustPresetTokens` only has `sliderHapticDefault`.
  3. **Visual Style Differences**: Tab Indicator (pill background/border), Radio/Checkbox shadows, and Skeleton Loader (pulse instead of shimmer animation) use custom Neobrutalism visual designs that aren't represented in `JustPresetTokens`.
- **Refactoring Visual Bugs**: Refactoring `buildPressEffect` for checkboxes/radios using `presetTokens.buildPressEffect` will actually *fix* an existing visual bug where the component translated by 3.0 or 4.0 pixels when pressed but the shadow offset was only 1.0 pixel (`xs`).

---

## 2. Detailed Component Audit

### 2.1 JustSlider
- **File**: `packages/core/lib/src/components/slider/just_slider.dart`
- **Current References to `neobrutalism`**:
  - Line 123: `final isNeobrutalism = theme.theme.preset == JustThemePreset.neobrutalism;`
  - Line 127: `widget.enableHaptic ?? globalTheme?.enableHaptic ?? isNeobrutalism`
  - Lines 134-143: Slider track heights and thumb sizes are switched based on `isNeobrutalism` and `size`.
  - Lines 152, 156, 160, 168: Colors are conditionally set if `isNeobrutalism`.
  - Lines 173-175: Track border radius is set to `xs` if `isNeobrutalism`, and `full` if not.
  - Lines 246-248: Inactive track border is `2.5` black border if `isNeobrutalism`.
  - Lines 265-272: Active track border is `2.5` black border if `isNeobrutalism`.
  - Lines 364-415: `_buildThumb` has an `if (isNeobrutalism)` branch rendering a rectangular, bordered thumb with translation-based press effect, vs a circular, scaled thumb for default.
  - Lines 442-488: `_buildTooltip` has an `if (isNeobrutalism)` branch rendering a rectangular bordered tooltip with flat offset shadows, vs a rounded tooltip.
- **Proposed Migration**:
  - Use `presetTokens.resolveSliderTrackHeight(widget.size)` and `presetTokens.resolveSliderThumbSize(widget.size)`.
  - Replace `isNeobrutalism` for haptic fallback with `presetTokens.sliderHapticDefault`.
  - Use `presetTokens.showsDefaultBorder` and `presetTokens.borderWidth` to determine borders on active/inactive tracks.
  - Wrap thumb visual building inside `_buildThumb` using `presetTokens.buildPressEffect` with `customOffset: const Offset(2.5, 2.5)` and `customScale: 1.15`.
- **Helper Methods / Sub-widgets Involved**:
  - `_buildThumb`: Remove `bool isNeobrutalism` parameter; query `theme.theme.presetTokens` instead.
  - `_buildTooltip`: Remove `bool isNeobrutalism` parameter; query `theme.theme.presetTokens` instead.
- **Visual Bugs / Static Analysis Concerns**:
  - **Track Border Radius Gap**: Default preset track radius uses `radius.full` but `DefaultPresetTokens.resolveBorderRadius(radius)` returns `radius.md`. Under Neobrutalism, track radius is `radius.xs` but `NeobrutalismPresetTokens.resolveBorderRadius(radius)` returns `.zero`. Thus, `resolveBorderRadius` cannot be used directly for the slider track. A custom track radius token or manual resolution is needed.

---

### 2.2 JustProgress
- **File**: `packages/core/lib/src/components/progress/just_progress.dart`
- **Current References to `neobrutalism`**:
  - Line 137: `final isNeobrutalism = customTheme.preset == .neobrutalism;`
  - Lines 143-150: Colors (track and fill) are conditionally resolved.
  - Lines 213-215: Linear progress default radius is `.zero` for Neobrutalism, and `radius.full` for default.
  - Lines 225-227: Border on track is applied if `isNeobrutalism`.
  - Lines 296, 389: Text font weight is `w700` if `isNeobrutalism`, and `w500` if not.
  - Lines 325-333: Circular progress stroke width is offset by +1.0 for Neobrutalism.
- **Proposed Migration**:
  - Use `presetTokens.resolveProgressStrokeWidth(widget.size)` for circular progress stroke widths.
  - Use `presetTokens.progressLabelFontWeight` for the text label's font weight.
  - Use `presetTokens.showsDefaultBorder` and `presetTokens.borderWidth` to determine track borders.
- **Helper Methods / Sub-widgets Involved**:
  - `_buildLinear` and `_buildCircular`: Remove the `bool isNeobrutalism` parameter; pass or query `customTheme.presetTokens` instead.
- **Visual Bugs / Static Analysis Concerns**:
  - **Linear Track Border Radius Gap**: Like the slider, `resolveBorderRadius(radius)` with `isPill: false` returns `radius.md` for Default, whereas linear progress track needs `radius.full`. If `isPill: true` is passed, Neobrutalism returns `radius.full` which is incorrect since Neobrutalism progress must have sharp corners (`.zero`).

---

### 2.3 JustSeparator
- **File**: `packages/core/lib/src/components/separator/just_separator.dart`
- **Current References to `neobrutalism`**:
  - Line 99: `final isNeobrutalism = JustThemeProvider.of(context).theme.preset == .neobrutalism;`
  - Line 104: `isNeobrutalism ? 2.0 : thickness`
- **Proposed Migration**:
  - Replace `isNeobrutalism ? 2.0 : thickness` with `presetTokens.resolveSeparatorThickness(thickness)`.
- **Helper Methods / Sub-widgets Involved**:
  - None.
- **Visual Bugs / Static Analysis Concerns**:
  - None. Clean refactoring.

---

### 2.4 JustTabIndicator
- **File**: `packages/core/lib/src/components/tabs/just_tab_indicator.dart`
- **Current References to `neobrutalism`**:
  - Line 41: `final isNeobrutalism = theme.preset == .neobrutalism;`
  - Line 53: `style?.indicatorThickness ?? (isNeobrutalism ? 4.0 : 2.0)`
  - Lines 97-98: Enclosed tab border uses `colors.textPrimary` and width `2.5` if `isNeobrutalism`, vs `colors.borderDefault` and width `1.0`.
  - Lines 107-113: Pill tab uses a light success background with a 1.5 black border if `isNeobrutalism`, vs a transparent activeColor background with no border.
- **Proposed Migration**:
  - Replace indicator thickness fallback with `theme.presetTokens.tabIndicatorThickness`.
  - Replace enclosed border width with `theme.presetTokens.borderWidth`.
  - Replace enclosed border color check using `theme.presetTokens.showsDefaultBorder` (to pick `colors.textPrimary` vs `colors.borderDefault`).
- **Helper Methods / Sub-widgets Involved**:
  - None.
- **Visual Bugs / Static Analysis Concerns**:
  - **Pill Style Decoupling Gap**: The custom pill layout's border (width 1.5) and success-based background under Neobrutalism cannot be resolved from existing tokens. We should recommend introducing a specific pill/tab resolution policy to `JustPresetTokens` or document this exception.

---

### 2.5 JustSwitch
- **File**: `packages/core/lib/src/components/switch/just_switch.dart`
- **Current References to `neobrutalism`**:
  - Line 140: `(JustThemeProvider.read(context).theme.preset == .neobrutalism)` for setting `finalEnableHaptic`.
  - Line 193: `final isNeobrutalism = customTheme.preset == .neobrutalism;`
  - Line 194: `final borderWidth = isNeobrutalism ? 2.5 : 0.0;`
  - Lines 233, 237: Colors are conditionally set for Neobrutalism (e.g. active color is `colors.success` vs `colors.borderFocus`).
  - Lines 313, 337: Border for track and thumb is applied if `isNeobrutalism`.
  - Line 343: Thumb shadow is disabled if `isNeobrutalism` (`boxShadow: isNeobrutalism ? null : customTheme.shadows.xs`).
- **Proposed Migration**:
  - Propose introducing a general `hapticFeedbackDefault` on `JustPresetTokens` to replace preset checks on toggle haptics.
  - Resolve track border width as: `customTheme.presetTokens.showsDefaultBorder ? customTheme.presetTokens.borderWidth : 0.0`.
  - Resolve track/thumb borders using `presetTokens.showsDefaultBorder`.
- **Helper Methods / Sub-widgets Involved**:
  - None.
- **Visual Bugs / Static Analysis Concerns**:
  - **Thumb Shadow Gap**: Neobrutalism switch thumb has no shadow. If we use `presetTokens.resolveShadow(shadows, JustShadowLevel.xs, isPressed: false)` for the thumb, Neobrutalism will return a flat offset shadow (`shadows.xs`). Thus, we must continue to explicitly set `boxShadow` to null for Neobrutalism (or check `showsDefaultBorder`).
  - **Inner Layout Calculation**: Neobrutalism Switch thumb size and positioning adjustments (`thumbSize - 2 * borderWidth` and `padding + borderWidth`) depend on the border width. Using `presetTokens.borderWidth` dynamically is safe and aligns with the inner-layout requirements.

---

### 2.6 JustRadio
- **File**: `packages/core/lib/src/components/radio/just_radio.dart`
- **Current References to `neobrutalism`**:
  - Line 133: `(JustThemeProvider.read(context).theme.preset == .neobrutalism)` for setting `finalEnableHaptic`.
  - Line 196: `final isNeobrutalism = customTheme.preset == .neobrutalism;`
  - Lines 232, 242, 257: Outer circle border color (`colors.textPrimary` vs `colors.borderDefault`), shadow (`xs` vs empty list), and border width (`2.5` vs `1.5`) are set if `isNeobrutalism`.
- **Proposed Migration**:
  - Resolve border width as `presetTokens.showsDefaultBorder ? presetTokens.borderWidth : 1.5`.
  - Resolve border color using `presetTokens.showsDefaultBorder` (using `colors.textPrimary` vs `colors.borderDefault`).
  - Resolve shadows using:
    ```dart
    List<BoxShadow> currentShadows = customTheme.presetTokens.showsDefaultBorder
        ? customTheme.presetTokens.resolveShadow(customTheme.shadows, JustShadowLevel.xs, isPressed: isPressed)
        : const [];
    ```
- **Helper Methods / Sub-widgets Involved**:
  - None.
- **Visual Bugs / Static Analysis Concerns**:
  - **Radio Border Width**: In Default mode, the radio uses a border width of `1.5`, whereas the standard `DefaultPresetTokens.borderWidth` is `1.0`. Thus, we should ensure the fallback width remains `1.5` for default mode (i.e. `presetTokens.showsDefaultBorder ? presetTokens.borderWidth : 1.5`).
  - **Press Effect Offset Mismatch**: Applying `presetTokens.buildPressEffect` to the radio box will translate it by the default `translationOffset` of `(3.0, 3.0)` under Neobrutalism, but its shadow offset (`xs`) is `(1.0, 1.0)`. Passing `customOffset: const Offset(1.0, 1.0)` fixes this mismatch.

---

### 2.7 JustCheckbox
- **File**: `packages/core/lib/src/components/checkbox/just_checkbox.dart`
- **Current References to `neobrutalism`**:
  - Line 130: `(JustThemeProvider.read(context).theme.preset == .neobrutalism)` for setting `finalEnableHaptic`.
  - Line 241: `customTheme.preset == .neobrutalism` to set `isNeobrutalism`.
  - Lines 251, 261, 277: Outer box border color (`colors.textPrimary` vs `colors.borderDefault`), shadow (`xs` vs empty list), and border width (`2.5` vs `1.5`) are set if `isNeobrutalism`.
- **Proposed Migration**:
  - Resolve border width as `presetTokens.showsDefaultBorder ? presetTokens.borderWidth : 1.5`.
  - Resolve border color using `presetTokens.showsDefaultBorder` (using `colors.textPrimary` vs `colors.borderDefault`).
  - Resolve shadows conditionally using `showsDefaultBorder` and `presetTokens.resolveShadow`.
- **Helper Methods / Sub-widgets Involved**:
  - None.
- **Visual Bugs / Static Analysis Concerns**:
  - **Checkbox Border Width**: Similar to the radio, default checkbox uses a border width of `1.5` instead of `1.0`. Keep the default fallback to `1.5`.
  - **Press Effect Offset Mismatch**: Pass `customOffset: const Offset(1.0, 1.0)` to `buildPressEffect` to align the pressed translation with the `xs` shadow.

---

### 2.8 JustToggle
- **File**: `packages/core/lib/src/components/toggle/just_toggle.dart`
- **Current References to `neobrutalism`**:
  - Line 87: `final isNeobrutalism = customTheme.preset == .neobrutalism;`
  - Line 116: `final BorderRadius defaultRadius = isNeobrutalism ? .zero : .all(radius.md);`
  - Lines 159, 166, 171, 176, 181: Color states (selected/unselected background, border, text) are conditionally resolved.
  - Lines 206, 214: Pressed/hover backgrounds are resolved differently under Neobrutalism.
  - Line 226: BoxBorder uses `Border.all(color: border, width: 2.5)` if `isNeobrutalism`.
  - Lines 266-287: Button content is wrapped with `buildPressEffect` and given a shadow if `isNeobrutalism` and `selected`.
- **Proposed Migration**:
  - Resolve `defaultRadius` as `customTheme.presetTokens.resolveBorderRadius(radius)`. (This correctly returns `.zero` for Neobrutalism and `.all(radius.md)` for default).
  - Resolve border width as `presetTokens.showsDefaultBorder ? presetTokens.borderWidth : 1.0`.
  - Propose a token or clean abstraction for hover/press states, or use `presetTokens.showsDefaultBorder` as the indicator.
- **Helper Methods / Sub-widgets Involved**:
  - None.
- **Visual Bugs / Static Analysis Concerns**:
  - **Group Border Collapse**: Default mode collapses borders between items in a `JustToggleGroup`. Neobrutalism does not (it always renders a full border around each item). This behavior should be preserved by using `if (customTheme.presetTokens.showsDefaultBorder)` to guard the group border construction.

---

### 2.9 JustSkeleton
- **File**: `packages/core/lib/src/components/skeleton/just_skeleton.dart`
- **Current References to `neobrutalism`**:
  - Line 889: `final isNeobrutalism = theme.preset == .neobrutalism;`
  - Lines 891-947: If `isNeobrutalism`, renders a pulse animation via opacity transition in `AnimatedBuilder` instead of shimmer.
- **Proposed Migration**:
  - Recommend adding `bool get useSkeletonPulse` to `JustPresetTokens` to decouple the pulse logic from a hardcoded preset check.
- **Helper Methods / Sub-widgets Involved**:
  - None.
- **Visual Bugs / Static Analysis Concerns**:
  - None. Decoupling this through a token is highly safe and maintains performance.

---

## 3. Decoupling Gaps and Recommendations

To achieve clean, complete decoupling, we recommend making the following additions/changes to `JustPresetTokens` in `packages/core/lib/src/theme/preset_tokens.dart`:

1. **Add `hapticFeedbackDefault`**:
   - Signature: `bool get hapticFeedbackDefault;`
   - Purpose: Replaces haptic default checks in Switch, Radio, and Checkbox.
   - Values: `false` for `DefaultPresetTokens`, `true` for `NeobrutalismPresetTokens`.
2. **Add `useSkeletonPulse`**:
   - Signature: `bool get useSkeletonPulse;`
   - Purpose: Replaces direct preset check in `JustSkeleton` to choose pulse vs shimmer.
   - Values: `false` for `DefaultPresetTokens`, `true` for `NeobrutalismPresetTokens`.
3. **Address Track/Progress Border Radius Policy**:
   - Since track shapes (linear progress, slider track) do not follow standard box radius schemes (`radius.md` vs `radius.full`), we could introduce a specific method:
     - `BorderRadius resolveTrackRadius(JustRadiusScheme radius);`
     - Default returns `.all(radius.full)`.
     - Neobrutalism returns `.zero` (or `.all(radius.xs)` for slider track).
