# Phase 3: Core Theme Engine

Status: Draft v1 (2026-10-13)
Depends on: P2
Blocks: P4, P7 (Dart snippets), P8
Areas: `packages/core/lib/src/theme`

## 1. Summary

Move every remaining preset decision out of `JustThemeData` and into
`JustPresetTokens`, add the Ink and Paper theme factory with a tint parameter,
deprecate `fromSeed`, rewrite high contrast mode, and remap the Material
bridge to the new roles.

## 2. Background

1. `theme_data.dart` still compares `preset == .neobrutalism` in
   `shadowOffset`, `resolveShadows` and four places in `fromSeed`
   (`03-baseline-audit.md` section 5.1).
2. `showsDefaultBorder` is a boolean that components use for color choices
   (130 references). It hides several decisions behind one flag.
3. `fromSeed` exists to generate an accent from a seed color. Ink and Paper has
   no accent.
4. `applyHighContrastOverrides` swaps the canvas to pure black or white.
5. The Material bridge maps `borderFocus` to Material primary.

## 3. Goals

1. Zero preset comparisons in the theme engine.
2. A preset contract rich enough that components never need
   `showsDefaultBorder` again.
3. One factory, `JustThemeData.inkAndPaper`, that covers both presets, both
   brightnesses and any safe tint.
4. High contrast mode that keeps the brand canvas and collapses hierarchy.

## 4. Non-goals

1. Component changes (P4).
2. New presets.
3. Changing the 8 fields of `JustThemeData` (unless DP-9 says so).

## 5. Functional requirements

### FR-3.1 New `JustPresetTokens` members

Each member is implemented in `DefaultPresetTokens` and
`NeobrutalismPresetTokens`:

| Member                                                                                   | Default                 | Neobrutalism                                           |
| ---------------------------------------------------------------------------------------- | ----------------------- | ------------------------------------------------------ |
| `Offset get shadowOffset`                                                                | `Offset.zero`           | `Offset(4, 4)`                                         |
| `List<BoxShadow> resolvePressedShadows(List<BoxShadow> base, {required bool isPressed})` | unchanged               | offset zero when pressed                               |
| `JustPrimaryEmphasis get primaryEmphasis` (new enum `{ inverseFill, elevatedSurface }`)  | `inverseFill`           | `elevatedSurface`                                      |
| `Color resolveContainerBorderColor(JustColorScheme c)`                                   | `c.borderSubtle`        | `c.textPrimary`                                        |
| `Color resolveControlBorderColor(JustColorScheme c)`                                     | `c.borderControl`       | `c.textPrimary`                                        |
| `double get containerBorderWidth`                                                        | 1.0                     | 2.5                                                    |
| `double get focusRingWidth`                                                              | 2.0                     | 2.5                                                    |
| `double get focusRingGap`                                                                | 2.0                     | 2.0                                                    |
| `double get errorBorderWidth`                                                            | 2.0                     | 3.0                                                    |
| `JustShadowScheme buildShadowScheme(JustColorScheme c, Brightness b)`                    | `InkShadowScheme(c, b)` | `NeobrutalismShadowScheme(shadowColor: c.textPrimary)` |
| `JustMotionProfile get defaultMotion`                                                    | `standard`              | `neobrutalism`                                         |
| `bool get selectedDropsShadow`                                                           | false                   | true                                                   |
| `double get secondaryShadowDepth`                                                        | 0                       | 2.0                                                    |
| `FontWeight get primaryLabelWeight`                                                      | `.w500`                 | `.w700`                                                |

Part colors (`primaryBg`, `primaryFg`, `containerBorder`, and so on) come from
the generated part mapping (P1 FR-1.2). Add
`JustPresetParts resolveParts(JustColorScheme c)` that returns them as a
`const`-constructible value object, so components read
`presetTokens.resolveParts(colors).primaryBg` instead of branching. A part
mapped to `"transparent"` resolves to `Color(0x00000000)`, not to a role
getter (`JustColorScheme` has no `transparent` role).

### FR-3.2 Deprecate `showsDefaultBorder`

1. Annotate `@Deprecated('Use the specific preset token instead.')`.
2. Keep both implementations returning today's values until P4 removes every
   component read.
3. `resolveHoverDecoration` uses `colors.hoverFill` instead of an alpha of
   `borderDefault`; the neobrutalism border uses
   `resolveContainerBorderColor` and `containerBorderWidth`.

### FR-3.3 Shadow schemes

1. New `InkShadowScheme`: xs and sm empty; md to xxl one layer of
   `textPrimary` at 6% alpha (light) or 40% alpha (dark), blur 2 x elevation,
   no spread (`02-design-spec.md` section 7).
