# 03. Baseline Audit

Status: Verified read-only on 2026-10-13
Baseline: `development` at `d80b55e`

Line numbers drift. Every implementer must re-locate code by symbol before
editing. Counts were taken with regex over the baseline tree and must be
re-counted in P0 (the guard-test allow-lists record the exact numbers).

## 1. Docs identity (`apps/docs`)

1. Fonts: IBM Plex Sans and IBM Plex Mono, named in the `@theme` block of
   `apps/docs/src/app/globals.css` and loaded in
   `apps/docs/src/app/[lang]/layout.tsx`.
2. Lime accent: `--just-accent: #a3e635` at `globals.css:83`, repeated at 182
   and 223. `--just-accent-text: #a3e635` in dark at 149 and 228. Light
   `--just-accent-text` is `#4d7c0f` (4.77:1 on `#f8fafc`, AA only).
3. `globals.css` is 386 lines: `@theme` (7 to 61), raw palette (72 to 91),
   default light (93 to 136), default dark (138 to 167), neobrutalism light
   (169 to 210, cream `#fff8e7`), neobrutalism dark (212 to 246), shadow
   overrides (253 to 281), press effect (283 to 295), Fumadocs block (297 to
   319), animations and reduced motion (321 to 386).
4. Muted text is `#6b6b6b` (line 100), 5.09:1 on `#f8fafc`: AA, not AAA.

## 2. Defects found in the docs

1. Unclosed CSS comment: the comment that starts at `globals.css:297`
   ("Fumadocs: route its surface tokens...") has no closing `*/` before the
   `body` rule at 299. The whole `body` block, including `background-color`,
   `color` and every `--color-fd-*` mapping, is commented out until the next
   `*/` at the stage animation comment. Fumadocs runs on its own defaults.
2. Focus ring fails: `apps/docs/src/lib/ui-classes.ts:18-19` uses
   `focus-visible:outline-accent` (lime). Lime on the light canvas is 1.44:1,
   which fails 1.4.11 and 2.4.13.
3. Links fail 1.4.1: `accentLink` in `ui-classes.ts` underlines only on hover.
4. Syntax colors fail AAA: `apps/docs/src/lib/justui-shiki-theme.ts:8-27`
   (light on white): string `#0f6a31` 6.72, type `#005c9b` 6.99, number
   `#994a00` 6.30, comment `#6b6b6b` 5.33.
5. No `forced-colors` or `prefers-contrast` handling anywhere in
   `apps/docs/src`.
6. `e2e/accessibility.spec.ts:16` runs axe with AA tags only
   (`wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`).

## 3. Docs color usage inventory

1. Accent utilities: 124 uses in 54 files under `apps/docs/src`. The file
   list is in `17-phase-7-docs-ui-and-content.md` section 6.1.
2. Status utilities (`bg|text|border-(success|warning|error|info|destructive)`)
   in 12 files: atoms badge, button, input; docs just-button-preview;
   molecules terminal-line; organisms component-preview-grid, studio-preview,
   theme-configurator; preview mocks avatar, dialog, icon-button, toast.
3. Seed literals: `DEFAULT_SEED_COLOR = '#a3e635'` at
   `src/lib/theme-studio-context.tsx:43`; `'#a3e635'` in
   `theme-configurator.tsx:225` and `:237`; a doc comment example in
   `code-export-drawer/code-generators.ts:7`.
4. Studio color math: `src/lib/theme/color-resolver.ts`, `oklch.ts`,
   `hsluv.ts`, `perceptual.ts`.

## 4. Flutter tokens (`packages/tokens`)

1. `color_palette.dart`: white, black and six 11-step families (neutral is
   slate, primary is blue with `primary500 = #3B82F6`, success, warning,
   error, info).
2. `color_semantic.dart`: 16 roles per mode. Light `borderFocus` is
   `primary500`, dark is `primary400`.
3. `color_tokens.dart`:
   - `JustColorScheme` (line 10): 16 abstract getters, `==`, `hashCode`. No
     primary or accent role.
   - `_JustColorSchemeNeobrutalismLight` (line 200): cream `#FFF8E7`, black
     text and borders, vivid status `#38E54D`, `#FFD93D`, `#FF4B4B`,
     `#4D96FF`.
   - `_JustColorSchemeNeobrutalismDark` (line 240): `#1A1A1A` canvas.
   - `JustThemePreset` enum (line 192).
   - `CustomColorScheme` (line 525) with `resolveSemantic` (line 580) that
     branches on preset and writes pure black and white (lines 601 to 613).
4. `typography.dart:9`: default font family `Inter`.
5. `colors_accessibility.dart`: `contrastRatioWith`, `isAccessibleWith` (AA).
6. Tests: `packages/tokens/test/colors_test.dart` asserts the current
   specification, including `borderFocus = primary500`.

