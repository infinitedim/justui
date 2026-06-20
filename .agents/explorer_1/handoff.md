# JustUI Monorepo Architectural Audit — Explorer Findings

## 1. Observation

This section documents the exact locations, classes, and code patterns observed during the exploration of the JustUI monorepo.

### 1.1. packages/just_ui_tokens/

The `just_ui_tokens` package defines the primitive design system tokens. Below is the file structure and primary classes observed:

*   **Exports File**: `lib/just_ui_tokens.dart`
*   **Breakpoints**: `lib/src/breakpoints.dart` -> `abstract final class JustBreakpoints`
    *   `static const double sm = 640.0;`
    *   `static const double md = 768.0;`
    *   `static const double lg = 1024.0;`
    *   `static const double xl = 1280.0;`
    *   `static const double xxl = 1536.0;`
*   **Color Palette**: `lib/src/colors/color_palette.dart` -> `abstract final class JustColorPalette`
    *   Defines pure `white` (`0xFFFFFFFF`), `black` (`0xFF000000`), and 11-step scales (from 50 to 950) for `neutral` (slate-like), `primary` (blue), `success` (green), `warning` (amber), `error` (red), and `info` (cyan).
*   **Color Semantics**: `lib/src/colors/color_semantic.dart` -> `abstract final class JustColorSemanticLight` and `abstract final class JustColorSemanticDark`
    *   Maps semantic keys (`background`, `card`, `elevated`, `overlay`, `textPrimary`, `textSecondary`, `textDisabled`, `textInverse`, `borderDefault`, `borderFocus`, `borderError`, `success`, `warning`, `error`, `info`) to the primitive palette.
*   **Color Schemes & Tokens**: `lib/src/colors/color_tokens.dart` -> `abstract final class JustColorScheme`, `_JustColorSchemeLight`, `_JustColorSchemeDark`, `CustomColorScheme`, and `abstract final class JustColors`
    *   `JustColors.light()` and `JustColors.dark()` return static instances of Light and Dark schemes.
*   **Accessibility Contrast Checks**: `lib/src/colors/colors_accessibility.dart` -> `extension JustColorAccessibility on Color`
    *   Method `double contrastRatioWith(Color other)`
    *   Method `bool isAccessibleWith(Color other, {bool isLargeText = false})`
*   **Dynamic Colors**: `lib/src/colors/colors_dynamic.dart` -> `class JustColorScale` (using HSL-based dynamic saturation curves), `extension JustColorContrastCorrection on Color` (using HSL binary search contrast correction), and `abstract final class JustDynamicSurfaces` (generating dark mode surfaces).
*   **Duration & Curves**: `lib/src/duration.dart` -> `abstract final class JustDuration`
    *   `instant` (50ms), `fast` (150ms), `normal` (250ms), `slow` (400ms), `slower` (600ms).
    *   Method `static Duration scaleForDistance(double distancePixels, {double speedPixelsPerMs = 1.5, ...})`
    *   `abstract final class JustCurves` defines `default_` (`Curves.easeInOut`), `enter` (`Curves.easeOut`), `exit` (`Curves.easeIn`), and `spring` (`Curves.elasticOut`).
*   **Motion**: `lib/src/motion.dart` -> `class JustMotionProfile`
    *   Resolves profiles based on `MediaQuery.disableAnimationsOf(context)` returning the `reduced` profile.
    *   Profiles: `standard`, `expressive`, `compact`, and `reduced` (where durations are `Duration.zero` and curves are `Curves.linear`).
*   **Radius**: `lib/src/radius.dart` -> `abstract final class JustRadius`
    *   `none` (0.0), `xs` (2.0), `sm` (4.0), `md` (8.0), `lg` (12.0), `xl` (16.0), `xxl` (24.0), `full` (9999.0).
    *   `abstract final class JustBorderRadius` provides shortcut `BorderRadius` mappings.
*   **Shadows**: `lib/src/shadows.dart` -> `abstract final class JustShadows`
    *   Defines Multi-layer `BoxShadow` constants `xs`, `sm`, `md`, `lg`, `xl`, `xxl` (and `*Dark` variants).
    *   Method `static List<BoxShadow> generate({required Color seedColor, required double elevation, bool isDark = false})` constructs ambient shadows tinted with the brand seed color.
