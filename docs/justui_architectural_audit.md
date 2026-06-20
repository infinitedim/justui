# JustUI Monorepo Architectural Documentation & Code Audit Report

## 1. Introduction

JustUI is a high-performance, developer-centric Flutter UI component library designed with a copy-paste architecture model (heavily inspired by the design philosophy of shadcn/ui). 

Unlike traditional UI libraries that require installation as external third-party packages from `pub.dev`, JustUI components are integrated directly into the user's codebase. Using the JustUI CLI (`just_ui_cli`), developers copy the source code of specific components directly into their project directories. 

This architectural decision has two major advantages:
1. **Zero-Dependency Footprint**: The components rely exclusively on core Flutter SDK primitives, keeping the project's dependency graph clean and free of third-party version conflicts.
2. **Infinite Customizability**: Since the source code lives directly within the developer's project, they can customize, modify, and style any component down to its raw canvas and widget layout level without fork maintenance overhead.

This audit report documents the underlying design token primitives, the optimized rebuild engine, component catalog conventions, CLI tool scaffolding, and sandbox development constraints.

---

## 2. Design Tokens & Accessibility (packages/just_ui_tokens)

The `just_ui_tokens` package represents the core design primitives of JustUI. All values are represented as compile-time (`const`) constants to minimize memory footprints and optimize rendering execution.

### 2.1. Primitive Token Definitions

#### Screen Breakpoints
Defined in `lib/src/breakpoints.dart` within the `JustBreakpoints` class. These provide standard layout boundaries for responsive design and media queries:
*   `sm`: `640.0` (Mobile landscape / small tablets)
*   `md`: `768.0` (Tablets / portrait iPads)
*   `lg`: `1024.0` (Landscape tablets / standard desktop monitors)
*   `xl`: `1280.0` (Large desktop monitors)
*   `xxl`: `1536.0` (Hi-res screens / high-DPI displays)

#### Raw Color Palette
Defined in `lib/src/colors/color_palette.dart` within the `JustColorPalette` class. This defines pure `white` (`0xFFFFFFFF`), `black` (`0xFF000000`), and a series of 11-step scales (ranging from `50` to `950`) for the following palettes:
*   `neutral` (Slate-based colors)
*   `primary` (Branded blue scale)
*   `success` (Green scale)
*   `warning` (Amber scale)
*   `error` (Red scale)
*   `info` (Cyan scale)

#### Semantic Colors
Defined in `lib/src/colors/color_semantic.dart`. The classes `JustColorSemanticLight` and `JustColorSemanticDark` map functional keys to specific primitive shades in the color palette:
*   **Surfaces**: `background`, `card`, `elevated`, `overlay`.
*   **Typography**: `textPrimary`, `textSecondary`, `textDisabled`, `textInverse`.
*   **Borders**: `borderDefault`, `borderFocus`, `borderError`.
*   **Feedback**: `success`, `warning`, `error`, `info`.

#### Corner Radius
Defined in `lib/src/radius.dart`. The `JustRadius` class contains:
*   `none`: `0.0`
*   `xs`: `2.0`
*   `sm`: `4.0`
*   `md`: `8.0`
*   `lg`: `12.0`
*   `xl`: `16.0`
*   `xxl`: `24.0`
*   `full`: `9999.0`

The `JustBorderRadius` helper class maps these values directly to pre-instantiated `BorderRadius` instances (e.g. `JustBorderRadius.md = BorderRadius.all(JustRadius.md)`), eliminating runtime instantiation boilerplate.

#### Spacing Scales
Defined in `lib/src/spacing.dart` using a strict `4px` grid system:
*   `xxs`: `2.0` (micro gaps, inline elements)
*   `xs`: `4.0` (tight spacing)
*   `sm`: `8.0` (base gap between text/blocks)
*   `md`: `12.0` (default badge/small card padding)
*   `lg`: `16.0` (standard container margins/paddings)
*   `xl`: `24.0` (page headers / cards)
*   `xxl`: `32.0` (major section gaps)
*   `xxxl`: `48.0` (layout boundaries)
*   `huge`: `64.0` (massive vertical gaps / hero page padding)

