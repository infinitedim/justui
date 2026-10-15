# Phase 4: Component Migration

Status: Draft v1 (2026-10-13)
Depends on: P3
Blocks: P5
Areas: `packages/core/lib/src/components`, `packages/core/test`

## 1. Summary

Move all 30 component families onto the Ink and Paper roles and the new preset
contract. Remove every color literal, palette reference, preset comparison,
`showsDefaultBorder` color decision and alpha-derived state color. Work in
three risk batches; after each batch the registry is regenerated and the guard
allow-list shrinks.

## 2. Background

See `03-baseline-audit.md` section 6 for the counts per component and the
list of known hacks. The guard test from P0 (`color_guard_test.dart`) holds the
current allowances.

## 3. Goals

1. Components read only roles and preset tokens.
2. Every component meets `02-design-spec.md` sections 5 and 6 in both presets
   and both modes.
3. Every state (hover, pressed, focused, selected, disabled, error) is
   specified and tested.

## 4. Non-goals

1. New variants, new props or layout changes, except where a rule requires
   them (status glyphs, error message icon).
2. Changing animation timings beyond what preset tokens already define.

## 5. The migration recipe (applies to every component)

1. In `build`, read `context.justColors` and `context.justPresetTokens`. In
   callbacks, use `context.readTheme()`. Never `JustThemeProvider.of(context)`
   without an aspect.
2. Replace deprecated getters using the map in section 6.
3. Replace `showsDefaultBorder` and local copies (`hasBorder`,
   `hasBorderPreset`, `isNeobrutalism`) with the specific preset token from
   P3 FR-3.1.
4. Replace alpha-derived state colors with roles (`hoverFill`,
   `inverseHover`, `inversePressed`, `errorHover`), resolved by switch
   expressions or lookup tables in the component's pure `*_style.dart`
   resolver where one exists.
5. Remove opaque literals. `Color(0x00000000)` (transparent) stays.
   `Colors.transparent` becomes `Color(0x00000000)` for consistency.
6. Keep dot shorthand and the existing file layout (4-file convention).
7. Resolve colors once per build. Do not allocate inside animation builders
   unless the value depends on the animation value.
8. Add or update widget tests for variant x state x preset x brightness.

## 6. Role migration map

| Old use                                                    | New role                                                             |
| ---------------------------------------------------------- | -------------------------------------------------------------------- |
| `borderFocus` drawn as focus                               | `focusRing`                                                          |
| `borderFocus` as primary or selected fill                  | `inverse` (or part `primaryBg`)                                      |
| Content on that fill (`textInverse`)                       | `onInverse`                                                          |
| `borderFocus` as selected indicator (underline, bar, ring) | `inverse`                                                            |
| `borderFocus.withValues(alpha: x)` hover or selected tint  | `hoverFill`                                                          |
| `borderDefault` on a control boundary                      | `presetTokens.resolveControlBorderColor(colors)`                     |
| `borderDefault` on a container or divider                  | `presetTokens.resolveContainerBorderColor(colors)` or `borderSubtle` |
| `background`, `card`, `elevated`, `muted`, `overlay`       | `canvas`, `surface`, `raised`, `sunken`, `scrim`                     |
| `textSecondary` for metadata or placeholder                | `textTertiary`                                                       |
| `borderError`                                              | `error`                                                              |
| `info`                                                     | `textPrimary` plus info glyph                                        |

## 7. Batch A: high risk

Public API semantics, primary or status hacks.