*   **Spacing**: `lib/src/spacing.dart` -> `abstract final class JustSpacing`
    *   `xxs` (2.0), `xs` (4.0), `sm` (8.0), `md` (12.0), `lg` (16.0), `xl` (24.0), `xxl` (32.0), `xxxl` (48.0), `huge` (64.0).
    *   `abstract final class JustGap` provides vertical/horizontal `SizedBox` spacing widgets.
*   **Typography**: `lib/src/typography.dart` -> `abstract final class JustTypo`
    *   Defines font families `Inter` and `JetBrains Mono` alongside static `TextStyle` scales.
*   **Fluid Typography**: `lib/src/typography_fluid.dart` -> `extension JustFluidTypography on TextStyle`
    *   Method `TextStyle fluid({required double screenWidth, ...})`
    *   Method `TextStyle withAdaptiveHeight(BuildContext context)` (loose 1.6 height for sizes <= 12.0, tight 1.15 height for sizes >= 36.0).
    *   `abstract final class JustFluidTypo` maps presets.

#### Color Contrast Calculation Details

The math in `colors_accessibility.dart` implements the WCAG 2.0 contrast ratio calculations:

1.  **Luminance calculation**: Relies on standard Flutter `Color.computeLuminance()` which implements the relative luminance formula:
    $$L = 0.2126 \times R + 0.7152 \times G + 0.0722 \times B$$
    where channels are linearized:
    $$\text{if } C_{srgb} \le 0.03928 \text{ then } C = C_{srgb} / 12.92 \text{ else } C = \left(\frac{C_{srgb} + 0.055}{1.055}\right)^{2.4}$$
2.  **Contrast Ratio formula**:
    $$\text{Ratio} = \frac{L_{lightest} + 0.05}{L_{darkest} + 0.05}$$
    This is executed in `contrastRatioWith`:
    ```dart
    final double l1 = computeLuminance();
    final double l2 = other.computeLuminance();
    return l1 > l2 ? (l1 + 0.05) / (l2 + 0.05) : (l2 + 0.05) / (l1 + 0.05);
    ```
3.  **Compliance Checks**:
    *   `isAccessibleWith` returns true if `ratio >= 4.5` (for standard text) or `ratio >= 3.0` (for large text).

---

### 1.2. packages/just_ui_core/

The `just_ui_core` package manages the theming engine and core component styles.

#### 1.2.1. Aspect-Based Rebuild Mechanism

*   **Aspect Enum**: `lib/src/theme/theme_aspects.dart` -> `enum JustThemeAspect` (keys: `colors`, `typography`, `spacing`, `radius`, `shadows`, `animations`).
*   **Inherited Model**: `lib/src/theme/theme_provider.dart` -> `class _JustThemeModel extends InheritedModel<JustThemeAspect>`
    *   `updateShouldNotifyDependent` checks target aspects:
    ```dart
    @override
    bool updateShouldNotifyDependent(_JustThemeModel oldWidget, Set<JustThemeAspect> dependencies) {
      if (dependencies.contains(JustThemeAspect.colors) && themeData.colors != oldWidget.themeData.colors) return true;
      if (dependencies.contains(JustThemeAspect.typography) && themeData.typography != oldWidget.themeData.typography) return true;
      if (dependencies.contains(JustThemeAspect.spacing) && themeData.spacing != oldWidget.themeData.spacing) return true;
      if (dependencies.contains(JustThemeAspect.radius) && themeData.radius != oldWidget.themeData.radius) return true;
      if (dependencies.contains(JustThemeAspect.shadows) && themeData.shadows != oldWidget.themeData.shadows) return true;
      if (dependencies.contains(JustThemeAspect.animations) && themeData.animations != oldWidget.themeData.animations) return true;
      return false;
    }
    ```
*   **BuildContext Extensions** (`lib/just_ui_core.dart`):
    *   `context.justColors` -> `JustThemeProvider.of(context, aspect: .colors).theme.colors`
    *   `context.justTypo` -> `JustThemeProvider.of(context, aspect: .typography).theme.typography`
    *   `context.justSpacing` -> `JustThemeProvider.of(context, aspect: .spacing).theme.spacing`
    *   `context.justRadius` -> `JustThemeProvider.of(context, aspect: .radius).theme.radius`
    *   `context.justShadows` -> `JustThemeProvider.of(context, aspect: .shadows).theme.shadows`
    *   `context.justAnimations` -> `JustThemeProvider.of(context, aspect: .animations).theme.animations`
    *   `context.readTheme()` -> `JustThemeProvider.read(context).theme`

