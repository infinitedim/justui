# Phase 8: CLI

Status: Draft v1 (2026-10-13)
Depends on: P3 (the `inkAndPaper` API the template calls)
Blocks: P5.T5 (showcase regeneration), P9
Areas: `packages/cli` (Rust crate `justui`)

## 1. Summary

Make `justui init` scaffold an Ink and Paper theme. Users pick a tint instead
of a brand seed color. `--seed` keeps working as a deprecated alias so existing
scripts and docs do not break. `justui doctor` warns when a project still has
tokens copied before the rebrand. The embedded templates pick up the new
tokens and core automatically because they are embedded from `packages/tokens/lib`
and `packages/core/lib`.

## 2. Background

1. `src/commands/init.rs:202-232` reads `--seed`, validates hex, defaults to
   `#3b82f6` (`--yes` and the interactive prompt), and builds `0xFF<hex>`.
2. `src/commands/init.rs:290-325` writes `lib/core/theme/just_theme.dart` with
   two `JustThemeData.fromSeed(...)` calls plus `colorSpace` when the user
   picked `oklch` or `hsluv`. It writes through `path_guard::atomic_write` and
   then runs the Dart formatter.
3. `src/main.rs:98-100` defines `--seed`. `--color-space` and `--preset` sit
   next to it.
4. `src/config.rs` stores `color_space` in `justui.config.yaml`. There is no
   seed field in the config.
5. `src/utils/embedded_templates.rs:15-21` embeds `packages/tokens/lib` and
   `packages/core/lib` with RustEmbed. The token source JSON lives outside
   `lib/` (P1), so it is not embedded.
6. `src/commands/doctor.rs` checks toolchains, pubspec dependencies and the
   configured folders. It does not look inside copied token files.
7. `src/commands/update.rs` refreshes registry components only. Users who ran
   `init` before the rebrand keep the old tokens and core until they re-run
   `init` (see `91-out-of-scope.md`, `justui core sync`).
8. The existing changeset `.changeset-polyglot/cli-init-seed-flag.md` introduced
   `--seed`. Area checks are listed in `.agents/rules/rust-cli.md` (fmt,
   clippy, test, deny, machete).

## 3. Goals

1. New projects start on Ink and Paper with zero hand edits.
2. Old command lines still work and print a clear deprecation note.
3. Users with stale tokens learn about it from `doctor`.
4. No change to the config file format.

## 4. Non-goals

1. A `core sync` or `tokens update` command (DP-5, `91-out-of-scope.md`).
2. Fixing the `preset` command bugs found in research (`91-out-of-scope.md`).
3. Changing registry signing or `crypto.rs`.
4. New crates.

## 5. Functional requirements

### FR-8.1 New flags

| Flag               | Values                 | Meaning                                                            |
| ------------------ | ---------------------- | ------------------------------------------------------------------ |
| `--tint <name>`    | `warm`, `graphite`     | Named tint. Default `warm`                                         |
| `--tint-hue <deg>` | integer 0 to 359       | Custom tint hue with chroma 0.0035                                 |
| `--no-font`        | boolean, default false | Skip copying Plus Jakarta Sans and editing `pubspec.yaml` (FR-8.9) |

Rules:

1. `--tint` and `--tint-hue` conflict (clap `conflicts_with`). Passing both
   exits with code 2 and a message naming both flags.
2. `--tint-hue` outside 0 to 359 or not an integer is a clap validation error.
3. Help text says the tint changes the neutral warmth only, not the status
   colors and not contrast.

### FR-8.2 Deprecated `--seed`

1. `--seed` stays accepted and hidden from the short help, visible in
   `--help` with "(deprecated, use --tint or --tint-hue)".
2. Conversion follows option D (DP-4), the same rule as Dart `fromSeed`:
   - hex to sRGB to OKLCH;
   - chroma below 0.02 maps to `warm`;
   - otherwise the OKLCH hue, rounded to the nearest integer, becomes
     `--tint-hue`.