## 5. Flutter theme engine (`packages/core/lib/src/theme`)

1. `theme_data.dart` preset branches: `shadowOffset` (66 to 67),
   `resolveShadows` (77), `fromSeed` cream background (155 to 156), `fromSeed`
   focus color (177 to 180), `fromSeed` shadows (245 to 247), `fromSeed` motion
   (262 to 263). `buildPressEffect` already delegates to preset tokens.
2. Pure color literals in `theme_data.dart`: 60, 156, 179 to 180, 247, 285,
   295 to 299, 310 to 314. `_makeAccessible` falls back to pure black or white
   (285). `applyHighContrastOverrides` swaps to pure black or white canvases
   (292 to 299).
3. `theme_data_material.dart`: anchor `// CLI:REGISTER_EXTENSIONS` at line 31. `borderFocus` mapped to Material primary and secondary (39, 41) and
   focused input border (75). `borderDefault` mapped to divider and input
   borders (35, 67, 71, 89).
4. `preset_tokens.dart`: `showsDefaultBorder` declared at 73 (false at 174,
   true at 277). `resolveHoverDecoration` builds alpha tints from
   `borderDefault`.
5. `schemes/shadow_scheme.dart`: `NeobrutalismShadowScheme` defaults to pure
   `#000000` (136). `TintedShadowScheme` depends on the seed.
6. `theme_provider.dart` exposes aspect getters including
   `context.justPresetTokens` (325).

## 6. Components (`packages/core/lib/src/components`)

Mirrored byte for byte into `registry/components` by
`tools/generate_checksums.dart`. Per-preset registry folders were removed in
commit `38af1d7`; `files_for_preset` falls back to `default`.

### 6.1 Role reads (regex count)

background 30, card 27, elevated 12, muted 12, overlay 6, textPrimary 146,
textSecondary 46, textDisabled 7, textInverse 17, borderDefault 82,
borderFocus 50, borderError 1, success 11, warning 11, error 15, info 9.

Other: 83 `withValues(alpha:` calls, 18 opaque `Color(0xFF...)`, 43
transparent `Color(0x00...)`, 11 `JustColorPalette.` references.

### 6.2 Per component

Columns: borderFocus reads / color literals / showsDefaultBorder /
preset comparisons / warning / success / error.

| Component   | bF  | lit | sDB | cmp | warn | succ | err |
| ----------- | --- | --- | --- | --- | ---- | ---- | --- |
| accordion   | 0   | 0   | 4   | 0   | 0    | 0    | 0   |
| avatar      | 0   | 2   | 2   | 0   | 0    | 0    | 0   |
| badge       | 1   | 10  | 4   | 0   | 2    | 1    | 1   |
| bottom_nav  | 1   | 0   | 0   | 0   | 0    | 0    | 0   |
| breadcrumb  | 5   | 1   | 3   | 0   | 0    | 0    | 0   |
| button      | 1   | 13  | 20  | 0   | 1    | 0    | 1   |
| card        | 1   | 2   | 6   | 0   | 0    | 0    | 0   |
| carousel    | 4   | 0   | 0   | 5   | 0    | 0    | 0   |
| checkbox    | 1   | 1   | 2   | 0   | 1    | 0    | 0   |
| date_picker | 6   | 0   | 8   | 0   | 0    | 0    | 2   |
| dialog      | 0   | 0   | 1   | 0   | 0    | 0    | 0   |
| input       | 1   | 1   | 4   | 0   | 0    | 2    | 2   |
| progress    | 1   | 1   | 4   | 0   | 0    | 0    | 0   |
| radio       | 1   | 0   | 1   | 0   | 0    | 0    | 0   |
| resizable   | 2   | 0   | 0   | 2   | 0    | 0    | 0   |
| scroll      | 1   | 9   | 1   | 0   | 0    | 0    | 0   |
| select      | 4   | 1   | 12  | 0   | 0    | 0    | 3   |
| separator   | 0   | 0   | 0   | 0   | 0    | 0    | 0   |
| shared      | 1   | 0   | 2   | 0   | 0    | 0    | 0   |
| sheet       | 0   | 0   | 2   | 0   | 0    | 0    | 0   |
| sidebar     | 1   | 6   | 8   | 0   | 0    | 0    | 0   |
| skeleton    | 0   | 8   | 0   | 0   | 0    | 0    | 0   |
| slider      | 1   | 0   | 9   | 0   | 1    | 0    | 0   |
| switch      | 1   | 0   | 1   | 0   | 0    | 1    | 0   |
| table       | 4   | 0   | 9   | 0   | 0    | 0    | 0   |
| tabs        | 2   | 1   | 4   | 0   | 0    | 1    | 0   |
| time_picker | 7   | 4   | 18  | 0   | 0    | 0    | 0   |
| toast       | 0   | 0   | 1   | 0   | 2    | 2    | 2   |
| toggle      | 3   | 1   | 1   | 0   | 0    | 0    | 0   |
| tooltip     | 0   | 0   | 3   | 0   | 0    | 0    | 0   |