#### 1.2.2. ThemeData Lazy-Caching

In `lib/src/theme/theme_data.dart`:
```dart
  // Cached material theme data.
  ThemeData? _cachedThemeData;

  /// Converts this [JustThemeData] configuration into Flutter [ThemeData].
  ///
  /// Caches the output value. Repeated calls return the same instance.
  ThemeData toThemeData() {
    return _cachedThemeData ??= _buildMaterialTheme();
  }
```
*   The cached instance is fully immutable. Since a new `JustThemeData` is returned via `copyWith` (instantiating a new object with `_cachedThemeData = null`), the cache is safely invalidated when modifications are applied.

#### 1.2.3. Dynamic Contrast Enforcement (`JustThemeData.fromSeed`)

`JustThemeData.fromSeed` enforces WCAG AA compliance by dynamically adjusting primary and semantic state colors against the generated background:
1.  **Lightness Adjustment (`_makeAccessible`)**:
    *   Checks if the contrast ratio is below the minimum threshold.
    *   Determines the background brightness: `isBgDark = background.computeLuminance() < 0.5`.
    *   Loops and increments/decrements `currentLightness` by `0.02`:
    ```dart
    while (currentLightness >= 0.0 && currentLightness <= 1.0) {
      if (isBgDark) {
        currentLightness += step;
        if (currentLightness > 1.0) break;
      } else {
        currentLightness -= step;
        if (currentLightness < 0.0) break;
      }
      final adjusted = hsl.withLightness(currentLightness).toColor();
      if (adjusted.contrastRatioWith(background) >= minRatio) return adjusted;
    }
    ```
    *   Falls back to pure white or black if the target ratio cannot be met.
2.  **Color Enforcement Targets**:
    *   Primary (`borderFocusColor`) is checked against background for a `3.0` ratio.
    *   Semantic State Colors (`success`, `error`, `info`) are checked against background for a `4.5` ratio.
    *   `warning` is checked against background for a `3.0` ratio.

#### 1.2.4. Component Catalog

The directory `lib/src/components` contains the following component subdirectories:
*   `avatar`, `badge`, `bottom_nav`, `breadcrumb`, `button`, `card`, `checkbox`, `input`, `radio`, `scroll`, `separator`, `sidebar`, `skeleton`, `switch`, `tabs`, and `shared`.

**Component Implementation Patterns**:
*   **Separation of Concerns**: Uses a 4-file bundle per component (e.g. `just_button.dart`, `just_button_style.dart`, `just_button_variants.dart`, `just_button_theme.dart`).
*   **Specific Rebuild Aspect Subscription**: Components like `JustButton` fetch tokens using specific aspects:
    ```dart
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(context, aspect: .typography).theme.typography;
    final spacing = JustThemeProvider.of(context, aspect: .spacing).theme.spacing;
    ```
*   **Touch Targets**: Ensures touch target size compliance (minimum 48px height/width check) using `ConstrainedBox`.
*   **Accessibility semantics**: Wraps widgets in `Semantics` (e.g., `button: true`).
*   **Interactive states & Focus indicators**: Uses `JustPressable` and custom `FocusIndicator` to coordinate hover/focus/pressed visual updates.

---

### 1.3. packages/just_ui_cli/

The CLI utility facilitates the copy-paste component scaffolding workflow.

#### 1.3.1. Code Structure

*   `bin/just_ui_cli.dart` calls `runCli` with `const LocalFileSystem()`.
*   `lib/just_ui_cli.dart` adds commands to `CommandRunner` and runs arguments.
*   `lib/src/commands/`:
    *   `init_command.dart`: Initializes `justui.config.yaml` and bootstraps `lib/theme/just_theme.dart`.
    *   `add_command.dart`: Downloads and validates components.
    *   `list_command.dart`: Retrieves registry index and groups components by category.
    *   `diff_command.dart`: Shows local files modification states and line diffs.
    *   `update_command.dart`: Pulls changes from registry.
    *   `create_command.dart`: Scaffolds a custom component locally.
*   `lib/src/config/justui_config.dart` parses `justui.config.yaml` options (`components_dir`, `tokens_dir`, `registry_url`).
*   `lib/src/registry/registry_client.dart` fetches `index.json` and file contents (supports local file scheme and remote HTTP).