2. `NeobrutalismShadowScheme.shadowColor` becomes required (no pure black
   default). Offsets 2, 4, 6, 8, 10, 12 for xs to xxl.
3. `TintedShadowScheme`, `DefaultShadowSchemeLight` and
   `DefaultShadowSchemeDark` become `@Deprecated` and stay functional.
4. `packages/tokens/lib/src/shadows.dart` default values follow item 1; their
   color comes from `JustBrandPalette`.

### FR-3.4 `JustThemeData`

1. `shadowOffset` and `resolveShadows` delegate to `presetTokens`. No preset
   comparison remains in the file.
2. The static themes `light`, `dark`, `neobrutalismLight` and
   `neobrutalismDark` use the generated schemes,
   `presetTokens.buildShadowScheme` and `presetTokens.defaultMotion`.
3. New `JustTint` value class in `packages/core/lib/src/theme/tint.dart`:

```dart
class const JustTint({double hue = 80.0, double chroma = 0.0035}) {
  static const JustTint warm = JustTint();
  static const JustTint graphite = JustTint(hue: 260.0);
}
```

The constructor is `const`, so it can only assert, not change values:
`assert(hue >= 0.0 && hue < 360.0)` and
`assert(chroma >= 0.0 && chroma <= 0.010)` in the initializer list.
Clamping and hue normalization happen in a non-const
`factory JustTint.clamped({double hue, double chroma})` (used by the
`fromSeed` conversion; the Rust CLI validates its own input and writes a
plain `JustTint(hue: ...)` literal, so it never calls this factory) and again defensively inside
`inkAndPaper()` before calling the color engine. `static const warm` and
`graphite` stay compile-time constants. The class uses the primary
constructor syntax already used in the repository (for example
`class const JustBadge(`). It is exported through `theme_data.dart`, never
through a component.

4. New factory:

```dart
static JustThemeData inkAndPaper({
  required Brightness brightness,
  JustThemePreset preset = .default_,
  JustTint tint = .warm,
  JustTypographyScheme typography = const DefaultTypographyScheme(),
  JustSpacingScheme spacing = const DefaultSpacingScheme(),
  JustRadiusScheme radius = const DefaultRadiusScheme(),
  JustMotionProfile? animations,
  JustColorSpaceEngine colorSpace = .oklch,
})
```

- With `tint == JustTint.warm` it returns the generated const schemes, with
  no runtime color math.
- With any other tint it rebuilds the neutral steps once through
  `OklchEngine` from `JustBrandPalette.neutralLightness`. Status colors do
  not change. Nothing runs per frame.
- `animations` defaults to `preset.tokens.defaultMotion`.

5. `fromSeed` becomes `@Deprecated('Use JustThemeData.inkAndPaper')` and keeps
   its signature (option D, DP-4):
   - The seed's OKLCH hue becomes the tint hue with chroma 0.0035.
   - A seed with chroma below 0.02 maps to `JustTint.warm`.
   - `colorSpace` is accepted and ignored for color.
   - The result equals `inkAndPaper(brightness: ..., preset: ..., tint: ...)`.
6. `_makeAccessible` falls back to the mode's `textPrimary`, never to pure
   black or white.
7. `copyWith`, `operator ==` and `hashCode` keep their 8 fields. If DP-9 adds
   a `tint` field, all three change in the same commit.

### FR-3.5 High contrast

Rewrite `applyHighContrastOverrides` per `02-design-spec.md` section 5.6:

| Role                            | High contrast value                                             |
| ------------------------------- | --------------------------------------------------------------- |
| canvas, surface, raised, sunken | unchanged                                                       |
| textSecondary, textTertiary     | textPrimary                                                     |
| borderSubtle                    | borderControl                                                   |
| borderControl                   | textPrimary                                                     |
| inverseHover, inversePressed    | inverse                                                         |
| status roles                    | unchanged (already >= 7.68)                                     |
| focus ring width                | 3.0 (read by the focus indicator from MediaQuery high contrast) |

### FR-3.6 Material bridge (`theme_data_material.dart`)

| Material property                 | Role                                              |
| --------------------------------- | ------------------------------------------------- |
| colorScheme.primary, secondary    | inverse                                           |
| onPrimary, onSecondary            | onInverse                                         |
| error                             | error                                             |
| onError                           | onInverse                                         |
| surface                           | surface                                           |
| onSurface                         | textPrimary                                       |
| outline                           | borderControl                                     |
| outlineVariant                    | borderSubtle                                      |
| surfaceContainerHighest           | sunken                                            |
| inverseSurface / onInverseSurface | inverse / onInverse                               |
| scrim                             | scrim                                             |
| surfaceTint                       | `Color(0x00000000)`                               |
| scaffoldBackgroundColor           | canvas                                            |
| cardColor                         | surface                                           |
| dialog background                 | raised                                            |
| dividerColor                      | borderSubtle                                      |
| textSelectionTheme                | selection, cursor textPrimary, handle textPrimary |
| input enabled border              | borderControl 1.0                                 |
| input focused border              | focusRing 2.0                                     |
| input error border                | error 2.0                                         |

