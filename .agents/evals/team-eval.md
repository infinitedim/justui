# Team mode evaluation

Use this to check whether team mode actually helps on JustUI before relying
on it, and to tune the tier rules. This file is for the maintainer. Nothing
loads it automatically, but agents can read it, so remove it from eval
worktrees (step 1).

## Method

1. Pick a base commit. For each task, make two worktrees from it:
   `git worktree add ../justui-eval-<n>-solo <base>` and
   `git worktree add ../justui-eval-<n>-team <base>`. In each worktree,
   delete `.agents/evals/` before the run so the expected tiers do not leak
   into the test.
2. Solo run: default agent, and add "Work solo: Tier 0 or 1 only, no
   subagents" to the prompt.
3. Team run: `orchestrator` as the main agent, same prompt without that
   line. Let it choose the tier.
4. Use a fresh conversation for every run. Give both runs the same prompt,
   copied from the table below.
5. Judge each run yourself with the checks, not with the agent's summary.
   Keep the better result if you want it; delete the other worktree.

Start with tasks 1-8 (cheap and varied). Add the rest when those look
sensible.

## What to record per run

| Field | How |
| ----- | --- |
| Tier chosen | From the plan |
| Acceptance criteria met | Your own check, count met / total |
| Definition of done | Pass / fail per area, run by you |
| Real defects caught in review | Confirmed findings that you agree were bugs |
| False findings | Findings that were wrong (rejected by the orchestrator or by you) |
| Defects that slipped | Bugs you found after the run that review missed |
| Your fixes needed | Number of follow-up prompts or manual edits |
| Time and cost | Wall time; tokens or credits if Antigravity shows them |

## What "team mode works" means here

- Tier choice matches "Expected" below in at least 16 of 20 tasks. The
  traps (marked) must not go to Tier 2.
- On Tier 2 tasks, the team run meets at least as many criteria as solo with
  fewer of your fixes.
- On Tier 1 tasks, the independent reviewer catches real defects more often
  than it raises false ones.
- If team runs cost several times more and do not beat solo on these, raise
  the bar in the split test (`orchestration.md`) rather than adding agents.

## Tasks

Prompts are short on purpose: the plan should fill in the rest. Numbers in
brackets point to `SETUP-TASKS.md`.

| # | Prompt | Expected | Why this task |
| - | ------ | -------- | ------------- |
| 1 | Make `@typescript-eslint/no-explicit-any` an error in the docs ESLint config [6] | 0 | Smallest case; no plan file, no reviewer |
| 2 | Fix `CONTRIBUTING.md` step 4 so it no longer tells contributors to export components from the barrel file [5] | 0 | Docs-only, one file; checks the agent does not over-plan |
| 3 | Enable `noUncheckedIndexedAccess` in the docs tsconfig and fix the errors [7] | 1 (trap) | Many files, but small fixes: big is not parallel |
| 4 | Switch Indonesian docs copy from "Anda" to "kamu" [10] | 2 | Disjoint files, independent units |
| 5 | Add Playwright visual snapshot tests for landing, catalog, one docs page and Studio, each in both presets x light/dark [11] | 2 | One spec file per page: parallel; design reviewer should join |
| 6 | Apply the stricter docs ESLint setup, with legacy disables for existing violations [45] | 1 or 2 | Borderline: config first (sequential), then per-folder disables (parallel). Plan must also notice plugins that need dependency approval |
| 7 | Make `generate_checksums.dart --dry-run` exit non-zero on drift [16] | 1, approval | Red zone in `tools/`; security reviewer should join |
| 8 | Which Bun version matches the current `bun.lock` format, and where must it be pinned? Do not change files. [15] | 1, research | Researcher plus research-reviewer; claims must cite versions |
| 9 | Add the `safe_join` path helper with symlink rejection [34] | 1, approval | Red zone; reviewer should try traversal and symlink cases |
| 10 | Registry input validation in `registry.rs` [57] | 1, approval | Red zone; several files but one sequential unit (validation, then wiring into `add.rs` and `pubspec_editor.rs`) |
| 11 | Typed errors with `thiserror` in `registry.rs` and `config.rs` [33] | 1, approval | Needs dependency approval; plan must stop |
| 12 | Shared HTTP client with connect and total timeouts and a size cap [35] | 1, approval | Red zone; tests for timeout and cap |
| 13 | Global `-v`/`-vv` and one color-decision function [37] | 1 | Cross-cutting but sequential |
| 14 | Config `version` field with a migration hook; warn on unknown fields [39] | 1, approval | Red zone config schema |
| 15 | `src/lib/env.ts` with zod; move the current `process.env` reads [46] | 1, approval | Red zone docs file; small |
| 16 | `src/lib/result.ts` with the `Result<T, E>` union and helpers [47] | 1 | New file plus tests; reviewer writes spec tests |
| 17 | Dependency-free hidden-Unicode check script in `tools/` [63] | 1 | Reviewer should feed it bidi and zero-width samples |
| 18 | Vitest test that locks the security headers and CSP baseline [64] | 1, approval | Red zone headers; must not change the CSP |
| 19 | Pin every GitHub Action to a full SHA with a version comment [59] | 2, approval | Research per action plus disjoint workflow files; security reviewer |
| 20 | Validate every Dart snippet in MDX and component docs in CI [12, 52] | 1 | Research then build; sequential |

## Results log

| # | Run | Tier | AC met | DoD | Real defects caught | False findings | Slipped | Your fixes | Time/cost | Notes |
| - | --- | ---- | ------ | --- | ------------------- | -------------- | ------- | ---------- | --------- | ----- |
| 1 | solo | | | | | | | | | |
| 1 | team | | | | | | | | | |