### 6.3 Known color hacks

| Location                                     | Current behavior                                                           |
| -------------------------------------------- | -------------------------------------------------------------------------- |
| button/just_button_style.dart:119-124        | Primary = `warning` (neobrutalism) or `borderFocus`; label pure black      |
| button/just_button_style.dart:193            | Destructive label pure black in neobrutalism                               |
| button/just_button_style.dart:211-214        | Link uses `info` in neobrutalism light                                     |
| badge/just_badge.dart:166                    | Primary badge uses `warning` in neobrutalism                               |
| checkbox/just_checkbox.dart:190              | Checked fill uses `warning` in neobrutalism                                |
| slider/just_slider.dart:227                  | Thumb uses `warning` in neobrutalism                                       |
| switch/just_switch.dart:233                  | On track uses `success` in neobrutalism                                    |
| tabs/just_tab_indicator.dart:107             | Indicator uses `success` at alpha 0.2                                      |
| input/just_input.dart:482, 1056              | Success border                                                             |
| input/just_input.dart:826-827                | Cursor `JustColorPalette.primary500`, background cursor `#888888`          |
| avatar/just_avatar.dart:80-85                | Six-color decorative name palette                                          |
| avatar/just_avatar.dart:199-208              | Presence dots from palette status colors                                   |
| avatar/just_avatar.dart:228                  | Pure white dot border                                                      |
| skeleton/just_skeleton.dart:148-152, 865-869 | Slate literals                                                             |
| scroll/just_scroll_area.dart:740-768         | White ShaderMask stops (masks, may stay)                                   |
| toast/just_toast.dart:599-657                | Status alpha tints and status icon colors                                  |
| shared/\_shared_focus_indicator.dart:30-35   | Focus color by `showsDefaultBorder`; reads preset tokens without an aspect |
| carousel, resizable                          | 7 `preset == .neobrutalism` comparisons                                    |

## 7. WCAG failures today

| Pair                                         | Ratio        | Fails          |
| -------------------------------------------- | ------------ | -------------- |
| Lime `#a3e635` on `#f8fafc` (focus ring)     | 1.44         | 1.4.11, 2.4.13 |
| Muted `#6b6b6b` on `#f8fafc`                 | 5.09         | 1.4.6          |
| Flutter primary label `#F8FAFC` on `#3B82F6` | 3.52         | 1.4.3          |
| Shiki string, type, number, comment          | 5.33 to 6.99 | 1.4.6          |

## 8. CLI (`packages/cli`, Rust)

1. `init.rs:202-232`: asks for a hex seed, default `#3b82f6`.
   `init.rs:306-313`: writes `lib/core/theme/just_theme.dart` with
   `JustThemeData.fromSeed`.
2. `main.rs:98-100`: `--seed` flag. `main.rs:277, 399, 411`: hidden
   `SignRegistry` command.
3. `utils/embedded_templates.rs:15-21`: RustEmbed of `../tokens/lib/` and
   `../core/lib/`.
4. `update.rs` refreshes registry components only. Nothing refreshes the
   tokens or core that `init` copied.

## 9. Apps and content

1. `apps/showcase/lib/main.dart` is a CLI sandbox gallery (not the counter
   template). Its generated theme uses `fromSeed(0xFF3B82F6)`.
2. `apps/preview/lib/usecases/` has 30 use-case files; `tokens_usecases.dart`
   holds iOS-style literals and swatches based on the old schemes.
3. Docs content that describes colors, the seed or `borderFocus` (en and id):
   `tokens/colors.mdx`, `theming.mdx`, `guides/custom-theme.mdx`,
   `tokens/shadows.mdx`, `cli-setup.mdx`, `guides/copy-paste-workflow.mdx`,
   plus mentions in `components/carousel.mdx`, `dialog.mdx`, `toast.mdx`,
   `tooltip.mdx`. The `cn` locale has no content.

## 10. Rule files that conflict with this rebrand

1. `.agents/rules/design.md:13-27`: locks the docs identity to lime and says
   docs and library identities must stay separate (line 19).
2. `.agents/rules/design.md:88` and `.agents/rules/flutter.md:84`: text
   contrast floor 4.5:1 (the new floor is 7:1).
3. `.agents/rules/flutter.md:42`: neobrutalism borders use `textPrimary` in
   every state (conflicts with the 3px `error` border in neobrutalism).
4. `.agents/rules/docs-web.md:136-138`: colors come from tokens mapped in
   `globals.css`; it must name the generated token files as the source.
   `docs-web.md:192-193`: Studio color math must match `packages/tokens`,
   with a parity test for one seed (this becomes one tint).