| Component                      | Files                                                                 | Required behavior                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| ------------------------------ | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| button, icon-button            | `just_button_style.dart`, `just_button.dart`, `just_icon_button.dart` | `resolveJustButtonColors` switches on `presetTokens.primaryEmphasis`. Default primary: inverse / inverseHover / inversePressed with onInverse, press scale 0.97. Neobrutalism primary: Rule A (surface fill, ink border 2.5, 4px ink shadow, w700). Secondary: transparent, control border, textPrimary, hoverFill; neobrutalism 2px shadow. Ghost: hoverFill. Destructive default: error / errorHover with onInverse; neobrutalism: errorTint fill, error label w700, ink border, 4px shadow. Destructive uses the same `primaryEmphasis` switch as primary (`inverseFill` gives the error fill, `elevatedSurface` gives the errorTint fill). Link: textPrimary, always underlined, 2px underline on hover. Disabled: sunken fill, textDisabled, borderSubtle. Remove literals at style 123 and 193 and the `info` link at 211-214. |
| input                          | `just_input.dart`                                                     | Border from `resolveControlBorderColor`; focus ring; error border `error` at `errorBorderWidth` plus error icon and message. Remove the success border (482, 1056); success is shown by icon and helper text. Cursor `textPrimary`; `backgroundCursorColor` `borderControl`; remove `JustColorPalette.primary500` (826) and `#888888` (827). Placeholder `textTertiary`.                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| select                         | `just_select.dart`, `just_select_style.dart`                          | Trigger uses control border; menu on `raised` with a `borderSubtle` edge; highlighted option `hoverFill`; selected option check glyph plus w600; no full ink fill in the list. 12 `showsDefaultBorder` reads removed.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| date_picker, date_range_picker | `_date_picker_calendar.dart`, `just_date_range_picker.dart`           | Selected day inverse / onInverse; range middle hoverFill; today 1px borderControl ring plus w600; hover hoverFill; circular vs square selection from `datePickerCircularSelection`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| time_picker                    | `just_time_picker.dart` and private parts                             | Dial hand, selected segment and period inverse / onInverse; segment borders from `resolveControlBorderColor`; 18 `showsDefaultBorder` reads and 4 literals removed.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| badge                          | `just_badge.dart`, `just_badge_style.dart`                            | Primary solid inverse / onInverse; secondary sunken / textPrimary; outline control border. Status variants (success, warning, error, info) render monochrome with a leading status glyph and stay in the enum as `@Deprecated` (DP-3). 10 literals reviewed.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| avatar                         | `just_avatar.dart`                                                    | Name color from a 3-step neutral lookup (sunken, borderSubtle, hoverFill) with textPrimary initials. Presence by shape: online filled ink dot, offline hollow borderControl ring, away half-filled dot, busy dot with a bar; each with a Semantics label. Dot outline `surface`. Remove palette references (80-85, 199-208) and the white literal (228).                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| toast                          | `just_toast.dart`                                                     | Container uses the status tint; icon and title use the status color; body textPrimary; info uses textPrimary and the info glyph; border from `resolveContainerBorderColor`. Remove alpha tints (599-602).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| checkbox                       | `just_checkbox.dart`                                                  | Unchecked border from `resolveControlBorderColor`; checked inverse fill with onInverse mark; remove `warning` (190).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| switch                         | `just_switch.dart`                                                    | Off: borderControl track outline and borderControl thumb on surface. On: inverse track, onInverse thumb. Remove `success` (233). Keep the neobrutalism thumb inset rule from AGENTS.md (thumb minus 2 x borderWidth).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| slider                         | `just_slider.dart`                                                    | Inactive track borderControl; active track inverse; thumb fill `resolveParts(colors).primaryBg` and thumb border `primaryBorder` (gives inverse in default, surface with ink border in neobrutalism); border width `containerBorderWidth`; the neobrutalism thumb size math from `AGENTS.md` section 6 reads `containerBorderWidth`. Replaces all 9 `showsDefaultBorder` reads. Remove `warning` (227).                                                                                                                                                                                                                                                                                                                                                                                                                              |

## 8. Batch B: medium risk

