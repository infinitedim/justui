# Milestone 2 Components Batch A Migration Analysis

This report outlines the detailed investigation and migration plan for the **Batch A** components (Switch, Radio, Checkbox, Toggle, and Skeleton) to remove hardcoded `isNeobrutalism` / `JustThemePreset.neobrutalism` checks. It leverages the existing `JustPresetTokens` abstraction and proposes minimal, high-cohesion extensions to it to achieve complete theme preset isolation.

---

## 1. Executive Summary & Core Strategy

Currently, components in `packages/core/lib/src/components` have inline branch statements checking if the active theme preset is `.neobrutalism`. This tightly couples component layouts to specific visual styles, violating the design philosophy of the project.

Our migration strategy redirects all preset-dependent logic to the `JustPresetTokens` class (accessed via `theme.presetTokens`), ensuring:
1. **Zero hardcoded checks**: Components never inspect `theme.preset` directly.
2. **Preset-independent layouts**: Components query sizes, borders, radii, shadows, and press behaviors through the helper methods.
3. **Cohesive Extensions**: We propose adding two properties to `JustPresetTokens` (`selectionHapticDefault` and `usePulsingSkeleton`) to cleanly encapsulate the haptic defaults and skeleton visual styles.

---

## 2. Token Extension Proposals

To fully decouple the components, we recommend adding two properties to `JustPresetTokens` in `packages/core/lib/src/theme/preset_tokens.dart`:

```dart
/// Add to abstract class JustPresetTokens:
abstract class JustPresetTokens {
  // ... existing members ...

  /// Whether selection controls (Switch, Radio, Checkbox) default to triggering haptic feedback.
  bool get selectionHapticDefault;

  /// Whether the skeleton loader should pulse opacity instead of showing a gradient sweep shimmer.
  bool get usePulsingSkeleton;
}

/// Add to class DefaultPresetTokens:
class DefaultPresetTokens extends JustPresetTokens {
  // ... existing members ...

  @override
  bool get selectionHapticDefault => false;

  @override
  bool get usePulsingSkeleton => false;
}

/// Add to class NeobrutalismPresetTokens:
class NeobrutalismPresetTokens extends JustPresetTokens {
  // ... existing members ...

  @override
  bool get selectionHapticDefault => true;

  @override
  bool get usePulsingSkeleton => true;
}
```

---

## 3. Component Migration Mappings

### 3.1. Switch (`just_switch.dart`)

The switch has a complex inner layout. Under Neobrutalism, the track has a border of `2.5` thickness and the thumb gets a `1.5` border, which shrinks the inner travel area of the thumb.

#### Summary of Changes:
- **Haptic Default**: Retrieve from `presetTokens.selectionHapticDefault`.
- **Border Width**: Use `presetTokens.showsDefaultBorder ? presetTokens.borderWidth : 0.0`.
- **Thumb Sizing**: Subtract `2 * borderWidth` from the base thumb size in Neobrutalism.
- **Track & Thumb Borders**: Conditionally apply the solid `colors.textPrimary` border depending on `presetTokens.showsDefaultBorder`.
- **Thumb Shadow**: Apply `xs` shadow only when `presetTokens.showsDefaultBorder` is false.

#### Mapping Table:
| Location | Current Check | Proposed Migration |
| :--- | :--- | :--- |
| **Line 140** | `theme.preset == .neobrutalism` | `customTheme.presetTokens.selectionHapticDefault` |
| **Line 194** | `borderWidth = isNeobrutalism ? 2.5 : 0.0` | `borderWidth = customTheme.presetTokens.showsDefaultBorder ? customTheme.presetTokens.borderWidth : 0.0` |
| **Line 223** | `resolvedThumbSize = isNeobrutalism ? thumbSize - 2 * borderWidth : thumbSize` | `resolvedThumbSize = customTheme.presetTokens.showsDefaultBorder ? thumbSize - 2 * borderWidth : thumbSize` |
| **Line 233** | `isNeobrutalism ? colors.success : colors.borderFocus` | `customTheme.presetTokens.showsDefaultBorder ? colors.success : colors.borderFocus` |
| **Line 237** | `isNeobrutalism ? colors.background : colors.borderDefault` | `customTheme.presetTokens.showsDefaultBorder ? colors.background : colors.borderDefault` |
| **Line 313** | `border: isNeobrutalism ? Border.all(...) : null` | `border: customTheme.presetTokens.showsDefaultBorder ? Border.all(color: colors.textPrimary, width: borderWidth) : null` |
| **Line 337** | `border: isNeobrutalism ? Border.all(...) : null` | `border: customTheme.presetTokens.showsDefaultBorder ? Border.all(color: colors.textPrimary, width: 1.5) : null` |
| **Line 343** | `boxShadow: isNeobrutalism ? null : customTheme.shadows.xs` | `boxShadow: customTheme.presetTokens.showsDefaultBorder ? null : customTheme.presetTokens.resolveShadow(customTheme.shadows, JustShadowLevel.xs, isPressed: false)` |

