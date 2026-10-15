# Phase 9: Verification and Release

Status: Draft v1 (2026-10-13)
Depends on: P0 to P8
Blocks: nothing (this is the release gate)
Areas: whole repository, `CHANGELOG.md`, `.changeset`, `.changeset-polyglot`, `tools/apply_changesets.dart`, `tools/apply_changesets_cargo.sh`

## 1. Summary

Prove that the finished branch meets every goal and metric in
`01-product-overview.md`, then prepare the release: version bumps through the
existing changeset tools, a changelog with a "Breaking" section, and the
migration guide. Nothing from P0 to P8 reaches users before this gate passes.
The owner decides when to merge and publish; this phase only prepares.

## 2. Background

1. Current versions: `just_ui_tokens` 0.14.0, `just_ui_core` 0.14.0, CLI
   (`packages/cli/Cargo.toml`) 0.14.0.
2. Dart versions are bumped by `tools/apply_changesets.dart` from
   `.changeset-polyglot/*.md`; the CLI by `tools/apply_changesets_cargo.sh`
   (key `"justui_cli"`); the docs app by Changesets in `.changeset/`.
3. `CHANGELOG.md` at the root has an `[Unreleased]` section with Added,
   Changed and Fixed. It has no "Breaking" heading yet.
4. The Definition of done in `AGENTS.md` section 6 lists the commands per
   area. Some checks need the owner machine (Flutter SDK, Playwright, a
   browser).

## 3. Goals

1. Every metric M1 to M10 measured and recorded.
2. Every acceptance criterion from P0 to P8 re-run on the final branch head.
3. A release that existing users can adopt without a compile break (DP-1).
4. A written record of what was verified and what was not.

## 4. Non-goals

1. Publishing, tagging, pushing or opening pull requests. The owner does
   these.
2. Removing deprecated API (next minor release after this one).
3. New features found during verification. They go to `91-out-of-scope.md`.

## 5. Functional requirements

### FR-9.1 Verification matrix

Every row runs on the final branch head. Results go into
`docs/ink-and-paper/verification-report.md` (FR-9.4).

| ID   | Check                    | How                                                                                                                                                                                                                                                                                                                                                                                         | Where                        |
| ---- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| V-1  | Contrast contract (Dart) | `contrast_contract_test.dart` for 2 presets x 2 modes, plus the hand floors                                                                                                                                                                                                                                                                                                                 | Sandbox                      |
| V-2  | Tint sweep               | Test that builds `inkAndPaper` for hue 0 to 359 step 15 and chroma 0, 0.0035, 0.010, in both modes, and checks every contract rule                                                                                                                                                                                                                                                          | Sandbox                      |
| V-3  | Generator drift          | `dart run tools/generate_tokens.dart --check`                                                                                                                                                                                                                                                                                                                                               | Sandbox                      |
| V-4  | Cross-language parity    | Dart parity test (P2) green, and `tokens.generated.ts` role values equal the Dart generated values (Vitest test from AC-6.2). The Studio TS parity test is deprecated (OS-2)                                                                                                                                                                                                                | Both                         |
| V-5  | Web contrast             | Vitest role pair test (AC-6.2) and Shiki test (AC-6.3)                                                                                                                                                                                                                                                                                                                                      | Sandbox                      |
| V-6  | Guards                   | `color_guard_test.dart` at the final state of P4 section 9; `style-guards.test.ts` with closed ratchets                                                                                                                                                                                                                                                                                     | Sandbox                      |
| V-7  | Flutter widget tests     | `melos exec --flutter --dir-exists="test" -- "flutter test"`                                                                                                                                                                                                                                                                                                                                | Owner machine                |
| V-8  | Goldens                  | Golden tests for every component family in 4 combinations, reviewed image by image                                                                                                                                                                                                                                                                                                          | Owner machine                |
| V-9  | Docs snapshots           | `bun run test:e2e` including `visual-snapshots.spec.ts`                                                                                                                                                                                                                                                                                                                                     | Owner machine                |
| V-10 | axe AAA                  | AC-7.9 pages (docs pages only; non-docs pages are deprecated, see P7 section 0), tags `wcag2a`, `wcag2aa`, `wcag2aaa`, `wcag21a`, `wcag21aa`, `wcag22aa`, 4 combinations                                                                                                                                                                                                                    | Owner machine                |
| V-11 | Keyboard focus           | Tab through header, search, one docs content page and one component docs page in 4 combinations: ring visible, not obscured by sticky header (2.4.11), width and color as in AC-6.5                                                                                                                                                                                                         | Owner machine                |
| V-12 | Forced colors            | Chromium `forcedColors: 'active'`: buttons keep a border, selected states use `Highlight`, focus visible                                                                                                                                                                                                                                                                                    | Owner machine                |
| V-13 | Prefers contrast         | `prefers-contrast: more` on the web and `MediaQuery.highContrast` in Flutter both collapse secondary and tertiary to primary and subtle borders to control borders                                                                                                                                                                                                                          | Both                         |
| V-14 | Color vision review      | Simulate protanopia, deuteranopia and tritanopia with the Machado 2009 matrices on the toast, badge, input error and destructive button screens. The three status colors sit at nearly the same lightness (OKLCH L 0.40 to 0.42 in light mode, about 0.80 in dark mode), so they will look alike under simulation. Pass condition: every status is still identified by glyph and text alone | Sandbox (script) plus review |
| V-15 | Neobrutalism checklist   | Section 6 of `02-design-spec.md`: 2.5px ink borders, ink shadows, zero radius except pills, translate on press with `animations.instant`, no shadow on any ink fill (Rule A), 3px error border, focus ring 2.5px                                                                                                                                                                            | Owner machine review         |
| V-16 | Registry and CLI         | Registry dry run clean, signature verifies, `justui init -y` plus `justui add --all -y` in a fresh Flutter app, `flutter analyze` clean, `justui doctor` behavior from AC-8.5                                                                                                                                                                                                               | Owner machine                |
| V-17 | Upgrade path             | Take a fresh app scaffolded with the baseline CLI 0.14.0 and its components; upgrade the packages and run `flutter analyze`: zero errors, deprecation infos allowed (M9)                                                                                                                                                                                                                    | Owner machine                |
| V-18 | New preset cost (M10)    | Paper exercise on a scratch branch that is then deleted: add a third preset stub and count the non-test, non-doc files touched. Pass at 3 or fewer                                                                                                                                                                                                                                          | Sandbox                      |
| V-19 | ASCII and hidden unicode | `dart run tools/check_hidden_unicode.dart`, `ascii-purity.test.ts`, and `LC_ALL=C grep -rnP '[^\x00-\x7F]'` over changed files                                                                                                                                                                                                                                                              | Sandbox                      |
| V-20 | Area checks              | Every command in `AGENTS.md` section 6 for every area touched                                                                                                                                                                                                                                                                                                                               | Both                         |