`JustGap` translates these constants into corresponding horizontal and vertical `SizedBox` spacers (e.g. `JustGap.md`).

#### Typography
Defined in `lib/src/typography.dart` within the `JustTypo` class. It loads standard font families `Inter` (sans-serif) and `JetBrains Mono` (monospace), alongside text styles:
*   `displayLg` (36px, height 1.15), `displayMd` (30px), `displaySm` (24px).
*   `headingLg` (20px), `headingMd` (18px), `headingSm` (16px).
*   `bodyLg` (16px), `bodyMd` (14px), `bodySm` (12px).
*   `caption` (11px, height 1.3), `overline` (10px).

Fluid typography is supported in `lib/src/typography_fluid.dart` via `JustFluidTypography` which recalculates font sizes dynamically relative to the current viewport scale.

#### Durations & Curves
Defined in `lib/src/duration.dart`:
*   `JustDuration.instant`: `50ms` (active/pressed states)
*   `JustDuration.fast`: `150ms` (hover/focus transitions)
*   `JustDuration.normal`: `250ms` (collapses, switches, default transitions)
*   `JustDuration.slow`: `400ms` (page sheet sweeps)
*   `JustDuration.slower`: `600ms` (complex choreographed layouts)

`JustDuration.scaleForDistance(double distancePixels)` maps pixel displacement to transition speed dynamically. `JustCurves` provides:
*   `default_`: `Curves.easeInOut`
*   `enter`: `Curves.easeOut`
*   `exit`: `Curves.easeIn`
*   `spring`: `Curves.elasticOut`

#### Motion Profiles
Defined in `lib/src/motion.dart`. The class `JustMotionProfile` manages transitions dynamically. If `MediaQuery.disableAnimationsOf(context)` returns `true` (indicating system-wide reduced motion preferences), the `reduced` profile overrides active transitions, clamping durations to `Duration.zero` and curves to `Curves.linear`.

#### Ambient Brand-Tinted Shadows
Defined in `lib/src/shadows.dart`. The `JustShadows` class provides ambient multi-layered shadows. Custom shadows are generated using the `generate({required Color seedColor, required double elevation, bool isDark = false})` method, which blends the brand seed hue into the shadow color channels to ensure cohesive visual styling rather than standard grey/black shadows.

---

### 2.2. Accessibility Contrast Auditor

JustUI contains a programmatic contrast validation engine implemented within `lib/src/colors/colors_accessibility.dart` as an extension on Flutter’s `Color` object.

#### Mathematical Formulas
The accessibility engine follows WCAG 2.0 guidelines for color contrast checks.

1.  **Relative Luminance ($L$)**
    Relative luminance is the relative brightness of any point in a color space, normalized to $0.0$ for darkest black and $1.0$ for lightest white. JustUI leverages Flutter's built-in `Color.computeLuminance()` which implements the relative luminance formula:
    
    $$L = 0.2126 \times R + 0.7152 \times G + 0.0722 \times B$$
    
    Where the red, green, and blue color channels are linearized from sRGB space:
    
    $$\text{For } C_{srgb} \in \{R, G, B\}:$$
    
    $$\text{if } C_{srgb} \le 0.03928 \implies C = \frac{C_{srgb}}{12.92}$$
    
    $$\text{else} \implies C = \left(\frac{C_{srgb} + 0.055}{1.055}\right)^{2.4}$$

2.  **Contrast Ratio Calculation**
    The contrast ratio between two colors is calculated as:
    
    $$\text{Ratio} = \frac{L_{lightest} + 0.05}{L_{darkest} + 0.05}$$
    
    Where $L_{lightest}$ is the relative luminance of the lighter color, and $L_{darkest}$ is the relative luminance of the darker color. The $0.05$ offset represents ambient light flare. The resulting ratio is clamped between $1.0$ (identical colors) and $21.0$ (perfect high-contrast black and white).