3. The CLI prints one warning line:
   `--seed is deprecated; using tint hue <h>. Use --tint-hue <h> next time.`
4. `--seed` combined with `--tint` or `--tint-hue` is a conflict error.
5. The existing hex validation and its error message stay as they are.
6. The OKLCH conversion is a small pure function in a new
   `src/utils/oklch.rs` (sRGB transfer, linear RGB to LMS, cube root, to Lab,
   to LCh). No crate is added.

### FR-8.3 Interactive prompt

1. When neither flag is given and `--yes` is not set, `init` asks:
   `Choose a neutral tint: warm (default), graphite, or a hue 0-359`.
2. Empty input means `warm`. Invalid input repeats the prompt with an error,
   matching the current seed prompt loop.
3. With `--yes`, the CLI logs `[auto] Using tint: warm`.

### FR-8.4 Theme template

`init` writes `lib/core/theme/just_theme.dart` as:

```
import 'package:flutter/material.dart' show Brightness;
import '../just_ui_core.dart';

/// Ink and Paper light theme.
final JustThemeData justThemeLight = JustThemeData.inkAndPaper(
  brightness: Brightness.light,{preset_param}{tint_param}
);

/// Ink and Paper dark theme.
final JustThemeData justThemeDark = JustThemeData.inkAndPaper(
  brightness: Brightness.dark,{preset_param}{tint_param}
);

/// Default bootstrap theme matching configuration.
final JustThemeData justTheme = {default_theme_ref};
```

Where:

1. `{tint_param}` is empty for `warm`, `\n  tint: JustTint.graphite,` for
   graphite, and `\n  tint: JustTint(hue: <h>),` for a custom hue.
2. `{preset_param}` keeps its current form.
3. `colorSpace` is no longer written. `--color-space` stays accepted and is
   still saved to `justui.config.yaml` because other commands read it; its
   help text says it no longer affects theme colors.
4. The import line matches what the P3 API needs (`Brightness` comes from
   `dart:ui` through Flutter); the formatter pass after writing stays.
5. The write keeps using `path_guard::atomic_write`.
6. `--dart-target` (`primary` or `standard`) only controls constructor syntax
   in copied library files through `apply_dart_target`; the theme file is
   written directly and has no constructor declarations, so it is the same
   for both targets. The template uses the long form (`Brightness.light`,
   `JustTint.graphite`) on purpose: it is user code and must read clearly.
   Dot shorthand in user code is the user's choice.

### FR-8.5 Doctor check

Add a check after the tokens folder check:

1. Find `color_tokens.dart` under the configured `tokens_dir` (depth limit 4).
2. If found and it does not contain `Color get inverse`, report a warning:
   `Tokens were copied before Ink and Paper. Re-run "justui init" in a clean
branch to update tokens and core, then run "justui diff".`
3. If not found, the check is skipped silently (the folder check already
   reports a missing folder).
4. The check never edits files and never fails `doctor` on its own (warning,
   not error).
5. Font check: if the copied `typography.dart` names `PlusJakartaSans` and
   the project `pubspec.yaml` has no font family with that name, warn:
   `Plus Jakarta Sans is not bundled; text falls back to the platform font.
Re-run "justui init" or add the font yourself.` This covers users who ran
   `init` before the rebrand or used `--no-font`.

### FR-8.6 Embedded templates

1. Dart sources: no change. The P8 build embeds the P2 and P3 versions of
   `packages/tokens/lib` and `packages/core/lib`. The test in FR-8.7 item 4
   proves the embedded tokens contain the new roles.
2. Fonts: a code change is needed. It depends on AC-2.10: the folder must
   exist with its files before the crate compiles. The existing `#[derive(RustEmbed)]`
   structs only cover `../tokens/lib/` and `../core/lib/`, and
   `extract_tokens` decodes every file as UTF-8 and silently skips files that
   fail (`Err(_) => continue`), so a `.ttf` placed there would be dropped. Add
   a separate `FontAssets` embed for `../tokens/assets/fonts/` and write its
   files as raw bytes (FR-8.9).

