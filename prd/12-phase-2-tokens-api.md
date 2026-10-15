# Phase 2: Tokens API

Status: Draft v1 (2026-10-13)
Depends on: P1
Blocks: P3, P4
Areas: `packages/tokens`

## 1. Summary

Give `JustColorScheme` the Ink and Paper roles, switch the built-in schemes to
the generated values, and keep every old role name compiling as a deprecated
forwarding getter. After this phase the Flutter library has the right colors
and vocabulary, but components still read old names until P4.

## 2. Background

1. `JustColorScheme` (`color_tokens.dart:10`) has 16 roles and no primary or
   selection role. Components use `borderFocus` as primary (50 reads).
2. Neobrutalism has its own color schemes with cream and vivid status colors
   (`color_tokens.dart:200` and `:240`). Under Ink and Paper presets do not own
   colors, so these schemes become aliases.
3. `CustomColorScheme.resolveSemantic` (`color_tokens.dart:580`) branches on
   preset and writes pure black and white.
4. `JustColorScheme` is `abstract final`, so there are no outside subclasses.
   Outside code only reads getters or calls `CustomColorScheme`.

## 3. Goals

1. Add every role from `02-design-spec.md` section 4.
2. Keep all 16 old names working for one minor release (DP-1).
3. Remove preset branching from the tokens package.
4. Make the contrast contract an executable test.

## 4. Non-goals

1. Changing component code (P4).
2. Changing `JustThemeData` (P3).
3. Removing deprecated API (next minor release after this rebrand ships).

## 5. Functional requirements

### FR-2.1 New abstract roles on `JustColorScheme`

Add abstract getters:

```
canvas, surface, raised, sunken, hoverFill, scrim, selection,
textPrimary, textSecondary, textTertiary, textDisabled, onInverse,
borderSubtle, borderControl, focusRing,
inverse, inverseHover, inversePressed,
error, errorHover, errorTint, success, successTint, warning, warningTint
```

`textPrimary`, `textSecondary`, `textDisabled`, `error`, `success` and
`warning` keep their names and become Ink and Paper values.

### FR-2.2 Deprecated forwarding getters

Old names become concrete getters on the abstract base, annotated
`@Deprecated('Use <new> instead. Removed in the next minor release.')`:

| Old name      | Forwards to   | Reason                                                                                                |
| ------------- | ------------- | ----------------------------------------------------------------------------------------------------- |
| background    | canvas        | Same meaning                                                                                          |
| card          | surface       | Same meaning                                                                                          |
| elevated      | raised        | Same meaning                                                                                          |
| muted         | sunken        | Same meaning                                                                                          |
| overlay       | scrim         | Same meaning                                                                                          |
| textInverse   | onInverse     | Same meaning                                                                                          |
| borderDefault | borderControl | Safe default: most of its 82 reads mark controls (1.4.11). Decorative uses move to borderSubtle in P4 |
| borderFocus   | inverse       | Equals focusRing in both modes, so focus and primary uses both keep working                           |
| borderError   | error         | Same meaning                                                                                          |
| info          | textPrimary   | Info has no color (DP-13)                                                                             |

### FR-2.3 Equality

`operator ==` and `hashCode` compare only the non-deprecated roles. Deprecated
getters are derived and must not be compared.

### FR-2.4 Built-in schemes

1. `_JustColorSchemeLight` and `_JustColorSchemeDark` return values from the
   generated `JustColorSemanticLight` and `JustColorSemanticDark`.
2. `color_semantic.dart` is now written by the generator (it was emitted to a
   temporary path in P1). It contains the new role constants plus deprecated
   constants under the old names.
3. `_JustColorSchemeNeobrutalismLight` and `_JustColorSchemeNeobrutalismDark`
   are removed as classes. `JustColors.neobrutalismLightScheme`,
   `neobrutalismDarkScheme`, `neobrutalismLight()` and `neobrutalismDark()`
   become `@Deprecated` aliases of the light and dark schemes.
4. `JustColors.brand` exposes `JustBrandPalette`.
5. `brand_palette.dart` is exported from `lib/just_ui_tokens.dart`.

### FR-2.5 Palette deprecation

1. `JustColorPalette` (slate, blue and the status families) is annotated
   `@Deprecated` in place. It is not deleted in this release.
2. The 68 `JustColors.<family><step>` re-exports are annotated `@Deprecated`.

### FR-2.6 `CustomColorScheme`

1. New `const CustomColorScheme.roles({...})` named constructor with the new
   role names (all required except `scrim`, which defaults from
   `textPrimary`).
