# Phase 0: Baseline and Safety Nets

Status: Draft v1 (2026-10-13)
Depends on: owner approval of this PRD set
Blocks: every other phase
Areas: `apps/docs`, `packages/core/test`, rule-file patches (as text only)

## 1. Summary

Before any color changes, fix the one pre-existing defect that would hide the
rebrand (the unclosed CSS comment), add ratchet guard tests that record every
current color violation, prepare the rule-file changes the rebrand needs, and
open the feature branch. After this phase, every later phase can prove it
removed violations instead of adding new ones.

## 2. Background

1. The `body` block in `apps/docs/src/app/globals.css` (Fumadocs mapping,
   page background and text color) is commented out by an unclosed comment at
   line 297 (`03-baseline-audit.md` section 2.1). Any token change made in P6
   would not reach Fumadocs until this is fixed.
2. There is no automated guard against color literals, palette references,
   preset comparisons or `showsDefaultBorder` color hacks in Flutter
   components. Without one, a migration of 30 components can regress silently.
3. The docs already have `apps/docs/test/style-guards.test.ts`, which bans
   some patterns but not accent or status utilities.
4. Rule files in `.agents/rules/` currently lock the docs identity to lime and
   set a 4.5:1 floor. Implementers are not allowed to edit rule files, so the
   owner must apply patches first.

## 3. Goals

1. Restore the Fumadocs token mapping, test-first.
2. Freeze the current list of color violations in Flutter components and in
   the docs as explicit allow-lists that can only shrink.
3. Deliver exact rule-file patches for the owner.
4. Create the feature branch.

## 4. Non-goals

1. Changing any color value.
2. Migrating any component.
3. Editing rule files directly.

## 5. Functional requirements

### FR-0.1 Fix the unclosed CSS comment (test-first)

1. Add `apps/docs/test/globals-css.test.ts`. It reads
   `src/app/globals.css`, strips comments with a regex that matches
   `/* ... */` pairs, and asserts that:
   - a `body {` rule exists after stripping;
   - that rule contains `--color-fd-background`;
   - the number of `/*` equals the number of `*/` in the raw file.
2. Run the test on the baseline and record that it fails.
3. Close the comment that starts at line 297 so that it ends before `body {`.
   Do not change any other line.
4. Run the test again and record that it passes.

### FR-0.2 Flutter component color guard

Add `packages/core/test/color_guard_test.dart`. It walks every `.dart` file
under `packages/core/lib/src/components` and reports, per file, every match
of:

| Rule ID | Pattern                                 | Meaning                        |
| ------- | --------------------------------------- | ------------------------------ | -------------------- | ------------------------------- |
| CG-1    | `Color\(0x(FF                           | ff)[0-9A-Fa-f]{6}\)`           | Opaque color literal |
| CG-2    | `JustColorPalette\.`                    | Palette bypassing the scheme   |
| CG-3    | `==\s*(JustThemePreset)?\.neobrutalism` | Preset comparison              |
| CG-4    | `showsDefaultBorder`                    | Preset flag used in components |
| CG-5    | `colors\.(warning                       | success                        | info)\b`             | Status color outside allow-list |
| CG-6    | `\.borderFocus\b`                       | Old focus-as-primary role      |
| CG-7    | `withValues\(alpha:`                    | Alpha-derived state color      |

Requirements:

1. Each rule has an explicit allow-list map of `file -> count` that equals the
   baseline counts (see `03-baseline-audit.md` section 6.2). The test fails if
   any file has more matches than its allowance, or if a file appears that is
   not in the list.
2. The test also fails if a count is lower than its allowance, with a message
   telling the developer to lower the allowance. This makes the ratchet move
   only down.
3. The final allowed state, reached in P4, is defined in
   `14-phase-4-component-migration.md` section 9.
4. The test must not read rule files or documentation; it reads only source.
5. Pure Dart I/O (`dart:io`), no new dependency.

### FR-0.3 Docs style-guard extension

Extend `apps/docs/test/style-guards.test.ts` with two new ratchet lists:

1. `ACCENT_ALLOWED`: the 54 files that use accent utilities today. Pattern:
   `/\b[a-z:-]*(bg|text|border|fill|caret|accent|outline|ring|decoration)-accent[a-z/0-9-]*/`.
2. `STATUS_ALLOWED`: the 12 files that use status utilities today. Pattern:
   `/\b(bg|text|border)-(success|warning|error|info|destructive)\b/`.
3. New hard bans with an empty allow-list from the start of P7:
   `focus-visible:outline-accent`, `bg-black`, `bg-white`, `text-white`.
   During P0 they are recorded with their current files so the test passes.