#### 1.3.2. Scaffolding & Copy-Paste Mechanics

*   **Security integrity check**: During `add`, the client computes the SHA-256 hash of the downloaded file content and validates it against the expected registry checksum.
*   **Conflict resolution**: If a local file has modified content (assessed via SHA-256 mismatch), the user is prompted: `Choose action: [o] Overwrite, [s] Skip, [d] Show Diff`.
*   **Registry Dependency resolution**: Resolves and downloads dependent components recursively before writing the parent component.
*   **Third-party pub dependencies**: Injects external pub packages listed in the component metadata into the user's `pubspec.yaml` using `PubspecEditor`.
*   **Scaffolding custom components (`create` command)**: Generates the 4-file bundle template (`*_style.dart`, `*_variants.dart`, `*_theme.dart`, `*.dart`) populated with default class names and imports.

---

### 1.4. Sandbox and Development Constraints

*   **Offline sandbox**: The sandbox is completely offline. Any attempt to download dependencies from pub.dev will fail. All dependencies are pre-configured locally inside `.dart_tool/package_config.json`.
*   **Telemetry Workaround**: Dart telemetry attempts to write to the system home directory which causes permission failures. The environment variable `HOME` must be overridden:
    ```bash
    export HOME=/home/yourblooo/development/justui/.home
    ```
*   **Static Analysis command**:
    ```bash
    export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/just_ui_core
    export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/just_ui_tokens
    ```
*   **Testing command**: Direct test execution in sandbox fails because there is no Flutter SDK. In user-land, tests are run via:
    ```bash
    flutter test packages/just_ui_tokens
    flutter test packages/just_ui_core
    ```

---

## 2. Logic Chain

1.  **Observing Color contrast checks**: In `colors_accessibility.dart`, the contrast math directly scales according to relative luminance values.
2.  **Observing HSL adjustments**: In `colors_dynamic.dart` and `theme_data.dart`, `adjustLightnessForContrast` and `_makeAccessible` shift the lightness step-by-step to enforce compliance.
3.  **Observing Aspect Rebuilds**: The `_JustThemeModel` class implements `InheritedModel<JustThemeAspect>` and compares specific fields in `updateShouldNotifyDependent`. Context extensions like `context.justColors` pass the correct aspect key to `InheritedModel.inheritFrom`. This validates that changes in one aspect (e.g. colors) do not rebuild components subscribed to other aspects (e.g. typography).
4.  **Observing Lazy ThemeData Caching**: Since `ThemeData` is built dynamically, caching it in `_cachedThemeData` ensures that subsequent build cycles return the exact same instance in memory, validating the claim of zero recalculation overhead.
5.  **Observing CLI workflow**: Reviewing commands and code in `packages/just_ui_cli` confirms that component files are copied directly into the directories specified in the YAML configuration. Mismatch checks using SHA-256 hashes prevent accidental overrides.

---

## 3. Caveats

*   **Flutter SDK missing in sandbox**: We could not run tests or commands using the full Flutter SDK in the sandbox environment. All observations are based on code inspections and verification of unit test files.
*   **Registry URL configuration**: In offline mode, the CLI registry client defaults to fetching from a local file directory if configured, but default production targets GitHub raw files.

---

## 4. Conclusion

The JustUI monorepo presents a modern, highly optimized architecture for a copy-paste UI component library:
*   `just_ui_tokens` provides fine-grained visual primitives and accessibility compliance utilities.
*   `just_ui_core` implements an aspect-based theme propagation system using `InheritedModel` that minimizes widget rebuild overhead and caches built themes.
*   `just_ui_cli` automates component copy-pasting, dependency resolution, checksum validation, conflict resolution, and package configuration in target projects.

---

## 5. Verification Method

To verify the codebase and theme constraints in user-land (where Flutter SDK is available):
1.  **Analyze packages**:
    ```bash
    export HOME=/home/yourblooo/development/justui/.home
    dart analyze packages/just_ui_tokens
    dart analyze packages/just_ui_core
    dart analyze packages/just_ui_cli
    ```
2.  **Run tests**:
    ```bash
    flutter test packages/just_ui_tokens
    flutter test packages/just_ui_core
    ```
3.  **Validate aspect rebuilds**: Inspect `packages/just_ui_core/test/theme_test.dart` lines 251-306, which asserts that widgets subscribed to a specific aspect are rebuilt appropriately on theme changes.