2. The unnamed `const CustomColorScheme({...})` keeps its 16 legacy
   parameters and its `const`-ness, and is annotated
   `@Deprecated('Use CustomColorScheme.roles. Removed in the next minor release.')`.
   This keeps every existing `const CustomColorScheme(...)` call compiling,
   which M9 (zero compile breaks) and DP-1 (minor release) require. Moving
   the old parameters to a new factory would break those calls, and a factory
   cannot be called with `const`. New role getters on the legacy path follow
   the mapping below: direct mappings return the stored field; derived roles
   (`inverseHover`, `inversePressed`, `errorHover`, tints) are computed on
   read. That allocation exists only on the deprecated path and is a
   documented exemption from NFR-2.1. Mapping:

| New role                        | Derived from (legacy)                             |
| ------------------------------- | ------------------------------------------------- |
| canvas, surface, raised, sunken | background, card, elevated, muted                 |
| textTertiary                    | textSecondary                                     |
| borderSubtle, borderControl     | borderDefault                                     |
| inverse, focusRing              | borderFocus                                       |
| onInverse                       | textInverse                                       |
| inverseHover, inversePressed    | inverse moved 0.10 and 0.18 OKLCH L toward canvas |
| hoverFill                       | sunken                                            |
| selection                       | borderSubtle                                      |
| errorHover                      | error moved 0.04 OKLCH L toward canvas            |
| tints                           | status color at 8% alpha composited over canvas   |

3. `copyWith` for every role, so a user can override one role on purpose.
4. `CustomColorScheme.resolveSemantic` becomes `@Deprecated`. Its `preset`
   argument is ignored; it returns Ink and Paper roles built from its inputs
   through the legacy unnamed constructor.

### FR-2.7 `JustThemePreset`

Stays in `packages/tokens` (moving it breaks user imports). No new values.

### FR-2.8 Contrast contract test

`packages/tokens/test/contrast_contract_test.dart` (new):

1. Iterates `JustThemePreset.values` x `{light, dark}` and checks every rule in
   `contrast_contract_generated.dart` with `contrastRatioWith`.
2. Contains a hand-written floor list that does not come from the generator,
   so a generator bug cannot pass silently:

| Role pair                                | Floor |
| ---------------------------------------- | ----- |
| textPrimary on every surface             | 14.0  |
| textSecondary on every surface           | 9.0   |
| textTertiary on every surface            | 7.0   |
| borderControl on every surface           | 3.4   |
| onInverse on inverse                     | 17.0  |
| error, success, warning on every surface | 7.0   |

### FR-2.9 Accessibility helpers

Add `isAccessibleAaaWith(Color background, {bool largeText = false})` next to
`isAccessibleWith` in `colors_accessibility.dart` (7.0 normal, 4.5 large).
Existing methods are unchanged.

### FR-2.10 Tests that must change on purpose

| Test                                                          | Change                                                                                                                                                          |
| ------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `packages/tokens/test/colors_test.dart` "match specification" | Assert the Ink and Paper specification. The phase summary states that the specification changed                                                                 |
| New `packages/tokens/test/custom_scheme_test.dart`            | Legacy constructor mapping (including a `const CustomColorScheme(...)` call that must still compile), `.roles`, `copyWith`, equality ignores deprecated getters |
| New parity test                                               | `OklchEngine` rebuild of every neutral from (L, warm tint) equals the generated hex within 1 unit                                                               |

### FR-2.11 Typography family: Plus Jakarta Sans (owner decision 2026-10-14)

1. `JustTypography` default `fontFamily` changes from `Inter`
   (`typography.dart:9`) to `PlusJakartaSans`.
2. The library stays zero-dependency: it does not use the `google_fonts`
   package. The font files are assets. This phase adds them to the repository:
   `packages/tokens/assets/fonts/PlusJakartaSans-{Regular,Medium,SemiBold,Bold}.ttf`
   and `OFL.txt` (downloaded on the owner machine; the sandbox is offline).
   Note: today `typography.dart:9` names Inter but no package bundles it, so
   Flutter already falls back to the platform font; shipping the files is new
   work, not a swap.
   Do not declare the font in `packages/tokens/pubspec.yaml`. A font declared
   by a package is registered as `packages/just_ui_tokens/PlusJakartaSans`,
   which would not match the plain `PlusJakartaSans` family that copied code
   in user apps uses. The folder is a source for the CLI embed and the test
   `FontLoader` only; each app (`apps/preview`, `apps/showcase`, user apps)
   declares the plain family in its own `pubspec.yaml`. The registry/CLI copies
   `PlusJakartaSans` (OFL license, weights 400, 500, 600, 700) into the user's
   `assets/fonts/` and adds the `fonts:` entry to `pubspec.yaml` (P8, FR-8.9).
3. If the font asset is missing, Flutter falls back to the platform default
   font; nothing crashes. The deprecation story: apps that set their own
   `fontFamily` are unaffected.
4. Text metrics change (Plus Jakarta Sans is wider than Inter), so goldens in
   P4 are taken after this change, and layout checks for tight components
   (badge, button, tabs, tooltip, breadcrumb) are part of P4 review.