The line `// CLI:REGISTER_EXTENSIONS` (line 31) must stay byte-identical.

## 6. Non-functional requirements

1. NFR-3.1: `inkAndPaper` with the warm tint allocates no new `Color` objects.
2. NFR-3.2: Re-tinting runs once per theme build and takes under 1 ms.
3. NFR-3.3: Every new preset member has a doc comment that names the design
   rule it implements.
4. NFR-3.4: Switch expressions or lookup tables, no if/else chains (AGENTS.md
   section 9).

## 7. Files

| File                                                                                                 | Change                                           |
| ---------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `packages/core/lib/src/theme/preset_tokens.dart`                                                     | New members, deprecation                         |
| `packages/core/lib/src/theme/schemes/shadow_scheme.dart`                                             | InkShadowScheme, required shadow color           |
| `packages/tokens/lib/src/shadows.dart`                                                               | Default shadow values                            |
| `packages/core/lib/src/theme/theme_data.dart`                                                        | Delegation, inkAndPaper, fromSeed, high contrast |
| `packages/core/lib/src/theme/tint.dart`                                                              | New                                              |
| `packages/core/lib/src/theme/theme_data_material.dart`                                               | Remap                                            |
| `packages/core/test/theme_test.dart`, `theme_schemes_test.dart`, `accessibility_semantics_test.dart` | Updated                                          |
| `.changeset-polyglot/ink-and-paper-core.md`                                                          | New                                              |

## 8. Tasks

| ID    | Task                                                                   | Depends on     |
| ----- | ---------------------------------------------------------------------- | -------------- |
| P3.T1 | Preset token members and parts (FR-3.1, FR-3.2)                        | P2             |
| P3.T2 | Shadow schemes (FR-3.3)                                                | P3.T1          |
| P3.T3 | `JustTint`, `inkAndPaper`, delegation, `fromSeed` deprecation (FR-3.4) | P3.T1, P3.T2   |
| P3.T4 | High contrast rewrite (FR-3.5)                                         | P3.T3          |
| P3.T5 | Material bridge (FR-3.6)                                               | P3.T3          |
| P3.T6 | Tests and changeset                                                    | P3.T1 to P3.T5 |

## 9. Acceptance criteria

1. AC-3.1: `grep -n "preset ==" packages/core/lib/src/theme/theme_data.dart`
   returns nothing.
2. AC-3.2: `inkAndPaper` for 2 presets x 2 brightnesses x {warm, graphite}
   returns schemes equal to the generated values (warm) or to the OKLCH
   rebuild (graphite), and passes the contrast contract.
3. AC-3.3: A hue sweep 0 to 355 (step 5) at chroma 0.0035, 0.006 and 0.010
   passes the contrast contract.
4. AC-3.4: `fromSeed(Color(0xFF3B82F6))` produces a tint hue near 260 and
   passes the contract; `fromSeed(Color(0xFF808080))` maps to warm.
5. AC-3.5: High contrast: `textSecondary == textPrimary`,
   `borderSubtle == borderControl`, canvas unchanged.
6. AC-3.6: Material mapping test covers every row of FR-3.6, and a test
   asserts the anchor line is present byte for byte.
7. AC-3.7: No `Color(0xFF000000)` remains in `shadow_scheme.dart`.
8. AC-3.8: `flutter analyze` and `flutter test` pass in `packages/core`
   (owner machine for tests).

## 10. Risks

| Risk                                                         | Mitigation                                                                                              |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| Scaffolded user apps call `fromSeed` with the blue seed      | Option D keeps them compiling with graphite tint                                                        |
| Re-tint math differs between Dart, the generator and the CLI | Shared reference values in the P2 parity test and the P8 `oklch.rs` tests (Studio parity moved to OS-2) |
| New preset contract grows too wide                           | Every member must be used by at least one component in P4, otherwise it is removed                      |

## 11. Pending decisions

| Decision | Default assumed                             |
| -------- | ------------------------------------------- |
| DP-2     | Rule A (`elevatedSurface` for neobrutalism) |
| DP-4     | Option D for `fromSeed`                     |
| DP-8     | Warm tint default                           |
| DP-9     | No tint field on `JustThemeData`            |

## 12. Exit criteria

All acceptance criteria met; the engine exposes everything P4 needs.
