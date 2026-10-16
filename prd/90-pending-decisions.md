# Pending Decisions

Status: Decided (2026-10-14). The owner accepted every recommended default.
Owner: Dimas

These are the questions the owner still has to answer. Every phase PRD
assumes the default listed here so planning can continue. Work that depends on
a decision must not be merged until the decision is answered or the default is
accepted (P0.T1 and the P9 release gate).

Each decision lists the options, the default, why that default was picked,
and the phases it affects.

## Decided

| Date       | Decision                                                                                                                                                  | Applied in |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| 2026-10-14 | Plus Jakarta Sans for everything (docs and Flutter)                                                                                                       | P2, P6, P8 |
| 2026-10-14 | All defaults in the summary table accepted (DP-1 to DP-14). For DP-6: IBM Plex Mono stays for code, the CLI copies the font assets and edits pubspec.yaml | all        |
| 2026-10-14 | DP-10: no logo exists yet; default Flutter and Next.js icons stay as placeholders                                                                         | P5, P7     |
| 2026-10-14 | Next.js pages that are not docs pages are deprecated; the owner redesigns them separately                                                                 | P7, P9     |
| 2026-10-16 | DP-6 update: IBM Plex Sans is removed everywhere. IBM Plex Mono stays only for text that must be monospaced (see DP-6 item 1); everything else is Plus Jakarta Sans | P6, P7     |

## Summary

| ID    | Topic                         | Default                                                                           | Affects        |
| ----- | ----------------------------- | --------------------------------------------------------------------------------- | -------------- |
| DP-1  | Release type                  | Minor (0.15.0) with deprecations                                                  | P2, P3, P4, P9 |
| DP-2  | Neobrutalism primary          | Rule A                                                                            | P3, P4, P6, P7 |
| DP-3  | Badge status variants         | Monochrome with glyph, deprecated                                                 | P4, P7         |
| DP-4  | `fromSeed` future             | Option D (seed hue becomes tint)                                                  | P3, P7, P8     |
| DP-5  | `justui core sync` command    | Out of scope, follow-up                                                           | P8             |
| DP-6  | Fonts                         | Plus Jakarta Sans for all text; IBM Plex Mono only for monospaced text (decided)  | P2, P6, P7, P8 |
| DP-7  | Exact hex values              | Keep the owner's hex (1-unit tolerance)                                           | P1             |
| DP-8  | Tint choice                   | Warm default, graphite as second named tint                                       | P1, P3, P7, P8 |
| DP-9  | Tint field on `JustThemeData` | No field                                                                          | P2, P3         |
| DP-10 | Icons and logo                | Unchanged                                                                         | P5, P7         |
| DP-11 | Dark dialog edge              | `borderSubtle` edge                                                               | P4             |
| DP-12 | `errorHover` role             | Included                                                                          | P1, P2, P4     |
| DP-13 | Info status color             | No color (forwards to `textPrimary`)                                              | P2, P4, P7     |
| DP-14 | Rule-file changes             | Owner applies the P0 patches before P1                                            | P0, P9         |

## DP-1 Release type

Question: Is the rebrand a minor or a major release?

| Option | Meaning                                                                                                     |
| ------ | ----------------------------------------------------------------------------------------------------------- |
| A      | Minor (0.15.0). Old API keeps compiling as deprecated; visual change is listed as Breaking in the changelog |
| B      | Major (1.0.0). Old API can be removed right away                                                            |

Default: A.
Why: the packages are pre-1.0, users copy source, and forwarding getters cost
little. M9 (zero compile breaks) only holds with A.
If B: P2 to P4 can delete old names instead of deprecating them, and every
polyglot changeset becomes `major`.

## DP-2 Neobrutalism primary

Question: How does the primary action look under neobrutalism?

| Option | Meaning                                                                                                       |
| ------ | ------------------------------------------------------------------------------------------------------------- |
| A      | Surface fill, 2.5px ink border, 4px ink shadow, w700 label. Ink fill only for selected states, with no shadow |
| B      | Ink fill with a `borderControl` colored shadow (4.81:1 against the fill)                                      |

Default: A.
Why: an ink fill next to an ink shadow measures 1.00:1, so the shadow
disappears. A keeps "all shadows are ink", which is the core of the style.
B keeps "primary is always inverted" across presets but adds a gray shadow.
Details: `02-design-spec.md` section 6.

## DP-3 Badge status variants

Question: What happens to `success`, `warning`, `error` and `info` badges?

| Option | Meaning                                                               |
| ------ | --------------------------------------------------------------------- |
| A      | Render monochrome with a leading glyph; variants marked `@Deprecated` |
| B      | Keep colored text on a status tint                                    |
| C      | Remove the variants                                                   |

Default: A.
Why: badges are decorative labels, which the allow-list in `02-design-spec.md`
keeps monochrome. A avoids a compile break; C breaks users; B adds color to a
place where it carries no extra meaning.

## DP-4 Future of `fromSeed`