### FR-8.7 Tests

Add or update in `src/commands/init_tests.rs`, `src/commands/doctor_tests.rs`
and `tests/cli_tests.rs`:

1. Template for `warm`, `graphite`, hue 0, hue 359, with and without
   neobrutalism, light and dark default: exact string snapshots, and none
   contains `fromSeed` or `colorSpace`.
2. `--seed #3b82f6` produces a hue within 1 degree of the value the Dart
   `fromSeed` rule gives (the expected number is computed once from the token
   tools and written into the test); `--seed #808080` produces `warm`.
3. Flag conflicts and range errors return exit code 2.
4. The embedded `color_tokens.dart` contains `Color get inverse` and
   `Color get focusRing`.
5. Doctor: a fixture with old tokens yields the warning; a fixture with new
   tokens yields a pass; a missing file yields no extra line.
6. `src/utils/oklch.rs` unit tests: white, black, mid gray, `#3b82f6`,
   `#a3e635` against reference values with a tolerance of 0.001 for L and C
   and 0.5 degree for h.
7. Font assets: `init -y` copies the four `.ttf` files and `OFL.txt` byte for
   byte (hash compare with the embedded source) and adds exactly one
   `PlusJakartaSans` family to `pubspec.yaml`; running it twice does not add
   a second block; a `pubspec.yaml` that already has a `flutter:` section
   (for example `uses-material-design: true`) keeps it; `init -y --no-font`
   creates no `assets/fonts/` folder and leaves `pubspec.yaml` byte-identical.
8. Doctor font check (FR-8.5 item 5): warns when the family is missing, passes
   when present, stays silent with `--no-font` projects that set their own
   `fontFamily`.

### FR-8.8 Changeset

`.changeset-polyglot/cli-ink-and-paper-init.md` with `"justui_cli": minor`,
describing the new flags, the deprecated `--seed`, the new template and the
doctor warning.

### FR-8.9 Font asset (owner decision 2026-10-14)

1. The font files for Plus Jakarta Sans (OFL, weights 400 to 700) are added to
   the embedded templates (`embedded_templates.rs` already embeds
   `packages/tokens/lib` and `packages/core/lib`; the fonts live in a new
   `packages/tokens/assets/fonts/` folder that is also embedded) together with
   the `OFL.txt` license.
2. `init` copies the four `.ttf` files and `OFL.txt` (the OFL requires the
   license to travel with the font) to `assets/fonts/` in the user's project
   and adds a `fonts:` entry for family `PlusJakartaSans` under the
   `flutter:` key of `pubspec.yaml`. `pubspec_editor.rs` today only has
   `add_dependency`, which inserts under `dependencies:`; this needs a new
   function that finds or creates the `flutter:` section, keeps existing keys
   such as `uses-material-design`, writes the same `.bak` backup and uses
   `path_guard::atomic_write`. If a `PlusJakartaSans` family already exists,
   `init` leaves it alone and prints a note.
3. `--no-font` skips both steps for users who want their own font.
4. Binary size grows by the font files (about 4 files); the size is recorded
   in the P9 report.

## 6. Non-functional requirements

1. NFR-8.1: No new crate (`cargo machete` and `cargo deny check` unchanged).
2. NFR-8.2: Follow `.agents/rules/rust-cli.md` (error style, no `unwrap` in
   non-test code except where the file already does so for static regexes).
3. NFR-8.3: All output and source ASCII.
4. NFR-8.4: `init` with `--yes` makes no extra prompt and no network call
   beyond what it does today.

## 7. Files