| Component              | Required behavior                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| tabs, tab indicator    | Underline inverse, thickness from `resolveTabIndicatorThickness` (2 default, 4 neobrutalism). Pill variant inverse fill. Remove `success` at alpha (indicator 107).                                                                                                                                                                                                                                                                                                                                                                                                     |
| toggle                 | On: inverse fill, onInverse. Off: transparent with control border.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| table                  | Row hover hoverFill; selected row hoverFill plus checked checkbox; header textSecondary w600; dividers borderSubtle.                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| sidebar                | Active item: 2px inverse bar (3px neobrutalism from `emphasizedBorderWidth`), w600, hoverFill. 6 literals removed.                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| carousel               | Remove 5 preset comparisons (`just_carousel.dart` 676, 772, 851, 885, 1097). Replacements: indicator colors become roles (active inverse, inactive borderControl); indicator, counter, arrow and content radius use the existing `presetTokens.resolveBorderRadius(radius)`; border presence and width use `containerBorderWidth` and `resolveContainerBorderColor`; animation duration uses the theme motion profile (instant under neobrutalism via `defaultMotion`); the counter fill becomes `raised` (removes `withValues(alpha: 0.85)`). Arrows use button roles. |
| resizable              | Remove 2 preset comparisons (`just_resizable.dart` 676, 995). Divider thickness uses `containerBorderWidth` (1.0 / 2.5); base divider color `resolveControlBorderColor(colors)`; hover, drag and focus color inverse.                                                                                                                                                                                                                                                                                                                                                   |
| progress               | Indicator inverse; track sunken with 1px control border; label weight from `progressLabelWeight`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| radio                  | Ring from `resolveControlBorderColor`; selected dot inverse.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| breadcrumb             | Current item textPrimary w600 with current-page Semantics; others textSecondary; hover underline. Replace 5 `borderFocus` reads.                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| bottom_nav             | Active item inverse indicator plus w600; inactive textSecondary.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| card                   | Border from `resolveContainerBorderColor` and `containerBorderWidth`; interactive cards get the focus ring.                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| skeleton               | Base sunken (light) or raised (dark); highlight borderSubtle. Remove 8 slate literals.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| shared focus indicator | `focusRing`, `focusRingWidth`, `focusRingGap`; 3px under `MediaQuery.highContrast`; read via `context.justPresetTokens`. Fix the gap so the visible gap equals `focusRingGap`.                                                                                                                                                                                                                                                                                                                                                                                          |

## 9. Batch C: low risk

| Component                                                               | Required behavior                                                             |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| accordion                                                               | Dividers borderSubtle; chevron textSecondary.                                 |
| dialog, sheet                                                           | `raised` fill, `scrim` backdrop, `borderSubtle` edge in dark (DP-11).         |
| tooltip                                                                 | Inverse fill, onInverse text.                                                 |
| separator                                                               | `resolveContainerBorderColor`, `resolveSeparatorThickness`.                   |
| scroll area                                                             | Thumb borderControl. ShaderMask literals (740-768) stay and are allow-listed. |
| shared pressable, overlay transition, tooltip overlay, progress spinner | Spinner uses textPrimary or onInverse depending on its host.                  |

### Final guard state (end of P4)

| Rule | Final allowance                                                                                                                                                                                                                                                                                                                                                      |
| ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CG-1 | Only `scroll/just_scroll_area.dart` mask lines                                                                                                                                                                                                                                                                                                                       |
| CG-2 | 0                                                                                                                                                                                                                                                                                                                                                                    |
| CG-3 | 0                                                                                                                                                                                                                                                                                                                                                                    |
| CG-4 | 0                                                                                                                                                                                                                                                                                                                                                                    |
| CG-5 | Only `toast/just_toast.dart` (there is no alert component; input keeps only `colors.error`, which CG-5 does not match)                                                                                                                                                                                                                                               |
| CG-6 | 0                                                                                                                                                                                                                                                                                                                                                                    |
| CG-7 | 0 in `components/`. Scrim and shadow construction live outside this folder. Opacity animations (skeleton shimmer, pulsing badge dot, fades) use `Opacity`, `FadeTransition` or an animated alpha on a role color computed in the animation builder; each remaining case is listed by file with a reason in the guard allow-list, and the list must be reviewed in P9 |