Question: What does `JustThemeData.fromSeed` do after the rebrand?

| Option | Meaning                                                                                      |
| ------ | -------------------------------------------------------------------------------------------- |
| A      | Remove it                                                                                    |
| B      | Keep the old colorful behavior                                                               |
| C      | Deprecate; ignore the seed and return the warm theme                                         |
| D      | Deprecate; the seed's OKLCH hue becomes the tint hue (chroma 0.0035); gray seeds map to warm |

Default: D.
Why: existing apps keep compiling, and their seed still means something. The
same rule converts old Studio links (P7) and the CLI `--seed` alias (P8).

## DP-5 `justui core sync`

Question: Should this rebrand add a CLI command that refreshes copied tokens
and core in existing projects?

Default: No. Tracked in `91-out-of-scope.md`.
Why: `update` only refreshes registry components today. A safe sync needs
diff and conflict handling for user-edited core files, which is a feature of
its own. P8 adds a `doctor` warning and P7 documents a manual path.

## DP-6 Fonts

Decided 2026-10-14 (owner): everything uses Plus Jakarta Sans, the docs and
the Flutter library default.

Details, all decided with the defaults on 2026-10-14:

1. Mono family (updated 2026-10-16): Plus Jakarta Sans has no monospace
   sibling, so IBM Plex Mono stays, but only for text that must be
   monospaced: code blocks, inline code, shell commands, terminal output,
   file paths, token and role names, and keyboard keys. Labels, metadata,
   taglines, counters and navigation use Plus Jakarta Sans. IBM Plex Sans is
   not loaded anywhere. Keywords in code use weight 500.
2. Flutter delivery: the font ships as asset files in
   `packages/tokens/assets/fonts/` (added in P2) and `justui init` copies them
   and edits the user's `pubspec.yaml` (P8 FR-8.9).
3. Wider metrics: P4 goldens load the real font and are taken after the
   change (P4 section 13).

## DP-7 Exact hex values

Question: The generator rebuilds neutrals from OKLCH. Some approved hex values
differ from the recomputed ones by 1 unit in one channel. Which wins?

Default: The approved hex in `02-design-spec.md` is stored in the token
source; the generator checks that the recomputed value is within 1 unit.
Why: the approved values were measured and published; a 1-unit difference has
no visible or contrast effect.

## DP-8 Tint

Question: Which neutral tint is the default?

| Option   | Hue | Chroma | Feel                  |
| -------- | --- | ------ | --------------------- |
| Warm     | 80  | 0.0035 | Paper, ink, editorial |
| Graphite | 260 | 0.0035 | Cool, technical       |
| Pure     | -   | 0      | Plain gray            |

Default: Warm, with graphite as the second named tint.
Why: warm reads as "paper" and gives the luxurious feel without visible color.
All contract rules pass for any hue up to chroma 0.010.

## DP-9 Tint field on `JustThemeData`

Question: Should `JustThemeData` store the tint as a field?

Default: No. The tint is an input to `inkAndPaper` and is baked into the color
scheme.
Why: adding a field changes `copyWith`, `==` and `hashCode`, and nothing reads
it after construction. If a future feature needs it, add it then in one commit
(P3 FR-3.4 item 7).

## DP-10 Icons and logo

Question: Do the logo shape and the Flutter web icons change?

Default: No. The logo is only recolored to `textPrimary`; default Flutter web
icons in the apps stay.
Why: identity work beyond color is out of this rebrand (`01-product-overview.md`
non-goals).

## DP-11 Dark dialog edge

Question: How do dark dialogs separate from the scrim?

Default: Dark dialogs always draw a 1px `borderSubtle` edge.
Why: dark `raised` against the dark scrim measures 1.17:1, so the dialog edge
is hard to see without a line. Light mode measures 3.45:1 and needs no edge.

## DP-12 `errorHover`

Question: Is there a dedicated hover color for destructive actions?

Default: Yes. `errorHover` is `#9a1f1d` light and `#e9978d` dark.
Why: without it, destructive hover would use alpha overlays, which the color
guard (CG-7) bans in components.

## DP-13 Info status

Question: Does "info" get a color?

Default: No. `info` forwards to `textPrimary`; info messages use an info glyph
and text only.
Why: blue would be a fourth hue and the palette promise is three status hues.
Info is not a warning or an error, so it needs no attention color.

## DP-14 Rule-file changes

Question: Who updates `.agents/rules/*.md` and `AGENTS.md` where they conflict
with these PRDs?

Known conflicts: `design.md` 13 to 27 (lime identity is locked), `design.md`
19, `design.md` 88 (text floor 4.5), `flutter.md` 42 and 84, `docs-web.md` 136
to 138 and 192 to 193.

Default: The implementer writes exact patches in P0 (FR-0.4); the owner
applies or rejects them before P1 starts.
Why: rule files steer every agent in the repository, so only the owner should
change them. Until they change, the rule files win over the PRDs.
