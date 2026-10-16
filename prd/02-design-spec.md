# 02. Design Specification: Ink and Paper

Status: Draft v1 (2026-10-13)
Applies to: every phase. This is the normative reference for colors and rules.

All contrast ratios in this file were computed with the WCAG 2.x relative
luminance formula from the final hex values:

```
Lc = c / 12.92                      if c <= 0.04045
Lc = ((c + 0.055) / 1.055) ^ 2.4    otherwise
L  = 0.2126 * R + 0.7152 * G + 0.0722 * B
ratio = (Lmax + 0.05) / (Lmin + 0.05)
```

## 1. Token layers

| Layer | Name             | Contains                                                        | Who may change it              |
| ----- | ---------------- | --------------------------------------------------------------- | ------------------------------ |
| 1     | Brand primitives | Neutral scale, status hues, tint, font family names             | Token source only              |
| 2     | Semantic roles   | The role list in section 4. Components read only these.         | Token source only              |
| 3     | Preset           | Shape, motion and a part mapping (which role paints which part) | Preset class plus token source |

Rules:

1. Components read roles, never primitives and never hex literals.
2. A preset may decide which role paints a part (for example "primary button
   background is `surface`"). A preset may override a role value only through a
   named entry in the token source, and only with a neutral or status
   primitive. A preset may never introduce a new hue.

## 2. Tint

The neutral scale has one global tint expressed in OKLCH.

| Tint     | Hue | Chroma | Default    |
| -------- | --- | ------ | ---------- |
| warm     | 80  | 0.0035 | yes (DP-8) |
| graphite | 260 | 0.0035 | no         |

Each neutral step is stored as an OKLCH lightness. Re-tinting rebuilds the
step from (L, hue, chroma). A sweep of hue 0 to 355 (step 5) with chroma
0.0035, 0.006 and 0.010 keeps every text role at or above 7.09:1 and
`borderControl` at or above 3.48:1, so chroma up to 0.010 is safe to expose.

## 3. Brand primitives

Neutral steps are named `n` plus OKLCH lightness times 1000.

| Primitive | Hex     | Used by (light / dark)                      |
| --------- | ------- | ------------------------------------------- |
| n1000     | #ffffff | surface, raised (light). Chroma forced to 0 |
| n985      | #fbfaf8 | canvas, onInverse (light)                   |
| n959      | #f3f1ef | sunken, hoverFill (light)                   |
| n955      | #f1f0ee | textPrimary, inverse, focusRing (dark)      |
| n905      | #e1dfdd | borderSubtle, selection (light)             |
| n861      | #d2d1ce | inverseHover (dark)                         |
| n815      | #c4c2c0 | textSecondary (dark)                        |
| n799      | #bfbdbb | inversePressed (dark)                       |
| n745      | #aeaca9 | textTertiary (dark)                         |
| n660      | #93928f | textDisabled (light)                        |
| n600      | #81807d | borderControl (light)                       |
| n560      | #767472 | borderControl (dark)                        |
| n500      | #646361 | textDisabled (dark)                         |
| n431      | #51504d | textTertiary (light)                        |
| n376      | #42413f | textSecondary (light)                       |
| n349      | #3b3a38 | inversePressed (light), selection (dark)    |
| n285      | #2b2a28 | inverseHover (light), borderSubtle (dark)   |
| n227      | #1d1c1a | raised, hoverFill (dark)                    |
| n192      | #151412 | surface (dark)                              |
| n174      | #11100f | textPrimary, inverse, focusRing (light)     |
| n155      | #0d0c0a | canvas, onInverse (dark)                    |
| n135      | #090807 | sunken (dark)                               |

Status primitives:

| Name    | Light   | Light hover | Light tint | Dark    | Dark hover | Dark tint |
| ------- | ------- | ----------- | ---------- | ------- | ---------- | --------- |
| oxblood | #901114 | #9a1f1d     | #fef0ee    | #f8a59b | #e9978d    | #241513   |
| bottle  | #115629 | -           | #edf6ee    | #99cda3 | -          | #111d13   |
| cognac  | #723f00 | -           | #faf2e9    | #e3b47d | -          | #21170c   |

Note on exact hex: rebuilding every neutral from (L, hue 80, chroma 0.0035)
reproduces the table exactly except for six values that differ by one unit in
one 8-bit channel (light borderControl, textTertiary, textDisabled; dark
borderControl, textTertiary, inverseHover). The table keeps the owner's hex
(DP-7). The generator accepts a difference of at most 1 unit per channel.

## 4. Semantic roles

### 4.1 Surfaces

| Role      | Light             | Dark              | Purpose                                          |
| --------- | ----------------- | ----------------- | ------------------------------------------------ |
| canvas    | #fbfaf8           | #0d0c0a           | Page background. Never pure white or black.      |
| surface   | #ffffff           | #151412           | Cards and inline containers                      |
| raised    | #ffffff           | #1d1c1a           | Dialogs, popovers, menus, sheets, tooltips host  |
| sunken    | #f3f1ef           | #090807           | Inputs, code blocks, tracks                      |
| hoverFill | #f3f1ef           | #1d1c1a           | Hover background for ghost, secondary, list rows |
| selection | #e1dfdd           | #3b3a38           | Text selection background                        |
| scrim     | n174 at 48% alpha | n135 at 72% alpha | Modal backdrop                                   |

### 4.2 Text

| Role          | Light   | Dark    | Min light | Min dark | Target |
| ------------- | ------- | ------- | --------- | -------- | ------ |
| textPrimary   | #11100f | #f1f0ee | 16.87     | 14.95    | >= 7   |
| textSecondary | #42413f | #c4c2c0 | 9.05      | 9.59     | >= 7   |
| textTertiary  | #51504d | #aeaca9 | 7.16      | 7.52     | >= 7   |
| textDisabled  | #93928f | #646361 | 2.76      | 2.84     | exempt |
| onInverse     | #fbfaf8 | #0d0c0a | see 4.4   | see 4.4  | >= 7   |

"Min" is the lowest ratio across canvas, surface and sunken (light) and
canvas, surface, sunken and raised (dark).

### 4.3 Lines

| Role          | Light   | Dark    | Min light | Min dark | Target                  |
| ------------- | ------- | ------- | --------- | -------- | ----------------------- |
| borderSubtle  | #e1dfdd | #2b2a28 | 1.18      | 1.19     | decoration only, exempt |
| borderControl | #81807d | #767472 | 3.51      | 3.66     | >= 3                    |
| focusRing     | #11100f | #f1f0ee | 16.87     | 14.95    | >= 3                    |

### 4.4 Interaction

| Role           | Light   | Dark    | With onInverse (light / dark) |
| -------------- | ------- | ------- | ----------------------------- |
| inverse        | #11100f | #f1f0ee | 18.22 / 17.17                 |
| inverseHover   | #2b2a28 | #d2d1ce | 13.75 / 12.80                 |
| inversePressed | #3b3a38 | #bfbdbb | 10.89 / 10.44                 |

### 4.5 Status

| Role        | Light   | Dark    | Min on surfaces                                   | On own tint | As fill with onInverse |
| ----------- | ------- | ------- | ------------------------------------------------- | ----------- | ---------------------- |
| error       | #901114 | #f8a59b | 8.19 / 8.80                                       | 8.31 / 9.10 | 8.84 / 10.10           |
| errorHover  | #9a1f1d | #e9978d | -                                                 | -           | 7.78 / 8.64            |
| errorTint   | #fef0ee | #241513 | textPrimary on it: 17.12 / 15.47                  | -           | -                      |
| success     | #115629 | #99cda3 | 7.81 / 9.42                                       | 7.97 / 9.61 | -                      |
| successTint | #edf6ee | #111d13 | textPrimary on it: 17.21 / 15.25                  | -           | -                      |
| warning     | #723f00 | #e3b47d | 7.68 / 8.99                                       | 7.81 / 9.30 | -                      |
| warningTint | #faf2e9 | #21170c | textPrimary on it: 17.14 / 15.46                  | -           | -                      |
| info        | no role | no role | deprecated getter forwards to textPrimary (DP-13) |             |                        |

### 4.6 Measured component pairs

| Pair                                              | Ratio         | Meaning                                             |
| ------------------------------------------------- | ------------- | --------------------------------------------------- |
| Switch off: borderControl track on canvas (light) | 3.79          | Off state visible                                   |
| Switch off: surface thumb vs borderControl        | 3.95          | Thumb visible                                       |
| Switch on: inverse track vs onInverse thumb       | 18.22 / 17.17 | On state visible                                    |
| Slider inactive track: borderControl on canvas    | 3.79          | Must not use borderSubtle (1.27)                    |
| Progress indicator: inverse on sunken             | 16.87         | Track needs a 1px borderControl edge                |
| textPrimary on selection                          | 14.30 / 9.98  | Selected text must be textPrimary                   |
| textTertiary on selection (light)                 | 6.07          | Forbidden combination                               |
| Ink fill vs its own ink shadow                    | 1.00          | Shadow invisible, see section 6                     |
| Ink fill vs borderControl shadow                  | 4.81          | Alternative B in section 6                          |
| Light dialog (#ffffff) against light scrim        | 3.45          | Dialog edge visible in light                        |
| Dark dialog (raised) against dark scrim           | 1.17          | Dark dialogs always get a borderSubtle edge (DP-11) |

## 5. Usage rules

### 5.1 Color

1. Text roles must reach 7:1 on every surface they can sit on (1.4.6).
2. Control boundaries, icons and state indicators must reach 3:1 against
   adjacent colors (1.4.11).
3. `borderSubtle` is decoration only. Inputs, checkboxes, radios, switch
   tracks in the off state and slider tracks use `borderControl`.
4. Hierarchy comes from size and weight (400, 500, 600) in Plus Jakarta Sans,
   including metadata and labels. A monospace face is never used for
   hierarchy (section 8). Never use a gray lighter than `textTertiary` for text.
5. State colors come from roles (`hoverFill`, `inverseHover`,
   `inversePressed`, `errorHover`). Building state colors with
   `withValues(alpha:)` on brand colors is not allowed. Alpha is allowed only
   for `scrim` and default-preset shadow layers.
6. Disabled means a `sunken` or transparent fill, a `textDisabled` label and a
   `borderSubtle` border.
7. Pure `#000000` and `#ffffff` are allowed only as `surface` and `raised` in
   light mode, as shader masks, and as the transparent constant
   `Color(0x00000000)`. They are never a page canvas, not even in high
   contrast mode.

### 5.2 Primary and selection

1. Primary actions and selected states are shown with ink.
2. Compact controls (toggle, segmented control, chip, date cell, checkbox,
   radio dot, switch track, tab pill) use an `inverse` fill with `onInverse`
   content.
3. Lists and menus (select options, menu items, table rows) show selection
   with a check glyph, weight 600 and `hoverFill`, not a full ink fill.
4. Indicators (tab underline, sidebar bar) are ink and at least 2px thick.
5. Every selected state also sets its Semantics or ARIA state (selected,
   checked, pressed, current).

### 5.3 Status

1. Status color may appear only in: validation messages, error borders,
   destructive actions, and the icon and title of alerts and toasts.
2. Tints may appear only as alert, toast and validation-message container
   backgrounds.
3. Every status has a distinct icon shape and visible text:
   error = octagon or circle with x, success = circle with check,
   warning = triangle with !, info = circle with i in `textPrimary`.
4. An error input border becomes 2px (default) or 3px (neobrutalism) in
   `error`, with an icon and a message.
5. Success is never a border color.
6. Status color is never used for primary or secondary buttons, links,
   active states, avatars, decorative graphics, category badges, terminal
   output (except error lines) or syntax highlighting.
7. The three status colors have almost the same OKLCH lightness (0.40 to
   0.42 in light), so under achromatopsia they cannot be told apart by color.
   The shape-plus-text rule is mandatory, not optional.

### 5.4 Focus

1. The focus indicator is a solid ring in `focusRing`, drawn outside the
   element with a 2px gap.
2. Width: 2px in default, 2.5px in neobrutalism, 3px under high contrast.
3. On the web it is drawn with `outline`, never only with `box-shadow`,
   because outlines survive forced-colors mode.

### 5.5 Links and copy

1. Links in running text are always underlined. Navigation links are exempt
   but must be identified by layout and `aria-current`.
2. Copy never names a color ("the red button").

### 5.6 User color control (1.4.8)

1. Web: support `@media (forced-colors: active)` with system colors and
   `@media (prefers-contrast: more)` with the high contrast set below.
2. Flutter: `applyHighContrastOverrides` collapses hierarchy instead of
   swapping canvases: `textSecondary` and `textTertiary` become `textPrimary`,
   `borderSubtle` becomes `borderControl`, `borderControl` becomes
   `textPrimary`, `inverseHover` and `inversePressed` become `inverse`, the
   focus ring becomes 3px, and the canvas stays brand paper or ink.

## 6. Neobrutalism under Ink and Paper

Kept: 2.5px ink borders, flat ink offset shadows, zero radius (except pills
and circles), translate-on-press, instant motion.

Removed: cream canvas (`#FFFDF5`, `#FFF8E7`), yellow primary, vivid status
colors (`#38E54D`, `#FFD93D`, `#FF4B4B`, `#4D96FF`).

Rule A (default, DP-2):

| Element          | Fill        | Border            | Shadow  | Label             | Press                   |
| ---------------- | ----------- | ----------------- | ------- | ----------------- | ----------------------- |
| Primary action   | surface     | textPrimary 2.5px | 4px ink | textPrimary, w700 | translate 4px, shadow 0 |
| Secondary action | transparent | textPrimary 2.5px | 2px ink | textPrimary, w500 | translate 2px, shadow 0 |
| Ghost            | none        | none              | none    | textPrimary       | hoverFill               |
| Destructive      | errorTint   | textPrimary 2.5px | 4px ink | error, w700       | translate 4px, shadow 0 |
| Selected/active  | inverse     | textPrimary 2.5px | none    | onInverse         | inversePressed fill     |

Reason: an ink fill next to its own ink shadow measures 1.00:1, so the shadow
disappears and the press looks broken. Ink fills therefore never carry a
shadow.

Alternative B (not default): ink fill with a `borderControl` shadow (4.81:1
against the fill). It keeps "primary = inversion" in every preset but breaks
the "shadows are ink" rule.

## 7. Shadows

1. Default preset: levels xs and sm have no shadow. Levels md to xxl are one
   ink layer at 6% alpha (light) or 40% alpha (dark), blur 2 x elevation, no
   spread. Layers are mainly separated by `borderSubtle` and the canvas to
   surface step.
2. Neobrutalism: flat offsets of 2, 4, 6, 8, 10 and 12px in `textPrimary` for
   both modes.
3. `TintedShadowScheme` is deprecated.

## 8. Typography links to color

1. Docs and Flutter: Plus Jakarta Sans for all text, including labels and
   metadata (DP-6). Docs: IBM Plex Mono only for text that must be
   monospaced: code blocks, inline code, shell commands, terminal output,
   file paths, token and role names, and keyboard keys. IBM Plex Sans is not
   used.
2. Numeric columns in tables use Plus Jakarta Sans with
   `font-variant-numeric: tabular-nums`. P6 checks that the loaded font
   renders tabular figures; if it does not, those columns fall back to
   IBM Plex Mono and the P6 summary says so.
3. Code blocks (on `sunken`): keyword textPrimary bold, type textPrimary,
   string textSecondary, number textSecondary, punctuation textSecondary,
   comment textTertiary italic. Minimum 7.16 (light) and 8.84 (dark).
   Keywords use weight 500 (DP-6, decided); no Plex Mono 600 is loaded.

## 9. WCAG 2.2 coverage

| Criterion                     | Level | How Ink and Paper meets it                                |
| ----------------------------- | ----- | --------------------------------------------------------- |
| 1.4.1 Use of Color            | A     | Status icons and text, error border width, link underline |
| 1.3.3 Sensory Characteristics | A     | Copy never names a color                                  |
| 1.4.3 Contrast (Minimum)      | AA    | Exceeded: all text >= 7                                   |
| 1.4.6 Contrast (Enhanced)     | AAA   | All text roles >= 7 on every surface                      |
| 1.4.11 Non-text Contrast      | AA    | borderControl >= 3.51, selected states by inversion       |
| 2.4.7 Focus Visible           | AA    | 2px ring in focusRing                                     |
| 2.4.11 Focus Not Obscured     | AA    | Ring drawn outside the element, sticky UI checked in P9   |
| 2.4.13 Focus Appearance       | AAA   | Solid ring >= 2px, contrast >= 14.95                      |
| 1.4.8 Visual Presentation     | AAA   | forced-colors, prefers-contrast, Flutter high contrast    |
| 1.4.12 Text Spacing           | AA    | Not color, checked so the rebrand does not regress it     |

Exemptions used on purpose: `textDisabled` (disabled controls) and
`borderSubtle` (decoration). Both are still kept near 3:1 and 1.2:1.