| File                                            | Change                                             |
| ----------------------------------------------- | -------------------------------------------------- |
| `packages/cli/src/main.rs`                      | `--tint`, `--tint-hue`, `--no-font`, `--seed` help |
| `packages/cli/src/commands/init.rs`             | Tint resolution, prompt, template                  |
| `packages/cli/src/commands/init_tests.rs`       | Updated and new tests                              |
| `packages/cli/src/commands/doctor.rs`           | Stale tokens check                                 |
| `packages/cli/src/commands/doctor_tests.rs`     | New tests                                          |
| `packages/cli/src/utils/oklch.rs`               | New                                                |
| `packages/cli/src/utils/embedded_templates.rs`  | `FontAssets` embed, binary write                   |
| `packages/cli/src/utils/pubspec_editor.rs`      | `fonts:` block insert                              |
| `packages/cli/src/utils/mod.rs`                 | Register module                                    |
| `packages/cli/tests/cli_tests.rs`               | Flag tests                                         |
| `packages/cli/tests/fixtures/**`                | Old and new token fixtures                         |
| `.changeset-polyglot/cli-ink-and-paper-init.md` | New                                                |

`src/config.rs` is not changed.

## 8. Tasks

| ID     | Task                                                      | Depends on     |
| ------ | --------------------------------------------------------- | -------------- |
| P8.T1  | New template writing `inkAndPaper` (FR-8.4)               | P3             |
| P8.T2  | Flags, `--seed` alias, `oklch.rs`, prompt (FR-8.1 to 8.3) | P8.T1          |
| P8.T3  | Doctor check (FR-8.5)                                     | P2             |
| P8.T4  | Tests (FR-8.7)                                            | P8.T1 to P8.T3 |
| P8.T4b | Font asset copy and pubspec edit (FR-8.9)                 | P8.T1          |
| P8.T5  | Changeset                                                 | P8.T4          |

## 9. Acceptance criteria

1. AC-8.1: The five area checks pass:
   `cargo fmt --all --check`,
   `cargo clippy --all-targets --all-features -- -D warnings`,
   `cargo test --all-targets`, `cargo deny check`, `cargo machete`.
2. AC-8.2: In an empty Flutter project, `justui init -y` writes a
   `just_theme.dart` that contains `inkAndPaper` and no `fromSeed`, and
   `flutter analyze` on that project reports no warning (owner machine; P5.T5
   is the same check on the showcase).
3. AC-8.3: `justui init -y --seed 3b82f6` succeeds, prints exactly one
   deprecation line and writes a custom hue near 260.
4. AC-8.4: `justui init --tint warm --tint-hue 10` exits 2.
5. AC-8.5: `justui doctor` in a project with pre-rebrand tokens prints the
   warning and exits 0.
6. AC-8.6: `justui.config.yaml` written by the new `init` is byte-identical in
   format to the baseline for the same answers.
7. AC-8.7: In an empty Flutter project, `justui init -y` produces
   `assets/fonts/` with five files and a `pubspec.yaml` that `flutter pub get`
   accepts; `justui init -y --no-font` produces neither change (owner machine
   for `flutter pub get`).

## 10. Risks

| Risk                                                     | Mitigation                                                                                                           |
| -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Rust and Dart compute a different hue for the same seed  | Shared reference values in tests on both sides; 1 degree tolerance; the result only shifts neutrals by a tiny chroma |
| Users read old docs and pass `--seed`                    | Alias with a clear warning; P7 updates `cli-setup.mdx`                                                               |
| Existing projects stay on old tokens                     | Doctor warning; migration guide (P7); `core sync` tracked as out of scope                                            |
| Clap conflict rules change exit codes other tests expect | Run the full `cargo test` before the changeset                                                                       |

## 11. Pending decisions

| Decision | Default assumed                        |
| -------- | -------------------------------------- |
| DP-4     | Option D: seed hue becomes tint hue    |
| DP-5     | No `core sync` command in this rebrand |
| DP-8     | `warm` is the default tint             |

## 12. Exit criteria

All acceptance criteria met. `init` scaffolds Ink and Paper by default, old
scripts keep working, and `doctor` flags stale token copies.