---

### 3.2. Radio (`just_radio.dart`)

The radio button resolves its borders, colors, and shadows based on the preset.

#### Summary of Changes:
- **Haptic Default**: Retrieve from `presetTokens.selectionHapticDefault`.
- **Border Color**: Under Neobrutalism, force `colors.textPrimary` (Rule 3). Under Default, lerp colors.
- **Shadows**: Resolve flat shadows via `presetTokens.resolveShadow` under Neobrutalism; resolve to `const []` otherwise.
- **Border Width**: Use `presetTokens.borderWidth` when `showsDefaultBorder` is true, falling back to `1.5`.

#### Mapping Table:
| Location | Current Check | Proposed Migration |
| :--- | :--- | :--- |
| **Line 133** | `theme.preset == .neobrutalism` | `customTheme.presetTokens.selectionHapticDefault` |
| **Line 232** | `isNeobrutalism ? colors.textPrimary : ...` | `customTheme.presetTokens.showsDefaultBorder ? colors.textPrimary : ...` |
| **Line 242** | `currentShadows = isNeobrutalism ? customTheme.shadows.xs : const []` | `currentShadows = customTheme.presetTokens.showsDefaultBorder ? customTheme.presetTokens.resolveShadow(customTheme.shadows, JustShadowLevel.xs, isPressed: isPressed) : const <BoxShadow>[]` |
| **Line 257** | `width: isNeobrutalism ? 2.5 : 1.5` | `width: customTheme.presetTokens.showsDefaultBorder ? customTheme.presetTokens.borderWidth : 1.5` |

---

### 3.3. Checkbox (`just_checkbox.dart`)

Similar to Radio, Checkbox resolves borders, radii, colors, and shadows using preset configurations.

#### Summary of Changes:
- **Haptic Default**: Retrieve from `presetTokens.selectionHapticDefault`.
- **Border Radius**: Fall back to `.zero` under Neobrutalism (or check `showsDefaultBorder`).
- **Border Color**: Use `colors.textPrimary` under Neobrutalism.
- **Shadows**: Query `presetTokens.resolveShadow` under Neobrutalism, defaulting to `const []`.
- **Border Width**: Use `presetTokens.borderWidth` under Neobrutalism, falling back to `1.5`.

#### Mapping Table:
| Location | Current Check | Proposed Migration |
| :--- | :--- | :--- |
| **Line 130** | `theme.preset == .neobrutalism` | `customTheme.presetTokens.selectionHapticDefault` |
| **Line 199** | `resolvedRadius = ... ?? .all(radius.xs)` | `resolvedRadius = ... ?? (customTheme.presetTokens.showsDefaultBorder ? .zero : .all(radius.xs))` |
| **Line 251** | `isNeobrutalism ? colors.textPrimary : ...` | `customTheme.presetTokens.showsDefaultBorder ? colors.textPrimary : ...` |
| **Line 261** | `currentShadows = isNeobrutalism ? customTheme.shadows.xs : const []` | `currentShadows = customTheme.presetTokens.showsDefaultBorder ? customTheme.presetTokens.resolveShadow(customTheme.shadows, JustShadowLevel.xs, isPressed: isPressed) : const <BoxShadow>[]` |
| **Line 277** | `width: isNeobrutalism ? 2.5 : 1.5` | `width: customTheme.presetTokens.showsDefaultBorder ? customTheme.presetTokens.borderWidth : 1.5` |

---

### 3.4. Toggle (`just_toggle.dart`)

