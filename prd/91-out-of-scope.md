# Out of Scope and Follow-up Work

Status: Draft v1 (2026-10-13)

Research for this rebrand found work that is real but does not belong in it.
Each item is kept here so it is not lost and is not silently added to a phase.
Items marked "not re-verified" come from the earlier research response and
should be confirmed against the current `development` branch before anyone
plans them.

## 1. Follow-up features

| ID   | Item                                                                                                       | Why it is out of scope                                                                                                                                                                               | Suggested next step                                                                    |
| ---- | ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| OS-1 | `justui core sync` (or `tokens update`) command that refreshes copied tokens and core in existing projects | `update` only refreshes registry components. A safe sync needs diff and conflict handling for user-edited core files (DP-5)                                                                          | Own PRD after the rebrand ships; reuse the meta-hash approach from `diff` and `update` |
| OS-2 | Redesign of all non-docs Next.js pages (landing, components catalog, Theme Studio, not-found)              | Owner decision 2026-10-14: these pages are deprecated in this rebrand (P7 section 0) and replaced by the redesign. Their Studio tint picker, code export for `inkAndPaper` and parity test move here | Separate design research thread; the redesign removes the transitional aliases         |
| OS-3 | Mono font change for code blocks                                                                           | Closed 2026-10-16: IBM Plex Mono stays for monospaced text only, IBM Plex Sans is removed (DP-6 item 1). Kept here as a record                                                                      | None                                                                                   |
| OS-4 | Logo and icon redesign                                                                                     | DP-10                                                                                                                                                                                                | Separate identity task                                                                 |
| OS-5 | Third and later presets                                                                                    | The rebrand makes presets data-driven (G7) but adds no new preset                                                                                                                                    | First new preset is the real test of M10                                               |
| OS-6 | Removing the deprecated API                                                                                | Happens in the next minor release after this one (DP-1)                                                                                                                                              | Track as a release task with a date                                                    |
| OS-7 | `cn` translation of the docs                                                                               | `cn` content is empty today                                                                                                                                                                          | Content task                                                                           |

## 2. Defects found during research

| ID    | Item                                                                                                                                              | Status           | Note                                                                                                         |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------ |
| OS-8  | `justui preset` apply does not rewrite `lib/core/theme/just_theme.dart`, so switching preset after `init` leaves the old preset in the theme file | Not re-verified  | From the earlier research response                                                                           |
| OS-9  | Non-atomic file write in `packages/cli/src/commands/preset.rs` (around line 336), while `init` uses `path_guard::atomic_write`                    | Not re-verified  | Same source as OS-8                                                                                          |
| OS-10 | The registry signing seed constant sits in public source in `packages/cli/src/utils/crypto.rs`                                                    | Verified present | Security follow-up. Anyone can sign a registry that the CLI trusts. Needs key management, not a color change |
| OS-11 | `CONTRIBUTING.md` is outdated (tests path and CLI tree no longer match the repository)                                                            | Verified         | Docs housekeeping                                                                                            |

## 3. Content issues not tied to color

These are partly fixed in P7 because the same pages are rewritten there. Only
the color and theming parts are in scope; anything else on these pages is
not.

| ID    | Item                                                                                                      | Handling                                                                                                       |
| ----- | --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| OS-12 | `cli-setup.mdx` documents a `seed_color` config field that does not exist in `packages/cli/src/config.rs` | Removed in P7 (FR-7.9) because the page is rewritten for `--tint`                                              |
| OS-13 | `tokens/colors.mdx` makes neobrutalism hex claims that do not match the code                              | Replaced in P7 by `ColorRoleTable`                                                                             |
| OS-14 | `guides/accessibility.mdx` says "WCAG 2.0" and documents only the AA floor                                | Updated in P7 for the color parts; other accessibility topics (touch targets, screen readers) are not reviewed |

## 4. Rules for adding to this list

1. Anything found while implementing a phase that is not needed for that
   phase's acceptance criteria goes here, not into the phase.
2. Each entry says where it was found and whether it was verified.
3. Moving an item into a phase needs the owner's approval.