#### Code Implementation
The calculations are exposed via `contrastRatioWith` and `isAccessibleWith` methods:

```dart
extension JustColorAccessibility on Color {
  /// Calculates the contrast ratio against another [Color].
  double contrastRatioWith(Color other) {
    final double l1 = computeLuminance();
    final double l2 = other.computeLuminance();

    if (l1 > l2) {
      return (l1 + 0.05) / (l2 + 0.05);
    } else {
      return (l2 + 0.05) / (l1 + 0.05);
    }
  }

  /// Verifies if this color is accessible when paired with [other] under WCAG AA standards.
  ///
  /// For normal text, a contrast ratio of at least 4.5:1 is required.
  /// For large text (18pt/24px or bold 14pt/18.67px), a ratio of at least 3.0:1 is required.
  bool isAccessibleWith(Color other, {bool isLargeText = false}) {
    final double ratio = contrastRatioWith(other);
    return ratio >= (isLargeText ? 3.0 : 4.5);
  }
}
```

---

## 3. Theme Engine & Provider (packages/just_ui_core)

The theming engine in `just_ui_core` propagates design tokens throughout the widget tree. It is optimized to eliminate unnecessary widget rebuilds during theme updates and to minimize overhead when building Flutter's internal `ThemeData` representation.

### 3.1. Aspect-Based Rebuilds via InheritedModel

Standard Flutter configurations using `InheritedWidget` cause all descendant widgets to rebuild when any field in the inherited widget changes. JustUI solves this using an aspect-based mechanism based on `InheritedModel`.

#### The Theme Aspects
The theme data is split into distinct facets using the `JustThemeAspect` enum (defined in `lib/src/theme/theme_aspects.dart`):

```dart
enum JustThemeAspect {
  colors,
  typography,
  spacing,
  radius,
  shadows,
  animations,
}
```

#### Inherited Model Implementation
In `lib/src/theme/theme_provider.dart`, the provider uses the internal `_JustThemeModel` class:

```dart
class _JustThemeModel extends InheritedModel<JustThemeAspect> {
  const _JustThemeModel({
    required this.state,
    required this.themeMode,
    required this.themeData,
    required super.child,
  });

  final JustThemeProviderState state;
  final ThemeMode themeMode;
  final JustThemeData themeData;

  @override
  bool updateShouldNotify(_JustThemeModel oldWidget) {
    return themeMode != oldWidget.themeMode || themeData != oldWidget.themeData;
  }

  @override
  bool updateShouldNotifyDependent(
    _JustThemeModel oldWidget,
    Set<JustThemeAspect> dependencies,
  ) {
    if (dependencies.contains(JustThemeAspect.colors) &&
        themeData.colors != oldWidget.themeData.colors) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.typography) &&
        themeData.typography != oldWidget.themeData.typography) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.spacing) &&
        themeData.spacing != oldWidget.themeData.spacing) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.radius) &&
        themeData.radius != oldWidget.themeData.radius) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.shadows) &&
        themeData.shadows != oldWidget.themeData.shadows) {
      return true;
    }
    if (dependencies.contains(JustThemeAspect.animations) &&
        themeData.animations != oldWidget.themeData.animations) {
      return true;
    }
    return false;
  }
}
```

#### BuildContext Extensions
In `lib/just_ui_core.dart`, extensions register widgets to specific aspects. If a widget only listens to colors, a typography change will not trigger a rebuild for it:

```dart
extension JustThemeContext on BuildContext {
  /// Subscribes to the entire theme (avoid using in small layout leaf widgets).
  JustThemeData get justTheme => JustThemeProvider.of(this).theme;

  /// Subscribes only to color changes.
  JustColorScheme get justColors =>
      JustThemeProvider.of(this, aspect: .colors).theme.colors;

  /// Subscribes only to typography changes.
  JustTypographyScheme get justTypo =>
      JustThemeProvider.of(this, aspect: .typography).theme.typography;

  /// Subscribes only to spacing changes.
  JustSpacingScheme get justSpacing =>
      JustThemeProvider.of(this, aspect: .spacing).theme.spacing;

  /// Subscribes only to radius changes.
  JustRadiusScheme get justRadius =>
      JustThemeProvider.of(this, aspect: .radius).theme.radius;

  /// Subscribes only to shadow changes.
  JustShadowScheme get justShadows =>
      JustThemeProvider.of(this, aspect: .shadows).theme.shadows;

  /// Subscribes only to animation/motion profile changes.
  JustMotionProfile get justAnimations =>
      JustThemeProvider.of(this, aspect: .animations).theme.animations;
}
```

---

### 3.2. Lazy-Cached Material ThemeData

Generating Flutter’s `ThemeData` dynamically on every rebuild is computationally expensive due to internal nested configurations (decoration themes, button styles, color schemes). JustUI implements caching in `JustThemeData` (defined in `lib/src/theme/theme_data.dart`):

```dart
class JustThemeData {
  // ... schemes declarations ...

  // Cached material theme data.
  ThemeData? _cachedThemeData;

  /// Converts this [JustThemeData] configuration into Flutter [ThemeData].
  ///
  /// Caches the output value. Repeated calls return the same instance.
  ThemeData toThemeData() {
    return _cachedThemeData ??= _buildMaterialTheme();
  }
}
```

#### Cache Invalidation Strategy
Because `JustThemeData` is immutable, modifications must go through a `copyWith(...)` helper. This method instantiates a brand new `JustThemeData` instance. Since the new instance initializes `_cachedThemeData` to `null`, the cache is safely and automatically invalidated without mutable state errors:

```dart
  JustThemeData copyWith({
    JustColorScheme? colors,
    JustTypographyScheme? typography,
    JustSpacingScheme? spacing,
    JustRadiusScheme? radius,
    JustShadowScheme? shadows,
    JustMotionProfile? animations,
  }) {
    return JustThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      animations: animations ?? this.animations,
    );
  }
```

---

### 3.3. Seeding & Dynamic Contrast Enforcement

To ensure visual accessibility even when themes are generated from random user input, `JustThemeData.fromSeed` dynamically adjusts colors at runtime.

#### The Lightness Search Algorithm (`_makeAccessible`)
When a color does not meet WCAG AA contrast criteria against the background surface, JustUI uses a linear HSL step adjustment to find a compliant lightness level:

```dart
  static Color _makeAccessible(
    Color color,
    Color background, {
    double minRatio = 3.0,
  }) {
    if (color.contrastRatioWith(background) >= minRatio) {
      return color;
    }
    final HSLColor hsl = .fromColor(color);
    final isBgDark = background.computeLuminance() < 0.5;
    double currentLightness = hsl.lightness;
    const double step = 0.02;

    while (currentLightness >= 0.0 && currentLightness <= 1.0) {
      if (isBgDark) {
        currentLightness += step;
        if (currentLightness > 1.0) break;
      } else {
        currentLightness -= step;
        if (currentLightness < 0.0) break;
      }
      final adjusted = hsl.withLightness(currentLightness).toColor();
      if (adjusted.contrastRatioWith(background) >= minRatio) {
        return adjusted;
      }
    }
    return isBgDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }
```

In addition to `_makeAccessible`, the `JustColorContrastCorrection` extension on `Color` (defined in `lib/src/colors/colors_dynamic.dart` under the `just_ui_tokens` package) implements a binary search variation `adjustLightnessForContrast`:

```dart
extension JustColorContrastCorrection on Color {
  Color adjustLightnessForContrast({
    required Color background,
    double targetRatio = 4.5,
  }) {
    final double currentRatio = contrastRatioWith(background);
    if (currentRatio >= targetRatio) return this;

    final double bgLuminance = background.computeLuminance();
    final HSLColor hsl = .fromColor(this);
    final bool makeLighter = bgLuminance < 0.5;

    double low = makeLighter ? hsl.lightness : 0.0;
    double high = makeLighter ? 1.0 : hsl.lightness;
    Color bestColor = this;

    for (int i = 0; i < 8; i++) {
      final double mid = (low + high) / 2;
      final Color testColor = hsl.withLightness(mid).toColor();
      final double ratio = testColor.contrastRatioWith(background);

      if (ratio >= targetRatio) {
        bestColor = testColor;
        if (makeLighter) {
          high = mid;
        } else {
          low = mid;
        }
      } else {
        if (makeLighter) {
          low = mid;
        } else {
          high = mid;
        }
      }
    }
    return bestColor;
  }
}
```

#### Enforcement Rules
When creating a theme from a seed color via `JustThemeData.fromSeed(...)`:
1.  **Primary Brand Color (`borderFocus`)**: Audited against the background to guarantee at least a **$3.0:1$** contrast ratio (WCAG AA standard for large components).
2.  **Semantic State Colors (`success`, `error`, `info`)**: Checked against the background to guarantee at least a **$4.5:1$** contrast ratio (WCAG AA standard for body copy/text).
3.  **Warning State Color (`warning`)**: Checked against the background to guarantee at least a **$3.0:1$** contrast ratio.

---

### 3.4. Best Practices for Theme Consumption

To maintain rendering efficiency, developers should adhere to the following theme consumption guidelines:

*   **Build Methods (Registering Bindings)**: Use specific aspect extensions (`context.justColors`, `context.justTypo`, `context.justSpacing`) rather than the monolithic `context.justTheme`. This ensures widgets only rebuild when relevant tokens are modified.
*   **Callbacks and Methods (Non-Registering Bindings)**: Never use registering extensions inside event handlers like `onPressed` or `onTap`. Instead, use `context.readTheme()`. This reads the active values without adding the callback context as a listener to the theme provider, preventing unnecessary rebuild cycles.

---

## 4. Component Catalog & Scaffolding Workflow

### 4.1. Component Catalog Listing

The components in JustUI are located in the `packages/just_ui_core/lib/src/components` directory. This catalog contains the following subdirectories:

1.  `avatar`: Avatar widgets, avatar groupings, and fallback text generation.
2.  `badge`: Numerical and text badge indicators.
3.  `bottom_nav`: Accessible bottom navigation bars.
4.  `breadcrumb`: Hierarchical navigation indicators.
5.  `button`: Standard button, icon button, and button group containers.
6.  `card`: Content containers with optional shadows and borders.
7.  `checkbox`: State-driven checkboxes.
8.  `input`: Text field wrappers with floating labels and error indicators.
9.  `radio`: Radio selection groupings and buttons.
10. `scroll`: Custom scroll area layouts with custom scrollbars.
11. `separator`: Layout dividers.
12. `shared`: Helper wrappers (`JustPressable`, `FocusIndicator`, `JustProgressSpinner`).
13. `sidebar`: Adaptive collapsible navigation drawer bars.
14. `skeleton`: Placeholder loading states.
15. `switch`: Accessible toggles.
16. `tabs`: Tab headers and content navigators.

---

### 4.2. Component Implementation Patterns

Each component is written according to a standardized pattern:

#### Separation of Concerns (The 4-File Bundle)
Each component contains four files:
*   `just_[name].dart`: The main widget tree implementation (e.g. state management, gesture handlers).
*   `just_[name]_style.dart`: The properties layout definitions (borders, paddings, color mappings).
*   `just_[name]_variants.dart`: The enums representing component variants or size classifications.
*   `just_[name]_theme.dart`: The theme configuration to allow system-wide visual defaults.