The toggle button includes group border-radius collapse, multiple color state overrides, custom press animation wrapping, and thick borders.

#### Summary of Changes:
- **Default Radius**: Query `presetTokens.resolveBorderRadius(radius)`.
- **Group Collapse**: Bypass group collapse if `presetTokens.showsDefaultBorder` is true.
- **State Colors (BG, Border, Text)**: Use `presetTokens.showsDefaultBorder` to decide whether to apply Neobrutalism's black/white colors vs Default modes.
- **Border Width & Styling**: Use `presetTokens.borderWidth` when `showsDefaultBorder` is true.
- **Press Effect & Shadows**: Wrap content with `presetTokens.buildPressEffect` and `presetTokens.resolveShadow` when `showsDefaultBorder` is true.

#### Mapping Table:
| Location | Current Check | Proposed Migration |
| :--- | :--- | :--- |
| **Line 116** | `defaultRadius = isNeobrutalism ? .zero : .all(radius.md)` | `defaultRadius = customTheme.presetTokens.resolveBorderRadius(radius)` |
| **Line 120** | `if (groupInfo != null && !isNeobrutalism)` | `if (groupInfo != null && !customTheme.presetTokens.showsDefaultBorder)` |
| **Line 159** | `isNeobrutalism ? colors.textPrimary : ...` | `customTheme.presetTokens.showsDefaultBorder ? colors.textPrimary : ...` |
| **Line 166** | `isNeobrutalism ? colors.background : ...` | `customTheme.presetTokens.showsDefaultBorder ? colors.background : ...` |
| **Line 171** | `isNeobrutalism ? colors.textPrimary : ...` | `customTheme.presetTokens.showsDefaultBorder ? colors.textPrimary : ...` |
| **Line 176** | `isNeobrutalism ? colors.textPrimary : ...` | `customTheme.presetTokens.showsDefaultBorder ? colors.textPrimary : ...` |
| **Line 181** | `isNeobrutalism ? colors.textInverse : ...` | `customTheme.presetTokens.showsDefaultBorder ? colors.textInverse : ...` |
| **Line 206** | `if (isNeobrutalism) { // skip press opacity }` | `if (customTheme.presetTokens.showsDefaultBorder) { ... }` |
| **Line 214** | `if (isNeobrutalism) { ... }` | `if (customTheme.presetTokens.showsDefaultBorder) { ... }` |
| **Line 226** | `if (isNeobrutalism) { border = 2.5 }` | `if (customTheme.presetTokens.showsDefaultBorder) { border = customTheme.presetTokens.borderWidth }` |
| **Line 255** | `borderRadius: isNeobrutalism ? .zero : resolvedRadius` | `borderRadius: customTheme.presetTokens.showsDefaultBorder ? .zero : resolvedRadius` |
| **Line 266** | `if (isNeobrutalism) { ... buildPressEffect ... }` | `if (customTheme.presetTokens.showsDefaultBorder) { ... customTheme.presetTokens.buildPressEffect ... }` |
| **Line 292** | `borderRadius: isNeobrutalism ? .zero : resolvedRadius` | `borderRadius: customTheme.presetTokens.showsDefaultBorder ? .zero : resolvedRadius` |

---

### 3.5. Skeleton (`just_skeleton.dart`)

Fades the container opacity dynamically under Neobrutalism, while Default preset uses a `ShaderMask` sweep gradient shimmer.

#### Summary of Changes:
- **Pulsing Animation Trigger**: Inspect the new property `theme.presetTokens.usePulsingSkeleton` instead of inspecting `theme.preset == .neobrutalism`.

#### Mapping Table:
| Location | Current Check | Proposed Migration |
| :--- | :--- | :--- |
| **Line 889** | `isNeobrutalism = theme.preset == .neobrutalism;` | `usePulsing = theme.presetTokens.usePulsingSkeleton;` |

---

## 4. Before & After Code Snippets