A new test asserts zero reads of deprecated `JustColorScheme` getters inside
`packages/core/lib/src/components`.

## 10. After each batch

1. `dart run tools/generate_checksums.dart --dry-run`, read the drift report,
   then run without `--dry-run`.
2. Re-sign the registry with the existing hidden command
   `cargo run -p justui -- sign-registry` (writes `registry/index.json.sig`).
3. Lower the guard allowances.
4. Update or add widget tests.
5. Commit locally.

## 11. Functional requirements summary

| ID     | Requirement                                                               |
| ------ | ------------------------------------------------------------------------- |
| FR-4.1 | Every component follows the recipe in section 5                           |
| FR-4.2 | Every component meets its row in sections 7 to 9                          |
| FR-4.3 | Every selected state sets Semantics (selected, checked, toggled, current) |
| FR-4.4 | Every status shows a distinct glyph and text                              |
| FR-4.5 | Under neobrutalism no element has an ink fill and an ink shadow at once   |
| FR-4.6 | Registry regenerated and re-signed after each batch                       |

## 12. Non-functional requirements

1. NFR-4.1: No new allocation per frame (checked by review of every
   `AnimatedBuilder`, `TweenAnimationBuilder` and drag handler touched).
2. NFR-4.2: Cyclomatic complexity of new resolvers at most 3 per function
   (guard clauses, switch expressions).
3. NFR-4.3: Public component APIs unchanged except deprecations listed in
   DP-3.

## 13. Tests

1. Widget tests per component: resolved decoration colors, border widths
   (error 2.0 / 3.0), shadows (neobrutalism primary 4px, selected none),
   Semantics flags, for variant x state x preset x brightness.
2. Golden tests (new, `packages/core/test/goldens/`): button, input (error),
   select (open), checkbox, switch, toast, date picker, badge, in 4
   combinations. Baselines created once on the owner machine with
   `--update-goldens` and reviewed by eye.
   Font loading: `flutter test` does not load app fonts; text renders in the
   built-in test font (blocks), so goldens would not show Plus Jakarta Sans
   metrics. Add `packages/core/test/flutter_test_config.dart` that loads the
   four `.ttf` files from `packages/tokens/assets/fonts/` with `FontLoader`
   under the family `PlusJakartaSans` before any golden runs. Widget tests
   that do not compare pixels are unaffected.
3. Focus test: each interactive component focused with a `FocusNode`; assert
   painter stroke (2.0 / 2.5 / 3.0 high contrast) and gap 2.0.

## 14. Acceptance criteria

1. AC-4.1: The guard test reaches the final state in section 9.
2. AC-4.2: Zero deprecated getter reads in components.
3. AC-4.3: `flutter analyze` clean; `flutter test` green (owner machine).
4. AC-4.4: Registry dry run shows no drift after writing; signature verifies.
5. AC-4.5: Goldens reviewed and committed.
6. AC-4.6: Design review of the 4 combinations confirms Rule A and the
   neobrutalism character checklist in `19-phase-9-verification-and-release.md`.

## 15. Risks

| Risk                                           | Mitigation                         |
| ---------------------------------------------- | ---------------------------------- |
| Batch A changes visible defaults users rely on | Changelog "Breaking" entries; DP-1 |
| Toast and badge status changes surprise users  | DP-3 decided before Batch A        |
| Large diff in time_picker (18 flag reads)      | Own commit; extra widget tests     |

## 16. Pending decisions

| Decision | Default assumed                                         |
| -------- | ------------------------------------------------------- |
| DP-2     | Rule A for neobrutalism primary                         |
| DP-3     | Badge status variants monochrome with glyph, deprecated |
| DP-11    | Dark dialog edge uses borderSubtle                      |
| DP-13    | Info has no color                                       |

## 17. Exit criteria

All acceptance criteria met for all three batches.