5. The weight floor from the docs applies: no weight below 400 for text.

## 6. Non-functional requirements

1. NFR-2.1: No new dependency. Zero heap allocation added to getters (all
   `const`).
2. NFR-2.2: `flutter analyze` reports deprecation infos only where P4 has not
   migrated yet; no warnings or errors.
3. NFR-2.3: Doc comments on every new role say what it is for and which
   contrast rule applies.

## 7. Files

| File                                                       | Change                                          |
| ---------------------------------------------------------- | ----------------------------------------------- |
| `packages/tokens/lib/src/colors/color_tokens.dart`         | Roles, deprecations, schemes, CustomColorScheme |
| `packages/tokens/lib/src/colors/color_semantic.dart`       | Generated                                       |
| `packages/tokens/lib/src/colors/color_palette.dart`        | Deprecated annotations                          |
| `packages/tokens/lib/src/colors/colors_accessibility.dart` | AAA helper                                      |
| `packages/tokens/lib/just_ui_tokens.dart`                  | Export brand palette                            |
| `packages/tokens/lib/src/typography.dart`                  | Font family                                     |
| `packages/tokens/assets/fonts/*.ttf`, `OFL.txt`            | New (font files)                                |
| `packages/tokens/test/*.dart`                              | Updated and new tests                           |
| `.changeset-polyglot/ink-and-paper-tokens.md`              | New changeset                                   |

## 8. Tasks

| ID     | Task                                                                                           | Depends on |
| ------ | ---------------------------------------------------------------------------------------------- | ---------- |
| P2.T1  | Add abstract roles and deprecated getters; update `==` and `hashCode`                          | P1         |
| P2.T2  | Generator writes `color_semantic.dart`; schemes read it; neobrutalism schemes become aliases   | P2.T1      |
| P2.T3  | Deprecate palette and re-exports; export brand palette                                         | P2.T2      |
| P2.T4  | `CustomColorScheme.roles`, legacy constructor mapping, `copyWith`, deprecate `resolveSemantic` | P2.T1      |
| P2.T5  | AAA helper                                                                                     | P2.T1      |
| P2.T6  | Contrast contract test, parity test, updated specification test                                | P2.T2      |
| P2.T6b | Typography family change and font files (FR-2.11)                                              | P2.T1      |
| P2.T7  | Changeset (`just_ui_tokens`: minor, or major per DP-1)                                         | P2.T6      |

## 9. Acceptance criteria

1. AC-2.1: Every role in FR-2.1 exists and returns the value in
   `02-design-spec.md` for light and dark.
2. AC-2.2: Every old name compiles, returns the forwarded value, and produces a
   deprecation info at the call site.
3. AC-2.3: `JustColors.neobrutalismLight() == JustColors.light()` is true.
4. AC-2.4: The contrast contract test passes for both presets and both modes.
5. AC-2.5: `grep -n "neobrutalism" packages/tokens/lib/src/colors/color_tokens.dart`
   matches only the enum value and deprecated aliases.
6. AC-2.6: No `Color(0xFF000000)` or `Color(0xFFFFFFFF)` remains in
   `color_tokens.dart` outside generated code.
7. AC-2.7: `generate_tokens.dart --check` passes.
8. AC-2.8: `melos exec --no-flutter --dir-exists="test" -- "dart test"` and
   `flutter test` in `packages/tokens` pass (owner machine for Flutter).
9. AC-2.9: `packages/core` still compiles (deprecation infos allowed).
10. AC-2.10: `packages/tokens/assets/fonts/` contains
    `PlusJakartaSans-Regular.ttf`, `PlusJakartaSans-Medium.ttf`,
    `PlusJakartaSans-SemiBold.ttf`, `PlusJakartaSans-Bold.ttf` and `OFL.txt`,
    committed on the branch. P4 (golden font loading) and P8 (`RustEmbed`)
    must not start without them: `#[derive(RustEmbed)]` fails to compile when
    its folder is missing, and git does not keep an empty folder.

## 10. Risks

| Risk                                                                      | Mitigation                                                                                                     |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `borderDefault -> borderControl` makes dividers look heavy until P4       | Accepted on the branch; release gate is P9                                                                     |
| Legacy `CustomColorScheme(...)` output looks different from the old theme | The legacy constructor maps roles one to one where it can; derived roles are documented in the migration guide |
| Users relying on vivid neobrutalism colors                                | Changelog "Breaking" entry in P9                                                                               |

## 11. Pending decisions

| Decision | Default assumed                  |
| -------- | -------------------------------- |
| DP-1     | Minor release with deprecations  |
| DP-9     | Tint is not stored on the scheme |
| DP-13    | `info` forwards to `textPrimary` |

## 12. Exit criteria

All acceptance criteria met. The library builds with Ink and Paper values;
visual output of components is still mixed until P4.