### Switch Track & Thumb Border / Shadows
```dart
// BEFORE
return Container(
  width: trackWidth,
  height: trackHeight,
  decoration: BoxDecoration(
    color: currentTrackColor,
    borderRadius: .all(.circular(trackHeight / 2)),
    border: isNeobrutalism
        ? .all(color: colors.textPrimary, width: borderWidth)
        : null,
  ),
  child: Stack(
    children: [
      Positioned(
        left: padding + borderWidth,
        top: padding + borderWidth,
        child: Transform.translate(
          offset: Offset(progress * maxTravel, 0.0),
          child: Container(
            width: resolvedThumbSize,
            height: resolvedThumbSize,
            decoration: BoxDecoration(
              color: currentThumbColor,
              shape: .circle,
              border: isNeobrutalism
                  ? .all(color: colors.textPrimary, width: 1.5)
                  : null,
              boxShadow: isNeobrutalism ? null : customTheme.shadows.xs,
            ),
          ),
        ),
      ),
    ],
  ),
);

// AFTER
final hasBorder = customTheme.presetTokens.showsDefaultBorder;
final resolvedShadow = hasBorder 
    ? null 
    : customTheme.presetTokens.resolveShadow(
        customTheme.shadows, 
        JustShadowLevel.xs, 
        isPressed: false,
      );

return Container(
  width: trackWidth,
  height: trackHeight,
  decoration: BoxDecoration(
    color: currentTrackColor,
    borderRadius: .all(.circular(trackHeight / 2)),
    border: hasBorder
        ? .all(color: colors.textPrimary, width: borderWidth)
        : null,
  ),
  child: Stack(
    children: [
      Positioned(
        left: padding + borderWidth,
        top: padding + borderWidth,
        child: Transform.translate(
          offset: Offset(progress * maxTravel, 0.0),
          child: Container(
            width: resolvedThumbSize,
            height: resolvedThumbSize,
            decoration: BoxDecoration(
              color: currentThumbColor,
              shape: .circle,
              border: hasBorder
                  ? .all(color: colors.textPrimary, width: 1.5)
                  : null,
              boxShadow: resolvedShadow,
            ),
          ),
        ),
      ),
    ],
  ),
);
```

### Checkbox Border Radius & Shadows
```dart
// BEFORE
final isNeobrutalism = customTheme.preset == .neobrutalism;
List<BoxShadow> currentShadows = isNeobrutalism
    ? customTheme.shadows.xs
    : const [];
currentShadows = customTheme.resolveShadows(
  currentShadows,
  isPressed: isPressed,
);

final checkboxBox = Container(
  width: boxSize,
  height: boxSize,
  decoration: BoxDecoration(
    color: currentBg,
    borderRadius: resolvedRadius,
    border: .all(
      color: currentBorder,
      width: isNeobrutalism ? 2.5 : 1.5,
    ),
    boxShadow: currentShadows.isNotEmpty ? currentShadows : null,
  ),
);

// AFTER
final hasBorder = customTheme.presetTokens.showsDefaultBorder;
final currentShadows = hasBorder
    ? customTheme.presetTokens.resolveShadow(
        customTheme.shadows,
        JustShadowLevel.xs,
        isPressed: isPressed,
      )
    : const <BoxShadow>[];

final checkboxBox = Container(
  width: boxSize,
  height: boxSize,
  decoration: BoxDecoration(
    color: currentBg,
    borderRadius: resolvedRadius,
    border: .all(
      color: currentBorder,
      width: hasBorder ? customTheme.presetTokens.borderWidth : 1.5,
    ),
    boxShadow: currentShadows.isNotEmpty ? currentShadows : null,
  ),
);
```

---

## 5. Verification Plan

The following verification steps must be run post-implementation to guarantee correctness and visual fidelity:

1. **Verify Code Style Compliance**:
   Ensure Dart Constructor Shorthands (`.all(...)`, `.symmetric(...)`) are preserved.
2. **Execute Unit Tests**:
   Ensure that no functionality is broken by running all component and theme tests:
   ```bash
   export HOME=/home/yourblooo/development/justui/.home
   flutter test packages/core/test/components/just_switch_test.dart
   flutter test packages/core/test/components/just_radio_test.dart
   flutter test packages/core/test/components/just_checkbox_test.dart
   flutter test packages/core/test/components/just_skeleton_test.dart
   flutter test packages/core/test/theme_test.dart
   ```
3. **Check Layout Constraints**:
   Validate that no source files have been placed in the `.agents/` folder. All changes must reside within `packages/core/lib`.