#### Specific Aspect Subscriptions
Components subscribe only to the layout tokens they need:

```dart
final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
final typography = JustThemeProvider.of(context, aspect: .typography).theme.typography;
final spacing = JustThemeProvider.of(context, aspect: .spacing).theme.spacing;
```

#### Touch Target Compliance
To meet physical accessibility requirements, interactive targets must be at least **48x48px**. If a component has a visual size smaller than this (e.g., small buttons, checkboxes), it is wrapped in a `ConstrainedBox` to ensure the hit region is expanded:

```dart
ConstrainedBox(
  constraints: BoxConstraints(
    minHeight: height < 48.0 ? 48.0 : height,
    minWidth: width < 48.0 ? 48.0 : width,
  ),
  child: ...
)
```

#### Semantics
Components are wrapped in Flutter's `Semantics` widget to expose correct roles and values to screen readers:

```dart
Semantics(
  button: true,
  label: widget.isLoading ? 'Loading ${widget.label}' : widget.label,
  enabled: isInteractive,
  child: ...
)
```

#### Focus & Interactive State Management
JustUI encapsulates hover, pressed, and focus states in the `JustPressable` widget (defined in `lib/src/components/shared/just_pressable.dart`). It uses `ValueNotifier` and `Listenable.merge` to minimize rebuilds:

```dart
class JustPressable extends StatefulWidget {
  // ...
  final JustPressableBuilder builder;
  // ...
}
```

Focus rings are rendered outside the widget layout bounds via `FocusIndicator` (defined in `lib/src/components/shared/just_focus_indicator.dart`), which draws a 2px stroke using `CustomPaint` offset by 3px. This prevents the layout shifting that occurs when adjusting inline borders.

---

### 4.3. CLI Scaffolding and Copy-Paste Workflow

The `just_ui_cli` package is a Dart command-line application used to copy component source code into user projects.

#### CLI Architecture
*   **Entrypoint**: `bin/just_ui_cli.dart` invokes `runCli(arguments, const LocalFileSystem())`.
*   **Command Runner**: Configured in `lib/just_ui_cli.dart` using the standard `args` package. Commands registered:
    *   `InitCommand`: Instantiates `justui.config.yaml` and generates the local theming entry point `lib/theme/just_theme.dart`.
    *   `AddCommand`: Resolves and copies components from the registry.
    *   `ListCommand`: Queries and displays all available components in the registry.
    *   `DiffCommand`: Computes line-by-line diffs between local components and registry originals.
    *   `UpdateCommand`: Overwrites local copies with newer registry versions.
    *   `CreateCommand`: Generates a local 4-file bundle template for custom component development.
*   **Configuration**: `lib/src/config/justui_config.dart` parses settings from the YAML file, including target locations:
    *   `components_dir`: Root folder for copied widgets (default: `lib/ui`).
    *   `tokens_dir`: Folder for style primitive tokens (default: `lib/tokens`).
    *   `registry_url`: Base URL of the component registry.

#### The `add` Scaffolding Engine