### FR-9.2 Metrics record

Fill this table in the verification report with the measured value, the
command or test that produced it, and pass or fail:

| Metric | Target                  | Source                                             |
| ------ | ----------------------- | -------------------------------------------------- |
| M1     | >= 7.00:1               | V-1, V-2, V-5                                      |
| M2     | >= 3.00:1               | V-1, V-2, V-11                                     |
| M3     | 0                       | V-10                                               |
| M4     | 0                       | V-6 (CG-1)                                         |
| M5     | 0                       | V-6 (CG-4)                                         |
| M6     | 0                       | V-6 (CG-3)                                         |
| M7     | 0 (in-scope docs files) | V-6 (accent ban)                                   |
| M8     | 1                       | Review: only the token source authors color values |
| M9     | 0                       | V-17                                               |
| M10    | <= 3                    | V-18                                               |

### FR-9.3 Changesets and versions

1. Confirm these changesets exist and agree with DP-1:

| File                                                 | Bump                      |
| ---------------------------------------------------- | ------------------------- |
| `.changeset/fix-fumadocs-token-mapping.md` (P0)      | `"docs": patch`           |
| `.changeset-polyglot/ink-and-paper-tokens.md` (P2)   | `"just_ui_tokens": minor` |
| `.changeset-polyglot/ink-and-paper-core.md` (P3, P4) | `"just_ui_core": minor`   |
| `.changeset-polyglot/cli-ink-and-paper-init.md` (P8) | `"justui_cli": minor`     |
| `.changeset/ink-and-paper-docs.md` (P6, P7)          | `"docs": minor`           |

2. Dry run first:
   `dart run tools/apply_changesets.dart --dry-run` and
   `bash tools/apply_changesets_cargo.sh --dry-run`. Expected result with the
   default DP-1: tokens, core and CLI go from 0.14.0 to 0.15.0.
3. Apply the version bumps only when the owner asks. If DP-1 is answered
   "major", every polyglot changeset changes to `major` in one commit.

### FR-9.4 Verification report

Write `docs/ink-and-paper/verification-report.md` (ASCII; the `docs/` folder
named in `AGENTS.md` section 2 does not exist at the baseline and is created
here) with:

1. The branch head commit.
2. The V-1 to V-20 table with result, command, and output excerpt or the line
   `not verified: <check> (<reason>)`, following the `AGENTS.md` rule.
3. The M1 to M10 table from FR-9.2.
4. Screenshots or golden file paths for V-8, V-14 and V-15.
5. Open issues found during verification and where they were filed.

### FR-9.5 Changelog

Add to `CHANGELOG.md` under `[Unreleased]`, keeping the existing style:

1. A new `### Breaking` heading above `### Added`. Entries:
   - Visual: default library colors change from blue to Ink and Paper
     monochrome.
   - Visual: neobrutalism loses its cream canvas, yellow primary and vivid
     status colors; it keeps borders, shadows, radius and motion.
   - Visual: badge status variants render monochrome with a glyph (DP-3).
   - API: `CustomColorScheme` default constructor takes the new role names;
     the old parameters move to `CustomColorScheme.fromLegacy`.
   - Visual: the library and docs font changes to Plus Jakarta Sans; text is wider.
2. `### Added`: roles, `JustThemeData.inkAndPaper`, `JustTint`,
   `isAccessibleAaaWith`, token generator, CLI `--tint` and `--tint-hue`,
   doctor check, migration guide, font assets copied by `init`.
3. `### Deprecated` (new heading): the forwarding getters, `fromSeed`,
   `showsDefaultBorder`, neobrutalism scheme aliases, `JustColorPalette`,
   `resolveSemantic`, CLI `--seed`. Each says "removed in the next minor
   release".
4. `### Fixed`: the Fumadocs mapping comment bug (P0), focus ring and link
   contrast on the docs.

### FR-9.6 Migration guide check

`guides/migrate-ink-and-paper.mdx` (P7) is checked against the shipped code:

1. Every deprecated symbol in FR-9.5 item 3 appears in the guide with its
   replacement.
2. A "keep my old look" section shows a `CustomColorScheme` that reproduces
   the old blue default, and it compiles (snippet test).
3. A section for users who copied tokens with an older CLI: re-run `init` on a
   clean branch, then `justui diff`, then review.
4. `en` and `id` match.

### FR-9.7 Release gate

The branch is ready for the owner to merge only when:

1. V-1 to V-20 pass, or a row is marked `not verified` with a reason that the
   owner accepts in writing.
2. M1 to M10 meet their targets.
3. Every pending decision in `90-pending-decisions.md` is answered or its
   default is accepted by the owner.
4. Rule-file patches from P0 are applied or rejected by the owner, and the
   code matches whichever rules are in force.
5. No generated file differs from its generator output.

## 6. Non-functional requirements

1. NFR-9.1: The report is reproducible: each row names the exact command.
2. NFR-9.2: No check is reported as passed unless it was run on the final
   head.
3. NFR-9.3: Temporary branches and scripts created for V-14 and V-18 are
   deleted after use and are not committed.

## 7. Files

| File                                          | Change                                              |
| --------------------------------------------- | --------------------------------------------------- |
| `docs/ink-and-paper/verification-report.md`   | New                                                 |
| `CHANGELOG.md`                                | Unreleased entries                                  |
| `.changeset/*.md`, `.changeset-polyglot/*.md` | Confirmed, not duplicated                           |
| Version files (`pubspec.yaml`, `Cargo.toml`)  | Only when the owner asks                            |
| Golden and snapshot baselines                 | Already updated in P4 and P7; only re-reviewed here |

## 8. Tasks

| ID    | Task                                               | Depends on     |
| ----- | -------------------------------------------------- | -------------- |
| P9.T1 | Sandbox checks V-1 to V-6, V-14 script, V-18, V-19 | P0 to P8       |
| P9.T2 | Owner machine checks V-7 to V-13, V-15 to V-17     | P9.T1          |
| P9.T3 | Metrics table                                      | P9.T1, P9.T2   |
| P9.T4 | Changelog and changeset review, dry-run bumps      | P9.T3          |
| P9.T5 | Migration guide check                              | P9.T3          |
| P9.T6 | Verification report                                | P9.T3 to P9.T5 |
| P9.T7 | Owner gate review                                  | P9.T6          |

## 9. Acceptance criteria

1. AC-9.1: The verification report exists and has no empty row.
2. AC-9.2: M1 to M10 all pass.
3. AC-9.3: Both changeset dry runs show the expected bumps and no error.
4. AC-9.4: `CHANGELOG.md` contains the Breaking, Added, Deprecated and Fixed
   entries in FR-9.5.
5. AC-9.5: The migration guide snippets compile and every deprecated symbol is
   covered.
6. AC-9.6: The owner signs off on the gate in FR-9.7.

## 10. Risks

| Risk                                             | Mitigation                                                            |
| ------------------------------------------------ | --------------------------------------------------------------------- |
| Owner-machine checks pile up at the end          | Run V-7, V-8 and V-9 after each P4 batch and after P7, not only here  |
| A late failure forces rework in an earlier phase | Fix in the owning phase, then re-run only the affected rows plus V-20 |
| Visual regressions hidden by large golden diffs  | Review per component family, not in one pass                          |
| Users skip the migration guide                   | Deprecation messages name the replacement; doctor warning             |

## 11. Pending decisions

| Decision | Default assumed                                         |
| -------- | ------------------------------------------------------- |
| DP-1     | Minor release (0.15.0) with deprecations                |
| DP-14    | Owner applies the P0 rule-file patches before P1 starts |

## 12. Exit criteria

The release gate in FR-9.7 is met and the owner has the report, the changelog
and the migration guide. Merging and publishing are the owner's call.
