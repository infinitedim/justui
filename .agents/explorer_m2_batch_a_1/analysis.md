# Milestone 2 Components Batch A Migration Analysis

## Executive Summary
This report analyzes the hardcoded neobrutalism checks in the first batch of Milestone 2 components (Slider, Progress, Separator, and Tab Indicator). It details how to migrate these checks to use the new `presetTokens` abstraction layer to achieve a clean, preset-agnostic design system.

---

## 1. Component Analysis: Slider (`packages/core/lib/src/components/slider/just_slider.dart`)

### 1.1 Hardcoded Neobrutalism Occurrences
* **Line 123**:
  ```dart
  final isNeobrutalism = theme.theme.preset == JustThemePreset.neobrutalism;
  ```
  This is the primary boolean check used to select between default and neobrutalism themes.
* **Line 127**:
  ```dart
  finalEnableHaptic = widget.enableHaptic ?? globalTheme?.enableHaptic ?? isNeobrutalism;
  ```
  If haptic feedback is not specified, it defaults to `isNeobrutalism` (enabled in neobrutalism, disabled in default).
* **Lines 134-145**:
  ```dart
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
  Slider track height and thumb sizes are branched using `isNeobrutalism`.
* **Line 152**: `isNeobrutalism ? colors.textPrimary : colors.borderFocus` (Active track color)
* **Line 156**: `isNeobrutalism ? colors.background : colors.borderDefault` (Inactive track color)
* **Line 160**: `isNeobrutalism ? colors.warning : colors.background` (Thumb color)
* **Line 168**: `isNeobrutalism ? colors.textPrimary : colors.borderDefault` (Tick mark color)
* **Line 173-175**:
  ```dart
  (isNeobrutalism
      ? .all(theme.theme.radius.xs)
      : .all(theme.theme.radius.full))
  ```
  Border radius is chosen based on the preset.
* **Line 246-248** (Inactive Track Border):
  ```dart
  border: isNeobrutalism ? .all(color: colors.textPrimary, width: 2.5) : null,
  ```
* **Line 265-273** (Active Track Border):
  ```dart
  border: isNeobrutalism
      ? .symmetric(
          horizontal: BorderSide(
            color: colors.textPrimary,
            width: 2.5,
          ),
        )
      : null,
  ```
* **Lines 309, 321, 334, 354, 364**: `isNeobrutalism` is passed to `_buildThumb` and branches the press interaction effect, border, and shadows:
  ```dart
  if (isNeobrutalism) {
    final Offset shadowOffset = isPressed ? .zero : const Offset(2.5, 2.5);
    final Offset translation = isPressed ? const Offset(2.5, 2.5) : .zero;
    thumbWidget = AnimatedContainer(
      duration: theme.theme.animations.instant,
      curve: theme.theme.animations.defaultCurve,
      transform: Matrix4.translationValues(translation.dx, translation.dy, 0.0),
      ...
      border: .all(color: thumbBorderColor, width: 2.5),
      boxShadow: isPressed ? null : [BoxShadow(color: colors.textPrimary, offset: shadowOffset, blurRadius: 0.0)],
    );
  } else {
    thumbWidget = AnimatedScale(
      scale: isPressed ? 1.15 : 1.0,
      duration: theme.theme.animations.instant,
      ...
      border: .all(color: thumbBorderColor, width: 1.5),
      boxShadow: [BoxShadow(color: colors.textPrimary.withValues(alpha: 0.15), offset: const Offset(0.0, 2.0), blurRadius: 4.0)],
    );
  }
  ```
* **Lines 427, 436, 442**: Tooltip container style is branched using `isNeobrutalism` (neobrutalism tooltip uses solid 2px borders, 2.0 offset flat shadows, and bold text).

### 1.2 Migration to `presetTokens`
* **Haptic Feedback**: Migrate to `theme.theme.presetTokens.sliderHapticDefault`.
* **Track Height & Thumb Size**: Replace the switch-cases with `theme.theme.presetTokens.resolveSliderTrackHeight(widget.size)` and `theme.theme.presetTokens.resolveSliderThumbSize(widget.size)`.
* **Track Border Radius**: Replace with `theme.theme.presetTokens.resolveBorderRadius(theme.theme.radius, isPill: theme.theme.preset != JustThemePreset.neobrutalism)`. Or create a semantic border radius helper for tracks if appropriate.
* **Borders & Shadows**: Replace the manual 2.5 borders with `theme.theme.presetTokens.borderWidth` or use `theme.theme.presetTokens.showsDefaultBorder` to conditionally render borders.
* **Thumb Press Effect & Shadow**: Use `theme.theme.presetTokens.buildPressEffect(child: child, isPressed: isPressed, animations: theme.theme.animations, customOffset: const Offset(2.5, 2.5))` and `theme.theme.presetTokens.resolveShadow(theme.theme.shadows, JustShadowLevel.sm, isPressed: isPressed)`.

### 1.3 Constraints & Layout Adjustments
* **Border Overlap / Collapsing shadow**: The neobrutalism thumb translates by `const Offset(2.5, 2.5)` to collapse into its flat shadow. To prevent visual drift (jitter), the duration is hardcoded to `animations.instant` (0ms), which matches the visual specs.
* **Track Inner Height**: The inactive/active tracks draw borders inside the box bounds (`BorderAlign.inside` style). The height of the track container must accommodate `2 * borderWidth` (which is `2 * 2.5 = 5.0`). Therefore, for size `.sm` (track height 6.0 in neobrutalism), only `1.0` pixel of the fill remains visible. For size `.md` (height 10.0), `5.0` pixels remain.

---

## 2. Component Analysis: Progress (`packages/core/lib/src/components/progress/just_progress.dart`)

### 2.1 Hardcoded Neobrutalism Occurrences
* **Line 137**:
  ```dart
  final isNeobrutalism = customTheme.preset == .neobrutalism;
  ```
  Primary preset check.
* **Line 143**:
  ```dart
  finalTrackColor = ... (isNeobrutalism ? const Color(0x00000000) : colors.borderDefault.withValues(alpha: 0.3));
  ```
  In neobrutalism, the background track is fully transparent.
* **Line 150**: `isNeobrutalism ? colors.textPrimary : colors.borderFocus` (Fill color)
* **Line 213-215**:
  ```dart
  final BorderRadius defaultRadius = isNeobrutalism ? BorderRadius.zero : .all(radius.full);
  ```
  Branding of border radius.
* **Line 225-227** (Linear Track Border):
  ```dart
  border: isNeobrutalism ? Border.all(color: colors.textPrimary, width: 2.5) : null,
  ```
* **Line 296-297**:
  ```dart
  fontWeight: isNeobrutalism ? .w700 : .w500,
  ```
  Linear progress label font weight is hardcoded.
* **Line 325, 329, 333**: Circular progress stroke widths:
  - `.sm`: `isNeobrutalism ? 3.0 : 2.0`
  - `.md`: `isNeobrutalism ? 4.0 : 3.0`
  - `.lg`: `isNeobrutalism ? 5.0 : 4.0`
* **Line 388-389**:
  ```dart
  fontWeight: isNeobrutalism ? .w700 : .w500,
  ```
  Circular progress label font weight is hardcoded.

### 2.2 Migration to `presetTokens`
* **Stroke Width**: Replace the manual switch-case with `customTheme.presetTokens.resolveProgressStrokeWidth(widget.size)`.
* **Font Weight**: Replace the hardcoded weights with `customTheme.presetTokens.progressLabelFontWeight`.
* **Border Radius**: Replace manual defaultRadius with `customTheme.presetTokens.resolveBorderRadius(radius, isPill: !isNeobrutalism)`. Since neobrutalism linear progress requires a rectangular shape, `resolveBorderRadius` returns `.zero` for neobrutalism when `isPill` is false.
* **Borders**: Replace manual `2.5` border width with `customTheme.presetTokens.borderWidth` and wrap with `customTheme.presetTokens.showsDefaultBorder` check.

### 2.3 Constraints & Layout Adjustments
* **Linear Track Height Overlap**: Under default preset, track heights are `4.0`, `8.0`, and `12.0`. Under neobrutalism, a border of `2.5` is added on all sides. This means the top and bottom borders sum to `5.0`.
  - For size `.sm` (height `4.0`), drawing a `5.0` thick border causes a visual layout failure (negative space inside).
  - **Proposed Constraint**: If neobrutalism is active, linear progress heights must be adjusted to accommodate the border. They should either map to larger sizes (e.g. minimum `6.0` or `8.0` for `.sm`) or we must increase the track container's height dynamically by `2 * borderWidth` when borders are shown.

---

## 3. Component Analysis: Separator (`packages/core/lib/src/components/separator/just_separator.dart`)

### 3.1 Hardcoded Neobrutalism Occurrences
* **Line 99-100**:
  ```dart
  final isNeobrutalism = JustThemeProvider.of(context).theme.preset == .neobrutalism;
  ```
* **Line 104**:
  ```dart
  (isNeobrutalism ? 2.0 : thickness)
  ```
  If neobrutalism is active, separator thickness is forced to `2.0`. Otherwise it uses `thickness` (default `1.0`).

### 3.2 Migration to `presetTokens`
* **Separator Thickness**: Replace line 104 with:
  ```dart
  final resolvedThickness = style?.thickness ?? themeStyle?.thickness ?? JustThemeProvider.of(context).theme.presetTokens.resolveSeparatorThickness(thickness);
  ```
  `resolveSeparatorThickness(thickness)` resolves to `2.0` in neobrutalism, and `thickness` in default.

### 3.3 Constraints & Layout Adjustments
* No complex layout overrides are needed. The separator thickness seamlessly maps to `presetTokens`.

---

## 4. Component Analysis: Tab Indicator (`packages/core/lib/src/components/tabs/just_tab_indicator.dart`)

### 4.1 Hardcoded Neobrutalism Occurrences
* **Line 41**:
  ```dart
  final isNeobrutalism = theme.preset == .neobrutalism;
  ```
* **Line 53 & Line 120**:
  ```dart
  style?.indicatorThickness ?? (isNeobrutalism ? 4.0 : 2.0);
  ```
  The thickness of the tab line indicator.
* **Line 97-98** (Enclosed Variant Border):
  ```dart
  border: .all(
    color: isNeobrutalism ? colors.textPrimary : colors.borderDefault,
    width: isNeobrutalism ? 2.5 : 1.0,
  ),
  ```
* **Line 107-113** (Pill Variant Style):
  ```dart
  color: isNeobrutalism
      ? colors.success.withValues(alpha: 0.2)
      : activeColor.withValues(alpha: 0.1),
  ...
  border: isNeobrutalism ? .all(color: colors.textPrimary, width: 1.5) : null,
  ```

### 4.2 Migration to `presetTokens`
* **Indicator Thickness**: Replace lines 53 and 120 with:
  ```dart
  style?.indicatorThickness ?? theme.presetTokens.tabIndicatorThickness;
  ```
  `tabIndicatorThickness` resolves to `4.0` in neobrutalism and `2.0` in default.
* **Border Width**: Replace the enclosed border width `2.5` / `1.0` with `theme.presetTokens.borderWidth`.
* **Border Color**: Use `isNeobrutalism ? colors.textPrimary : colors.borderDefault` or check if the theme exposes a semantic border color helper.
* **Pill Border**: For neobrutalism pill indicator, it draws a custom border with `width: 1.5`. This is a specific visual rule, but we should evaluate if it should map to standard `borderWidth` or remain a custom layout exception.

### 4.3 Constraints & Layout Adjustments
* **Enclosed Tab Header Border Collision**:
  In `just_tabs.dart` (the parent tab component, line 667), the header container draws a border under neobrutalism:
  ```dart
  border: isNeobrutalism
      ? (widget.variant == .enclosed || widget.variant == .pill
            ? .all(color: colors.textPrimary, width: 2.5)
            : null)
      : (widget.variant == .enclosed
            ? .all(color: colors.borderDefault, width: 1.0)
            : null)
  ```
  Since the indicator for the enclosed active tab also has a border, they align on top of each other. Proper alignment and padding must be maintained in both the parent tab header and the child tab indicator.

---

## 5. Summary Table of Migration Mapping

| Component | Target File | Neobrutalism Logic | Proposed `presetTokens` Mapping |
| :--- | :--- | :--- | :--- |
| **Slider** | `just_slider.dart` | `isNeobrutalism` (Haptic feedback) | `theme.theme.presetTokens.sliderHapticDefault` |
| **Slider** | `just_slider.dart` | Switch-case size tracks & thumbs | `theme.theme.presetTokens.resolveSliderTrackHeight` & `resolveSliderThumbSize` |
| **Slider** | `just_slider.dart` | Inner-layout border & shadow collapse | `theme.theme.presetTokens.buildPressEffect` & `resolveShadow` |
| **Progress** | `just_progress.dart` | Switch-case stroke widths | `customTheme.presetTokens.resolveProgressStrokeWidth` |
| **Progress** | `just_progress.dart` | `isNeobrutalism ? .w700 : .w500` (Label weight) | `customTheme.presetTokens.progressLabelFontWeight` |
| **Separator** | `just_separator.dart` | `isNeobrutalism ? 2.0 : thickness` | `theme.presetTokens.resolveSeparatorThickness` |
| **Tab Indicator**| `just_tab_indicator.dart` | `isNeobrutalism ? 4.0 : 2.0` (Thickness) | `theme.presetTokens.tabIndicatorThickness` |
| **Tab Indicator**| `just_tab_indicator.dart` | `isNeobrutalism ? 2.5 : 1.0` (Enclosed border) | `theme.presetTokens.borderWidth` |