```
[User runs 'justui add <component>']
                  │
                  ▼
   ┌──────────────────────────────┐
   │ Fetch Registry Index JSON   │
   └──────────────┬───────────────┘
                  │
                  ▼
   ┌──────────────────────────────┐
   │ Recursive Dep Resolution     │  ◄─── Calls addComponent recursively
   └──────────────┬───────────────┘       for dependencies
                  │
                  ▼
   ┌──────────────────────────────┐
   │ Fetch Component File Contents│
   └──────────────┬───────────────┘
                  │
                  ▼
   ┌──────────────────────────────┐
   │ Compute SHA-256 Checksum     │
   └──────────────┬───────────────┘
                  │
      [Mismatched Checksum]
                  ├──────────────────────────────► [Throw Corrupted Download Error]
                  │
         [Matched Checksum]
                  │
                  ▼
   ┌──────────────────────────────┐
   │   File Already Exists?       │
   └──────────────┬───────────────┘
                  ├─── (No) ──► [Write File to Disk]
                  │
                (Yes)
                  │
                  ▼
   ┌──────────────────────────────┐
   │ Compare Local & Registry Hash│
   └──────────────┬───────────────┘
                  ├─── (Equal) ──► [Skip (Already Up-To-Date)]
                  │
             (Mismatched)
                  │
                  ▼
   ┌──────────────────────────────┐
   │ Prompt User Conflict Action  │
   └──────────────┬───────────────┘
                  ├─── [Overwrite (o)] ──► [Write File to Disk]
                  ├─── [Skip (s)]      ──► [Ignore File Change]
                  └─── [Show Diff (d)] ──► [Print Line Diff] ──► (Loop back to Prompt)
```

1.  **Security Checksum Validation**:
    Files are validated using SHA-256 checksums to ensure they haven't been tampered with or corrupted during download:
    ```dart
    final bytes = utf8.encode(content);
    final downloadedHash = sha256.convert(bytes).toString();
    final expectedHash = file.checksum.replaceAll('sha256:', '').trim();
    if (downloadedHash != expectedHash) {
      throw Exception('Security check failed: Checksum mismatch.');
    }
    ```
2.  **Conflict Resolution**:
    If a component file already exists locally, the CLI compares the local file's SHA-256 hash against the registry's expected hash. If there are local modifications, the user is prompted:
    `Choose action: [o] Overwrite, [s] Skip, [d] Show Diff`
    Selecting `[d]` prints a line-by-line git-like terminal diff.
3.  **Recursive Registry Dependencies**:
    The scaffolding engine resolves dependencies recursively to ensure that all prerequisites (e.g. `shared` components or primitive tokens) are downloaded and configured before writing the target component.
4.  **Pub Dependencies Injection**:
    If a component requires external pub.dev dependencies, the CLI updates the user's `pubspec.yaml` using a parsing wrapper `PubspecEditor` (defined in `lib/src/utils/pubspec_editor.dart`).
    The editor creates a backup file (`pubspec.yaml.bak`), parses the YAML structure to verify if the dependency is already present, and uses string manipulation to append the version constraint below the root `dependencies:` line. This targeted insertion preserves comments, indentation, and formatting.

---

## 5. Development & Sandbox Constraints

The JustUI monorepo environment is configured with strict constraints.

### 5.1. Offline Package Configuration
The sandbox has no internet connectivity. All dependencies are pre-configured locally inside `.dart_tool/package_config.json`. Do not delete or overwrite this directory, as doing so will break package resolutions.

### 5.2. Telemetry Override
Dart and Flutter telemetry configurations attempt to write to system directory paths that are read-only in the sandbox environment. To prevent telemetry errors and build failures, you must override the `HOME` environment variable to point to a writable local project directory when running Dart commands:

```bash
export HOME=/home/yourblooo/development/justui/.home
```

### 5.3. Static Analysis
Run the following commands from the root directory to verify code formatting and static analysis compliance:

```bash
export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/just_ui_tokens
export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/just_ui_core
export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/just_ui_cli
```

### 5.4. Unit Testing
Because the sandbox environment lacks the full Flutter SDK, running test commands directly within the sandbox will fail. Tests must be executed in a environment with a complete Flutter SDK using:

```bash
flutter test packages/just_ui_tokens
flutter test packages/just_ui_core
```

Visual rebuild tests are located in `packages/just_ui_core/test/theme_test.dart` (lines 251–348). These verify that widgets subscribed to specific aspects (e.g., colors) rebuild correctly, and include negative validation assertions (using theme changes and viewport rescales) to prove that widgets subscribed to other aspects (e.g., spacing or radius) remain unaffected by unrelated updates.