4. Same ratchet behavior as FR-0.2 (fail on new files, fail on stale
   allowances).

### FR-0.4 Rule-change patches (text only)

Write exact unified-diff patches for the owner, stored outside the repository
(for example in the run notes), covering:

| File                        | Change                                                                                                                                                            |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.agents/rules/design.md`   | Replace the locked lime identity with Ink and Paper; allow the library default to match the docs identity; raise the text floor to 7:1; list the new roles        |
| `.agents/rules/flutter.md`  | Text floor 7:1; allow the 3px `error` border in neobrutalism; focus ring tokens; ban `showsDefaultBorder` and status getters outside the allow-list in components |
| `.agents/rules/docs-web.md` | Name `tokens.generated.css` and `tokens.generated.ts` as the color source; the Studio parity test compares one tint                                               |
| `AGENTS.md` section 4       | New invariant: never hand-edit generated token outputs                                                                                                            |
| `AGENTS.md` section 6       | Add `dart run tools/generate_tokens.dart --check` to Definition of done                                                                                           |

### FR-0.5 Feature branch

Create `feat/ink-and-paper` from `development`. Commit locally only.

## 6. Non-functional requirements

1. NFR-0.1: Guard tests run in under 2 seconds each.
2. NFR-0.2: All new files are ASCII.
3. NFR-0.3: Guard failure messages name the rule, the file, the count found
   and the allowance.

## 7. Files

| File                                       | Change       |
| ------------------------------------------ | ------------ |
| `apps/docs/test/globals-css.test.ts`       | New          |
| `apps/docs/src/app/globals.css`            | One-line fix |
| `packages/core/test/color_guard_test.dart` | New          |
| `apps/docs/test/style-guards.test.ts`      | Extended     |

## 8. Tasks

| ID    | Task                                                                     | Depends on |
| ----- | ------------------------------------------------------------------------ | ---------- |
| P0.T1 | Owner approves the PRD set and the defaults in `90-pending-decisions.md` | -          |
| P0.T2 | Write rule-change patches (FR-0.4); owner applies or rejects them        | P0.T1      |
| P0.T3 | Create the feature branch (FR-0.5)                                       | P0.T1      |
| P0.T4 | Failing CSS test, fix, passing test (FR-0.1)                             | P0.T3      |
| P0.T5 | Flutter color guard with baseline allow-lists (FR-0.2)                   | P0.T3      |
| P0.T6 | Docs style-guard extension (FR-0.3)                                      | P0.T3      |
| P0.T7 | Changeset `.changeset/fix-fumadocs-token-mapping.md` (docs: patch)       | P0.T4      |

## 9. Acceptance criteria

1. AC-0.1: `globals-css.test.ts` fails on the baseline and passes after the
   fix. Both runs are recorded in the phase summary.
2. AC-0.2: In a browser, the computed `--color-fd-background` on `body` equals
   `--just-background` in all four combinations (default and neobrutalism,
   light and dark). Owner machine.
3. AC-0.3: `color_guard_test.dart` passes on the baseline, and its allow-list
   totals equal the counts in `03-baseline-audit.md` section 6 (re-counted).
4. AC-0.4: Adding one `Color(0xFF123456)` to any component makes the guard
   fail with a message naming CG-1 and the file. Removing an allowed match
   makes it fail with a "lower the allowance" message.
5. AC-0.5: The extended `style-guards.test.ts` passes on the baseline and
   fails when an accent utility is added to a file outside the list.
6. AC-0.6: `bun run lint`, `bun run type-check`, `bun run test` pass in
   `apps/docs`; `flutter analyze` passes in `packages/core`.
7. AC-0.7: The owner has applied or rejected every patch in FR-0.4.

## 10. Test plan

| Check                                                        | Where         |
| ------------------------------------------------------------ | ------------- |
| `bun run test` (vitest)                                      | Sandbox       |
| `flutter test test/color_guard_test.dart` in `packages/core` | Owner machine |
| Browser check of Fumadocs variables                          | Owner machine |

## 11. Risks

| Risk                                                        | Mitigation                                           |
| ----------------------------------------------------------- | ---------------------------------------------------- |
| Restoring the `body` block changes how Fumadocs looks today | Visual check of 4 combinations right after the fix   |
| Regex counts differ from the audit                          | The guard records real counts; the audit is advisory |

## 12. Pending decisions

None block this phase. P0.T1 is where the owner answers or accepts the
defaults for DP-1 to DP-14.

## 13. Exit criteria

1. All acceptance criteria met.
2. The rule files reflect the owner's decisions.
3. The branch exists with the P0 commits.
